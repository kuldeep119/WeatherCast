//
//  ContentView.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if !authManager.hasCompletedOnboarding {
                OnboardingView()
            } else if authManager.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
    }
}
#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}
