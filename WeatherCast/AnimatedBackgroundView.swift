//
//  AnimatedBackgroundView.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    let condition: String
    @State private var animate = false
    
    var isClear: Bool {
        let lower = condition.lowercased()
        return lower.contains("sun") || lower.contains("clear")
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: isClear ?
                [Color(red: 0.68, green: 0.85, blue: 0.95), Color(red: 0.85, green: 0.92, blue: 0.97)] :
                [Color(red: 0.5, green: 0.6, blue: 0.7), Color(red: 0.6, green: 0.7, blue: 0.8)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background Circles...
        }
        .onAppear { animate = true }
    }
}
#Preview {
    AnimatedBackgroundView(condition: "sun")
}
