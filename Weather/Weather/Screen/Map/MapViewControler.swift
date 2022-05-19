//
//  MapViewControler.swift
//  Weather
//
//  Created by Sebastian Mraz on 22/04/2022.
//

import MapKit
import UIKit

class MapViewControler : UIViewController {
    
//    MARK: Variables

    @IBOutlet var mapView: MKMapView!
    private var geocoder = CLGeocoder()
    var currLoc : CurrentLocation?

//    MARK: Lifecycle
    /**
    Fukncia preberie parameter animated a zavola funkciu viewDidApear predka a varesetuje všetky anotations
     
    Parametes:
     -  animated:Bool
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.removeAnnotations(mapView.annotations)
    }

    /**
     Fukcia zabezpečuje položenie anotation na mapu v mieste dlhého podržania pouvateľom
     
     Parameters:
     -  sender:UILongPressGestureRecognizer
     */
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
    /**
     Fukcia zabezpečuje vykonanie akcie na stlačenie položenej anotation.
     
     Parameters:
     -  mapView:MKMapView, view:MKAnnotationView
     */
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotationTitle = view.annotation?.title, let anotationSubTitle = view.annotation?.subtitle
        else {
            return
        }
        let place = Place(city: annotationTitle!, country: anotationSubTitle!)
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
