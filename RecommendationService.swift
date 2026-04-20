import Foundation
import FirebaseFirestore
import FirebaseAuth

class RecommendationService {
    
    static let shared = RecommendationService()
    private let db = Firestore.firestore()
    
    // MARK: - Track Product View
    func trackView(product: Product) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data: [String: Any] = [
            "productId": product.id,
            "category": product.category,
            "productName": product.name,
            "viewedAt": Timestamp(date: Date())
        ]
        db.collection("users").document(userId)
            .collection("viewHistory")
            .document(product.id)
            .setData(data)
    }
    
    // MARK: - Track Order (call after order placed)
    func trackOrder(items: [CartItem]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        for item in items {
            let data: [String: Any] = [
                "productId": item.product.id,
                "category": item.product.category,
                "productName": item.product.name,
                "orderedAt": Timestamp(date: Date()),
                "quantity": item.quantity
            ]
            db.collection("users").document(userId)
                .collection("orderHistory")
                .document(item.product.id)
                .setData(data)
        }
    }
    
    // MARK: - Get Recommendations
    func getRecommendations(currentProductId: String,
                            completion: @escaping ([Product]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([]); return
        }
        
        var categoryScores: [String: Int] = [:]
        let group = DispatchGroup()
        
        // Score from views (1 point each)
        group.enter()
        db.collection("users").document(userId)
            .collection("viewHistory")
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { doc in
                    if let cat = doc.data()["category"] as? String {
                        categoryScores[cat, default: 0] += 1
                    }
                }
                group.leave()
            }
        
        // Score from orders (3 points each — orders matter more)
        group.enter()
        db.collection("users").document(userId)
            .collection("orderHistory")
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { doc in
                    if let cat = doc.data()["category"] as? String {
                        categoryScores[cat, default: 0] += 3
                    }
                }
                group.leave()
            }
        
        group.notify(queue: .main) {
            // Sort categories by score, take top 3
            let topCategories = categoryScores
                .sorted { $0.value > $1.value }
                .prefix(3)
                .map { $0.key }
            
            guard !topCategories.isEmpty else {
                completion([]); return
            }
            
            // Fetch products from those categories
            APIService.shared.fetchProductsByCategory(
                categories: Array(topCategories),
                excludeIds: [currentProductId]
            ) { products in
                // Shuffle for variety, limit to 6
                completion(Array(products.shuffled().prefix(6)))
            }
        }
    }
    
    // MARK: - Get Home Recommendations
    func getHomeRecommendations(completion: @escaping ([Product]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([]); return
        }
        
        var categoryScores: [String: Int] = [:]
        let group = DispatchGroup()
        
        group.enter()
        db.collection("users").document(userId)
            .collection("viewHistory")
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { doc in
                    if let cat = doc.data()["category"] as? String {
                        categoryScores[cat, default: 0] += 1
                    }
                }
                group.leave()
            }
        
        group.enter()
        db.collection("users").document(userId)
            .collection("orderHistory")
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { doc in
                    if let cat = doc.data()["category"] as? String {
                        categoryScores[cat, default: 0] += 3
                    }
                }
                group.leave()
            }
        
        group.notify(queue: .main) {
            let topCategories = categoryScores
                .sorted { $0.value > $1.value }
                .prefix(3)
                .map { $0.key }
            
            guard !topCategories.isEmpty else {
                completion([]); return
            }
            
            APIService.shared.fetchProductsByCategory(
                categories: Array(topCategories),
                excludeIds: []
            ) { products in
                completion(Array(products.shuffled().prefix(8)))
            }
        }
    }
}
