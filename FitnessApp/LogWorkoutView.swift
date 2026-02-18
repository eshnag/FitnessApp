//
//  LogWorkoutView.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import SwiftUI


struct LogWorkoutView: View {

    @State private var workoutType = "Strength"
    @State private var duration = 45
    @State private var intensity = 7
    @State private var moodBefore = 5
    @State private var moodAfter = 7
    @State private var notes = ""

    @State private var isSaving = false
    @State private var saveMessage: String?

    let workoutTypes = ["Strength", "Cardio", "Legs", "Upper Body", "Full Body", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: sectionHeader("Workout Type")) {
                    Picker("Type", selection: $workoutType) {
                        ForEach(workoutTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .listRowBackground(AppTheme.beigeLight)
                }

                Section(header: sectionHeader("Duration (minutes)")) {
                    Stepper("\(duration) min", value: $duration, in: 5...180, step: 5)
                    .listRowBackground(AppTheme.beigeLight)
                }

                Section(header: sectionHeader("Intensity (1–10)")) {
                    Stepper("Intensity: \(intensity)", value: $intensity, in: 1...10)
                    .listRowBackground(AppTheme.beigeLight)
                }

                Section(header: sectionHeader("Mood")) {
                    Stepper("Before: \(moodBefore)", value: $moodBefore, in: 1...10)
                    .listRowBackground(AppTheme.beigeLight)
                    Stepper("After: \(moodAfter)", value: $moodAfter, in: 1...10)
                    .listRowBackground(AppTheme.beigeLight)
                }

                Section(header: sectionHeader("Notes (optional)")) {
                    TextField("How did it feel?", text: $notes)
                    .listRowBackground(AppTheme.beigeLight)
                }

                Section {
                    if isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                                .tint(AppTheme.oliveGreen)
                            Spacer()
                        }
                        .listRowBackground(AppTheme.beigeLight)
                    } else {
                        Button("Log Workout") {
                            Task {
                                await saveWorkout()
                            }
                        }
                        .tint(AppTheme.oliveGreen)
                        .listRowBackground(AppTheme.beigeLight)
                    }
                }

                if let message = saveMessage {
                    Section {
                        Text(message)
                            .foregroundColor(AppTheme.oliveGreen)
                            .listRowBackground(AppTheme.beigeLight)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.beige)
            .navigationTitle("Log Session")
            .toolbarBackground(AppTheme.beige, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundColor(AppTheme.oliveGreen)
            .fontWeight(.semibold)
    }
    
    // MARK: - Save Logic
    
    func saveWorkout() async {
        isSaving = true
        saveMessage = nil
        
        let workout = Workout(
            type: workoutType,
            duration_min: duration,
            intensity: intensity,
            mood_before: moodBefore,
            mood_after: moodAfter,
            notes: notes.isEmpty ? nil : notes
        )
        
        do {
            try await WorkoutService.shared.saveWorkout(workout)
            saveMessage = "Workout logged successfully."
            resetForm()
        } catch {
            saveMessage = "Error saving workout."
            print("Save error:", error)
        }
        
        isSaving = false
    }
    
    func resetForm() {
        duration = 45
        intensity = 7
        moodBefore = 5
        moodAfter = 7
        notes = ""
    }
}

#Preview {
    LogWorkoutView()
}
