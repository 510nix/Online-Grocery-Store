import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AdminProductsView()
                .tabItem {
                    Label("Shop", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)
            
            AdminOrdersView()
                .tabItem {
                    Label("Orders", systemImage: "shippingbox.fill")
                }
                .tag(1)
        }
        .accentColor(.green)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    authService.logout()
                }) {
                    Text("Logout")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
        }
    }
}
