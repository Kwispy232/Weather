import UIKit

 @main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

//
//  TabbarViewControler.swift
//  Weather
//
//  Created by Sebastian Mraz on 26/04/2022.
//

import Foundation

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

//
//  MapViewControler.swift
//  Weather
//
//  Created by Sebastian Mraz on 22/04/2022.
//

import MapKit

class MapViewControler : UIViewController {
    
//    MARK: Variables

    @IBOutlet var mapView: MKMapView!
    private var geocoder = CLGeocoder()
    var currLoc : CurrentLocation?

//    MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
    }

    @IBAction func longTouch(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coord = mapView.convert(location, toCoordinateFrom: mapView)
        let anot = MKPointAnnotation()
        
        let clLocatioin = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        geocoder.reverseGeocodeLocation(clLocatioin) { [weak self] placemarks , error in
            guard let placemark = placemarks?.first,
            let city = placemark.locality,
            let country = placemark.country,
            error == nil else {
                return
            }
            self?.currLoc = CurrentLocation(city: city, country: country, coordinate: clLocatioin.coordinate)
            anot.coordinate = coord
            anot.title = city
            anot.subtitle = country
        }
    
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(anot)
    }
}

//    MARK: Extensions

extension MapViewControler: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotationTitle = view.annotation?.title, let anotationSubTitle = view.annotation?.subtitle
        else {
            return
        }
        let place = Place(city: annotationTitle!, country: anotationSubTitle!)
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

//
//  SearchVievControler.swift
//  Weather
//
//  Created by Sebastian Mraz on 16/04/2022.
//

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


//MARK: - Extensions

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

//
//  ViewController.swift
//  Weather
//
//  Created by Sebastian Mraz on 25/03/2022.
//

import CoreLocation
import Charts

class WeatherDetailViewControler: UIViewController {

//    MARK: Outlets
    
    @IBOutlet var date: UILabel!
    @IBOutlet var feelsLike: UILabel!
    @IBOutlet var temperature: UILabel!
    @IBOutlet var weather: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var favMark: UIBarButtonItem!
    @IBOutlet var chartView: LineChartView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var errorMessLabel: UILabel!
    
//    MARK: Var
    
    var refreshControl = UIRefreshControl()
    var place: Place?
    var location : CurrentLocation?
    var shouldUpdateLocation = true
    var days = [Daily]()
    var hours = [CurrentWeather]()
    
//    MARK: Buttons
    
    @IBAction func buttonReload(_ sender: Any) {
        loadData()
    }
    
    @IBAction func manageFav(_ sender: Any) {
        guard let place = place else {
            return
        }
        if FavouriteManager.favouriteManager.exists(place) {
            FavouriteManager.favouriteManager.removeFav(with: Place(city: place.city, country: place.country))
        } else {
            FavouriteManager.favouriteManager.addFav(with: Place(city: place.city, country: place.country))
        }
        setButtonImage()
    }
        
//    MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.isHidden = true
        activityIndicator.startAnimating()

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let currentDate = Date()
        date.text = formatter.string(from: currentDate)
    
           
        tableView.refreshControl = UIRefreshControl()
        
        LocationManager.shared.onAuthorizationChange { [weak self] authorized in
            guard let self = self else {
                return
            }
            
            if self.shouldUpdateLocation {
                self.getLocation()
            } else {
                self.getLocationFromPlace()
            }
        }
        
