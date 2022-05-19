//
//  SearchManager.swift
//  Weather
//
//  Created by Sebastian Mraz on 17/04/2022.
//

import Foundation
import MapKit

typealias LocalSearchCompletionHandler = (([Place]) -> Void)

class SearchManager: NSObject {

//    MARK: - Constants

    private let searchCompleter = MKLocalSearchCompleter()

//    MARK: - Variables
    
    private var searchCompletion: LocalSearchCompletionHandler?
    
    /**
     Konštruktor volá konštruktor predka a nastaví delegáta a resultt type LocalSearchCompletionHandelera
     */
    override init() {
        super.init()
        
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }

    /**
     Funkcia preberie query a completion a poskytne výsledok vyhľadávania
     
     Parameters:
     -  query:String, completion: @escaping LocalSearchCompletionHandler
     */
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

//    MARK: - Extensions

extension SearchManager: MKLocalSearchCompleterDelegate {
    /**
     Funkcia postupne filtruje text pri písaní používateľa a poskytuje návrhy na základe písaného textu.
     
     Parameters:
     -  completer:MKLocalSearchCompleter
     */
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        let places = completer.results
            .filter { !$0.title.isEmpty }
            .map{ $0.title.components(separatedBy: ",") }
            .filter { $0.count > 1 }
            .map{ Place(city: $0[0], country: $0[1]) }
        searchCompletion?(places)
    }
    
}

