//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by Vitaliy on 17.09.2020.
//  Copyright © 2020 Vitaliy Gribko. All rights reserved.
//

import Foundation
import UIKit

struct CurrentWeather {
    var temperature: Double
    var humidity: Double
    var pressure: Double
    var iconCode: String
    
    var sunrise: Date
    var sunset: Date
    
    var state: String
    var city: String
    var country: String
    
    init() {
        temperature = 0
        humidity = 0
        pressure = 0
        iconCode = ""
        
        sunrise = Date()
        sunset = Date()
        
        state = ""
        city = ""
        country = ""
    }
}

extension CurrentWeather {
    var temperatureString: String {
        return "\(Int(temperature))˚C"
    }
    
    var humidityString: String {
        return "\(Int(humidity)) %"
    }
    
    var pressureString: String {
        return "\(Int(pressure)) " + NSLocalizedString("mmHg", comment: "")
    }
    
    var locationString: String {
        guard city.count > 0 else {
            return NSLocalizedString("Error find location", comment: "")
        }
        
        return "\(country), \(state)/\(city)"
    }
}
