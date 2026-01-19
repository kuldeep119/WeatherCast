//
//  ProfileView.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import SwiftUI

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.68, green: 0.85, blue: 0.95), Color(red: 0.75, green: 0.88, blue: 0.98)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 8) {
                                            if let user = authManager.currentUser {
                                                Text(user.name ?? "User")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(Color(white: 0.2))
                                                
                                                Text(user.email)
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color(white: 0.4))
                                            }
                                        }
                    
                    Button(action: { authManager.signOut() }) {
                        Text("Sign Out")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
                .padding(.top, 100)
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
}
