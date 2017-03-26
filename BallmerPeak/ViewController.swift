//
//  ViewController.swift
//  BallmerPeak
//
//  Created by Neil Sekhon on 3/25/17.
//  Copyright © 2017 Totem LC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // EXTRA: calculate food eaten, medications taken, tolerance
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var numDrinksLabel: UILabel!
    
    @IBOutlet weak var drinksStepper: UIStepper!
    
    @IBOutlet weak var firstDrinkPicker: UIDatePicker!
    @IBOutlet weak var lastDrinkPicker: UIDatePicker!
    
    
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    @IBAction func drinkStepperChanged(_ sender: Any) {
        numDrinksLabel.text = (drinksStepper.value == 1) ? "1 drink" : "\(drinksStepper.value) drinks"
        
        if drinksStepper.value == 10 && showSavage {
            showAlert(self, title: "Savage", message: "", okMessage: "I know")
            showSavage = false
        }
    }
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var weightSlider: UISlider!
    
    @IBAction func weightSliderChanged(_ sender: Any) {
        weightLabel.text = "Weight: \(weightSlider.value) lbs"
    }
    
    
    // VARIABLES----------------------------------
    
    var isMale = true
    
    let startDate = Date()
    
    var showSavage = true
    
    // OVERRIDE FUNCS----------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.selectedSegmentIndex = 0
        
        calculateButton.addTarget(self, action: #selector(ViewController.calculatePressed), for: .touchUpInside)
        helpButton.addTarget(self, action: #selector(ViewController.showHelp), for: .touchUpInside)
    }
    
    // todo: show savage alert if more than 10 drinks
    
    func showHelp() {
        let imageView = UIImageView(frame: CGRect(x: 50, y: 100, width: 200, height: 100))
        imageView.image = UIImage(named: "just_drinks_for_web3")
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
        alert.view.addSubview(imageView)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func calculatePressed() {
        // get input vals
        /*
        if  {
            showAlert(self, title: "Try Again", message: "You left something blank", okMessage: "Sorry")
            return
        }
        */
        
        let numDrinks = drinksStepper.value
        let lbsWeight = Double(weightSlider.value)
        
        let isMale = (segmentedControl.selectedSegmentIndex == 0)
        
        
        let hoursSinceFirst = Double(firstDrinkPicker.date.minutes(from: startDate) * 60)
        let hoursSinceLast = Double(lastDrinkPicker.date.minutes(from: startDate) * 60)
        
        if hoursSinceFirst < hoursSinceLast {
            showAlert(self, title: "Try Again", message: "You couldn't have had your last drink before your first drink", okMessage: "Sorry")
            return
        }
        
        calculateBAC(numDrinks, lbsWeight: lbsWeight, isMale: isMale,
                     hoursSinceFirst: Double(hoursSinceFirst), hoursSinceLast: Double(hoursSinceLast))
    }
    
    func calculateBAC(_ numDrinks: Double, lbsWeight: Double, isMale: Bool, hoursSinceFirst: Double, hoursSinceLast: Double) {
        // liver takes 1
        // BAC[percentage] = (alch[grams] / (bodyWeight[grams] * r)) * 100 - (hours * 0.015)
        
        // convert lbs to grams
        let bodyWeight = lbsWeight * 453.592
        
        // convert # standard drinks to grams of alcohol
        let alch = Double(numDrinks * 14)
        
        let r = isMale ? 0.68 : 0.55
        
        // estimate hours passed since drinks (take avg of start and end time)
        let hoursPassed = (hoursSinceFirst + hoursSinceLast)/2
        
        let bac = (alch / (bodyWeight * r)) * 100 - (hoursPassed * 0.015)
        
        let numDrinksForConstantBAC = (0.015/100 * r * bodyWeight) / 14
        
        calcTime(bac, hoursSinceFirst: hoursSinceFirst, constantDrinks: numDrinksForConstantBAC.roundTo(places: 3))
    }
    
    // calculate the time it will take to reach the Ballmer peak
    func calcTime(_ currBac: Double, hoursSinceFirst: Double, constantDrinks: Double) {
        let hours = (currBac - 0.1337)/0.015
        
        // add in seconds
        let date = startDate.addingTimeInterval(hours * 3600.0)
        
        if date < startDate {
            let startedDrinkingDate = startDate.addingTimeInterval(-(hoursSinceFirst * 3600.0))
            if date < startedDrinkingDate {
                showAlert(self, title: "Warning", message: "You will not reach Ballmer Peak, please consume more alcohol", okMessage: "Ok")
                return
            }
            
            showAlert(self, title: "Warning", message: "You have already peaked (Ballmer-wise), please consume more alcohol", okMessage: "Ok")
            
        }
        
        showAlert(self, title: "Ballmer Peak Report:",
            message: "You will Ballmer peak at \(date.toShortTimeString()). At this time, have \(constantDrinks) drinks every hour to maintain your peak",
            okMessage: "Wow thanks!")
    }

}

func showAlert(_ vc: UIViewController, title: String, message: String, okMessage: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: okMessage, style: UIAlertActionStyle.default, handler: nil))
    
    vc.present(alert, animated: true, completion: nil)
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Date {
    func hour() -> Int {
        //Get Hour
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: self)
        let hour = components.hour
        
        //Return Hour
        return hour!
    }
    
    func minute() -> Int {
        //Get Minute
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.minute, from: self)
        let minute = components.minute
        
        //Return Minute
        return minute!
    }
    
    func toShortTimeString() -> String {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: self)
        
        //Return Short Time String
        return timeString
    }
    
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
}
