//
//  APIClient.swift
//  SimpleWeatherApp
//
//  Created by Ashan Anuruddika on 7/6/20.
//  Copyright © 2020 Ashan. All rights reserved.
//

import Foundation

class APIClient{
    
    static let shared : APIClient = APIClient()
    
    let appId = "1525c0c5083747c97a425b6cd4c22a17"
    
    let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    func getWeatherDataURL(lat : String , lon : String) -> String {
        return "\(baseURL)?lat=\(lat)&lon=\(lon)&appid=\(appId)"
    }
    
}
