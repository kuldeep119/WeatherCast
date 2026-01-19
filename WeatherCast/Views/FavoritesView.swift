//
//  FavoritesView.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var selectedWeather: WeatherData?
    @State private var isShowingDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(red: 0.68, green: 0.85, blue: 0.95), Color(red: 0.75, green: 0.88, blue: 0.98)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if supabaseManager.favoriteCities.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "star.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.black.opacity(0.6))
                        Text("No Favourite Added")
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(supabaseManager.favoriteCities) { city in
                                FavoriteCityCard(city: city) { weather in
                                    self.selectedWeather = weather
                                    self.isShowingDetail = true
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Favorites")
            .sheet(isPresented: $isShowingDetail) {
                if let weather = selectedWeather {
                    DetailView(weather: weather)
                }
            }
            .task {
                await loadLiveTemps()
            }
        }
    }
    
    private func loadLiveTemps() async {
        for city in supabaseManager.favoriteCities {
            let service = WeatherService()
            await service.fetchWeather(for: city.cityName)
            if let temp = service.currentWeather?.temperature {
                supabaseManager.updateTemperature(for: city.cityName, temp: temp)
            }
        }
    }
}

struct FavoriteCityCard: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var authManager: AuthenticationManager
    let city: FavoriteCity
    var onSelect: (WeatherData) -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await weatherService.fetchWeather(for: city.cityName)
                if let weather = weatherService.currentWeather {
                    onSelect(weather)
                }
            }
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(city.cityName)
                        .font(.title3).bold()
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if let temp = supabaseManager.cityTemperatures[city.cityName] {
                    Text("\(temp)°")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.blue)
                } else {
                    ProgressView().scaleEffect(0.8)
                }
                
                Button(action: {
                    Task {
                        if let token = authManager.getAuthToken() {
                            await supabaseManager.removeFavoriteCity(cityId: city.id, token: token)
                        }
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.8))
                        .padding(10)
                        .background(Circle().fill(Color.red.opacity(0.1)))
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(AuthenticationManager())
        .environmentObject(WeatherService())
        .environmentObject(SupabaseManager())
}
