//
//  MainWeatherCard.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import SwiftUI

// MARK: - Main Weather Card
struct MainWeatherCard: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(weather.cityName)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Color(white: 0.3))
                
                HStack(alignment: .top, spacing: 4) {
                    Text("\(weather.temperature)°")
                        .font(.system(size: 90, weight: .bold))
                        .foregroundColor(Color(white: 0.3))
                    Text("C")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(white: 0.3))
                        .padding(.top, 15)
                }
                
                Text(weather.description.capitalized)
                    .font(.system(size: 20))
                    .foregroundColor(Color(white: 0.4))
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            HStack(spacing: 0) {
                WeatherStatView(icon: "sun.max.fill", label: "UV Index", value: "\(weather.uvIndex)", subtitle: "High")
                
                Divider()
                    .frame(height: 60)
                    .background(Color.white.opacity(0.2))
                
                WeatherStatView(icon: "humidity.fill", label: "Humidity", value: "\(weather.humidity)%", subtitle: "")
                
                Divider()
                    .frame(height: 60)
                    .background(Color.white.opacity(0.2))
                
                WeatherStatView(icon: "cloud.rain.fill", label: "Precipitation", value: "\(weather.precipitation)mm", subtitle: "")
            }
            .padding(.vertical, 25)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Next days")
                    .font(.system(size: 16))
                    .foregroundColor(Color(white: 0.5))
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    ForEach(weather.forecast) { forecast in
                        ForecastRow(forecast: forecast)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        MainWeatherCard(weather: .previewSample)
            .padding()
    }
}
