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
                
                Section(header: Text("Workout Type")) {
                    Picker("Type", selection: $workoutType) {
                        ForEach(workoutTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                }
                
                Section(header: Text("Duration (minutes)")) {
                    Stepper("\(duration) min", value: $duration, in: 5...180, step: 5)
                }
                
                Section(header: Text("Intensity (1–10)")) {
                    Stepper("Intensity: \(intensity)", value: $intensity, in: 1...10)
                }
                
                Section(header: Text("Mood")) {
                    Stepper("Before: \(moodBefore)", value: $moodBefore, in: 1...10)
                    Stepper("After: \(moodAfter)", value: $moodAfter, in: 1...10)
                }
                
                Section(header: Text("Notes (optional)")) {
                    TextField("How did it feel?", text: $notes)
                }
                
                Section {
                    if isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Button("Log Workout") {
                            Task {
                                await saveWorkout()
                            }
                        }
                    }
                }
                
                if let message = saveMessage {
                    Section {
                        Text(message)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Log Session")
        }
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
