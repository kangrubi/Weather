//
//  ViewController.swift
//  Weather
//
//  Created by 강루비 on 2022/02/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var cityNameTextField: UITextField!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var weatherDesriptionLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var maxTempLabel: UILabel!
    @IBOutlet var minTempLabel: UILabel!
    @IBOutlet var weatherStackView: UIStackView!
    
    override func viewDidLoad() {
      super.viewDidLoad()
    }

    @IBAction func tapFatchWeatherButton(_ sender: UIButton) {
      if let cityName = self.cityNameTextField.text {
        self.getCurrentWeather(cityName: cityName)
        self.view.endEditing(true)
      }
    }
    
    func configureView(weatherInformation: WeatherInformation) {
      self.cityNameLabel.text = weatherInformation.name
      if let weather = weatherInformation.weather.first {
        self.weatherDesriptionLabel.text = weather.description
      }
      self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))℃"
      self.minTempLabel.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))℃"
      self.maxTempLabel.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))℃"
    }
    
    func showAlert(message: String) {
      let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }

    func getCurrentWeather(cityName: String) {
      guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=aeb4a5d513908e3670fdb54dee182775") else { return }
      let session = URLSession(configuration: .default)
      session.dataTask(with: url) { [weak self] data, response, error in
        let successRange = (200..<300)
        guard let data = data, error == nil else { return }
        let decoder = JSONDecoder()
        if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
          guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
          DispatchQueue.main.async {
            self?.weatherStackView.isHidden = false
            self?.configureView(weatherInformation: weatherInformation)
          }
        } else {
          guard let errorMesaage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
          DispatchQueue.main.async {
            self?.showAlert(message: errorMesaage.message)
          }
        }

      }.resume()
    }
}

