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
    
    @IBOutlet weak var numDrinksInput: UITextField!
    @IBOutlet weak var bodyWeightInput: UITextField!
    
    @IBOutlet weak var firstDrinkInput: UITextField!
    @IBOutlet weak var lastDrinkInput: UITextField!
    
    @IBOutlet weak var calculateButton: UIButton!
    
    
    // VARIABLES----------------------------------
    
    var isMale = true
    
    // OVERRIDE FUNCS----------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.selectedSegmentIndex = 0
        
        calculateButton.addTarget(self, action: #selector(ViewController.calculatePressed), forControlEvents: .TouchUpInside)
    }
    
    func calculatePressed() {
        // get input vals
        if !numDrinksInput.hasText() || !bodyWeightInput.hasText() || !firstDrinkInput.hasText() || !lastDrinkInput.hasText() {
            showAlert(self, title: "Try Again", message: "You left something blank", okMessage: "Sorry")
            return
        }
        
        let numDrinks = Int(numDrinksInput.text!)!
        let lbsWeight = Double(bodyWeightInput.text!)!
        
        let isMale = (segmentedControl.selectedSegmentIndex == 0)
        
        let hoursSinceFirst = Double(firstDrinkInput.text!)!
        let hoursSinceLast = Double(lastDrinkInput.text!)!
        
        if hoursSinceFirst < hoursSinceLast {
            showAlert(self, title: "Try Again", message: "You couldn't have had your last drink before your first drink", okMessage: "Sorry")
            return
        }
        
        calculateBAC(numDrinks, lbsWeight: lbsWeight, isMale: isMale,
                     hoursSinceFirst: hoursSinceFirst, hoursSinceLast: hoursSinceLast)
    }
    
    func calculateBAC(numDrinks: Int, lbsWeight: Double, isMale: Bool, hoursSinceFirst: Double, hoursSinceLast: Double) {
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
        
        calcTime(bac)
    }
    
    // calculate the time it will take to reach the Ballmer peak
    func calcTime(currBac: Double) {
        let hours = (currBac - 0.1337)/0.015
        
        let startDate = NSDate()
        
        // add in seconds
        let date = startDate.dateByAddingTimeInterval(hours * 3600.0)
        
        
        showAlert(self, title: "Ballmer Peak Time:", message: date.toShortTimeString(), okMessage: "Wow thanks!")
    }

}

func showAlert(vc: UIViewController, title: String, message: String, okMessage: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: okMessage, style: UIAlertActionStyle.Default, handler: nil))
    
    vc.presentViewController(alert, animated: true, completion: nil)
}

extension NSDate {
    func hour() -> Int {
        //Get Hour
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: self)
        let hour = components.hour
        
        //Return Hour
        return hour
    }
    
    
    func minute() -> Int {
        //Get Minute
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Minute, fromDate: self)
        let minute = components.minute
        
        //Return Minute
        return minute
    }
    
    func toShortTimeString() -> String {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let timeString = formatter.stringFromDate(self)
        
        //Return Short Time String
        return timeString
    }
}
