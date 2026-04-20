import Foundation

struct NutritionInfo {
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var fiber: Double
    var sugar: Double
    var servingSize: String
}

class NutritionService {
    
    static let shared = NutritionService()
    
    // 1. Updated for CalorieNinjas
    private let apiKey = "ruCyohn/OKfpeFEYNOwSQg==DOmIcLMuch3Za5Zz"
    private let baseURL = "https://api.calorieninjas.com/v1/nutrition"
    
    // Cache results
    private var cache: [String: NutritionInfo] = [:]
    
    func fetchNutrition(for productName: String, completion: @escaping (NutritionInfo?) -> Void) {
        
        let key = productName.lowercased()
        if let cached = cache[key] {
            completion(cached)
            return
        }
        
        let query = productName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)?query=\(query)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print("DEBUG: Network error: \(error?.localizedDescription ?? "unknown")")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            if let http = response as? HTTPURLResponse {
                print("DEBUG: Nutrition API status: \(http.statusCode)")
                guard http.statusCode == 200 else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
            }
            
            // ---> HERE IS THE DO BLOCK <---
            do {
                // Decode the wrapper first
                let response = try JSONDecoder().decode(CalorieNinjasResponse.self, from: data)
                let items = response.items // Extract the array
                
                guard !items.isEmpty else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                
                // Sum all items
                let total = items.reduce(
                    NutritionInfo(calories: 0, protein: 0, fat: 0, carbs: 0, fiber: 0, sugar: 0, servingSize: "Per 100g")
                ) { result, item in
                    NutritionInfo(
                        calories: result.calories + item.calories,
                        protein: result.protein + item.protein_g,
                        fat: result.fat + item.fat_total_g,
                        carbs: result.carbs + item.carbohydrates_total_g,
                        fiber: result.fiber + item.fiber_g,
                        sugar: result.sugar + item.sugar_g,
                        servingSize: "Per 100g"
                    )
                }
                
                self.cache[key] = total
                DispatchQueue.main.async { completion(total) }
                
            } catch {
                print("DEBUG: Decode error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}

// MARK: - Response Models

// 2. Added Wrapper for CalorieNinjas
struct CalorieNinjasResponse: Codable {
    let items: [NinjaNutritionItem]
}

// 3. Your struct with the safe decoder (just in case they send strings!)
struct NinjaNutritionItem: Codable {
    let name: String
    let calories: Double
    let protein_g: Double
    let fat_total_g: Double
    let carbohydrates_total_g: Double
    let fiber_g: Double
    let sugar_g: Double
    
    enum CodingKeys: String, CodingKey {
        case name, calories, protein_g, fat_total_g, carbohydrates_total_g, fiber_g, sugar_g
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        
        func decodeSafely(forKey key: CodingKeys) -> Double {
            if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return doubleValue
            } else if let stringValue = try? container.decode(String.self, forKey: key),
                      let convertedDouble = Double(stringValue) {
                return convertedDouble
            }
            return 0.0
        }
        
        calories = decodeSafely(forKey: .calories)
        protein_g = decodeSafely(forKey: .protein_g)
        fat_total_g = decodeSafely(forKey: .fat_total_g)
        carbohydrates_total_g = decodeSafely(forKey: .carbohydrates_total_g)
        fiber_g = decodeSafely(forKey: .fiber_g)
        sugar_g = decodeSafely(forKey: .sugar_g)
    }
}
