//
//  WeatherService.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import Foundation
import Combine

enum HourlyMetric {
    case temp, humidity, wind
}

class WeatherService: ObservableObject {
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = APIConfig.apiKey
    private let baseURL = "https://api.weatherapi.com/v1"
    
    func fetchWeather(for city: String) async {
        await MainActor.run { isLoading = true }
        
        // WeatherAPI uses key= instead of appid=
        let urlString = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(city)&days=5&aqi=no&alerts=no"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
            let rawHourlyData = response.forecast?.forecastday.first?.hour ?? []
            
            let weather = WeatherData(
                cityName: response.location.name,
                temperature: Int(response.current.temp_c),
                condition: response.current.condition.text,
                description: response.current.condition.text,
                uvIndex: Int(response.current.uv),
                humidity: response.current.humidity,
                precipitation: Int(response.current.precip_mm),
                windSpeed: response.current.wind_kph,
                // Use optional chaining and provide empty defaults to prevent crashes
                forecast: processForecast(response.forecast?.forecastday ?? []),
                hourlyTemperatures: processHourly(rawHourlyData, type: .temp),
                hourlyHumidity: processHourly(rawHourlyData, type: .humidity),
                hourlyWindSpeed: processHourly(rawHourlyData, type: .wind)
            )
            await MainActor.run {
                self.currentWeather = weather
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func processForecast(_ days: [ForecastDayData]) -> [DailyForecast] {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let dateOnlyFormatter = DateFormatter()
        dateOnlyFormatter.dateFormat = "d MMM"
        
        return days.map { dayData in
            let date = Date(timeIntervalSince1970: TimeInterval(dayData.date_epoch))
            return DailyForecast(
                day: dayFormatter.string(from: date),
                date: dateOnlyFormatter.string(from: date),
                temperature: Int(dayData.day.avgtemp_c),
                icon: getWeatherIcon(dayData.day.condition.text)
            )
        }
    }
    
    private func processHourly(_ hours: [HourData], type: HourlyMetric) -> [HourlyTemp] {
            let formatter = DateFormatter()
            formatter.dateFormat = "ha"
            
            return hours.prefix(8).map { hourData in
                let date = Date(timeIntervalSince1970: TimeInterval(hourData.time_epoch))
                
                // Determine which value to use based on the metric type
                let value: Double
                switch type {
                case .temp:
                    value = hourData.temp_c
                case .humidity:
                    value = Double(hourData.humidity)
                case .wind:
                    value = hourData.wind_kph
                }
                
                return HourlyTemp(
                    hour: formatter.string(from: date),
                    temperature: value
                )
            }
        }
        
        private func getWeatherIcon(_ condition: String) -> String {
            let lower = condition.lowercased()
            if lower.contains("sunny") || lower.contains("clear") { return "sun.max.fill" }
            if lower.contains("cloud") || lower.contains("overcast") { return "cloud.sun.fill" }
            if lower.contains("rain") || lower.contains("drizzle") { return "cloud.rain.fill" }
            if lower.contains("snow") { return "cloud.snow.fill" }
            if lower.contains("thunder") { return "cloud.bolt.fill" }
            return "cloud.fill"
        }
    }

