import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var localError = ""
    
    var body: some View {
        ZStack {
            // Same gradient as login
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
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 38))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 50)
                        
                        Text("Join FreshCart")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundColor(.white)
                        
                        Text("Create your free account today!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 30)
                    
                    // Card
                    VStack(spacing: 18) {
                        
                        // Email
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
                        
                        // Password
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color(red: 0.0, green: 0.7, blue: 0.4))
                                    .frame(width: 20)
                                SecureField("Min 6 characters", text: $password)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Confirm Password
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Confirm Password")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(Color(red: 0.0, green: 0.7, blue: 0.4))
                                    .frame(width: 20)
                                SecureField("Repeat password", text: $confirmPassword)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Errors
                        if !localError.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text(localError)
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                            .padding(10)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if !authService.errorMessage.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text(authService.errorMessage)
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                            .padding(10)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Register button
                        Button {
                            if password != confirmPassword {
                                localError = "Passwords do not match"
                                return
                            }
                            localError = ""
                            authService.register(email: email, password: password) { success in
                                if success {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
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
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Create Account")
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
                        
                        // Back to login
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Text("Already have an account?")
                                    .foregroundColor(.gray)
                                Text("Login")
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
    }
}
