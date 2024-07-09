//
//  ViewController.swift
//  ScientificCalculatorUIKit-001
//
//  Created by humanoid on 22.06.2024.
//

import UIKit
import Darwin

class ViewController: UIViewController {
    
    var currentNumber: Double = 0
    var operations: [String] = []
    var performingOperation = false
    var labelText: String = ""
    var completeExpression: String = ""
    
    @IBOutlet weak var displayLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLabel.text = "0"
        
        
    }
    
    @IBAction func piButtonPressed(_ sender: UIButton) {
        let piValue = Double.pi
        let piValStr = String(format: "%.6f", piValue)
        
        completeExpression += piValStr
        labelText = piValStr
        displayLabel.text = completeExpression
    }
    
    @IBAction func eButtonPressed(_ sender: UIButton) {
        let eValue = M_E
        let eValStr: String = String(format: "%.6f", eValue)
        
        completeExpression += eValStr
        labelText = eValStr
        displayLabel.text = completeExpression
    }
    
    
    @IBAction func digitButtonPressed(_ sender: UIButton) {
        print("operations: ", operations)
        print("performingOperation: ", performingOperation)
        print("labelText: ", labelText)
        print("completeExpression: ", completeExpression)
        if let digit = sender.titleLabel?.text {
            if performingOperation {
                labelText = digit
                performingOperation = false
            } else {
                if labelText == "0" || displayLabel.text == "Error" {
                    labelText = digit
                } else {
                    labelText += digit
                }
            }
            completeExpression += digit
            displayLabel.text = completeExpression
        }
    }
    
    @IBAction func commaButtonPressed(_ sender: UIButton) {
        if !labelText.contains(".") {
            if labelText.isEmpty {
                labelText = "0."
            } else {
                labelText += "."
            }
        completeExpression += "."
        displayLabel.text = completeExpression
        }
    }
    
    
    @IBAction func delButtonPressed(_ sender: UIButton) {
        if !labelText.isEmpty && labelText != "0" {
            labelText.removeLast()
            completeExpression.removeLast()
            currentNumber = Double(labelText) ?? 0
            displayLabel.text = completeExpression.isEmpty ? "0" : completeExpression

        }
    }
    
    @IBAction func acButtonPressed(_ sender: UIButton) {
        labelText = "0"
        completeExpression = ""
        displayLabel.text = labelText
        operations.removeAll()
        currentNumber = 0
        performingOperation = false
    }
    
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        if let number = Double(labelText) {
            operations.append(formatResult(number))
        }
        if let operation = sender.titleLabel?.text {
            operations.append(operation)
            completeExpression += operation
        }
        labelText = ""
        performingOperation = true
        displayLabel.text = completeExpression
    }
    
    @IBAction func equalsButtonPressed(_ sender: UIButton) {
        operations.removeAll()
        var tmp = ""
        var isNegativeNumber = false

        for i in completeExpression {
            
            if "+-x/^".contains(i) {
                if !tmp.isEmpty {
                    operations.append(tmp)
                    tmp = ""
                }
                operations.append(String(i))
            }
            else if i == "(" {
                if !tmp.isEmpty {
                    operations.append(tmp)
                    tmp = ""
                }
                operations.append("(")
            }
            else if i == ")" {
                if !tmp.isEmpty {
                    operations.append(tmp)
                    tmp = ""
                }
                operations.append(")")
            }
            else {
                tmp += String(i)
            }
        }

        // Eğer döngü bittiğinde tmp'de hala bir değer varsa, operations'a ekle
        if !tmp.isEmpty {
            operations.append(tmp)
        }
        print("equals button opeartions list: ", operations)
        
        print(completeExpression)

        let rpnExpression = convertToRPN(operations)
        let result = evaluateRPN(rpnExpression)
        displayLabel.text = result == nil ? "Error" : formatResult(result!)
        operations.removeAll()
        if let res = result {
            labelText = formatResult(res)
            completeExpression = labelText
        } else {
            labelText = "0"
            completeExpression = labelText
        }
    }
    
    @IBAction func parenthesisButtonPressed(_ sender: UIButton) {
        if let parenthesis = sender.titleLabel?.text {
            operations.append(parenthesis)
            labelText += parenthesis
            completeExpression += parenthesis
            displayLabel.text = completeExpression
        }
    }
    
    @IBAction func percentButtonPressed(_ sender: UIButton) {
        
        if let number = Double(labelText) {
            let percentValue = number / 100.0
            labelText = String(format: "%.6f", percentValue)
            completeExpression = labelText
            displayLabel.text = labelText
        } else {
            displayLabel.text = "Error"
        }
        
    }
    
    
    @IBAction func factorialButtonPressed(_ sender: UIButton) {
        if let number = Int(labelText), number >= 0 {
            var result = 1
            for i in 1...number {
                result *= i
            }
            labelText = String(result)
            completeExpression = labelText
            displayLabel.text = labelText
        } else {
            displayLabel.text = "Error"
        }
    }
    
    
    func convertToRPN(_ tokens: [String]) -> [String] {
        var output: [String] = []
        var ops: [String] = []
        
        for token in tokens {
            if let _ = Double(token) {
                output.append(token)
            } else if token == "(" {
                ops.append(token)
            } else if token == ")" {
                while !ops.isEmpty && ops.last != "(" {
                    output.append(ops.removeLast())
                }
                if !ops.isEmpty {
                    ops.removeLast()
                }
            } else if "+-x/^".contains(token) {
                while !ops.isEmpty && hasPrecedence(token, ops.last!) {
                    output.append(ops.removeLast())
                }
                ops.append(token)
            }
        }
        
        while !ops.isEmpty {
            output.append(ops.removeLast())
        }
        
        return output
    }
    
    func evaluateRPN(_ tokens: [String]) -> Double? {
        var stack: [Double] = []
        
        for token in tokens {
            if let number = Double(token) {
                stack.append(number)
            } else if "+-x/^".contains(token) {
                if stack.count < 2 {
                    return nil
                }
                let b = stack.removeLast()
                let a = stack.removeLast()
                guard let result = applyOp(token, b, a) else {
                    return nil
                }
                stack.append(result)
            }
        }
        
        return stack.last
    }
    
    func applyOp(_ op: String, _ b: Double, _ a: Double) -> Double? {
        switch op {
        case "+":
            return a + b
        case "-":
            return a - b
        case "x":
            return a * b
        case "/":
            return b != 0 ? a / b : nil
        case "^":
            return pow(a, b)
        default:
            return nil
        }
    }
    
    func hasPrecedence(_ op1: String, _ op2: String) -> Bool {
        if op2 == "(" || op2 == ")" {
            return false
        }
        if (op1 == "x" || op1 == "/" || op1 == "^") && (op2 == "+" || op2 == "-") {
            return false
        } else {
            return true
        }
    }

    func formatResult(_ result: Double) -> String {
        if result.isNaN || result.isInfinite {
            return "Error"
        } else if result.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", result)
        } else {
            return String(format: "%.6f", result)
        }
    }

    
    @IBAction func sinButtonPressed(_ sender: UIButton) {
        if let number = Double(displayLabel.text!) {
            currentNumber = number
            displayLabel.text = formatResult(sin(currentNumber))
            completeExpression = formatResult(sin(number))
            labelText = completeExpression
        }
    }

    @IBAction func cosButtonPressed(_ sender: UIButton) {
        if let number = Double(displayLabel.text!) {
            currentNumber = number
            displayLabel.text = formatResult(cos(currentNumber))
            completeExpression = formatResult(cos(number))
            labelText = completeExpression

        }
    }

    @IBAction func tanButtonPressed(_ sender: UIButton) {
        if let number = Double(displayLabel.text!) {
            currentNumber = number
            displayLabel.text = formatResult(tan(currentNumber))
            completeExpression = formatResult(tan(number))
            labelText = completeExpression
        }
    }

    @IBAction func logButtonPressed(_ sender: UIButton) {
        if let number = Double(displayLabel.text!), number > 0 {
            currentNumber = number
            displayLabel.text = formatResult(log10(currentNumber))
            completeExpression = formatResult(log10(number))
            labelText = completeExpression
        } else {
            displayLabel.text = "Error"
        }
    }

    @IBAction func lnButtonPressed(_ sender: UIButton) {
        if let number = Double(displayLabel.text!), number > 0 {
            currentNumber = number
            displayLabel.text = formatResult(log(currentNumber))
            completeExpression = formatResult(log(number))
            labelText = completeExpression
        } else {
            displayLabel.text = "Error"
        }
    }

    @IBAction func sqrtButtonPressed(_ sender: UIButton) {
        if let number = Double(displayLabel.text!), number >= 0 {
            currentNumber = number
            displayLabel.text = formatResult(sqrt(currentNumber))
            completeExpression = formatResult(sqrt(number))
            labelText = completeExpression
        } else {
            displayLabel.text = "Error"
        }
    }

    @IBAction func powerButtonPressed(_ sender: UIButton) {
        if performingOperation {
            equalsButtonPressed(sender) // Önceki işlemi tamamla
        }
        
        if let number = Double(displayLabel.text!) {
            currentNumber = number // İlk işlemse currentNumber'ı ayarla
            labelText += "^"
            completeExpression += "^"
            displayLabel.text = completeExpression
            operations.append(formatResult(currentNumber))
            operations.append("^")
            performingOperation = true
        } else {
            displayLabel.text = "Error"
            acButtonPressed(sender)
        }
    }
    

}
