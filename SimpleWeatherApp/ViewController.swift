//
//  ViewController.swift
//  SimpleWeatherApp
//
//  Created by Ashan Anuruddika on 7/6/20.
//  Copyright © 2020 Ashan. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var cityNameLabel: UILabel!
    
    @IBOutlet weak var temprutureLabel: UILabel!
    
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestLocation()
    }
}

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let locationDegrees = locations.first{
            
            let latitude = locationDegrees.coordinate.latitude
            
            let longitude = locationDegrees.coordinate.longitude
            
            print("Latitude : \(latitude) and Longitude : \(longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
        case .notDetermined:
            
            locationManager.requestWhenInUseAuthorization()
            
            break
            
        case .authorizedAlways,.authorizedWhenInUse:
            
            locationManager.requestLocation()
            
            break
            
        case .denied,.restricted:
            
            let alert = UIAlertController(title: "Location Access Disabled.", message: "Weather App needs your location to give a weather forecast.Open your settings to change authorization.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(cancelAction)
            
            let openSettingsAction = UIAlertAction(title: "Open", style: .default) { (action) in
                
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            alert.addAction(openSettingsAction)
            
            self.present(alert, animated: true, completion: nil)
            
            break
        default:
            break
        }
    }
}
