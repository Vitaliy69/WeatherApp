//
//  WeaherManager.swift
//  WeatherApp
//
//  Created by Vitaliy on 22.09.2020.
//  Copyright © 2020 Vitaliy Gribko. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class WeatherManager {
    
    let httpTimeOut: TimeInterval = 15
    let deltaTimeout: TimeInterval = 2
    
    /// Get new weather data from server
    /// - Parameters:
    ///   - weatherKey: API key for climacell service
    ///   - locationKey: API key for opencagedata service
    ///   - coordinate: Coordinates for location whose data is requested
    ///   - completion: Completion handler
    func getWeather(weatherKey: String, locationKey: String, coordinate: CLLocationCoordinate2D, completion: @escaping (CurrentWeather, Error?) -> Void) {
        var currentWeather = CurrentWeather()
        var globalError: Error?
        
        var urlStrings = ["https://api.climacell.co/v3/weather/realtime?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&unit_system=si&fields=temp%2Chumidity%2Cbaro_pressure%3AmmHg%2Csunrise%2Csunset%2Cweather_code&apikey=\(weatherKey)",
                          "https://api.opencagedata.com/geocode/v1/json?key=\(locationKey)&q=\(coordinate.latitude)%2C\(coordinate.longitude)"]
        
        switch Bundle.main.preferredLocalizations.first {
            case "ru":
                urlStrings[1].append("&language=ru")
            default:
                urlStrings[1].append("&language=en")
        }
        
        let dataGroup = DispatchGroup()
        let dataSemaphore = DispatchSemaphore(value: 1)
        
        DispatchQueue.concurrentPerform(iterations: urlStrings.count) { (index) in
            if let url = URL(string: urlStrings[index]) {
                dataGroup.enter()
                
                DispatchQueue.global(qos: .utility).async {
                    self.getData(url: url, timeout: self.httpTimeOut) { (data, error) in
                        if let weatherData = data {
                            dataSemaphore.wait()
                            globalError = self.processData(dataType: DataType.init(rawValue: index)!, data: weatherData, currentWeather: &currentWeather)
                            dataSemaphore.signal()
                        }
                        
                        if let error = error {
                            globalError = error
                        }
                        
                        dataGroup.leave()
                    }
                }
                
            }
        }
        
        dataGroup.notifyWait(target: .main, timeout: DispatchTime.now() + .seconds(Int(httpTimeOut + deltaTimeout))) {
            completion(currentWeather, globalError)
        }
    }
    
    private enum DataType: Int {
        case weather
        case location
    }
    
    /// Parse new weather data
    /// - Parameters:
    ///   - dataType: Tyoe of data
    ///   - data: Raw data
    ///   - currentWeather: Returned weather data
    /// - Returns: Error
    private func processData(dataType: DataType, data: Data, currentWeather: inout CurrentWeather) -> NSError? {
        let decoder = JSONDecoder()
        
        switch dataType {
            case .weather:
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                do {
                    let weather = try decoder.decode(Weather.self, from: data)
                    
                    currentWeather.temperature = weather.temperature.value
                    currentWeather.humidity = weather.humidity.value
                    currentWeather.pressure = weather.pressure.value
                    currentWeather.iconCode = weather.code.value
                    currentWeather.sunrise = weather.sunrise.value
                    currentWeather.sunset = weather.sunset.value
                    // let seconds = TimeZone.current.secondsFromGMT()
                } catch let error as NSError {
                    return error
                }
                
            case .location:
                do {
                    let location = try decoder.decode(Location.self, from: data)
                    switch location.results.first {
                        case .components(let components):
                            currentWeather.state = components.state
                            currentWeather.country = components.country
                            currentWeather.city = components.city
                        case .none:
                            break
                    }
                    
                } catch let error as NSError {
                    return error
                }
        }
        
        return nil
    }
    
    /// Request data from server
    /// - Parameters:
    ///   - url: URL
    ///   - timeout: Request timeout in seconds
    ///   - completion: Comletion closure
    private func getData(url: URL, timeout: TimeInterval, completion: @escaping (Data?, Error?) -> Void) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForResource = TimeInterval(timeout)
        let session = URLSession(configuration: sessionConfiguration)
        
        let requset = URLRequest(url: url)
        let dataTask = session.dataTask(with: requset) { (data, response, error) in
            
            if let data = data, let httpRespose = response as? HTTPURLResponse {
                if httpRespose.statusCode == 200 {
                    completion(data, nil)
                } else {
                    let httpError = NSError(domain: Bundle.main.bundleIdentifier ?? "WeatherApp", code: httpRespose.statusCode, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Unexpected HTTP status response", comment: "")])
                    completion(nil, httpError)
                }
            } else {
                completion(nil, error)
            }
        }
        
        dataTask.resume()
    }
}
