//
//  ProgressSummaryViewModel.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import Foundation

@MainActor
class ProgressSummaryViewModel: ObservableObject {

    @Published var summary: String?
    @Published var workouts: [Workout] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var totalWorkouts: Int { workouts.count }
    var totalMinutes: Int { workouts.reduce(0) { $0 + $1.duration_min } }
    var avgIntensity: Int { workouts.isEmpty ? 0 : workouts.reduce(0) { $0 + $1.intensity } / workouts.count }
    var moodImprovedCount: Int { workouts.filter { $0.mood_after > $0.mood_before }.count }
    var moodImprovedRate: String { workouts.isEmpty ? "0/0" : "\(moodImprovedCount)/\(workouts.count)" }

    func generateSummary() async {
        isLoading = true
        summary = nil
        workouts = []
        errorMessage = nil

        do {
            async let workoutsTask = WorkoutService.shared.fetchWorkouts(lastDays: 7)
            async let summaryTask = WorkoutService.shared.fetchProgressSummary()
            workouts = try await workoutsTask
            summary = try await summaryTask
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
