//
//  DateFormatter.swift
//  Weather
//
//  Created by Sebastian Mraz on 24/04/2022.
//

import Foundation

extension DateFormatter {
    
    static let dayFormatter: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "EEEE"
        return dateFormater
    }()
    
}