        if LocationManager.shared.denied {
             presentAlert()
        } else {
            if shouldUpdateLocation {
                getLocation()
            } else {
                getLocationFromPlace()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setButtonImage()
    }
    
//    MARK: DataLoad
    
    func loadData() {
        guard let location = self.location else {
            return
        }

        RequestManager.shared.getWeatherData(for: location.coordinate) {[weak self] response in
            guard let self = self else {
                return
            }
            
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false
            switch response {
            case .success(let weatherData):
                
                self.setUpView(with: weatherData.current)
                
                self.days = weatherData.daily
                self.hours = weatherData.hourly
                self.setGraph()
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                
            case .failure(let error):
                self.errorMessLabel.text = error.localizedDescription
                self.tableView.isHidden = true
                self.emptyView.isHidden = false
            }
        }

    }
    
    func getLocation() {
        LocationManager.shared.getLocation { [weak self] location, error in
            guard let self = self else { return }
            
            self.tableView.refreshControl?.addTarget(self, action: #selector(self.refreshLocation), for: .valueChanged)
            
            if let error = error {
                
            } else if let location = location {
                self.location = location
                self.loadData()
                self.locationLabel.text = location.city
                self.place = Place(city: location.city, country: location.country)
            }
        }
    }
    
    func getLocationFromPlace() {
        LocationManager.shared.stopUpdatingLocation()
        if let place = place {
            locationLabel.text = place.city
            self.setButtonImage()
            
            LocationManager.shared.getLocationFromPlace(where: place) { [weak self] location, error in
                guard let self = self else {
                    return
                }
                self.tableView.refreshControl?.addTarget(self, action: #selector(self.noRefreshLocation), for: .valueChanged)
                
                if let location = location {
                    self.location = location
                    self.loadData()
                    self.locationLabel.text = location.city
                    self.place = Place(city: location.city, country: location.country)
                }
            }
        }
    }
    
    @objc func refreshLocation() {
        LocationManager.shared.startUpdatingLocation()
        shouldUpdateLocation = true
        loadData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    @objc func noRefreshLocation() {
        self.tableView.refreshControl?.endRefreshing()
    }
    
//    MARK: UI Setup
    
    func setUpView(with currentWeather: CurrentWeather) {
        setButtonImage()
        temperature.text = "\(Int(currentWeather.temperature))°C"
        feelsLike.text = "Feels like ".localizable() + "\(Int(currentWeather.feelsLike))°C"
        if let first = currentWeather.weather.first {
            weather.text = "\(first.desc.rawValue)".localizable()
        }
        tableView.register(UINib(nibName: "WeatherCell", bundle: nil), forCellReuseIdentifier: "WeatherCell")
        tableView.rowHeight = 50
    }
    
    
    func presentAlert() {
        var alertControler : UIAlertController?
        
        if UIDevice.current.model.contains("iPad") {
            alertControler = UIAlertController(title: "Localization is denied".localizable(), message: "If you want to continue turn on localization.".localizable(), preferredStyle: .alert)
        } else {
            alertControler = UIAlertController(title: "Localization is denied".localizable(), message: "If you want to continue turn on localization.".localizable(), preferredStyle: .actionSheet)
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else {
                    return
                }
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
        if let alertControler = alertControler {
            alertControler.addAction(okAction)
            alertControler.addAction(settingsAction)
            present(alertControler, animated: true)
        }
    }
    
    
    func setButtonImage() {
        if let place = place {
            favMark.image = FavouriteManager.favouriteManager.exists(place) ? UIImage(systemName: "star.fill"): UIImage(systemName: "star")
        }
    }
    
    func setGraph() {
        var lineChart = [ChartDataEntry]()
        let calendar = Calendar.current
        var date = Date()
        let actualHour = calendar.component(.hour, from: date)
        var moreThan23 = false
        
        if hours.count > 0 {
            for i in 1...24 - actualHour {
                if calendar.component(.hour, from: hours[i].date) == 23 {
                    moreThan23 = true
                }
                let hour = calendar.component(.hour, from: hours[i].date) == 0 && moreThan23 ? 24 : calendar.component(.hour, from: hours[i].date)
                let temp = hours[i].temperature
                let val = ChartDataEntry(x:Double(hour), y: temp)
                lineChart.append(val)
            }
        }

        
        let line = LineChartDataSet(entries: lineChart, label: "Hourly temperature in °C".localizable())
        line.colors = [NSUIColor .systemBlue]
        let data = LineChartData()
        data.addDataSet(line)
        chartView.data = data
    }
}

//    MARK: Extensions

extension WeatherDetailViewControler: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell") as? WeatherCell
        else {
            return UITableViewCell()
        }
        cell.setDailyCell(with: days[indexPath.row])
        return cell
    }
    
}

extension WeatherDetailViewControler {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        loadData()
    }
}

extension String {
    func localizable() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}

//
//  WeatherCell.swift
//  Weather
//
//  Created by Sebastian Mraz on 07/04/2022.
//

import UIKit

class WeatherCell: UITableViewCell {

    @IBOutlet var img: UIImageView!
    @IBOutlet var day: UILabel!
    @IBOutlet var pop: UILabel!
    @IBOutlet var temp: UILabel!
    
    func setDailyCell(with day: Daily) {
        self.day.text = DateFormatter.dayFormatter.string(from: day.date)
        if self.traitCollection.userInterfaceStyle == .dark {
            self.img.image = day.weather.first?.image?.withRenderingMode(.alwaysOriginal)
        } else {
            self.img.image = day.weather.first?.image?.withRenderingMode(.automatic)
        }
        self.pop.text = String(Int(day.pop * 100)) + "%"
        self.temp.text = "\(Int(day.temp.day))°C"
                
    }
    
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let weatherResponse = try? newJSONDecoder().decode(WeatherResponse.self, from: jsonData)

// MARK: - WeatherResponse
struct WeatherResponse: Decodable {
    let current: CurrentWeather
    let hourly: [CurrentWeather]
    let daily: [Daily]

    enum CodingKeys: String, CodingKey {
        case current, hourly, daily
    }
}

// MARK: - Current
struct CurrentWeather: Decodable {
    let date: Date
    let temperature: Double
    let feelsLike: Double
    let weather: [Weather]

    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case temperature = "temp"
        case feelsLike = "feels_like"
        case weather
    }
}

// MARK: - Weather
struct Weather: Decodable {
    let desc: Main
    let icon: String
    
    enum CodingKeys: String, CodingKey {
        case desc = "main"
        case icon
    }
    
    var image: UIImage? {
        switch icon {
        case "03d":
            return UIImage(systemName: "cloud.fill")
        case "04d":
            return UIImage(systemName: "cloud.fill")
        case "11d":
            return UIImage(systemName: "cloud.bolt.fill")
        case "09d":
            return UIImage(systemName: "cloud.drizzle.fill")
        case "10d":
            return UIImage(systemName: "cloud.rain.fill")
        case "13d":
            return UIImage(systemName: "cloud.snow.fill")
        case "50d":
            return UIImage(systemName: "smoke.fill")
        case "01d":
            return UIImage(systemName: "sun.max.fill")
        case "02d":
            return UIImage(systemName: "cloud.sun.fill")
        default:
            return UIImage(systemName: "moon.circle.fill")
        }
    }
}

enum Main: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
}

// MARK: - Daily
struct Daily: Decodable {
    let date: Date
    let temp: Temp
    let weather: [Weather]
    let pop: Double

    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case temp
        case weather, pop
    }
}

