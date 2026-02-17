//
//  MainAppView.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import SwiftUI

struct MainAppView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        TabView {
            
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "chart.bar")
                }
            
            LogWorkoutView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle.fill")
                }
            
            ProgressSummaryView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
    }
}



#Preview {
    MainAppView()
}

