//
//  WeatherIconManager.swift
//  WeatherApp
//
//  Created by Vitaliy on 17.09.2020.
//  Copyright © 2020 Vitaliy Gribko. All rights reserved.
//

import Foundation
import UIKit

enum WeatherIconManager: String {
    case RainHeavy = "rain_heavy"
    case Rain = "rain"
    case RainLight = "rain_light"
    case FreezingRainHeavy = "freezing_rain_heavy"
    case FreezingRain = "freezing_rain"
    case FreezingRainLight = "freezing_rain_light"
    case FreezingDrizzle = "freezing_drizzle"
    case Drizzle = "drizzle"
    case IcePelletsHeavy = "ice_pellets_heavy"
    case IcePellets = "ice_pellets"
    case IcePelletsLight = "ice_pellets_light"
    case SnowHeavy = "snow_heavy"
    case Snow = "snow"
    case SnowLight = "snow_light"
    case Flurries = "flurries"
    case Tstorm = "tstorm"
    case FogLight = "fog_light"
    case Fog = "fog"
    case Cloudy = "cloudy"
    case MostlyCloudy = "mostly_cloudy"
    case PartlyCloudyNight = "partly_cloudy_night"
    case PartlyCloudyDay = "partly_cloudy_day"
    case MostlyClearNight = "mostly_clear_night"
    case MostlyClearDay = "mostly_clear_day"
    case ClearNight = "clear_night"
    case ClearDay = "clear_day"
    
    init(rawValue: String) {
        switch rawValue {
            case "rain_heavy": self = .RainHeavy
            case "rain": self = .Rain
            case "rain_light": self = .RainLight
            case "freezing_rain_heavy": self = .FreezingRainLight
            case "freezing_rain": self = .FreezingRain
            case "freezing_rain_light": self = .FreezingRainLight
            case "freezing_drizzle": self = .FreezingDrizzle
            case "drizzle": self = .Drizzle
            case "ice_pellets_heavy": self = .IcePelletsHeavy
            case "ice_pellets": self = .IcePellets
            case "ice_pellets_light": self = .IcePelletsLight
            case "snow_heavy": self = .SnowHeavy
            case "snow": self = .Snow
            case "snow_light": self = .SnowLight
            case "flurries": self = .Flurries
            case "tstorm": self = .Tstorm
            case "fog_light": self = .FogLight
            case "fog": self = .Fog
            case "cloudy": self = .Cloudy
            case "mostly_cloudy": self = .MostlyCloudy
            case "partly_cloudy_night": self = .PartlyCloudyNight
            case "partly_cloudy_day": self = .PartlyCloudyDay
            case "mostly_clear_night": self = .MostlyClearNight
            case "mostly_clear_day": self = .MostlyClearDay
            case "clear_night": self = .ClearNight
            case "clear_day": self = .ClearDay
            default: self = .ClearDay
        }
    }
}

extension WeatherIconManager {
    var image: UIImage {
        return UIImage(named: self.rawValue)!
    }
}
