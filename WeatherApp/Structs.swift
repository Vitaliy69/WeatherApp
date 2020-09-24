//
//  Structs.swift
//  WeatherApp
//
//  Created by Vitaliy on 23.09.2020.
//  Copyright © 2020 Vitaliy Gribko. All rights reserved.
//

import Foundation

struct Weather: Decodable, Hashable {
    let lat: Double
    let lon: Double
    
    let temperature: Datas
    let pressure: Datas
    let code: Code
    let humidity: Datas
    
    let sunrise: Timestamp // UTC
    let sunset: Timestamp // UTC
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case temperature = "temp"
        case pressure = "baro_pressure"
        case code = "weather_code"
        case humidity
        case sunrise
        case sunset
    }
    
    struct Datas: Decodable, Hashable {
        let value: Double
        let units: String
    }
    
    struct Code: Decodable, Hashable {
        let value: String
    }
    
    struct Timestamp: Decodable, Hashable {
        let value: Date
    }
}

struct Location: Decodable, Hashable {
    let results: [Results]
    
    enum Results: Decodable, Hashable {
        enum DecodingError: Error {
            case wrongJSON
        }
        
        case components(Components)
        
        enum CodingKeys: String, CodingKey {
            case components = "components"
        }
        
        struct Components: Decodable, Hashable {
            let city: String
            let country: String
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            switch container.allKeys.first {
                case .components:
                    let value = try container.decode(Components.self, forKey: .components)
                    self = .components(value)
                case .none:
                    throw DecodingError.wrongJSON
            }
        }
    }
}
