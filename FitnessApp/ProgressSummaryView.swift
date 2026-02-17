//
//  ProgressSummaryView.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import SwiftUI
import Charts

struct ProgressSummaryView: View {

    @StateObject private var viewModel = ProgressSummaryViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else if viewModel.workouts.isEmpty && viewModel.summary == nil {
                    Spacer()
                    Text("Tap below to get a personal trainer-style summary of your recent workouts and mood.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            Text("Based on your last 7 days")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)

                            if !viewModel.workouts.isEmpty {
                                statsRow
                                MoodTrendChart(workouts: viewModel.workouts)
                                IntensityByTypeChart(workouts: viewModel.workouts)
                                DurationChart(workouts: viewModel.workouts)
                            }

                            if let summary = viewModel.summary {
                                coachSection(summary: summary)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }

                if !viewModel.isLoading {
                    Button("Generate progress summary") {
                        Task {
                            await viewModel.generateSummary()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Progress summary")
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(title: "Workouts", value: "\(viewModel.totalWorkouts)")
            StatCard(title: "Min", value: "\(viewModel.totalMinutes)")
            StatCard(title: "Avg Int", value: "\(viewModel.avgIntensity)")
            StatCard(title: "Mood↑", value: viewModel.moodImprovedRate)
        }
        .padding(.horizontal)
    }

    private func coachSection(summary: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coach's take")
                .font(.headline)
            Text(summary)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
}

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .bold()
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

private struct MoodTrendChart: View {
    let workouts: [Workout]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood trend")
                .font(.headline)
            Chart {
                ForEach(Array(workouts.enumerated()), id: \.offset) { i, w in
                    LineMark(
                        x: .value("Workout", i + 1),
                        y: .value("Before", w.mood_before)
                    )
                    .foregroundStyle(.orange)
                    .interpolationMethod(.catmullRom)
                    LineMark(
                        x: .value("Workout", i + 1),
                        y: .value("After", w.mood_after)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYScale(domain: 1...10)
            .frame(height: 160)
            HStack(spacing: 16) {
                Label("Before", systemImage: "circle.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
                Label("After", systemImage: "circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct IntensityByTypeChart: View {
    let workouts: [Workout]

    private var typeAverages: [(type: String, avg: Double)] {
        let grouped = Dictionary(grouping: workouts, by: { $0.type })
        return grouped.map { type, wks in
            (type, Double(wks.reduce(0) { $0 + $1.intensity }) / Double(wks.count))
        }.sorted { $0.type < $1.type }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Intensity by workout type")
                .font(.headline)
            Chart(typeAverages, id: \.type) { item in
                BarMark(
                    x: .value("Type", item.type),
                    y: .value("Intensity", item.avg)
                )
                .foregroundStyle(.blue)
            }
            .chartYScale(domain: 0...10)
            .frame(height: 160)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct DurationChart: View {
    let workouts: [Workout]

    private var durationByDay: [(day: Date, label: String, minutes: Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let grouped = Dictionary(grouping: workouts) { w -> Date in
            guard let d = w.created_at else { return Date() }
            return calendar.startOfDay(for: d)
        }
        return grouped.map { day, wks in
            (day, formatter.string(from: day), wks.reduce(0) { $0 + $1.duration_min })
        }.sorted { $0.day < $1.day }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duration by day")
                .font(.headline)
            Chart(durationByDay, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.label),
                    y: .value("Minutes", item.minutes)
                )
                .foregroundStyle(.purple)
            }
            .frame(height: 160)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    ProgressSummaryView()
}
