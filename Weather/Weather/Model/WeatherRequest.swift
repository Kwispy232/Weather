//
//  WeatherRequest.swift
//  Weather
//
//  Created by Sebastian Mraz on 24/04/2022.
//

import Foundation
struct WeatherRequest: Encodable {
    let lat: String
    let lon: String
    let exclude: String
    let appid: String
    let units: String
    
}

