//
//  File.swift
//  Weather
//
//  Created by Sebastian Mraz on 06/04/2022.
//

import Foundation
import CoreLocation
import UIKit
import MapKit
import Alamofire

struct CurrentLocation {
    
    let city:String
    let country: String
    let coordinate: CLLocationCoordinate2D
}

class LocationManager : CLLocationManager {
    
    //  MARK: Atributes
    static let shared = LocationManager()
    private var geokoder = CLGeocoder()
    
    var completion : ((CurrentLocation?, Error?)->Void)?
    var autCompletion : ((Bool?)->Void)?

    var denied : Bool {
        LocationManager.shared.authorizationStatus == .denied
    }

    //  MARK: LocationHandling
    func getLocation(complation: @escaping(CurrentLocation?, Error?)->Void) {
        self.completion = complation
        startUpdatingLocation()
        requestWhenInUseAuthorization()
        delegate = self
    }

    
    func getLocationFromPlace(where place : Place, comp: @escaping(CurrentLocation?, Error?) -> Void ) {
        let address = place.country + ", " + place.city
        geokoder.geocodeAddressString(address) { placemars, error in
            guard let placemark = placemars?.first, let location = placemark.location, error == nil else {
                comp(nil, error)
                return
            }
            let coord = location.coordinate
            comp(CurrentLocation(city: place.city, country: place.country, coordinate: coord), nil)
            self.stopUpdatingLocation()

        }
    }
    
    
    func onAuthorizationChange(completion : ((Bool?)->Void)?) {
        self.autCompletion = completion
    }
    
    
    func getTimeZone(location: CLLocationCoordinate2D, completion: @escaping ((TimeZone) -> Void)) {
        let cllLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(cllLocation) { placemarks, error in

            if let error = error {
                print(error.localizedDescription)

            } else {
                if let placemarks = placemarks {
                    if let optTime = placemarks.first!.timeZone {
                        completion(optTime)
                        self.stopUpdatingLocation()

                    }
                }
            }
        }
    }
    
    
    
}

//  MARK: Extensions
extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        geokoder.reverseGeocodeLocation(location) { [weak self] placemarks , error in
            guard let placemark = placemarks?.first, let city = placemark.locality, let country = placemark.country, error == nil else {
            if let self = self, let completion = self.completion{
                completion(nil, error)
            }
            return
        }
            let currentLocation = CurrentLocation(city: city, country: country, coordinate: location.coordinate)
            if let self = self, let completion = self.completion{
                completion(currentLocation, error)
                self.stopUpdatingLocation()
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            autCompletion?(false)
        case .authorizedAlways, .authorizedWhenInUse:
            autCompletion?(true)
        @unknown default:
            break
        }
    }
}
