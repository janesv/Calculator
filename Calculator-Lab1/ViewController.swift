//
//  ViewController.swift
//  Calculator-Lab1
//
//  Created by Sviridova Evgenia on 15.09.17.
//  Copyright © 2017 Sviridova Evgenia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var userInTheMiddleOfTyping = false
    private var commaDisplayed = false
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text! = brain.formatter(newValue)
        }
    }
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var operationSequence: UILabel!
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
        operationSequence.text! = brain.description
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display.text!
        if userInTheMiddleOfTyping {
            if digit == "," {
                if commaDisplayed {
                    display.text = textCurrentlyInDisplay
                } else {
                    display.text = textCurrentlyInDisplay + "."
                    commaDisplayed = true
                }
            } else {
                    display.text = textCurrentlyInDisplay + digit
            }
        } else {
            if digit == "," {
                display.text = "0."
                commaDisplayed = true
            } else {
                display.text = digit
                commaDisplayed = false
            }
        }
        userInTheMiddleOfTyping = true
        if (textCurrentlyInDisplay == "0.0" || textCurrentlyInDisplay == "0") && digit == "0" {
            display.text = textCurrentlyInDisplay
            userInTheMiddleOfTyping = false
        }
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

