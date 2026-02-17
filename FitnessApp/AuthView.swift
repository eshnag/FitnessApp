//
//  AuthView.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("AI Personal Trainer")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if authVM.isLoading {
                ProgressView()
            } else {
                VStack(spacing: 12) {
                    
                    Button("Sign In") {
                     
                        Task {
                            await authVM.signIn(email: email, password: password)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Create Account") {
                        Task {
                            await authVM.signUp(email: email, password: password)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
