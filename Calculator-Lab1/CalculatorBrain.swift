//
//  CalculatorBrain.swift
//  Calculator-Lab1
//
//  Created by Sviridova Evgenia on 27.09.17.
//  Copyright © 2017 Sviridova Evgenia. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var accumulator = 0.0
    private var lastOperation : LastOperation = .Clear
    private var sequence = [String]()
    private var internalProgram = [AnyObject]()
    private let dots = "..."
    private var pending: PendingBinaryOperationInfo?
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                }
            }
        }
    }
    
    private var operation: Dictionary<String, Operation> = [
        "R": Operation.Random(drand48),
        "pi": Operation.Constant(.pi),
        "e": Operation.Constant(M_E),
        "ln": Operation.UnaryOperation(log),
        "log": Operation.UnaryOperation(log10),
        "log2": Operation.UnaryOperation(log2),
        "√": Operation.UnaryOperation(sqrt),
        "%": Operation.UnaryOperation({$0 / 100}),
        "cos":Operation.UnaryOperation(cos),
        "sin": Operation.UnaryOperation(sin),
        "tan": Operation.UnaryOperation(tan),
        "cosh":Operation.UnaryOperation(cosh),
        "sinh": Operation.UnaryOperation(sinh),
        "tanh": Operation.UnaryOperation(tanh),
        "ctg": Operation.UnaryOperation({1 / tan($0)}),
        "1/x": Operation.UnaryOperation({1 / $0}),
        "±": Operation.UnaryOperation({-$0}),
        "×": Operation.BinaryOperation({$0 * $1}),
        "÷": Operation.BinaryOperation({$0 / $1}),
        "+": Operation.BinaryOperation({$0 + $1}),
        "−": Operation.BinaryOperation({$0 - $1}),
        "=": Operation.Equals,
        "C": Operation.Clear
    ]
    
    private enum Operation {
        case Random(() -> Double)
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
    }

    private enum LastOperation {
        case Random
        case Constant
        case UnaryOperation
        case BinaryOperation
        case Equals
        case Clear
        case Digit
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private func addBrackets(_ symbol: String) {
        let openBracket = "("
        let closeBracket = ")"
        if lastOperation == .Equals || lastOperation == .UnaryOperation {
            sequence.insert(symbol + openBracket, at: 0)
            sequence.insert(closeBracket, at: sequence.count - 1)
        } else {
            sequence.insert(symbol + openBracket, at: sequence.count - 1)
            sequence.insert(closeBracket, at: sequence.count)
        }
    }
    
    func formatter(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 9
        return formatter.string(from: NSNumber(value: value))!
    }
    
    func setOperand (operand: Double) {
        if lastOperation == .Equals || lastOperation == .UnaryOperation {
            sequence.removeAll()
        }
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        sequence.append(formatter(operand))
        lastOperation = .Digit
    }

    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operation[symbol] {
            switch operation {
            case .Random(let function):
                if lastOperation == .Random {
                    sequence.removeLast()
                }
                accumulator = function()
                sequence.append(String(accumulator))
                lastOperation = .Random
            case .Constant(let value):
                if lastOperation == .Constant {
                    sequence.removeLast()
                }
                accumulator = value
                sequence.append(symbol)
                lastOperation = .Constant
            case .UnaryOperation(let function):
                if checkSequence {
                    accumulator = function(accumulator)
                    addBrackets(symbol)
                    lastOperation = .UnaryOperation
                }
            case .BinaryOperation(let function):
                if lastOperation == .Equals {
                    sequence.removeLast()
                }
                if lastOperation != .BinaryOperation {
                    sequence.append(symbol)
                    executePendingBinaryOperation()
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                }
                lastOperation = .BinaryOperation
            case .Equals:
                if lastOperation == .BinaryOperation {
                    sequence.append(formatter(accumulator))
                }
                if lastOperation != .Equals {
                    sequence.append(symbol)
                }
                executePendingBinaryOperation()
                lastOperation = .Equals
            case .Clear:
                clear()
                lastOperation = .Clear
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        sequence.removeAll()
        sequence.append("  ")
    }
    
    var checkSequence: Bool {
        get {
            return sequence.count > 0 && sequence.last != " "
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    var description: String {
        get {
            return isPartialResult ? sequence.joined() + dots : sequence.joined()
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
