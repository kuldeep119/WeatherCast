//
//  SupabaseManager.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import Foundation
import Combine

class SupabaseManager: ObservableObject {
    @Published var favoriteCities: [FavoriteCity] = []
    @Published var cityTemperatures: [String: Int] = [:]
    
    private let supabaseURL = "https://yqcgidtbsrvftxkmurpn.supabase.co"
    private let supabaseKey = "sb_publishable_wXLdL-MFlQ0FRJg3U4R_aA_aLW5QDhL"
    
    @MainActor
    func fetchFavoriteCities(userId: String, token: String) async {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/favorite_cities?user_id=eq.\(userId)") else { return }
        
        var request = URLRequest(url: url)
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let cities = try JSONDecoder().decode([FavoriteCity].self, from: data)
            self.favoriteCities = cities
        } catch {
            print("Error: \(error)")
        }
    }

    @MainActor
    func addFavoriteCity(userId: String, cityName: String, token: String) async {
        if favoriteCities.contains(where: { $0.cityName.lowercased() == cityName.lowercased() }) {
            return
        }

        guard let url = URL(string: "\(supabaseURL)/rest/v1/favorite_cities") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer") // Isse data turant wapas milta hai

        let body = ["user_id": userId, "city_name": cityName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                let savedCities = try JSONDecoder().decode([FavoriteCity].self, from: data)
                if let newCity = savedCities.first {
                    // Local list mein add karo taaki multiple cities dikhein
                    self.favoriteCities.append(newCity)
                }
            }
        } catch {
            print("Error adding favorite: \(error)")
        }
    }

    @MainActor
    func updateTemperature(for cityName: String, temp: Int) {
        self.cityTemperatures[cityName] = temp
    }

    @MainActor
    func removeFavoriteCity(cityId: String, token: String) async {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/favorite_cities?id=eq.\(cityId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            self.favoriteCities.removeAll { $0.id == cityId }
            // Temperature list se bhi hatao
            if let cityToRemove = favoriteCities.first(where: { $0.id == cityId }) {
                self.cityTemperatures.removeValue(forKey: cityToRemove.cityName)
            }
        } catch {
            print("Error deleting favorite")
        }
    }
}
