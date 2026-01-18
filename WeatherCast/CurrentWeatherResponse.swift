//
//  CurrentWeatherResponse.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import Foundation

struct WeatherAPIResponse: Codable {
    let location: LocationData
    let current: CurrentData
    let forecast: ForecastData?
}

struct LocationData: Codable {
    let name: String
}

struct CurrentData: Codable {
    let temp_c: Double
    let humidity: Int
    let uv: Double
    let precip_mm: Double
    let wind_kph: Double
    let condition: ConditionData
}

struct ConditionData: Codable {
    let text: String
}

struct ForecastData: Codable {
    let forecastday: [ForecastDayData]
}

struct ForecastDayData: Codable {
    let date_epoch: Int
    let day: DayData
    let hour: [HourData]
}

struct DayData: Codable {
    let avgtemp_c: Double
    let condition: ConditionData
}

struct HourData: Codable {
    let time_epoch: Int
    let temp_c: Double
    let humidity: Int
    let wind_kph: Double
}
