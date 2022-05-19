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
    
    /**
     Funckia preberie dáta v parametry day a nastavý svoje grafikcé prvky
     
     Parameters:
     -  day:Daily
     */
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
