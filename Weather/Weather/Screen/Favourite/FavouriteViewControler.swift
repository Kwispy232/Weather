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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        favTableView.reloadData()
    }
    
}

//  MARK: Extensions

extension FavouriteViewControler : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favouriteCell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath)
        let place = FavouriteManager.favouriteManager.favGet(on: indexPath.row)
        favouriteCell.textLabel?.text = place.city
        favouriteCell.detailTextLabel?.text = place.country
        
        return favouriteCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavouriteManager.favouriteManager.favCount()
    }
    
}

extension FavouriteViewControler : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = FavouriteManager.favouriteManager.favGet(on: indexPath.row)
        
        presentWeatherDetail(with: place)
    }
    
    func presentWeatherDetail(with place: Place) {
        let storyboard = UIStoryboard(name: "WeatherDetailViewControler", bundle: nil)
        if let weatherViewControler = storyboard.instantiateViewController(identifier: "WeatherDetailViewControler") as? WeatherDetailViewControler {
            weatherViewControler.shouldUpdateLocation = false
            weatherViewControler.place = place
            
            navigationController?.pushViewController(weatherViewControler, animated: true)
        }
    }
}
