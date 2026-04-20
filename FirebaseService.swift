import Foundation
import Firebase
import FirebaseFirestore

class FirebaseService {
    
    static let shared = FirebaseService()
    let db = Firestore.firestore()
    
    // MARK: - Save Order
    func saveOrder(order: Order, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = [
            "id": order.id,
            "userId": order.userId,
            "totalAmount": order.totalAmount,
            "status": order.status,
            "createdAt": Timestamp(date: order.createdAt),
            "address": order.address,
            "phone": order.phone,
            "note": order.note,
            "items": order.items.map { item in
                [
                    "id": item.id,
                    "quantity": item.quantity,
                    "productId": item.product.id,
                    "productName": item.product.name,
                    "productPrice": item.product.price,
                    "productImage": item.product.imageURL,
                    "productCategory": item.product.category
                ]
            }
        ]
        db.collection("orders")
            .document(order.id)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    
    // MARK: - Fetch Orders for User
    func fetchOrders(userId: String,
                     completion: @escaping ([Order]) -> Void) {
        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let orders = docs.compactMap { doc -> Order? in
                    self.parseOrder(doc.data())
                }
                DispatchQueue.main.async {
                    completion(orders)
                }
            }
    }
    
    // MARK: - Fetch All Orders (Admin)
    func fetchAllOrders(completion: @escaping ([Order]) -> Void) {
        db.collection("orders")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let orders = docs.compactMap { doc -> Order? in
                    self.parseOrder(doc.data())
                }
                DispatchQueue.main.async {
                    completion(orders)
                }
            }
    }
    
    // MARK: - Parse Order Helper
    private func parseOrder(_ d: [String: Any]) -> Order? {
        guard
            let id = d["id"] as? String,
            let userId = d["userId"] as? String,
            let total = d["totalAmount"] as? Double,
            let status = d["status"] as? String,
            let ts = d["createdAt"] as? Timestamp,
            let rawItems = d["items"] as? [[String: Any]]
        else { return nil }
        
        let items = rawItems.compactMap { i -> CartItem? in
            guard
                let iid = i["id"] as? String,
                let qty = i["quantity"] as? Int,
                let pid = i["productId"] as? String,
                let pname = i["productName"] as? String,
                let pprice = i["productPrice"] as? Double,
                let pimage = i["productImage"] as? String,
                let pcat = i["productCategory"] as? String
            else { return nil }
            
            let product = Product(
                id: pid,
                name: pname,
                category: pcat,
                price: pprice,
                imageURL: pimage,
                description: "",
                unit: "piece",
                isAvailable: true,
                stock: 0
            )
            return CartItem(id: iid, product: product, quantity: qty)
        }
        
        return Order(
            id: id,
            userId: userId,
            items: items,
            totalAmount: total,
            status: status,
            createdAt: ts.dateValue(),
            address: d["address"] as? String ?? "",
            phone: d["phone"] as? String ?? "",
            note: d["note"] as? String ?? ""
        )
    }
    
    // MARK: - Update Order Status
    func updateOrderStatus(orderId: String,
                           status: String,
                           completion: @escaping (Bool) -> Void) {
        db.collection("orders")
            .document(orderId)
            .updateData(["status": status]) { error in
                completion(error == nil)
            }
    }
    
    // MARK: - Save Product (Add/Edit)
    func saveProduct(product: Product, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = [
            "id": product.id,
            "name": product.name,
            "category": product.category,
            "price": product.price,
            "imageURL": product.imageURL,
            "description": product.description,
            "unit": product.unit,
            "isAvailable": product.isAvailable,
            "stock": product.stock    // ← Make sure this line exists!
        ]
        
        print("DEBUG: Saving product \(product.name) with stock: \(product.stock)")
        
        db.collection("products")
            .document(product.id)
            .setData(data) { error in
                if let error = error {
                    print("DEBUG: Save failed: \(error)")
                } else {
                    print("DEBUG: Product saved successfully!")
                }
                completion(error == nil)
            }
    }
    
    // MARK: - Fetch Admin Products
    func fetchAdminProducts(completion: @escaping ([Product]) -> Void) {
        db.collection("products")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let products = docs.compactMap { doc -> Product? in
                    self.parseProduct(doc.data())
                }
                DispatchQueue.main.async {
                    completion(products)
                }
            }
    }
    
    // MARK: - Delete Product
    func deleteProduct(productId: String,
                       completion: @escaping (Bool) -> Void) {
        db.collection("products")
            .document(productId)
            .delete { error in
                completion(error == nil)
            }
    }
    
    // MARK: - Parse Product Helper
    func parseProduct(_ d: [String: Any]) -> Product? {
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
        
        // Handle price as Int or Double
        let price: Double
        if let p = d["price"] as? Double {
            price = p
        } else if let p = d["price"] as? Int {
            price = Double(p)
        } else {
            return nil
        }
        
        // Handle stock as Int or Double
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
    // MARK: - Reduce Stock After Order
    func reduceStock(items: [CartItem]) {
        for item in items {
            // Search by name since ID might not match
            db.collection("products")
                .whereField("name", isEqualTo: item.product.name)
                .getDocuments { snapshot, error in
                    guard let doc = snapshot?.documents.first else {
                        print("DEBUG: Product not found: \(item.product.name)")
                        return
                    }
                    
                    let currentStock: Int
                    if let s = doc.data()["stock"] as? Int {
                        currentStock = s
                    } else if let s = doc.data()["stock"] as? Double {
                        currentStock = Int(s)
                    } else {
                        currentStock = 0
                    }
                    
                    let newStock = max(0, currentStock - item.quantity)
                    print("DEBUG: \(item.product.name): \(currentStock) → \(newStock)")
                    
                    doc.reference.updateData([
                        "stock": newStock,
                        "isAvailable": newStock > 0
                    ]) { error in
                        if let error = error {
                            print("DEBUG: Failed: \(error)")
                        } else {
                            print("DEBUG: ✅ Stock updated!")
                        }
                    }
                }
        }
    }
    // MARK: - Reserve Stock When Added to Cart
    func reserveStock(productId: String, productName: String, quantity: Int, completion: @escaping (Bool) -> Void) {
        let ref = db.collection("products").document(productId)
        
        db.runTransaction { transaction, errorPointer in
            let doc: DocumentSnapshot
            do {
                doc = try transaction.getDocument(ref)
            } catch {
                return nil
            }
            
            guard let data = doc.data() else { return nil }
            
            let currentStock: Int
            if let s = data["stock"] as? Int {
                currentStock = s
            } else if let s = data["stock"] as? Double {
                currentStock = Int(s)
            } else {
                currentStock = 0
            }
            
            // Check if enough stock
            guard currentStock >= quantity else {
                return nil // Fails the transaction
            }
            
            let newStock = currentStock - quantity
            
            transaction.updateData([
                "stock": newStock,
                "isAvailable": newStock > 0
            ], forDocument: ref)
            
            return newStock // Success
            
        } completion: { object, error in
            if let error = error {
                print("DEBUG: Reservation failed for \(productName): \(error.localizedDescription)")
                completion(false)
            } else if object == nil {
                print("DEBUG: Not enough stock to reserve \(productName)!")
                completion(false)
            } else {
                print("DEBUG: Successfully reserved \(quantity) of \(productName).")
                completion(true)
            }
        }
    }

    // MARK: - Release Stock When Removed from Cart
    func releaseStock(productId: String, quantity: Int) {
        let ref = db.collection("products").document(productId)
        
        db.runTransaction { transaction, errorPointer in
            let doc: DocumentSnapshot
            do {
                doc = try transaction.getDocument(ref)
            } catch {
                return nil
            }
            
            guard let data = doc.data() else { return nil }
            
            let currentStock: Int
            if let s = data["stock"] as? Int {
                currentStock = s
            } else if let s = data["stock"] as? Double {
                currentStock = Int(s)
            } else {
                currentStock = 0
            }
            
            let newStock = currentStock + quantity
            
            transaction.updateData([
                "stock": newStock,
                "isAvailable": newStock > 0 // Guarantee it turns back on if it was 0!
            ], forDocument: ref)
            
            return nil
            
        } completion: { _, error in
            if let error = error {
                print("DEBUG: Failed to release stock: \(error.localizedDescription)")
            } else {
                print("DEBUG: Stock successfully released back into inventory!")
            }
        }
    }
}
