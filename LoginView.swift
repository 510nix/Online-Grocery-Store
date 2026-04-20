import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.8, blue: 0.4),
                    Color(red: 0.0, green: 0.6, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 200, height: 200)
                .offset(x: 150, y: -100)
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 250, height: 250)
                .offset(x: 100, y: 300)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // Logo area
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 90, height: 90)
                            Image(systemName: "cart.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 60)
                        
                        Text("FreshCart")
                            .font(.system(size: 36, weight: .heavy))
                            .foregroundColor(.white)
                        
                        Text("Your daily grocery companion")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 40)
                    
                    // Card
                    VStack(spacing: 20) {
                        
                        Text("Welcome Back!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(Color(red: 0.0, green: 0.7, blue: 0.4))
                                    .frame(width: 20)
                                TextField("Enter your email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color(red: 0.0, green: 0.7, blue: 0.4))
                                    .frame(width: 20)
                                SecureField("Enter your password", text: $password)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Error
                        if !authService.errorMessage.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(authService.errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(10)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Login button
                        Button {
                            authService.login(email: email, password: password) { _ in }
                        } label: {
                            ZStack {
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.0, green: 0.8, blue: 0.4),
                                        Color(red: 0.0, green: 0.6, blue: 0.9)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .cornerRadius(14)
                                
                                if authService.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Login")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .font(.title3)
                                }
                            }
                            .frame(height: 54)
                        }
                        .disabled(authService.isLoading)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: 1)
                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: 1)
                        }
                        
                        // Register button
                        Button {
                            showRegister = true
                        } label: {
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(.gray)
                                Text("Sign Up")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.0, green: 0.7, blue: 0.4))
                            }
                            .font(.subheadline)
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(authService)
        }
    }
}
