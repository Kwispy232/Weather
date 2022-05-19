//
//  ViewController.swift
//  Weather
//
//  Created by Sebastian Mraz on 25/03/2022.
//

import UIKit
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
    /**
     Funkcia sprístupňujúca používateľovi možnosť reloadu
     
     Parameters:
     -  sender:Any
     */
    @IBAction func buttonReload(_ sender: Any) {
        loadData()
    }
    
    /**
     Funkcia sprístupňuje používateľovi možnosť pridať alebo odobrať lokácii do obľúbených
     
     Parameters:
     -  sender:Any
     */
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
    
    /**
     Funkcia sa zavolá na načítanie obrazovky WeatherDetailView volá metódu predka a volá všetky metódy potrebné na nastavenie dát a grafických prvkov obrazovky
     */
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
    
    /**
     Funkcia sa zavolá pri zovrazení WeatherDetailView a nastaví obrázok tlačidla obľúbené
     */
    override func viewDidAppear(_ animated: Bool) {
        setButtonImage()
    }
    
//    MARK: DataLoad
    /**
     Funkcia volá metódu RequesrManagera ktorý vykoná API call nastaví grafické prvky a naplní dáta z API callu do atribútov
     */
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
    
    /**
    Funckia požiada LocationManagera o zistenie aktuálnej lokácue používateľa, výsledkami práce LocationManagera naplní atribúty
     */
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
    
    /**
     Funkcia požiada LocationManagera o dáta zvolenej polohy, výsledky práce LocationManagera naplní do atribútov
     */
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
    
    /**
     OBJC funkcia volaná pri refreshi vykonanom používateľom nastaví LocationManagera a načíta data
     */
    @objc func refreshLocation() {
        LocationManager.shared.startUpdatingLocation()
        shouldUpdateLocation = true
        loadData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    /**
     OBJC funkcia volaná pri refreshi vykonanom používateľom.
     */
    @objc func noRefreshLocation() {
        self.tableView.refreshControl?.endRefreshing()
    }
    
//    MARK: UI Setup
    
    /**
     Funkcia nastaví grafické prvky WeatherDetailView dátami prebratými v parametri
     
     Parameters:
     -  currentWeather:CurrentWeather
     */
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
    
    /**
     Funkcia používatelovi prezentuje alert v prípade že sú jeho lokalizačné služby neprístupné, pouźívateľovi je umožnené prekliknutie do nastavení a povolenie lokalizačných služieb
     */
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
    
    /**
     Funkicia nastavuje grafickú reprezentáciu obrázku na základe toho či je daná lokáciua uložená v obľúbených alebo nie
     */
    func setButtonImage() {
        if let place = place {
            favMark.image = FavouriteManager.favouriteManager.exists(place) ? UIImage(systemName: "star.fill"): UIImage(systemName: "star")
        }
    }
    
    /**
     Funkcia prezentuje dáta o hodinovej teplote získané z API callu prostredníctvom grafu
     */
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
    /**
     Funkcia volá funkciu presentWeatherDetailView na základe používateľom zakliknutej celly
     
     Parameters:
     -  tableView:UITableView, indexPath:IndexPath
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    /**
     Funkcia preberá v parametri index aktuálne prezentovanej celly v tableView. Danej celle nastavuje hodnoty a následne ju varacia
     
     Parameters:
     -  tableView: UITableVIew, indexPath:IndexPath
     
     Returns:
     - UITableViewCell
     */
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
    /**
     Funkcia sa zavolá na zmenu Farebného režimu zariadenia a je implementovaná z dôvodu potreby zmeny niektorých grafických prvkov pre jednotlivé režimy
     
     Parameters:
     -  previousTraitCollection: UITraitCollection
     */
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        loadData()
    }
}

extension String {
    /**
     Funkcia umožní jednotlivým strignom používať preklad do slovenčiny, ak je definovaný
     */
    func localizable() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}

