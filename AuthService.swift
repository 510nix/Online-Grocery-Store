//
//  AuthService.swift
//  online grocery store
//
//  Created by Sayaka Alam on 7/4/26.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthService: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    // MARK: - Register
    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            self.userSession = result?.user
            completion(true)
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            self.userSession = result?.user
            completion(true)
        }
    }
    
    // MARK: - Logout
    func logout() {
        try? Auth.auth().signOut()
        self.userSession = nil
    }
}
