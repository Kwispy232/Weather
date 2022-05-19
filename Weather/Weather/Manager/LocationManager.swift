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
    
    /**
     Funkcia preberie completion a spustí získavanie lokácie používateľa
     
     Parameters:
     -complation: @escaping(CurrentLocation?, Error?)->Void
     */
    func getLocation(complation: @escaping(CurrentLocation?, Error?)->Void) {
        self.completion = complation
        startUpdatingLocation()
        requestWhenInUseAuthorization()
        delegate = self
    }

    /**
     Funkcia preberie completion a spustí získavanie lokácie pre parameter place na základe používateľovej voľby
     
     Parameters:
     -place:Place, complation: @escaping(CurrentLocation?, Error?)->Void
     */
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
    
    /**
     Funkcia priradí hodnotu parametra do atribútu autCompletion s ktorým buďe LocationManager ďalej pracovať
     
     Parameters:
     -completion : ((Bool?)->Void?)
     */
    func onAuthorizationChange(completion : ((Bool?)->Void)?) {
        self.autCompletion = completion
    }
    
}

//  MARK: Extensions
extension LocationManager : CLLocationManagerDelegate {
    
    /**
     Funkcia sa vykoná pri zmene lokácie používateľa, či už poďla jeho aktuálnej polohy alebo voľby. Funkcia v tele nastaví hodnoty completion.
     
     Parameters:
     -  manager:CLLocationManager, locations:[CLLocation]
     */
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
    
    /**
     Funkcia sa zavolá na pri zmene autorizácie lokalizačných služieb používateľa a nastaví hodnotu authCompletion
     
     Parameters:
     -  manager:CLLocationManager
     */
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
