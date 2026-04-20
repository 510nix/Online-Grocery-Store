import SwiftUI
import FirebaseAuth

struct OrderHistoryView: View {
    
    @State private var orders: [Order] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                Spacer()
                ProgressView("Loading orders...")
                Spacer()
            } else if orders.isEmpty {
                Spacer()
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("No orders yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 10)
                Text("Your order history will appear here")
                    .foregroundColor(.gray)
                    .font(.caption)
                Spacer()
            } else {
                List(orders) { order in
                    VStack(alignment: .leading, spacing: 8) {
                        
                        HStack {
                            Text("Order #\(String(order.id.prefix(8)).uppercased())")
                                .font(.caption)
                                .fontWeight(.bold)
                            Spacer()
                            StatusBadge(status: order.status)
                        }
                        
                        Text("\(order.items.count) item(s)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text(order.createdAt.formatted(
                                date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("$\(String(format: "%.2f", order.totalAmount))")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("My Orders")
        .onAppear { loadOrders() }
    }
    
    func loadOrders() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        FirebaseService.shared.fetchOrders(userId: userId) { fetched in
            self.orders = fetched
            self.isLoading = false
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: String
    
    var color: Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "confirmed": return .blue
        case "delivered": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        Text(status.uppercased())
            .font(.system(size: 10))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(8)
    }
}
