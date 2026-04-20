import SwiftUI
import FirebaseAuth

struct AdminView: View {
    
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            AdminProductsView()
                .tabItem {
                    Image(systemName: "cube.box")
                    Text("Products")
                }
                .tag(0)
            
            AdminOrdersView()
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Orders")
                }
                .tag(1)
        }
        .navigationTitle("Admin Panel")
        .navigationBarItems(trailing:
            Button("Logout") {
                authService.logout()
            }
            .foregroundColor(.red)
        )
    }
}
