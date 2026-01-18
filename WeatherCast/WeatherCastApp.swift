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
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager) // This covers the whole app
        }
    }
}
