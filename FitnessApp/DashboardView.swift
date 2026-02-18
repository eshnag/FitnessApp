//
//  DashboardView.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import SwiftUI


struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @StateObject var viewModel = WorkoutViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(AppTheme.oliveGreen)
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else if viewModel.workouts.isEmpty {
                    Text("No workouts logged yet.")
                        .foregroundColor(AppTheme.oliveDark.opacity(0.7))
                } else {
                    List {
                        ForEach(viewModel.workouts) { workout in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.type)
                                    .font(.headline)
                                    .foregroundColor(AppTheme.oliveDark)

                                Text("Intensity: \(workout.intensity)")
                                    .foregroundColor(AppTheme.oliveDark.opacity(0.9))

                                Text("Mood Δ: \(workout.mood_after - workout.mood_before)")
                                    .foregroundColor(AppTheme.oliveDark.opacity(0.7))

                                if let date = workout.created_at {
                                    Text(date.formatted())
                                        .font(.caption)
                                        .foregroundColor(AppTheme.oliveDark.opacity(0.6))
                                }
                            }
                            .padding(.vertical, 4)
                            .listRowBackground(AppTheme.beigeLight)
                            .listRowSeparatorTint(AppTheme.beigeDark)
                        }
                        .onDelete { offsets in
                            Task {
                                await viewModel.deleteWorkout(at: offsets)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(AppTheme.beige)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.beige)
            .navigationTitle("Dashboard")
            .toolbarBackground(AppTheme.beige, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout") {
                        Task {
                            await authVM.signOut()
                        }
                    }
                    .tint(AppTheme.oliveGreen)
                }
            }
            .task {
                await viewModel.loadWorkouts()
            }
        }
    }
}


#Preview {
    DashboardView()
}
