//
//  FavouriteManager.swift
//  Weather
//
//  Created by Sebastian Mraz on 26/04/2022.
//

import Foundation

class FavouriteManager {
    static let favouriteManager = FavouriteManager()
    /**
     Atribút reprezentuje databázu používateľských dát v pamäti zariadenia do ktorej sa vkladajú páry - kľúč, dáta
     */
    private let userDefaults = UserDefaults.standard
    private var favourites = [Place]()
    
    /**
     Konštruktor zavolá metódu reloadFav
     */
    init() {
        reloadFav()
    }
    
    /**
     Funkcia preberie place a pridá ho do kontajnera favourites
     
     Parameters:
     -  place:Place
     */
    func addFav(with place : Place) {
        if (!exists(place)) {
            favourites.append(place)
            saveFav()
        }
    }
    
    /**
     Funkcia odstráni selectedPlace z kontajnera favourites
     
     Parameters:
     -  selectedPlace:Place
     */
    func removeFav(with selectedPlace : Place) {
        let index = favourites.firstIndex {
            $0.city == selectedPlace.city && $0.country == selectedPlace.country
        }
        
        if let index = index {
            favourites.remove(at: index)
            saveFav()
        }
    }
    
    /**
     Funckia overuje existenciu daného place v kontajneri favourites
     
     Parameters:
     -place:Place
     
     Returns:
     -  Bool
     */
    func exists(_ place: Place) -> Bool {
        return favourites.firstIndex { $0.city == place.city && $0.country == place.country } != nil
    }
    
    /**
     Funkcia zakóduje dáta z kontajnera favourites na to aby bolo možné ich uložit do userDefaults a uloží ich
     */
    func saveFav() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(favourites)
            self.userDefaults.set(data, forKey: "places")
        } catch {
            print("error")
        }
    }
    
    /**
     Funkcia dekóduje dáta uožené v userDefaults a priradí ich do kontajnera
     */
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
    
    /**
     Funkcia vráti počet prvkov uložených v kontrajneri favourites
     
     Returns:
     -  Int
     */
    func favCount() -> Int {
        return favourites.count
    }
    
    /**
     Funkcia preberie id a vráti place na danom id kontajnera favourites
     
     Parameters:
     -  id:Int
    
     Returns:
     -  Place
     */
    func favGet(on id: Int) -> Place {
        return favourites[id]
    }
}
