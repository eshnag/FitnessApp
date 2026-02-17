//
//  ContentView.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        Group {
            if authVM.isLoggedIn {
                MainAppView()
            } else {
                AuthView()
            }
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}

