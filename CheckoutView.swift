//
//  Checkout.swift
//  online grocery store
//
//  Created by Sayaka Alam on 7/4/26.
//

import SwiftUI
import FirebaseAuth

struct CheckoutView: View {
    
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var address = ""
    @State private var phone = ""
    @State private var note = ""
    @State private var isPlacingOrder = false
    @State private var orderPlaced = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Order Summary
                VStack(alignment: .leading, spacing: 10) {
                    Text("Order Summary")
                        .font(.headline)
                    
                    ForEach(cartVM.cartItems) { item in
                        HStack {
                            AsyncImage(url: URL(string: item.product.imageURL)) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Color(.systemGray5)
                            }
                            .frame(width: 44, height: 44)
                            .clipped()
                            .cornerRadius(6)
                            
                            Text(item.product.name)
                                .font(.caption)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("x\(item.quantity)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("$\(String(format: "%.2f", item.totalPrice))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartVM.totalPrice))")
                            .fontWeight(.heavy)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Delivery Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Delivery Details")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Delivery Address")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter your full address", text: $address)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Phone Number")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter phone number", text: $phone)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Note (Optional)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Any special instructions?", text: $note)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                
                // Error Display
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Place Order Button
                Button {
                    placeOrder()
                } label: {
                    if isPlacingOrder {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(14)
                    } else {
                        Text("Place Order 🛒")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(address.isEmpty || phone.isEmpty
                                        ? Color.gray : Color.green)
                            .cornerRadius(14)
                    }
                }
                .disabled(address.isEmpty || phone.isEmpty || isPlacingOrder)
                
            }
            .padding()
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $orderPlaced) {
            Alert(
                title: Text("✅ Order Placed!"),
                message: Text("Your order has been placed successfully. We will deliver soon!"),
                dismissButton: .default(Text("OK")) {
                    cartVM.clearCart()
                    // Pop back to the root (HomeView)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    func placeOrder() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isPlacingOrder = true
        errorMessage = ""
        
        let order = Order(
            id: UUID().uuidString,
            userId: userId,
            items: cartVM.cartItems,
            totalAmount: cartVM.totalPrice,
            status: "pending",
            createdAt: Date(),
            address: address,
            phone: phone,
            note: note
        )
        
        FirebaseService.shared.saveOrder(order: order) { success in
            // ⚠️ Architecture Catch: Move UI state updates to the Main Thread!
            DispatchQueue.main.async {
                self.isPlacingOrder = false
                
                if success {
                    NotificationService.shared.notifyOrderPlaced(orderId: order.id)
                    RecommendationService.shared.trackOrder(items: self.cartVM.cartItems)
                    
                    // Stock already reduced when added to cart
                    // Just clear cart WITHOUT releasing stock
                    self.cartVM.clearCartAfterOrder()
                    
                    self.orderPlaced = true
                } else {
                    self.errorMessage = "Failed to place order. Try again."
                }
            }
        }
    }
}
