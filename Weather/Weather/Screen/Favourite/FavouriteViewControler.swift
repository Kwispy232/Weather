//
//  TabbarViewControler.swift
//  Weather
//
//  Created by Sebastian Mraz on 26/04/2022.
//

import Foundation
import UIKit

class FavouriteViewControler : UIViewController {
    
    static let favViewControler = FavouriteViewControler()
    @IBOutlet var favTableView: UITableView!

//  MARK: Lifecycle
    /**
     Fukncia ktorása volá v momente zobrazenie viewu
 
     Paremeters:
     - ako parameter preberá bool hodnotu o tom ci má byť prezentovanie animované alebo nie
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        favTableView.reloadData()
    }
    
}

//  MARK: Extensions

extension FavouriteViewControler : UITableViewDataSource {
    /**
     Funkcia preberá v parametri index aktuálne prezentovanej celly v tableView. Danej celle nastavuje hodnoty a následne ju varacia
     
     Parameters:
     -  tableView: UITableVIew, indexPath:IndexPath
     
     Returns:
     - UITableViewCell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favouriteCell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath)
        let place = FavouriteManager.favouriteManager.favGet(on: indexPath.row)
        favouriteCell.textLabel?.text = place.city
        favouriteCell.detailTextLabel?.text = place.country
        
        return favouriteCell
    }
    
    /**
     Funkkcia preberie tableView a počet riadkov v sekcii, section a vráti počet riadkov ktoré majú byť v tableView
    
     Parameters:
     -  tableView:UITableView, section:Int
     
     Returns:
     - Int
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavouriteManager.favouriteManager.favCount()
    }
    
}

extension FavouriteViewControler : UITableViewDelegate {
    
    /**
     Funkcia volá funkciu presentWeatherDetailView na základe používateľom zakliknutej celly
     
     Parameters:
     -  tableView:UITableView, indexPath:IndexPath
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = FavouriteManager.favouriteManager.favGet(on: indexPath.row)
        
        presentWeatherDetail(with: place)
    }
    
    /**
     Fukncia preberie ako parameter miesto a prezentuje WeatherDetailView pre v parametri prebrate miesto
     
     Parameters:
     - place:Place
     */
    func presentWeatherDetail(with place: Place) {
        let storyboard = UIStoryboard(name: "WeatherDetailViewControler", bundle: nil)
        if let weatherViewControler = storyboard.instantiateViewController(identifier: "WeatherDetailViewControler") as? WeatherDetailViewControler {
            weatherViewControler.shouldUpdateLocation = false
            weatherViewControler.place = place
            
            navigationController?.pushViewController(weatherViewControler, animated: true)
        }
    }
}
