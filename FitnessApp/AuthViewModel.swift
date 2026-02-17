//
//  AuthViewModel.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import Foundation
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        Task {
            await checkSession()
        }
    }
    
    func checkSession() async {
        do {
            let session = try await SupabaseService.shared.client.auth.session
            isLoggedIn = session != nil
        } catch {
            isLoggedIn = false
        }
    }
    
    func signUp(email: String, password: String) async {
        print("Starting signup...")
        isLoading = true
        errorMessage = nil
        
        do {
            try await SupabaseService.shared.client.auth.signUp(
                email: email,
                password: password
            )
            print("Signup success")
            isLoggedIn = true
        } catch {
            print("Signup error:", error)
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

    
    func signIn(email: String, password: String) async {
        print("Starting sign in...")
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await SupabaseService.shared.client.auth.signIn(
                email: email,
                password: password
            )
            
            print("Sign in success:", response)
            
            isLoggedIn = true
            
        } catch {
            print("Sign in error:", error)
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

    
    func signOut() async {
        try? await SupabaseService.shared.client.auth.signOut()
        isLoggedIn = false
    }
}
