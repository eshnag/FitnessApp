//
//  Experiment.swift
//  FitnessApp
//
//  Data-driven hypothesis testing: compare mood delta across two groups.
//

import Foundation

enum ExperimentHypothesis: String, CaseIterable {
    case timeOfDay = "Morning vs Evening"
    case workoutType = "Workout type A vs B"
    case intensityBand = "Low vs High intensity"
}

struct ExperimentDefinition {
    var hypothesis: ExperimentHypothesis
    /// For .workoutType: first type and second type to compare.
    var typeA: String?
    var typeB: String?
}

struct ExperimentResult {
    var group1Label: String
    var group2Label: String
    var n1: Int
    var n2: Int
    var meanDelta1: Double
    var meanDelta2: Double
    /// meanDelta1 - meanDelta2 (positive = group1 outperforms group2).
    var difference: Double
    var message: String
}

enum ExperimentRunner {
    private static let morningStart = 6   // 06:00
    private static let morningEnd = 12   // 12:00
    private static let eveningEnd = 21   // 21:00

    /// Segments workouts by definition and returns result. Returns nil if insufficient data (n < 3 in either group).
    static func run(workouts: [Workout], definition: ExperimentDefinition) -> ExperimentResult? {
        let (group1, group2, label1, label2) = segment(workouts: workouts, definition: definition)
        guard group1.count >= 3, group2.count >= 3 else { return nil }
        let deltas1 = group1.map { $0.mood_after - $0.mood_before }
        let deltas2 = group2.map { $0.mood_after - $0.mood_before }
        let mean1 = Double(deltas1.reduce(0, +)) / Double(deltas1.count)
        let mean2 = Double(deltas2.reduce(0, +)) / Double(deltas2.count)
        let diff = mean1 - mean2
        let message: String
        if diff > 0 {
            message = "\(label1) sessions outperform \(label2) sessions by +\(String(format: "%.1f", abs(diff))) mood points (n=\(group1.count) vs n=\(group2.count))."
        } else if diff < 0 {
            message = "\(label2) sessions outperform \(label1) sessions by +\(String(format: "%.1f", abs(diff))) mood points (n=\(group2.count) vs n=\(group1.count))."
        } else {
            message = "No meaningful difference between \(label1) and \(label2) (n=\(group1.count) vs n=\(group2.count))."
        }
        return ExperimentResult(
            group1Label: label1,
            group2Label: label2,
            n1: group1.count,
            n2: group2.count,
            meanDelta1: mean1,
            meanDelta2: mean2,
            difference: diff,
            message: message
        )
    }

    private static func segment(workouts: [Workout], definition: ExperimentDefinition) -> ([Workout], [Workout], String, String) {
        switch definition.hypothesis {
        case .timeOfDay:
            var morning: [Workout] = []
            var evening: [Workout] = []
            let cal = Calendar.current
            for w in workouts {
                guard let d = w.created_at else { continue }
                let hour = cal.component(.hour, from: d)
                if hour >= morningStart && hour < morningEnd {
                    morning.append(w)
                } else if hour >= morningEnd && hour < eveningEnd {
                    evening.append(w)
                }
            }
            return (morning, evening, "Morning", "Evening")

        case .workoutType:
            let typeA = definition.typeA ?? "Strength"
            let typeB = definition.typeB ?? "Cardio"
            let group1 = workouts.filter { $0.type == typeA }
            let group2 = workouts.filter { $0.type == typeB }
            return (group1, group2, typeA, typeB)

        case .intensityBand:
            let low = workouts.filter { $0.intensity >= 1 && $0.intensity <= 4 }
            let high = workouts.filter { $0.intensity >= 7 && $0.intensity <= 10 }
            return (low, high, "Low (1–4)", "High (7–10)")
        }
    }
}
