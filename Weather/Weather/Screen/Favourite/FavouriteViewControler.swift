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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.favTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        favTableView.reloadData()
    }
    
    
}
//  MARK: Extensions
extension FavouriteViewControler : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favCell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath)
        let place = FavouriteManager.favouriteManager.favGet(on: indexPath.row)
        favCell.textLabel?.text = place.city
        favCell.detailTextLabel?.text = place.country
        
        return favCell
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
