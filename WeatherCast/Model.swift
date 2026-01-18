import SwiftUI

struct User: Codable {
    let id: String
    let email: String
    let name: String?
}

struct FavoriteCity: Codable, Identifiable {
    let id: String
    let userId: String
    let cityName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case cityName = "city_name"
    }
}

struct WeatherData {
    let cityName: String
    let temperature: Int
    let condition: String
    let description: String
    let uvIndex: Int
    let humidity: Int
    let precipitation: Int
    let windSpeed: Double
    let forecast: [DailyForecast]
    let hourlyTemperatures: [HourlyTemp]
    let hourlyHumidity: [HourlyTemp]
    let hourlyWindSpeed: [HourlyTemp]
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let day: String
    let date: String
    let temperature: Int
    let icon: String
}

struct HourlyTemp: Identifiable {
    let id = UUID()
    let hour: String
    let temperature: Double
}

extension WeatherData {
    static let previewSample = WeatherData(
        cityName: "Gwalior",
        temperature: 22,
        condition: "Sunny",
        description: "Clear skies",
        uvIndex: 4,
        humidity: 45,
        precipitation: 0,
        windSpeed: 10.5,
        forecast: [
            DailyForecast(day: "Mon", date: "19 Jan", temperature: 24, icon: "sun.max.fill"),
            DailyForecast(day: "Tue", date: "20 Jan", temperature: 23, icon: "cloud.sun.fill"),
            DailyForecast(day: "Wed", date: "21 Jan", temperature: 21, icon: "cloud.fill"),
            DailyForecast(day: "Thu", date: "22 Jan", temperature: 20, icon: "cloud.rain.fill"),
            DailyForecast(day: "Fri", date: "23 Jan", temperature: 22, icon: "sun.max.fill")
        ],
        // FIXED: Added missing hourly data arrays
        hourlyTemperatures: (0...6).map { HourlyTemp(hour: "\($0 + 1)PM", temperature: Double(20 + $0)) },
        hourlyHumidity: (0...6).map { HourlyTemp(hour: "\($0 + 1)PM", temperature: Double(40 + $0)) },
        hourlyWindSpeed: (0...6).map { HourlyTemp(hour: "\($0 + 1)PM", temperature: Double(10 + $0)) }
    )
}
