import SwiftUI

struct AdminOrdersView: View {
    
    @State private var orders: [Order] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    Spacer()
                    ProgressView("Loading orders...")
                    Spacer()
                } else if orders.isEmpty {
                    Spacer()
                    Text("No orders yet")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(orders) { order in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Order #\(String(order.id.prefix(8)).uppercased())")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Spacer()
                                StatusBadge(status: order.status)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                
                                // Show each item
                                ForEach(order.items) { item in
                                    HStack(spacing: 8) {
                                        AsyncImage(url: URL(string: item.product.imageURL)) { img in
                                            img.resizable().scaledToFill()
                                        } placeholder: {
                                            Color(.systemGray5)
                                        }
                                        .frame(width: 36, height: 36)
                                        .clipped()
                                        .cornerRadius(6)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.product.name)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                            
                                            HStack {
                                                // 💡 Tip: Simplified from String(format: "%d")
                                                Text("Qty: \(item.quantity)")
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                                Text("•")
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                                Text("$\(String(format: "%.2f", item.totalPrice))")
                                                    .font(.caption2)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                                
                                Divider()
                                    .padding(.vertical, 4) // Added a touch of breathing room
                                
                                // Delivery info
                                if !order.address.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "location.fill")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                        Text(order.address)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                if !order.phone.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "phone.fill")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                        Text(order.phone)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                if !order.note.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "note.text")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                        Text(order.note)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                            .italic()
                                    }
                                }
                                
                                Text("Total: $\(String(format: "%.2f", order.totalAmount))")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .padding(.top, 4)
                            }
                            Divider()
                            
                            // Status Changer Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Update Status:")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 8) {
                                    ForEach(["pending", "confirmed", "delivered"], id: \.self) { status in
                                        Button {
                                            updateStatus(order: order, status: status)
                                        } label: {
                                            Text(status.capitalized)
                                                .font(.system(size: 10))
                                                .fontWeight(.semibold)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(order.status == status ? Color.green : Color(.systemGray5))
                                                .foregroundColor(order.status == status ? .white : .primary)
                                                .cornerRadius(6)
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("All Orders")
            .onAppear { loadOrders() }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        loadOrders()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    func loadOrders() {
        isLoading = true
        FirebaseService.shared.fetchAllOrders { fetched in
            self.orders = fetched
            self.isLoading = false
        }
    }
    
    func updateStatus(order: Order, status: String) {
        FirebaseService.shared.updateOrderStatus(
            orderId: order.id, status: status) { success in
            if success {
                // Notify the customer
                switch status {
                case "confirmed":
                    NotificationService.shared.notifyOrderConfirmed(orderId: order.id)
                case "delivered":
                    NotificationService.shared.notifyOrderDelivered(orderId: order.id)
                default:
                    break
                }
                loadOrders()
            }
        }
    }
}
