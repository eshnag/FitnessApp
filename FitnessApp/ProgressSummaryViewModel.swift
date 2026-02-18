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
    /// Last 30 days of workouts for metrics and 7-day section.
    @Published var workouts: [Workout] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Result of the last run experiment (e.g. morning vs evening).
    @Published var experimentResult: ExperimentResult?
    @Published var experimentError: String?
    @Published var isRunningExperiment = false

    private let calendar = Calendar.current
    private let sevenDaysAgo: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

    /// Workouts in the last 7 calendar days (for "Based on your last 7 days" section).
    var workouts7Days: [Workout] {
        workouts.filter { w in
            guard let d = w.created_at else { return false }
            return d >= calendar.startOfDay(for: sevenDaysAgo)
        }.sorted { ($0.created_at ?? .distantPast) > ($1.created_at ?? .distantPast) }
    }

    // 7-day stats (for top section)
    var totalWorkouts: Int { workouts7Days.count }
    var totalMinutes: Int { workouts7Days.reduce(0) { $0 + $1.duration_min } }
    var avgIntensity: Int { workouts7Days.isEmpty ? 0 : workouts7Days.reduce(0) { $0 + $1.intensity } / workouts7Days.count }
    var moodImprovedCount: Int { workouts7Days.filter { $0.mood_after > $0.mood_before }.count }
    var moodImprovedRate: String { workouts7Days.isEmpty ? "0/0" : "\(moodImprovedCount)/\(workouts7Days.count)" }

    /// Average mood delta (after - before) over last 30 days.
    var avgMoodDelta30Days: Double {
        guard !workouts.isEmpty else { return 0 }
        let sum = workouts.reduce(0) { $0 + ($1.mood_after - $1.mood_before) }
        return Double(sum) / Double(workouts.count)
    }

    /// (Type, average mood delta) for last 30 days, sorted by type.
    var avgMoodDeltaByType: [(type: String, avgDelta: Double)] {
        let grouped = Dictionary(grouping: workouts, by: { $0.type })
        return grouped.map { type, wks in
            let deltas = wks.map { $0.mood_after - $0.mood_before }
            let avg = deltaAverage(deltas)
            return (type, avg)
        }.sorted { $0.type < $1.type }
    }

    /// Intensity bands: low 1–3, mid 4–7, high 8–10. (Band label, average mood delta) for last 30 days.
    var avgMoodDeltaByIntensityBand: [(band: String, avgDelta: Double)] {
        func band(for intensity: Int) -> String {
            switch intensity {
            case 1...3: return "Low (1–3)"
            case 4...7: return "Mid (4–7)"
            default: return "High (8–10)"
            }
        }
        let grouped = Dictionary(grouping: workouts, by: { band(for: $0.intensity) })
        let order = ["Low (1–3)", "Mid (4–7)", "High (8–10)"]
        return order.compactMap { label in
            guard let wks = grouped[label] else { return nil }
            let deltas = wks.map { $0.mood_after - $0.mood_before }
            return (label, deltaAverage(deltas))
        }
    }

    /// 0–100: percentage of workouts in last 30 days where mood improved (after > before).
    var emotionalStabilityScore: Int {
        guard !workouts.isEmpty else { return 0 }
        let improved = workouts.filter { $0.mood_after > $0.mood_before }.count
        return Int(round(Double(improved) / Double(workouts.count) * 100))
    }

    private func deltaAverage(_ deltas: [Int]) -> Double {
        guard !deltas.isEmpty else { return 0 }
        return Double(deltas.reduce(0, +)) / Double(deltas.count)
    }

    /// Load last 30 days of workouts for metrics. Call on appear.
    func loadProgressData() async {
        isLoading = true
        errorMessage = nil
        do {
            workouts = try await WorkoutService.shared.fetchWorkouts(lastDays: 30)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Fetch 7-day summary from backend and store; uses existing workouts for 7-day charts.
    func generateSummary() async {
        isLoading = true
        summary = nil
        errorMessage = nil
        do {
            summary = try await WorkoutService.shared.fetchProgressSummary()
            if workouts.isEmpty {
                workouts = try await WorkoutService.shared.fetchWorkouts(lastDays: 30)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Fetches last 14 days, runs experiment, sets experimentResult or experimentError.
    func runExperiment(definition: ExperimentDefinition) async {
        isRunningExperiment = true
        experimentResult = nil
        experimentError = nil
        do {
            let last14 = try await WorkoutService.shared.fetchWorkouts(lastDays: 14)
            if let result = ExperimentRunner.run(workouts: last14, definition: definition) {
                experimentResult = result
            } else {
                experimentError = "Need more data. Log at least 3 workouts in each group over the last 2 weeks."
            }
        } catch {
            experimentError = error.localizedDescription
        }
        isRunningExperiment = false
    }
}