// MARK: - Temp
struct Temp: Codable {
    let day: Double
}


//
//  WeatherRequest.swift
//  Weather
//
//  Created by Sebastian Mraz on 24/04/2022.
//

struct WeatherRequest: Encodable {
    let lat: String
    let lon: String
    let exclude: String
    let appid: String
    let units: String
    
}

//
//  DateFormatter.swift
//  Weather
//
//  Created by Sebastian Mraz on 24/04/2022.
//

extension DateFormatter {
    
    static let dayFormatter: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "EEEE"
        return dateFormater
    }()
    
}

//
//  File.swift
//  Weather
//
//  Created by Sebastian Mraz on 06/04/2022.
//

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

//
//  SearchManager.swift
//  Weather
//
//  Created by Sebastian Mraz on 17/04/2022.
//

typealias LocalSearchCompletionHandler = (([Place]) -> Void)

class SearchManager: NSObject {

//    MARK: - constants

    private let searchCompleter = MKLocalSearchCompleter()

    //    MARK: - variables
    
    private var searchCompletion: LocalSearchCompletionHandler?
    
    override init() {
        super.init()
        
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }

    func getlocalSearchResult(from query: String, completion: @escaping LocalSearchCompletionHandler) {
        self.searchCompletion = completion
        
        if query.isEmpty {
            completion([])
        }
        searchCompleter.queryFragment = query
    }
    
}

struct Place : Codable {
    
    let city: String
    let country: String
}

extension SearchManager: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        let places = completer.results
            .filter { !$0.title.isEmpty }
            .map{ $0.title.components(separatedBy: ",") }
            .filter { $0.count > 1 }
            .map{ Place(city: $0[0], country: $0[1]) }
        searchCompletion?(places)
    }
    
}

//
//  RequestManager.swift
//  Weather
//
//  Created by Sebastian Mraz on 24/04/2022.
//

struct RequestManager {
    static let shared = RequestManager()
    
    func getWeatherData(for coordinates :CLLocationCoordinate2D, completion: @escaping (Result<WeatherResponse, AFError>) -> Void) {
        let request = WeatherRequest(lat: "\(coordinates.latitude)", lon: "\(coordinates.longitude)", exclude: "minutely", appid: "b9944ed07816bcbc5572cb754deafb21", units: "metric")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        AF.request("https://api.openweathermap.org/data/2.5/onecall", method: .get, parameters: request)
            .validate()
            .responseDecodable(of: WeatherResponse.self, decoder: decoder) { completion($0.result) }
    }
    
    
}

//
//  FavouriteManager.swift
//  Weather
//
//  Created by Sebastian Mraz on 26/04/2022.
//

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
