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
import SwiftyJSON

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
    
    private func getweatherWithAlamofire(lat : String,long : String) {
        
        guard let url = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, lon: long)) else
        {
            
            print("cloud not from url")
            
            return
            
        }
        
        let parameter : Parameters = [:]
        
        AF.request(url, method: HTTPMethod.get, parameters: parameter, encoding: URLEncoding.default, headers: ["Accept" : "application/json"], interceptor: .none).responseJSON { [ weak self] (response) in
            
            guard let strongSelf = self else {return }
            
            guard let data = response.data else {return }
            
            DispatchQueue.main.async {
                strongSelf.parseJSONWithCodable(data: data)
            }
            
            /*
            if let jsonData = response.value as? [String : Any]{
                
                DispatchQueue.main.async {
                    
                    //strongSelf.parseJSONManually(data: jsonData)
                    
                    strongSelf.parseJSONWithSwiftyJSON(data: jsonData)
                    
                }
            }
            */
            
        }
        
        /*
        AF.request(url).responseJSON { (response) in
            if let jsonData = response.value as? [String:Any]{
                print(jsonData)
            }
        }
        */
    }
    
    private func parseJSONManually(data : [String : Any]) {
        
        if let cityName = data["name"] as? String {
            
            cityNameLabel.text = "\(cityName)"
            
        }
        
        if let main = data["main"] as? [String : Any] {
            
            if let temp = main["temp"] as? Double {
                
                temprutureLabel.text = "\(Int(temp))"
                
            }
            
            if let humidity = main["humidity"] as? Int{
                
                humidityLabel.text = "\(humidity)"
            }
        }
        
        if let wind = data["wind"] as? [String : Any] {
            
            if let windSpeed = wind["speed"] as? Double {
                
                windSpeedLabel.text = "\(windSpeed)"
                
            }
        }
    }
    
    private func parseJSONWithCodable(data : Data){
        
        do {
            
            let weatherObject = try JSONDecoder().decode(WeatherModel.self, from: data)
            
            cityNameLabel.text = weatherObject.name
            
            temprutureLabel.text = "\(Int(weatherObject.temp))"
            
            humidityLabel.text = "\(weatherObject.humidity)"
            
            windSpeedLabel.text = "\(weatherObject.windSpeed)"
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    private func parseJSONWithSwiftyJSON(data : [String : Any]){
        
        let jsonData = JSON(data)
        
        if let cityName = jsonData["name"].string {
            
            cityNameLabel.text = "\(cityName)"
            
        }
        
        if let temp = jsonData["main"]["temp"].double {
            
            temprutureLabel.text = "\(Int(temp))"
            
        }
        
        if let huminity = jsonData["main"]["humidity"].double {
            
            humidityLabel.text = "\(huminity)"
            
        }
        
        if let windSpeed = jsonData["wind"]["speed"].double {
            
            windSpeedLabel.text = "\(windSpeed)"
            
        }
    }
    
    private func getWeatherWithURLSession(lat : String,long : String) {
        
        guard let weatherURL = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, lon: long)) else {return}
        
        let task = URLSession.shared.dataTask(with: weatherURL) { (data, response, error) in
            
            if let sessionError = error{
                
                print(sessionError.localizedDescription)
                
                return
            }
            
            guard let data = data else {
                print("Error data")
                return
    
            }
            
            do {
                
                guard let weatherData = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                    
                    print("there was an error converting data into JSON.")
                    
                    return
                }
                
                print(weatherData)
            } catch {
                print("error")
            }
        }
        
        task.resume()
        
    }
}

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let locationDegrees = locations.first{
            
            let latitude = String(locationDegrees.coordinate.latitude)
            
            let longitude = String(locationDegrees.coordinate.longitude)
            
            print("Latitude : \(latitude) and Longitude : \(longitude)")
            
            //getWeatherWithURLSession(lat: latitude, long: longitude)
            
            getweatherWithAlamofire(lat: latitude, long: longitude)
        
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
