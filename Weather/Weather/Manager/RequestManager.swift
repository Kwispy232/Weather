//
//  RequestManager.swift
//  Weather
//
//  Created by Sebastian Mraz on 24/04/2022.
//

import Foundation
import Alamofire
import CoreLocation


struct RequestManager {
    static let shared = RequestManager()
    
    /**
     Funkcia používa Alamofire na vykonnie API requestu pre konkrétnu lokáciu a výsledné dáta priradí do predpripravených štruktúr WeatherResponse
     
     Parameters:
     -  coordinates:CLLocationCoordinate2D, completion:@escaping (Result<WeatherResponse, AFError>) -> Void
     */
    func getWeatherData(for coordinates :CLLocationCoordinate2D, completion: @escaping (Result<WeatherResponse, AFError>) -> Void) {
        let request = WeatherRequest(lat: "\(coordinates.latitude)", lon: "\(coordinates.longitude)", exclude: "minutely", appid: "b9944ed07816bcbc5572cb754deafb21", units: "metric")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        AF.request("https://api.openweathermap.org/data/2.5/onecall", method: .get, parameters: request)
            .validate()
            .responseDecodable(of: WeatherResponse.self, decoder: decoder) { completion($0.result) }
    }
    
    
}
