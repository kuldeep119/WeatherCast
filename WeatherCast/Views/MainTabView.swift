//
//  MainTabView.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var supabaseManager: SupabaseManager
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Favorites")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        // Injecting here once makes them available to all tabs
//        .environmentObject(weatherService)
//        .environmentObject(supabaseManager)
//        .environmentObject(authManager)
        .task {
            if let userId = authManager.currentUser?.id,
               let token = authManager.getAuthToken() {
                await supabaseManager.fetchFavoriteCities(userId: userId, token: token)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
        .environmentObject(WeatherService())
}
