//
//  FavouriteManager.swift
//  Weather
//
//  Created by Sebastian Mraz on 26/04/2022.
//

import Foundation

class FavouriteManager {
    static let favouriteManager = FavouriteManager()
    
    private let userDefaults = UserDefaults.standard
    private var favourits : [String]
    
    init() {
        favourits = self.userDefaults.object(forKey: "places") as? [String] ?? []
    }
    
    func addFav(with place : Place) {
        favourits.append(place.city + "/" + place.country)
        saveFav()
    }
    
    func removeFav(with place : Place) {
        var id = -1
        for i in 0..<favourits.count {
            let placeInfo = favourits[i].components(separatedBy: "/")
            let city = placeInfo[0]
            let country = placeInfo[1]
            if city == place.city && country == place.country  {
                id = i
            }
        }
        if id > -1 {
            favourits.remove(at: id)
            saveFav()
        }
    }
    
    func exists(_ place: Place) -> Bool {
        var id = -1
        for i in 0..<favourits.count {
            let placeInfo = favourits[i].components(separatedBy: "/")
            let city = placeInfo[0]
            let country = placeInfo[1]
            if city == place.city && country == place.country  {
                id = i
            }
        }

        return id != -1
    }
    
    func saveFav() {
        self.userDefaults.set(favourits, forKey: "places")
    }
    
    func reloadFav() {
        favourits = self.userDefaults.object(forKey: "places") as? [String] ?? []
    }
    
    func favCount() -> Int {
        return favourits.count
    }
    
    func favGet(on id: Int) -> Place {
        let placeInfo = favourits[id].components(separatedBy: "/")
        return Place(city: placeInfo[0], country: placeInfo[1])
    }
}
