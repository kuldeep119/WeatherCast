//
//  HomeView.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import SwiftUI
import Combine

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var supabaseManager: SupabaseManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showDetails = false
    @State private var searchCity = ""
    @State private var showSearch = false
    
    var body: some View {
        ZStack {
            if let weather = weatherService.currentWeather {
                AnimatedBackgroundView(condition: weather.condition)
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.68, green: 0.85, blue: 0.95),
                        Color(red: 0.75, green: 0.88, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            if weatherService.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if let weather = weatherService.currentWeather {
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome, \(authManager.currentUser?.name ?? "Explorer")")
                                            .font(.system(size: 24,weight: .semibold))
                                            .foregroundColor(Color(white: 0.3))
                                Text(Date().formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(white: 0.5))
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button(action: { showSearch.toggle() }) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(white: 0.4))
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                        )
                                }
                                
                                Button(action: {
                                    Task {
                                        if let city = weatherService.currentWeather?.cityName,
                                           let userId = authManager.currentUser?.id,
                                           let token = authManager.getAuthToken() {
                                            await supabaseManager.addFavoriteCity(userId: userId, cityName: city, token: token)
                                        }
                                    }
                                }) {
                                    Image(systemName: isFavorite() ? "star.fill" : "star")
                                        .font(.system(size: 20))
                                        .foregroundColor(.orange)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 60)
                        
                        if showSearch {
                            HStack {
                                TextField("Search city", text: $searchCity)
                                    .textFieldStyle(SearchFieldStyle())
                                
                                Button("Search") {
                                    Task {
                                        await weatherService.fetchWeather(for: searchCity)
                                        showSearch = false
                                        searchCity = ""
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 30)
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                showDetails = true
                            }
                        }) {
                            MainWeatherCard(weather: weather)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "cloud.sun.fill")
                        .symbolRenderingMode(.multicolor)
                        .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Search for a city to view weather")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                    
                    
                    TextField("Search city", text: $searchCity)
                        .textFieldStyle(SearchFieldStyle())
                    
                    Button("Search City") {
                        Task {
                            await weatherService.fetchWeather(for: searchCity)
                            searchCity = ""
                        }
                        showSearch = true
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(40)
            }
        }
        .sheet(isPresented: $showDetails) {
            if let weather = weatherService.currentWeather {
                DetailView(weather: weather)
            }
        }
        .onAppear {
                    // Agar pehle se koi city saved hai aur abhi screen khali hai
                    if weatherService.currentWeather == nil && !weatherService.lastCity.isEmpty {
                        Task {
                            await weatherService.fetchWeather(for: weatherService.lastCity)
                        }
                    }
                }
        
    }
    
    private func isFavorite() -> Bool {
        guard let cityName = weatherService.currentWeather?.cityName else { return false }
        return supabaseManager.favoriteCities.contains { $0.cityName == cityName }
    }
    
}

struct SearchFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
    }
}

#Preview {
    let manager = AuthenticationManager()
    manager.currentUser = User(id: "123", email: "test@me.com", name: "Kuldeep")
    return HomeView().environmentObject(manager)
                .environmentObject(AuthenticationManager())
                .environmentObject(WeatherService())
                .environmentObject(SupabaseManager())
}
