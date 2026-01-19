//
//  OnboardingView.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.68, green: 0.85, blue: 0.95),
                    Color(red: 0.75, green: 0.88, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.orange, Color.orange.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 150, height: 150)
                .offset(x: -150, y: -350)
            
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 400, height: 400)
                .offset(x: 100, y: 200)
            
            VStack(spacing: 20) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Never get caught\nin the rain again")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(white: 0.3))
                        .lineSpacing(4)
                    
                    Text("Stay ahead of the weather with our\naccurate forecasts")
                        .font(.system(size: 18))
                        .foregroundColor(Color(white: 0.4))
                        .lineSpacing(2)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        authManager.hasCompletedOnboarding = true
                    }
                }) {
                    Text("Get started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.blue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(25)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthenticationManager())
}
