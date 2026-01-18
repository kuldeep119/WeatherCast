//
//  WeatherStatView.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import SwiftUI

// MARK: - Weather Stat View
struct WeatherStatView: View {
    let icon: String
    let label: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(white: 0.4))
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(white: 0.5))
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(white: 0.3))
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.5))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WeatherStatView(icon: "sun.max.fill", label: "UV Index", value: "4", subtitle: "Moderate")
}
