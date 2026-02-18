//
//  MainAppView.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import SwiftUI
import UIKit

struct MainAppView: View {

    @EnvironmentObject var authVM: AuthViewModel

    init() {
        let barAppearance = UITabBarAppearance()
        barAppearance.configureWithOpaqueBackground()
        barAppearance.backgroundColor = UIColor(AppTheme.beige)
        UITabBar.appearance().standardAppearance = barAppearance
        UITabBar.appearance().scrollEdgeAppearance = barAppearance
    }

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
        .tint(AppTheme.oliveGreen)
    }
}



#Preview {
    MainAppView()
}

