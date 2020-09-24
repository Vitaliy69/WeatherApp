//
//  ViewController.swift
//  WeatherApp
//
//  Created by Vitaliy on 15.09.2020.
//  Copyright © 2020 Vitaliy Gribko. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imageBackground: UIImageView!
    
    @IBOutlet weak var refreshButton: UIButton!
    
    let weatherKey = "insert_APIKEY_here"
    let locationKey = "insert_APIKEY_here"
    
    let locationManager = CLLocationManager()
    
    var coordinares: CLLocationCoordinate2D?
    var wasUpdateAtStartup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .white
        }
        
        setIconsForLabels()
        
        checkLocationService()
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        if CLLocationManager.locationServicesEnabled() == true {
            let authStatus = CLLocationManager.authorizationStatus()
            
            if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
                updateWeather()
            } else {
                showAllert(title: NSLocalizedString("Error find location", comment: ""), message: NSLocalizedString("Unable to find your location.", comment: ""))
            }
        } else {
            showAllert(title: NSLocalizedString("Error find location", comment: ""), message: NSLocalizedString("Please enable location service in the settings.", comment: ""))
        }
    }
    
    /// Check location service
    private func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            
            let authStatus = CLLocationManager.authorizationStatus()
            
            if authStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            if authStatus == .denied || authStatus == .restricted {
                showAllert(title: NSLocalizedString("Error find location", comment: ""), message: NSLocalizedString("Unable to find your location.", comment: ""))
            }
        } else {
            showAllert(title: NSLocalizedString("Error find location", comment: ""), message: NSLocalizedString("Please enable location service in the settings.", comment: ""))
        }
    }
    
    /// Request new weather data from server
    private func updateWeather() {
        guard Reachability.isConnectedToNetwork() == true else {
            showAllert(title: NSLocalizedString("Internet connection error", comment: ""), message: NSLocalizedString("Check your internet connection settings.", comment: ""))
            return
        }
        
        if let location = coordinares {
            activityIndicator.startAnimating()
            refreshButton.isEnabled = false
            
            let wm = WeatherManager()
            let coordinate = CLLocationCoordinate2D.init(latitude: location.latitude, longitude: location.longitude)
            wm.getWeather(weatherKey: weatherKey, locationKey: locationKey, coordinate: coordinate) {
                (weather, error) in
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.refreshButton.isEnabled = true
                    
                    if error != nil {
                        self.showAllert(title: NSLocalizedString("Error getting weather", comment: ""), message: error!.localizedDescription)
                    } else {
                        self.updateUIWith(currentWeather: weather)
                    }
                }
            }
        }
    }
    
    /// Show allert
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert detail description
    private func showAllert(title: String, message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    /// Udpate UI with new weather data
    /// - Parameter currentWeather: new weather data
    private func updateUIWith(currentWeather: CurrentWeather) {
        let dependentIcons = ["clear", "mostly_clear", "partly_cloudy"]
        var iconCode = currentWeather.iconCode
        
        let date = Date()
        
        switch date {
            case let d where d > currentWeather.sunrise && d < currentWeather.sunset:
                imageBackground.image = UIImage(named: "Afternoon")
                if dependentIcons.contains(currentWeather.iconCode) {
                    iconCode.append("_day")
                }
            default:
                imageBackground.image = UIImage(named: "Night")
                if dependentIcons.contains(currentWeather.iconCode) {
                    iconCode.append("_night")
                }
        }
        
        locationLabel.text = currentWeather.locationString
        
        let weatherIconManager = WeatherIconManager.init(rawValue: iconCode)
        imageView.image = weatherIconManager.image
        
        pressureLabel.text = currentWeather.pressureString
        humidityLabel.text = currentWeather.humidityString
        temperatureLabel.text = currentWeather.temperatureString
        
        setIconsForLabels()
    }
    
    /// Add icons leading icons for pressure/humidity and temperature labels
    private func setIconsForLabels() {        
        if let pressureImage = UIImage(named: "pressure") {
            pressureLabel.addLeading(image: pressureImage, size: CGSize(width: 12, height: 12))
        }
        
        if let humidityImage = UIImage(named: "humidity") {
            humidityLabel.addLeading(image: humidityImage, size: CGSize(width: 12, height: 12))
        }
        
        if let temperatureImage = UIImage(named: "temperature") {
            temperatureLabel.addLeading(image: temperatureImage, size: CGSize(width: 30, height: 30))
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        coordinares = location.coordinate
        
        if !wasUpdateAtStartup {
            wasUpdateAtStartup = true
            updateWeather()
        }
    }
}
