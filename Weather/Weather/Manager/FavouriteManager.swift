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
    private var favourites = [Place]()
    
    init() {
        reloadFav()
    }
    
    func addFav(with place : Place) {
        favourites.append(place)
        saveFav()
    }
    
    func removeFav(with selectedPlace : Place) {
        let index = favourites.firstIndex {
            $0.city == selectedPlace.city && $0.country == selectedPlace.country
        }
        
        if let index = index {
            favourites.remove(at: index)
            saveFav()
        }
    }
    
    func exists(_ place: Place) -> Bool {
        return favourites.firstIndex { $0.city == place.city && $0.country == place.country } != nil
    }
    
    func saveFav() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(favourites)
            self.userDefaults.set(data, forKey: "places")
        } catch {
            print("error")
        }
    }
    
    func reloadFav() {
        let decoder = JSONDecoder()
        let data = userDefaults.data(forKey: "places")
        if let data = data {
            do {
                try favourites = decoder.decode([Place].self, from: data)
            } catch {
                print("error")
            }
        }
    }
    
    func favCount() -> Int {
        return favourites.count
    }
    
    func favGet(on id: Int) -> Place {
        return favourites[id]
    }
}
