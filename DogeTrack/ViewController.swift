//
//  ViewController.swift
//  DogeTrack
//
//  Created by Jakub Minkiewicz on 26/11/2018.
//  Copyright © 2018 Jakub Minkiewicz/lolltd. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    //Outlets elements on storyboard
    @IBOutlet weak var lastRefresh: UILabel!
    @IBOutlet weak var priceTextFIeld: UITextField!
//    @IBOutlet weak var priceChange1hText: UIButton!
    @IBOutlet weak var priceChange24hText: UIButton!
//    @IBOutlet weak var priceChange7dText: UIButton!
    @IBOutlet weak var Picker: UIPickerView!
    @IBOutlet weak var outputButtonText: UIButton!
    
    //Button copies result into user's clipboard and displays notification
    @IBAction func outputButtonCopy(_ sender: Any) {
        var copyHolder = outputButtonText.titleLabel?.text
        copyHolder?.removeLast(4)
        UIPasteboard.general.string = copyHolder
        showBanner(text: "Copied", type: .success, duration: 1)
    }
    
    //Price format switch - changes between 8 and 2 decimal points
    @IBAction func formatSwitch(_ sender: UISwitch) {
        if(sender.isOn) {
            formatPrice = "%.2f"
            getDogePrice(row: currentCurrency)
        } else {
            formatPrice = "%.8f"
            getDogePrice(row: currentCurrency)
        }
    }

    @IBAction func priceChange1hCopy(_ sender: Any) {
        let copyHolder = priceChange1hText.titleLabel?.text
        UIPasteboard.general.string = copyHolder
        showBanner(text: "Copied", type: .success, duration: 1)
    }
    @IBAction func priceChange24hCopy(_ sender: Any) {
        let copyHolder = priceChange24hText.titleLabel?.text
        UIPasteboard.general.string = copyHolder
        showBanner(text: "Copied", type: .success, duration: 1)
    }
    @IBAction func priceChange7dCopy(_ sender: Any) {
        let copyHolder = priceChange7dText.titleLabel?.text
        UIPasteboard.general.string = copyHolder
        showBanner(text: "Copied", type: .success, duration: 1)
    }
    
    @IBAction func refreshButton(_ sender: UIButton) {
        getDogePrice(row: currentCurrency)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  //if desired
        dogeAmount = Double(priceTextFIeld.text!)!
        getDogePrice(row: currentCurrency)
        return true
    }
    
    // How may coloums in picker?
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //How many rows in the array (as many items (count) as the array of items
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayCurrency.count
    }
    
    // Fills the picker with the items in the array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //and you return this value basically
        return arrayCurrency[row]
    }
    
    //This will execute every time the picker is scrolled to a new row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Sets the currentCurrency is the value of row, which is the index of the item on show in the array currencyArray
        currentCurrency = row
        //Fires the getDogePrice fucntions and passes the index of the item to do JSON magic
        getDogePrice(row: row)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dogeAmount = Double(priceTextFIeld.text!)!
        getDogePrice(row: currentCurrency)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    //The API url, this will be combied with the arrayCurrency currency code to form the entire API URL.
    let apiURL = "https://api.coingecko.com/api/v3/simple/price?ids=dogecoin&vs_currencies="
    let apiURL2 = "&include_24hr_change=true"
    //This is the link for the history request, need to do a seperate JSON call for these
    // https://api.coingecko.com/api/v3/coins/dogecoin/market_chart?vs_currency=gbp&days=7
    //Self explaintonary
    let arrayCurrency = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RUB","SEK","SGD","USD","ZAR"]
    //Keeps track of the currenct currency
    var currentCurrency = 0
    //Modukates the format so that a user can change it later
    var formatPrice = "%.2f"
    var dogeAmount = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outputButtonText.titleLabel?.adjustsFontSizeToFitWidth = true
        getDogePrice(row: 0)
        dogeAmount = Double(priceTextFIeld.text!)!
    }
    
    //This function preforms a JSON request and dumps the JSON data into a temporary store. It is then passed to updatePrice
    func getDogePrice(row: Int){
        //Puts the base URL and currency code togethor into the complete API URL to be used for JSON
        let finalURL = apiURL + arrayCurrency[row] + apiURL2
        
        //The Alamofire function - this basically grabs the API file and stores it in dogeJSON
        Alamofire.request(finalURL, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let dogeJSON : JSON = JSON(response.result.value!)
                    self.updatePrice(json: dogeJSON, row: row)
                } else {
                    self.outputButtonText.setTitle("....", for: .normal)
                    self.showBanner(text: "Error connecting to API", type: .danger , duration: 5)
                }
            }
    }
    
    //A JSON Parser, extracts the price from the json store and formats it, then displays it by updating the label text
    func updatePrice(json : JSON, row : Int) {
        
        //checks if the JSON has the specific piece of data required, if not gives error
        if let tempResult = json["dogecoin"][arrayCurrency[row].lowercased()].double {
            
            
            //Temp disabled
//            if let tempResult1h = json["data", "quotes", arrayCurrency[row], "percent_change_1h"].double{
//                if(tempResult1h > 0.00){
//                    priceChange1hText.setTitleColor(UIColor(red:0.20, green:1.0, blue:0.20, alpha:1.0), for: .normal)
//                } else {
//                    priceChange1hText.setTitleColor(.red, for: .normal)
//                }
//                priceChange1hText.setTitle("\(tempResult1h)%", for: .normal)
//            }
            
            if let tempResult24h = json["dogecoin"][arrayCurrency[row].lowercased() + "_24h_change"].double{
                if(tempResult24h > 0.00){
                    priceChange24hText.setTitleColor(UIColor(red:0.20, green:1.0, blue:0.20, alpha:1.0), for: .normal)
                } else {
                    priceChange24hText.setTitleColor(.red, for: .normal)
                }
                priceChange24hText.setTitle(String(format: "%.2f", tempResult24h) + "%", for: .normal)
            }
            
            //Temp disabled
//            if let tempResult7d = json["data", "quotes", arrayCurrency[row], "percent_change_7d"].double{
//                if(tempResult7d > 0.00){
//                    priceChange7dText.setTitleColor(UIColor(red:0.20, green:1.0, blue:0.20, alpha:1.0), for: .normal)
//                } else {
//                    priceChange7dText.setTitleColor(.red, for: .normal)
//                }
//                priceChange7dText.setTitle("\(tempResult7d)%", for: .normal)
//            }
            
            let temphold = tempResult * dogeAmount
            let tempout = String(format: formatPrice, temphold)
            outputButtonText.setTitle(tempout + " " + arrayCurrency[row], for: .normal)
            
            let date = Date()
            let calender = Calendar.current
            let hour = String(calender.component(.hour, from: date))
            let minute = String(calender.component(.minute, from: date))
            let seconds = String(calender.component(.second, from: date))
            lastRefresh.text = ("\(hour):\(minute):\(seconds)")
            showBanner(text: "Refresh Successful", type: .info, duration: 1)
        }
        else {
            showBanner(text: "Error formating JSON", type: .warning, duration: 2)
            print("2")
        }
    }
    
    //Banner controller, takes in the text type and duration and displays a banner.
    func showBanner(text: String, type: BannerStyle, duration: Double){
        let banner = StatusBarNotificationBanner(title: text, style: type)
        banner.haptic = .medium
        banner.show()
        NotificationBannerQueue.default.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            banner.dismiss()
        }
    }
    
}

