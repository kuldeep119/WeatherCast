//
//  AuthenticationManager.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//
import Foundation
import Combine
import SwiftUI
 

class AuthenticationManager: ObservableObject {
//    @Published var isAuthenticated = false
//    @Published var hasCompletedOnboarding = false
    @AppStorage("isAuthenticated") var isAuthenticated = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    private let supabaseURL = "https://yqcgidtbsrvftxkmurpn.supabase.co"
    private let supabaseKey = "sb_publishable_wXLdL-MFlQ0FRJg3U4R_aA_aLW5QDhL"
    
    func signUp(email: String, password: String, name: String) async {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/signup") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "data": ["full_name": name]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                await MainActor.run {
                    self.errorMessage = nil
                    // We don't set isAuthenticated = true here so the popup can show
                }
            } else {
                await MainActor.run { self.errorMessage = "Sign up failed. User may already exist." }
            }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }
    
    init() {
            if let savedUserData = UserDefaults.standard.data(forKey: "savedUser"),
               let decodedUser = try? JSONDecoder().decode(User.self, from: savedUserData) {
                self.currentUser = decodedUser
            }
        }
    
    func signIn(email: String, password: String) async {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let userJson = json["user"] as? [String: Any],
                   let userId = userJson["id"] as? String,
                   let userEmail = userJson["email"] as? String {
                    
                    let metadata = userJson["user_metadata"] as? [String: Any]
                    let userName = metadata?["full_name"] as? String
                    
                    await MainActor.run {
                        self.currentUser = User(id: userId, email: userEmail, name: userName)
                        self.isAuthenticated = true
                        self.saveAuthToken(json)
                    }
                    if let encoded = try? JSONEncoder().encode(self.currentUser) {
                        UserDefaults.standard.set(encoded, forKey: "savedUser")
                    }
                }
            } else {
                await MainActor.run { self.errorMessage = "Invalid email or password." }
            }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }
    
    

    func resetPassword(email: String) async {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/recover") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
        let body = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                await MainActor.run {
                    self.errorMessage = "Reset link sent to your email!"
                }
            } else {
                await MainActor.run { self.errorMessage = "Failed to send reset email." }
            }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    private func saveAuthToken(_ json: [String: Any]) {
        if let token = json["access_token"] as? String {
            UserDefaults.standard.set(token, forKey: "authToken")
        }
    }
    
    func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
}
