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
    @State private var showExperimentSheet = false
    @State private var experimentDefinition = ExperimentDefinition(hypothesis: .timeOfDay, typeA: "Strength", typeB: "Cardio")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppTheme.oliveGreen)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else if viewModel.workouts.isEmpty && viewModel.summary == nil {
                    Spacer()
                    Text("See what the data says. Get optimization suggestions based on your workouts and mood.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.oliveDark.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            Text("Based on your last 7 days")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.oliveDark.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)

                            if !viewModel.workouts7Days.isEmpty {
                                statsRow
                                MoodTrendChart(workouts: viewModel.workouts7Days)
                                IntensityByTypeChart(workouts: viewModel.workouts7Days)
                                DurationChart(workouts: viewModel.workouts7Days)
                            }

                            if !viewModel.workouts.isEmpty {
                                thirtyDaySection
                            }

                            experimentSection

                            if let summary = viewModel.summary {
                                coachSection(summary: summary)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .refreshable {
                        await viewModel.loadProgressData()
                    }
                }

                if !viewModel.isLoading {
                    Button("Get optimization suggestions") {
                        Task {
                            await viewModel.generateSummary()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.oliveGreen)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .sheet(isPresented: $showExperimentSheet) {
                ExperimentSheet(
                    definition: $experimentDefinition,
                    result: viewModel.experimentResult,
                    error: viewModel.experimentError,
                    isRunning: viewModel.isRunningExperiment,
                    onRun: {
                        Task {
                            await viewModel.runExperiment(definition: experimentDefinition)
                        }
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.beige)
            .navigationTitle("Progress summary")
            .toolbarBackground(AppTheme.beige, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .onAppear {
                Task {
                    if !viewModel.isLoading {
                        await viewModel.loadProgressData()
                    }
                }
            }
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

    private var thirtyDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 30 days — emotional ROI")
                .font(.subheadline)
                .foregroundColor(AppTheme.oliveDark.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            HStack(spacing: 12) {
                StatCard(title: "Mood Δ avg", value: String(format: "%.1f", viewModel.avgMoodDelta30Days))
                StatCard(title: "Stability", value: "\(viewModel.emotionalStabilityScore)")
            }
            .padding(.horizontal)

            MoodDeltaByTypeChart(data: viewModel.avgMoodDeltaByType)
            MoodDeltaByIntensityBandChart(data: viewModel.avgMoodDeltaByIntensityBand)
        }
    }

    private var experimentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Run an experiment")
                .font(.subheadline)
                .foregroundColor(AppTheme.oliveDark.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Button {
                viewModel.clearExperimentResult()
                showExperimentSheet = true
            } label: {
                Label("Test a hypothesis (e.g. morning vs evening)", systemImage: "flask")
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.oliveGreen)
            .padding(.horizontal)
        }
    }

    private func coachSection(summary: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Optimization Suggestions")
                .font(.headline)
                .foregroundColor(AppTheme.oliveGreen)
            Text(summary)
                .font(.body)
                .foregroundColor(AppTheme.oliveDark)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .journalCard()
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
                .foregroundColor(AppTheme.oliveGreen)
            Text(title)
                .font(.caption2)
                .foregroundColor(AppTheme.oliveDark.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.beigeDark)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

private struct MoodTrendChart: View {
    let workouts: [Workout]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood trend")
                .font(.headline)
                .foregroundColor(AppTheme.oliveGreen)
            Chart {
                ForEach(Array(workouts.enumerated()), id: \.offset) { i, w in
                    LineMark(
                        x: .value("Workout", i + 1),
                        y: .value("Before", w.mood_before)
                    )
                    .foregroundStyle(AppTheme.oliveDark)
                    .interpolationMethod(.catmullRom)
                    LineMark(
                        x: .value("Workout", i + 1),
                        y: .value("After", w.mood_after)
                    )
                    .foregroundStyle(AppTheme.oliveGreen)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYScale(domain: 1...10)
            .frame(height: 160)
            HStack(spacing: 16) {
                Label("Before", systemImage: "circle.fill")
                    .foregroundStyle(AppTheme.oliveDark)
                    .font(.caption)
                Label("After", systemImage: "circle.fill")
                    .foregroundStyle(AppTheme.oliveGreen)
                    .font(.caption)
            }
        }
        .padding()
        .background(AppTheme.beigeDark)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
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
                .foregroundColor(AppTheme.oliveGreen)
            Chart(typeAverages, id: \.type) { item in
                BarMark(
                    x: .value("Type", item.type),
                    y: .value("Intensity", item.avg)
                )
                .foregroundStyle(AppTheme.oliveGreen)
            }
            .chartYScale(domain: 0...10)
            .frame(height: 160)
        }
        .padding()
        .background(AppTheme.beigeDark)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
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
                .foregroundColor(AppTheme.oliveGreen)
            Chart(durationByDay, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.label),
                    y: .value("Minutes", item.minutes)
                )
                .foregroundStyle(AppTheme.oliveDark)
            }
            .frame(height: 160)
        }
        .padding()
        .background(AppTheme.beigeDark)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

private struct MoodDeltaByTypeChart: View {
    let data: [(type: String, avgDelta: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Avg mood delta by workout type")
                .font(.headline)
                .foregroundColor(AppTheme.oliveGreen)
            if data.isEmpty {
                Text("No data yet")
                    .font(.caption)
                    .foregroundColor(AppTheme.oliveDark.opacity(0.7))
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(data, id: \.type) { item in
                    BarMark(
                        x: .value("Type", item.type),
                        y: .value("Mood Δ", item.avgDelta)
                    )
                    .foregroundStyle(item.avgDelta >= 0 ? AppTheme.oliveGreen : AppTheme.oliveDark.opacity(0.8))
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 160)
            }
        }
        .padding()
        .background(AppTheme.beigeDark)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

private struct MoodDeltaByIntensityBandChart: View {
    let data: [(band: String, avgDelta: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood delta by intensity band")
                .font(.headline)
                .foregroundColor(AppTheme.oliveGreen)
            if data.isEmpty {
                Text("No data yet")
                    .font(.caption)
                    .foregroundColor(AppTheme.oliveDark.opacity(0.7))
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(data, id: \.band) { item in
                    BarMark(
                        x: .value("Band", item.band),
                        y: .value("Mood Δ", item.avgDelta)
                    )
                    .foregroundStyle(item.avgDelta >= 0 ? AppTheme.oliveGreen : AppTheme.oliveDark.opacity(0.8))
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 160)
            }
        }
        .padding()
        .background(AppTheme.beigeDark)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

private struct ExperimentSheet: View {
    @Binding var definition: ExperimentDefinition
    let result: ExperimentResult?
    let error: String?
    let isRunning: Bool
    let onRun: () -> Void

    private static let workoutTypes = ["Strength", "Cardio", "Legs", "Upper Body", "Full Body", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Hypothesis", selection: $definition.hypothesis) {
                        ForEach(ExperimentHypothesis.allCases, id: \.self) { h in
                            Text(h.rawValue).tag(h)
                        }
                    }
                    if definition.hypothesis == .workoutType {
                        Picker("Type A", selection: Binding(
                            get: { definition.typeA ?? "Strength" },
                            set: { definition.typeA = $0 }
                        )) {
                            ForEach(Self.workoutTypes, id: \.self) { t in
                                Text(t).tag(t)
                            }
                        }
                        Picker("Type B", selection: Binding(
                            get: { definition.typeB ?? "Cardio" },
                            set: { definition.typeB = $0 }
                        )) {
                            ForEach(Self.workoutTypes, id: \.self) { t in
                                Text(t).tag(t)
                            }
                        }
                    }
                } header: {
                    Text("Last 14 days")
                } footer: {
                    Text("At least 3 workouts in each group required.")
                }

                Section {
                    Button {
                        onRun()
                    } label: {
                        HStack {
                            if isRunning {
                                ProgressView()
                                    .scaleEffect(0.9)
                            }
                            Text(isRunning ? "Running…" : "Run experiment")
                        }
                    }
                    .disabled(isRunning)
                }

                if let result = result {
                    Section(header: Text("Result")) {
                        Text(result.message)
                            .font(.body)
                            .foregroundColor(AppTheme.oliveDark)
                    }
                }
                if let error = error, result == nil {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.beige)
            .navigationTitle("Run an experiment")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProgressSummaryView()
}
