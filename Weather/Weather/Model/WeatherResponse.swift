// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let weatherResponse = try? newJSONDecoder().decode(WeatherResponse.self, from: jsonData)

import Foundation
import UIKit

// MARK: - WeatherResponse
struct WeatherResponse: Decodable {
    let current: CurrentWeather
    let hourly: [CurrentWeather]
    let daily: [Daily]

    enum CodingKeys: String, CodingKey {
        case current, hourly, daily
    }
}

// MARK: - Current
struct CurrentWeather: Decodable {
    let date: Date
    let temperature: Double
    let feelsLike: Double
    let weather: [Weather]

    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case temperature = "temp"
        case feelsLike = "feels_like"
        case weather
    }
}

// MARK: - Weather
struct Weather: Decodable {
    let desc: Main
    let icon: String
    
    enum CodingKeys: String, CodingKey {
        case desc = "main"
        case icon
    }
    
    var image: UIImage? {
        switch icon {
        case "03d":
            return UIImage(systemName: "cloud.fill")
        case "04d":
            return UIImage(systemName: "cloud.fill")
        case "11d":
            return UIImage(systemName: "cloud.bolt.fill")
        case "09d":
            return UIImage(systemName: "cloud.drizzle.fill")
        case "10d":
            return UIImage(systemName: "cloud.rain.fill")
        case "13d":
            return UIImage(systemName: "cloud.snow.fill")
        case "50d":
            return UIImage(systemName: "smoke.fill")
        case "01d":
            return UIImage(systemName: "sun.max.fill")
        case "02d":
            return UIImage(systemName: "cloud.sun.fill")
        default:
            return UIImage(systemName: "moon.circle.fill")
        }
    }
}

enum Main: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
}

// MARK: - Daily
struct Daily: Decodable {
    let date: Date
    let temp: Temp
    let weather: [Weather]
    let pop: Double

    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case temp
        case weather, pop
    }
}

// MARK: - Temp
struct Temp: Codable {
    let day: Double
}
