//
//  FitnessAppApp.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import SwiftUI

@main
struct FitnessAppApp: App {
    
    @StateObject var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .accentColor(AppTheme.oliveGreen)
                .preferredColorScheme(.light)
        }
    }
}
