import Foundation
import Combine

class CartViewModel: ObservableObject {
    
    @Published var cartItems: [CartItem] = []
    
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var totalItems: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    // MARK: - Add to Cart (reduces stock immediately)
    func addToCart(product: Product, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            // Already in cart — reserve extra quantity
            FirebaseService.shared.reserveStock(
                productId: product.id,
                productName: product.name,
                quantity: quantity
            ) { success in
                if success {
                    DispatchQueue.main.async {
                        self.cartItems[index].quantity += quantity
                    }
                }
            }
        } else {
            // New item — reserve stock
            FirebaseService.shared.reserveStock(
                productId: product.id,
                productName: product.name,
                quantity: quantity
            ) { success in
                if success {
                    let item = CartItem(
                        id: UUID().uuidString,
                        product: product,
                        quantity: quantity
                    )
                    DispatchQueue.main.async {
                        self.cartItems.append(item)
                    }
                }
            }
        }
    }
    
    // MARK: - Remove from Cart (releases stock back)
    func removeFromCart(item: CartItem) {
        FirebaseService.shared.releaseStock(
            productId: item.product.id, // ← Updated to use ID!
            quantity: item.quantity
        )
        cartItems.removeAll { $0.id == item.id }
    }
    
    // MARK: - Update Quantity
    func updateQuantity(item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            let diff = quantity - cartItems[index].quantity
            if quantity <= 0 {
                // Remove item and release all stock
                FirebaseService.shared.releaseStock(
                    productId: item.product.id, // ← Updated to use ID!
                    quantity: cartItems[index].quantity
                )
                cartItems.remove(at: index)
            } else if diff > 0 {
                // Increasing quantity — reserve more
                FirebaseService.shared.reserveStock(
                    productId: item.product.id,
                    productName: item.product.name,
                    quantity: diff
                ) { success in
                    if success {
                        DispatchQueue.main.async {
                            self.cartItems[index].quantity = quantity
                        }
                    }
                }
            } else if diff < 0 {
                // Decreasing quantity — release back
                FirebaseService.shared.releaseStock(
                    productId: item.product.id, // ← Updated to use ID!
                    quantity: abs(diff)
                )
                cartItems[index].quantity = quantity
            }
        }
    }
    
    // MARK: - Clear Cart
    func clearCart() {
        // Release all reserved stock
        for item in cartItems {
            FirebaseService.shared.releaseStock(
                productId: item.product.id, // ← Updated to use ID!
                quantity: item.quantity
            )
        }
        cartItems = []
    }
    
    // MARK: - Clear Cart After Order (stock already reduced)
    func clearCartAfterOrder() {
        cartItems = []
    }
}
