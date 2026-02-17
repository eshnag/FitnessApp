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
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                } else if viewModel.workouts.isEmpty {
                    Text("No workouts logged yet.")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(viewModel.workouts) { workout in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.type)
                                    .font(.headline)
                                
                                Text("Intensity: \(workout.intensity)")
                                
                                Text("Mood Δ: \(workout.mood_after - workout.mood_before)")
                                    .foregroundColor(.secondary)
                                
                                if let date = workout.created_at {
                                    Text(date.formatted())
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete { offsets in
                            Task {
                                await viewModel.deleteWorkout(at: offsets)
                            }
                        }
                    }

                    
                }
            }
            .navigationTitle("Dashboard")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Logout") {
                            Task {
                                await authVM.signOut()
                            }
                        }
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
