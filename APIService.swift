import Foundation
import FirebaseFirestore

class APIService {
    
    static let shared = APIService()
    private let db = Firestore.firestore()
    
    // MARK: - Fetch All Products from Firestore
    func fetchProducts(completion: @escaping ([Product]) -> Void) {
        db.collection("products")
            .whereField("isAvailable", isEqualTo: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([]); return
                }
                let products = docs.compactMap { doc -> Product? in
                    self.parseProduct(doc.data())
                }
                DispatchQueue.main.async { completion(products) }
            }
    }
    
    // MARK: - Fetch By Category from Firestore
    func fetchByCategory(_ category: String,
                         completion: @escaping ([Product]) -> Void) {
        db.collection("products")
            .whereField("category", isEqualTo: category)
            .whereField("isAvailable", isEqualTo: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([]); return
                }
                let products = docs.compactMap { doc -> Product? in
                    self.parseProduct(doc.data())
                }
                DispatchQueue.main.async { completion(products) }
            }
    }
    
    // MARK: - Search Products
    func searchProducts(query: String,
                        completion: @escaping ([Product]) -> Void) {
        fetchProducts { all in
            let results = all.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.category.localizedCaseInsensitiveContains(query) ||
                $0.description.localizedCaseInsensitiveContains(query)
            }
            completion(results)
        }
    }
    
    // MARK: - Fetch Products by IDs (for recommendations)
    func fetchProductsByCategory(categories: [String],
                                  excludeIds: [String],
                                  completion: @escaping ([Product]) -> Void) {
        guard !categories.isEmpty else { completion([]); return }
        
        db.collection("products")
            .whereField("category", in: Array(categories.prefix(10)))
            .whereField("isAvailable", isEqualTo: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([]); return
                }
                let products = docs.compactMap { doc -> Product? in
                    self.parseProduct(doc.data())
                }
                .filter { !excludeIds.contains($0.id) }
                DispatchQueue.main.async { completion(products) }
            }
    }
    
    // MARK: - Parse Helper
    private func parseProduct(_ d: [String: Any]) -> Product? {
        guard
            let id = d["id"] as? String,
            let name = d["name"] as? String,
            let category = d["category"] as? String,
            let imageURL = d["imageURL"] as? String,
            let description = d["description"] as? String,
            let unit = d["unit"] as? String,
            let isAvailable = d["isAvailable"] as? Bool
        else {
            return nil
        }
        
        let price: Double
        if let p = d["price"] as? Double {
            price = p
        } else if let p = d["price"] as? Int {
            price = Double(p)
        } else {
            return nil
        }
        
        let stock: Int
        if let s = d["stock"] as? Int {
            stock = s
        } else if let s = d["stock"] as? Double {
            stock = Int(s)
        } else {
            stock = 0
        }
        
        return Product(
            id: id,
            name: name,
            category: category,
            price: price,
            imageURL: imageURL,
            description: description,
            unit: unit,
            isAvailable: isAvailable,
            stock: stock
        )
    }
}
