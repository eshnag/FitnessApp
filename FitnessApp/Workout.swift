//
//  Workout.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import Foundation
import Foundation

struct Workout: Codable, Identifiable {
    var id: UUID?
    var user_id: UUID?
    var type: String
    var duration_min: Int
    var intensity: Int
    var mood_before: Int
    var mood_after: Int
    var notes: String?
    var created_at: Date?
}
