import SwiftUI

struct CartView: View {
    
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        VStack {
            if cartVM.cartItems.isEmpty {
                Spacer()
                Image(systemName: "cart.badge.minus")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                Text("Your cart is empty")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 10)
                Text("Add some products to get started!")
                    .foregroundColor(.gray)
                    .font(.caption)
                Spacer()
            } else {
                List {
                    ForEach(cartVM.cartItems) { item in
                        HStack(spacing: 12) {
                            
                            // Item Image
                            AsyncImage(url: URL(string: item.product.imageURL)) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color(.systemGray5)
                            }
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                            
                            // Details
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.product.name)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                Text("$\(String(format: "%.2f", item.product.price))")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            // Quantity Controls
                            HStack(spacing: 8) {
                                Button {
                                    cartVM.updateQuantity(item: item,
                                        quantity: item.quantity - 1)
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.borderless)
                                
                                Text(String(format: "%d", item.quantity))
                                    .fontWeight(.bold)
                                    .frame(width: 25)
                                
                                Button {
                                    cartVM.updateQuantity(item: item,
                                        quantity: item.quantity + 1)
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.green)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { i in
                            cartVM.removeFromCart(item: cartVM.cartItems[i])
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                // Total + Checkout Section
                VStack(spacing: 12) {
                    Divider()
                    HStack {
                        Text("Total:")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartVM.totalPrice))")
                            .font(.title3)
                            .fontWeight(.heavy)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination:
                        CheckoutView()
                            .environmentObject(cartVM)
                            .environmentObject(authService)
                    ) {
                        Text("Proceed to Checkout")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle("My Cart 🛒")
        .navigationBarItems(trailing:
            Button("Clear All") {
                cartVM.clearCart()
            }
            .foregroundColor(.red)
            .disabled(cartVM.cartItems.isEmpty)
            .opacity(cartVM.cartItems.isEmpty ? 0 : 1)
        )
    }
}
