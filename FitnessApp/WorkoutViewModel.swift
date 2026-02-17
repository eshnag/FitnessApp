//
//  WorkoutViewModel.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import Foundation

@MainActor
class WorkoutViewModel: ObservableObject {
    
    @Published var workouts: [Workout] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadWorkouts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            workouts = try await WorkoutService.shared.fetchWorkouts()
        } catch {
            errorMessage = error.localizedDescription
            print("Fetch error:", error)
        }
        
        isLoading = false
    }
    func deleteWorkout(at offsets: IndexSet) async {
        for index in offsets {
            let workout = workouts[index]
            
            if let id = workout.id {
                do {
                    try await WorkoutService.shared.deleteWorkout(id: id)
                } catch {
                    print("Delete error:", error)
                }
            }
        }
        
        await loadWorkouts()
    }

}
