import SwiftUI

struct AdminOrdersView: View {
    @State private var orders: [Order] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                if isLoading {
                    ProgressView().tint(.green)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(orders) { order in
                                OrderCard(order: order, updateAction: updateStatus)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Orders")
            .onAppear { loadOrders() }
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
        FirebaseService.shared.updateOrderStatus(orderId: order.id, status: status) { _ in loadOrders() }
    }
}

struct OrderCard: View {
    let order: Order
    let updateAction: (Order, String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("#" + order.id.prefix(6).uppercased())
                    .font(.system(.subheadline, design: .monospaced)).bold()
                Spacer()
                Text(order.status.uppercased())
                    .font(.caption2).bold()
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(order.status == "delivered" ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    .foregroundColor(order.status == "delivered" ? .green : .orange)
                    .cornerRadius(8)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(order.items) { item in
                    HStack {
                        Text("\(item.quantity)x").bold().foregroundColor(.green)
                        Text(item.product.name).font(.subheadline)
                        Spacer()
                        Text("$\(String(format: "%.2f", item.totalPrice))").font(.subheadline).foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                Text("Total Revenue").font(.headline)
                Spacer()
                Text("$\(String(format: "%.2f", order.totalAmount))")
                    .font(.title3).bold().foregroundColor(.green)
            }
            .padding(.top, 5)
            
            HStack(spacing: 12) {
                StatusToggle(title: "Confirm", active: order.status == "confirmed", color: .blue) { updateAction(order, "confirmed") }
                StatusToggle(title: "Deliver", active: order.status == "delivered", color: .green) { updateAction(order, "delivered") }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

struct StatusToggle: View {
    let title: String
    let active: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption).bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(active ? color : Color(.systemGray6))
                .foregroundColor(active ? .white : .primary)
                .cornerRadius(10)
        }
    }
}
