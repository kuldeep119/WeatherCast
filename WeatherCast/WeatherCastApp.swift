//
//  WeatherCastApp.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import SwiftUI
import Combine

// MARK: - Main App
@main
struct WeatherCastApp: App {
    @AppStorage("isAuthenticated") var isAuthenticated = false
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var weatherService = WeatherService()
    @StateObject private var supabaseManager = SupabaseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                            .environmentObject(authManager)
                            .environmentObject(weatherService)
                            .environmentObject(supabaseManager)
        }
    }
}
