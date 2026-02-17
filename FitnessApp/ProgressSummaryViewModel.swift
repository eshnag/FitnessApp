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
    @Published var isLoading = false
    @Published var errorMessage: String?

    func generateSummary() async {
        isLoading = true
        summary = nil
        errorMessage = nil

        do {
            summary = try await WorkoutService.shared.fetchProgressSummary()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
