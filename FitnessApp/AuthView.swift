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
                .foregroundColor(AppTheme.oliveDark)

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(AppTheme.beigeLight)
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(AppTheme.beigeLight)
                    .cornerRadius(10)
            }
            .journalCard()

            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if authVM.isLoading {
                ProgressView()
                    .tint(AppTheme.oliveGreen)
            } else {
                VStack(spacing: 12) {
                    Button("Sign In") {
                        Task {
                            await authVM.signIn(email: email, password: password)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.oliveGreen)

                    Button("Create Account") {
                        Task {
                            await authVM.signUp(email: email, password: password)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(AppTheme.oliveGreen)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.beige)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
