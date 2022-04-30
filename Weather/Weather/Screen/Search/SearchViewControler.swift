//
//  SearchVievControler.swift
//  Weather
//
//  Created by Sebastian Mraz on 16/04/2022.
//

import UIKit
import Alamofire

class SearchViewControler : UIViewController {
    
//MARK: - Outlets
    @IBOutlet weak var tableView : UITableView!
    
    
//    MARK: - constants
    private let searchController = UISearchController(searchResultsController: nil)
    private let searchManager = SearchManager()

    //MARK: - Variables
    private var places = [Place]()
    
//    MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController?.searchBar.delegate = self
    }
}


//MARK: - extensions

extension SearchViewControler : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchManager.getlocalSearchResult(from: searchText) { places in
            self.places = places
            self.tableView.reloadData()
        }
    }
}
extension SearchViewControler : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        let place = places[indexPath.row]
        searchCell.textLabel?.text = place.city
        searchCell.detailTextLabel?.text = place.country
        return searchCell
    }
}

extension SearchViewControler: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        
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
