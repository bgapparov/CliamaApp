//
//  WeatherManager.swift
//  Clima
//
//  Created by Baiaman Gapparov on 7/19/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weeatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=0c573f6fec7671f37f5eb0d0271f7a6f&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weeatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weeatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in

        if error != nil {
            self.delegate?.didFailWithError(error: error!)
            return
        }
        
        if let safeData = data {
          if let weather = self.parseJson(safeData){
            self.delegate?.didUpdateWeather(self, weather:weather)
            }
        }
    }
             task.resume()
        }
    }
    
     func parseJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
          let decodeData = try  decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        }catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
    
}
