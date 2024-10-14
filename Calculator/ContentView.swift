//
//  ContentView.swift
//  Caculator
//
//  Created by ice on 2024/10/12.
//

import SwiftUI

struct ContentView: View {
    let buttons: [[String]] = [
        ["%", "√", "Del",  "AC"],
        ["7", "8", "9", "÷"],
        ["4", "5", "6", "×"],
        ["1", "2", "3", "-"],
        ["0", ".", "+", "="]
    ]
    @State var inputStr: String = ""
    @State var resultStr: String = "0"
    
    @State private var currentNumber: Double = 0
    @State private var previousNumber: Double = 0
    @State private var currentOperation: String = ""
    
    let spaceSize: CGFloat = 10
    
    var body: some View {
        VStack {
            VStack{
                HStack{
                    Spacer(minLength: 0)
                    if resultStr.count > 0{
                        Text(resultStr)
                            .font(.system(size: 56).monospacedDigit())
                            .lineLimit(1)
                            .fontDesign(.rounded)
                    }else{
                        Text("0")
                            .font(.system(size: 56).monospacedDigit())
                            .fontDesign(.rounded)
                            .opacity(0)
                    }
                }
                HStack{
                    Spacer(minLength: 0)
                    if inputStr.count > 0{
                        Text(inputStr)
                            .font(.title.monospacedDigit())
                            .lineLimit(1)
                            .truncationMode(.head) // 在前面截断
                            .fontDesign(.rounded)
                    }else{
                        Text("0")
                            .font(.title.monospacedDigit())
                            .fontDesign(.rounded)
                            .opacity(0)
                    }
                }
            }
            .foregroundStyle(.black)
            .padding()
            .background(.calculatorBg)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.bottom)
            
            
            // 使用 GeometryReader 使按钮自适应宽高
            GeometryReader { geometry in
                let buttonWidth = geometry.size.width / CGFloat(
                    buttons.first!.count
                ) - spaceSize // 计算每个按钮的宽度
                let buttonHeight = geometry.size.height / CGFloat(
                    buttons.count
                ) - spaceSize // 计算每个按钮的高度
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: spaceSize),
                        count: buttons.first!.count
                    ),
                    spacing: spaceSize,
                    content: {
                        ForEach(buttons, id: \.self){ row in
                            ForEach(row, id: \.self){ num in
                                Button(action: {dealInput(num: num)}, label:{
                                    Text(num)
                                        .font(num.count > 1 ? .title : .largeTitle)
                                        .frame(width: buttonWidth, height: buttonHeight)
//                                        .foregroundStyle(num == "=" ? Color.white : Color.primary)
                                })
                                .frame(width: buttonWidth, height: buttonHeight)
//                                .background(num == "=" ? Color.orange : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(color: .gray.opacity(0.3), radius: 2, y: 2)
                            }
                        }
                    })
                .frame(maxHeight: .infinity)
            }
        }
        .padding()
    }
    
    // 处理输入
    func dealInput(num: String){
        switch num {
        case "AC":
            inputStr = ""
            resultStr = "0"
        case "Del":
            if inputStr.contains("="){
                inputStr = String(inputStr.split(separator: "=").first!)
            }
            guard !inputStr.isEmpty else { return }
            inputStr.removeLast()
        case "-":
            removePre()
            if ".√".contains(inputStr.last ?? "c"){
                inputStr.removeLast()
            }
            if "+-".contains(inputStr.last ?? "c"){
                inputStr.removeLast()
            }
            inputStr.append(num)
        case "+", "×", "÷":
            removePre()
            if "+-×÷.√".contains(inputStr.last ?? "c"){
                inputStr.removeLast()
            }
            if "+-×÷.√".contains(inputStr.last ?? "c"){
                inputStr.removeLast()
            }
            inputStr.append(num)
        case "=":
            if "+-×÷.√".contains(inputStr.last ?? "c"){
                inputStr.removeLast()
            }
            if "+-×÷.√".contains(inputStr.last ?? "c"){
                inputStr.removeLast()
            }
            let inputArray = inputStr.split(separator: "=")
            let lastInput: String = String(inputArray.last!)
            if let result = calculateExpression(lastInput){
                print(result)
                if result >= Double(Int64.min) && result <= Double(Int64.max) && result == Double(Int64(result)) {
                    resultStr = "\(Int64(result))"
                } else {
                    var tempStr = ""
                    var occurPot = false
                    var tempPotNum = ""
                    let tempResStr = String(result) + "#"
                    for c in tempResStr{
                        if c == "."{
                            occurPot = true
                            continue
                        }
                        if occurPot{
                            if "0123456789".contains(c){
                                // 14280000000
                                tempPotNum.append(c)
                                continue
                            }else{
                                // 数字部分结束
                                occurPot = false
                                if Int(tempPotNum) == 0{
                                    // 无小数部分
                                }else{
                                    if tempPotNum.count > 10 {
                                        let endIndex = tempPotNum.index(tempPotNum.startIndex, offsetBy: 10)
                                        tempPotNum = String(tempPotNum[..<endIndex])
                                    }
                                    while tempPotNum.last == "0"{
                                        tempPotNum.removeLast()
                                    }
                                    if tempPotNum.count > 0{
                                        tempStr.append(".")
                                        tempStr.append(tempPotNum)
                                        tempPotNum = ""
                                    }
                                }
                            }
                        }
                        if c != "#"{
                            tempStr.append(c)
                        }
                    }
                    resultStr = tempStr
                }
                inputStr = lastInput + num + resultStr
            }
        case ".":
            if inputStr.contains("="){
                inputStr = ""
                resultStr = ""
            }
            if inputStr.isEmpty{
                inputStr.append("0")
            }
            if "0123456789".contains(inputStr.last ?? "c"){
                inputStr.append(num)
            }
        case "%":
            if "+-×÷.√".contains(inputStr.last ?? "c"){
                break
            }
            removePre()
            if inputStr.count > 0{
                var tempStr = inputStr
                var tempNum = ""
                // 12414 * 123.45
                while ".0123456789".contains(tempStr.last ?? "c"){
                    tempNum.insert(tempStr.removeLast(), at: tempNum.startIndex)
                }
                tempNum = String(Double(tempNum)! / 100.0)
                inputStr = tempStr + tempNum
            }
        case "√":
            if inputStr.contains("="){
                inputStr = ""
                resultStr = ""
                inputStr.append(num)
                break
            }
            if "0123456789.√".contains(inputStr.last ?? "c"){
                break
            }
            inputStr.append(num)
        default:
            if inputStr.contains("="){
                inputStr = ""
                resultStr = ""
            }
            inputStr.append(num)
        }
    }
    
    func removePre(){
        let inputArray = inputStr.split(separator: "=")
        if inputArray.count > 1{
            inputStr = String(inputArray.last!)
        }
    }
    
    
    // Helper function to compute square root
    func sqrtValue(_ value: Double) -> Double {
        return sqrt(value)
    }

    // Helper function to parse percentage (assuming it's modulo operation here)
    func percentageValue(_ value: Double) -> Double {
        return value / 100.0
    }

    // Function to evaluate the expression from the string
    func calculateExpression(_ expression: String) -> Double? {
        // 处理乘除符号：将 × 替换为 *，将 ÷ 替换为 /
        var cleanExpression = expression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
        var tempStr = ""
        var startSqrt = false
        var tempNum = ""
        cleanExpression.append("#")
        // 123123    √123#       123123*sqrt(123)
        for c in cleanExpression{
            if c == "√"{
                tempStr.append("sqrt(")
                startSqrt = true
                continue
            }
            if startSqrt {
                if ".0123456789".contains(c){
                    tempNum.append(c)
                    continue
                }else{
                    tempStr.append(tempNum)
                    tempStr.append(")")
                    startSqrt = false
                    tempNum = ""
                }
            }
            if c != "#"{
                tempStr.append(c)
            }
        }
        cleanExpression = tempStr
                
        print(cleanExpression)
        // 1.0* 5/2 = 2  2.5
        // Expression: Replace operators accordingly for easier parsing
        let expressionWithBrackets = NSExpression(format: "1.0*" + cleanExpression)
        
        // Safely evaluate the expression
        if let result = expressionWithBrackets.expressionValue(with: nil, context: nil) as? Double {
            return result
        }
        return nil
    }
}

#Preview {
    ContentView()
        .frame(width: 320, height: 520)
}
