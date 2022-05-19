//
//  SearchVievControler.swift
//  Weather
//
//  Created by Sebastian Mraz on 16/04/2022.
//

import UIKit
import Alamofire

class SearchViewControler : UIViewController {
    
//    MARK: - Outlets
    @IBOutlet weak var tableView : UITableView!
    
//    MARK: - Constants
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let searchManager = SearchManager()

//    MARK: - Variables
    private var places = [Place]()
    
//    MARK: - Lifecycle
    
    /**
     Funkcia sa vykoná pri zobrazení SearchView, volá metódu predka a metódu setupSearchControler
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
    }
    
    /**
     Fukncia viažúca sa k tlačídlu close vykoná animovaný dismiss okna
     
     Parameters:
     -  sender:Any
     */
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /**
     Funkcia nastaví potrebné prvky searchControllera
     */
    func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController?.searchBar.delegate = self
    }
}


//    MARK: - Extensions

extension SearchViewControler : UISearchBarDelegate {
    
    /**
     Fukcia preberie parameter searchText a požiada searchManager o výpis lokácii na základe toho čo je napísané v searchBare pri zmene obsahu searchBaru
     
     Parameters:
     -  searchBar:UISearchBar, searchText:String
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchManager.getlocalSearchResult(from: searchText) { places in
            self.places = places
            self.tableView.reloadData()
        }
    }
}
extension SearchViewControler : UITableViewDataSource {
    /**
     Funkkcia preberie tableView a počet riadkov v sekcii, section a vráti počet riadkov ktoré majú byť v tableView
    
     Parameters:
     -  tableView:UITableView, section:Int
     
     Returns:
     - Int
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    /**
     Funkcia preberá v parametri index aktuálne prezentovanej celly v tableView. Danej celle nastavuje hodnoty a následne ju varacia
     
     Parameters:
     -  tableView: UITableVIew, indexPath:IndexPath
     
     Returns:
     - UITableViewCell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        let place = places[indexPath.row]
        searchCell.textLabel?.text = place.city
        searchCell.detailTextLabel?.text = place.country
        return searchCell
    }
}

extension SearchViewControler: UITableViewDelegate {
    /**
     Funkcia volá funkciu presentWeatherDetailView na základe používateľom zakliknutej celly
     
     Parameters:
     -  tableView:UITableView, indexPath:IndexPath
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        
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
