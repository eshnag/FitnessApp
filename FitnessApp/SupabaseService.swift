//
//  SupabaseService.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import Supabase
import Foundation

class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        let url = URL(string: "https://vvyvfhovpbpofrseteut.supabase.co")!
        let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2eXZmaG92cGJwb2Zyc2V0ZXV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyOTY2MDksImV4cCI6MjA4Njg3MjYwOX0.NZBIOS1d8PvSdxcnm4D4Y5FpIv9VZ3AZ3qYNC0j4lNM"
        
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key
        )
    }
}
