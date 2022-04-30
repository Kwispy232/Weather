//
//  MapViewControler.swift
//  Weather
//
//  Created by Sebastian Mraz on 22/04/2022.
//

import MapKit
import UIKit

class MapViewControler : UIViewController {
    @IBOutlet var mapView: MKMapView!
    private var geokoder = CLGeocoder()

    var currLoc : CurrentLocation?
    
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
        geokoder.reverseGeocodeLocation(clLocatioin) { [weak self] placemarks , error in guard let placemark = placemarks?.first, let city = placemark.locality, let country = placemark.country, let country = placemark.country, error == nil else {
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
