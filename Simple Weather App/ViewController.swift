//
//  ViewController.swift
//  Simple Weather App
//
//  Created by KENNETH VACZI on 9/2/16.
//  Copyright © 2016 KENNETH VACZI. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var weatherDetailsLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBAction func queryWeather(_ sender: UIButton) {
        
        guard let locationText = locationTextField.text as NSString? else {
            // user has not entered a string in location text field
            return
        }
        
        let urlTextForLocation = locationText.replacingOccurrences(of: " ", with: "-")
        
        guard let url = URL(string: "http://www.weather-forecast.com/locations/\(urlTextForLocation)/forecasts/latest") else {
            // invalid URL
            return
        }

        let request = NSMutableURLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard error == nil else {
                // Request returned an error
                print("error in request:")
                print(error)
                return
            }

            if let unwrappedData = data {
                let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                
                DispatchQueue.main.async {
                    var weatherSummary = ""
                    if let unwrappedDataString = dataString {
                        let firstCut = unwrappedDataString.components(separatedBy: "3 Day Weather Forecast Summary")
                        if firstCut.count > 1 {
                            let secondCut = firstCut[1].components(separatedBy: "<span class=\"phrase\">")
                            if secondCut.count > 1 {
                                weatherSummary = secondCut[1].components(separatedBy: "</span>")[0]
                            }
                        }
                    }
                    if weatherSummary != "" {
                        self.weatherDetailsLabel.text = self.convertFromHTMLString(weatherSummary)
                    } else {
                        self.weatherDetailsLabel.text = "Sorry, we were unable to retrieve weather for that location..."
                    }
                }
            }

        }
        task.resume()
    }
    
    func convertFromHTMLString (_ HTMLString: String) -> String {
        let encodedData = HTMLString.data(using: String.Encoding.utf8)!
        let attributedOptions : [String : AnyObject] = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue]
        do {
            return try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil).string
        } catch let error as NSError {
            print(error.localizedDescription)
            return  ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

