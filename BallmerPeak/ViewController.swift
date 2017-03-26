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
    
    @IBAction func drinkStepperChanged(_ sender: Any) {
        numDrinksLabel.text = "Number of drinks you drank: \(Int(drinksStepper.value))"
        setAttributedLabelText(label: numDrinksLabel, text: "Number of drinks you drank: \(Int(drinksStepper.value))",
            textToChange: "\(Int(drinksStepper.value))",
            originalFont: helveticaFont(size: 18).thin, newFont: helveticaFont(size: 18).medium, newColor: darkText)
        
        if drinksStepper.value == 10 && showSavage {
            showAlert(self, title: "Savage", message: "", okMessage: "Ok")
            showSavage = false
        }
        
        if drinksStepper.value == 25 && showHospital {
            showAlert(self, title: "Hospital time", message: "Please go to the hospital", okMessage: "Ok")
            showSavage = false
        }
    }
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var weightSlider: UISlider!
    
    @IBAction func weightSliderChanged(_ sender: Any) {
        weightLabel.text = "Weight: \(Int(weightSlider.value)) lbs"
        setAttributedLabelText(label: weightLabel, text: "Weight: \(Int(weightSlider.value)) lbs",
            textToChange: "\(Int(weightSlider.value)) lbs",
            originalFont: helveticaFont(size: 18).thin, newFont: helveticaFont(size: 18).medium, newColor: darkText)
    }
    
    @IBOutlet weak var bacLabel: UILabel!
    
    @IBOutlet weak var bacSlider: UISlider!
    
    @IBAction func bacSliderChanged(_ sender: Any) {

        let val = Double(bacSlider.value).roundTo(places: 4)
        bacLabel.text = ("\(ballmerText()) BAC: \(val) %")
        setAttributedLabelText(label: bacLabel, text: "\(ballmerText()) BAC: \(val) %",
            textToChange: "\(val) %",
            originalFont: helveticaFont(size: 18).thin, newFont: helveticaFont(size: 18).medium, newColor: darkText)
    }
    
    
    // VARIABLES----------------------------------
    
    var isMale = true
    
    let startDate = Date()
    
    var showSavage = true
    var showHospital = true
    
    // OVERRIDE FUNCS----------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.selectedSegmentIndex = 0
        
        calculateButton.addTarget(self, action: #selector(ViewController.calculatePressed), for: .touchUpInside)
        //helpButton.addTarget(self, action: #selector(ViewController.showHelp), for: .touchUpInside)
        
        firstDrinkPicker.countDownDuration = 1
        lastDrinkPicker.countDownDuration = 1
        
        let val = Double(bacSlider.value).roundTo(places: 4)
        setAttributedLabelText(label: bacLabel, text: "\(ballmerText()) BAC: \(val) %",
            textToChange: "\(val) %",
            originalFont: helveticaFont(size: 18).thin, newFont: helveticaFont(size: 18).medium, newColor: darkText)
        
        setAttributedLabelText(label: numDrinksLabel, text: "Number of drinks you drank: \(Int(drinksStepper.value))",
            textToChange: "\(Int(drinksStepper.value))",
            originalFont: helveticaFont(size: 18).thin, newFont: helveticaFont(size: 18).medium, newColor: darkText)
        
        setAttributedLabelText(label: weightLabel, text: "Weight: \(Int(weightSlider.value)) lbs",
            textToChange: "\(Int(weightSlider.value)) lbs",
            originalFont: helveticaFont(size: 18).thin, newFont: helveticaFont(size: 18).medium, newColor: darkText)
        
    }
    
    func ballmerText() -> String {
        return (bacSlider.value > 0.12 && bacSlider.value < 0.14) ? "Ballmer" : "Custom"
    }
    
    
    func calculatePressed() {
        // get input vals
        let numDrinks = drinksStepper.value
        let lbsWeight = Double(weightSlider.value)
        
        let isMale = (segmentedControl.selectedSegmentIndex == 0)
        
        
        let hoursSinceFirst = Double(firstDrinkPicker.countDownDuration/3600)
        let hoursSinceLast = Double(lastDrinkPicker.countDownDuration/3600)
        
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
        let hours = (currBac - Double(bacSlider.value))/0.015
        
        // add in seconds
        let date = startDate.addingTimeInterval(hours * 3600.0)
        
        if date < startDate {
            let startedDrinkingDate = startDate.addingTimeInterval(-(hoursSinceFirst * 3600.0))
            if date < startedDrinkingDate {
                showAlert(self, title: "Warning", message: "You will not reach \(ballmerText()) Peak. \nPlease consume more alcohol", okMessage: "Ok")
                return
            }
            
            showAlert(self, title: "Warning",
                      message: "You have already peaked (\(ballmerText())-wise) at \(date.toShortTimeString()). \nPlease consume more alcohol",
                okMessage: "Ok")
            
            return
            
        }
        
        showAlert(self, title: "\(ballmerText()) Peak Report:",
            message: "Current BAC = \(currBac)\nYou will \(ballmerText()) peak at \(date.toShortTimeString()). At this time, have \(constantDrinks) drinks every hour to maintain your peak",
            okMessage: "Ok")
    }

}

func helveticaFont(size: CGFloat) -> (bold: UIFont, medium: UIFont, light: UIFont, thin: UIFont) {
    let bold = UIFont(name: "HelveticaNeue-Bold", size: size)!
    let medium = UIFont(name: "HelveticaNeue-Medium", size: size)!
    let light = UIFont(name: "HelveticaNeue-Light", size: size)!
    let thin = UIFont(name: "HelveticaNeue-Thin", size: size)!
    
    return (bold, medium, light, thin)
}

func setAttributedLabelText(label: UILabel, text: String, textToChange: String, originalFont: UIFont, newFont: UIFont, newColor: UIColor) {
    let range = (text as NSString).range(of: textToChange)
    let attrString = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: originalFont])
    attrString.setAttributes([NSFontAttributeName: newFont, NSForegroundColorAttributeName: newColor], range: range)
    label.attributedText = attrString
}

func showAlert(_ vc: UIViewController, title: String, message: String, okMessage: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: okMessage, style: UIAlertActionStyle.default, handler: nil))
    
    vc.present(alert, animated: true, completion: nil)
}

let red = UIColor(red: 196.0/255.0, green: 43.0/255.0, blue: 28/255.0, alpha: 1.0)
let darkText = UIColor.darkText


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
