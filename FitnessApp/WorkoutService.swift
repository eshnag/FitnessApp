//
//  WorkoutService.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import Foundation
import Supabase

class WorkoutService {
    
    static let shared = WorkoutService()
    
    func saveWorkout(_ workout: Workout) async throws {
        let user = try await SupabaseService.shared.client.auth.session.user
        
        var newWorkout = workout
        newWorkout.user_id = user.id
        
        try await SupabaseService.shared.client
            .from("workouts")
            .insert(newWorkout)
            .execute()
    }
    func fetchWorkouts() async throws -> [Workout] {
        let user = try await SupabaseService.shared.client.auth.session.user
        
        let response: [Workout] = try await SupabaseService.shared.client
            .from("workouts")
            .select()
            .eq("user_id", value: user.id)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    func deleteWorkout(id: UUID) async throws {
        try await SupabaseService.shared.client
            .from("workouts")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    /// Invokes the progress-summary Edge Function; returns the generated summary string.
    func fetchProgressSummary() async throws -> String {
        struct ProgressSummaryResponse: Decodable {
            let summary: String
        }
        let session = try await SupabaseService.shared.client.auth.session
        let response: ProgressSummaryResponse = try await SupabaseService.shared.client
            .functions
            .invoke(
                "progress-summary",
                options: FunctionInvokeOptions(headers: ["Authorization": "Bearer \(session.accessToken)"])
            )
        return response.summary
    }
}

