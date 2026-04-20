import SwiftUI

struct ContentView: View {
    
    @StateObject var authService = AuthService()
    @StateObject var cartVM = CartViewModel()
    
    // Simple logic to check if the logged-in user is the administrator
    var isAdmin: Bool {
        authService.userSession?.email == "admin@grocery.com"
    }
    
    var body: some View {
        Group {
            if authService.userSession != nil {
                if isAdmin {
                    // Admin Flow
                    NavigationView {
                        AdminView()
                            .environmentObject(authService)
                    }
                } else {
                    // Customer Flow
                    HomeView()
                        .environmentObject(authService)
                        .environmentObject(cartVM)
                }
            } else {
                // Auth Flow
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}
