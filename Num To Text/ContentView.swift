//
//  ContentView.swift
//  Num To Text
//
//  Created by Rahul Gupta on 25/10/22.
//

import SwiftUI

struct ContentView: View {
    @State var input: String = ""
    @State var conversionType: ConversionType = .indian
    
    var body: some View {
        let binding = Binding<String>(get: {
            self.input
        }, set: {
            self.input = $0
            // do whatever you want here
        })
        
        return ScrollView {
            VStack(spacing: 30) {
                
                Text("\(numToStr(input: Int(input) ?? 0, type: conversionType))")
                    .font(.title).frame(height: 300)
                
                Text("\(getCommaSeparatedValue(input: input, type: conversionType))").font(.title)
                TextField("1000", text: binding)
                    .padding(.all)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.5))
                    )
                Picker("", selection: $conversionType) {
                    ForEach(ConversionType.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                    .padding()
                Spacer()
            }
            .padding(.all)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


func getCommaSeparatedValue(input: String, type: ConversionType) -> String {
    let inputValue = "\(Int(input) ?? 0)"
    var first = true
    var ans = ""
    let length = inputValue.count
    var currentContinuousLength = 0
    let inputCharArray = Array(inputValue).map{(value) -> String in String(value)}
    for i in (0..<length).reversed() {
        if (first || type == .english) {
            if currentContinuousLength == 3 {
                first = false
                ans += ","
                currentContinuousLength = 0
            }
        } else if (currentContinuousLength == 2) {
            ans += ","
            currentContinuousLength = 0
        }
        ans += inputCharArray[i]
        currentContinuousLength += 1
    }
    return String(ans.reversed())
}

import Foundation


enum ConversionType: String, CaseIterable {
    case indian = "Indian"
    case english = "English"
}

func getBaseNumsToStrMap(type: ConversionType) -> [Int: String] {
    func pow (_ base:Int, _ power:UInt) -> Int {
        var answer : Int = 1
        for _ in 0..<power { answer *= base }
        return answer
    }
    
    let _indianSpecific = [
        "\(pow(10, 5))": "lakh",
        "\(pow(10, 7))": "crore",
        "\(pow(10, 9))": "arab",
        "\(pow(10, 11))": "kharab",
        "\(pow(10, 13))": "nil",
        "\(pow(10, 15))": "padma",
        "\(pow(10, 17))": "shankh",
    ]
    let _englishSpecific = [
        "\(pow(10, 6))": "million",
        "\(pow(10, 9))": "billion",
        "\(pow(10, 12))": "trillion",
        "\(pow(10, 15))": "quadrillion",
    ]
    var _baseNumsToStrMap: [String: String] = [
        "0": "zero",
        "1": "one",
        "2": "two",
        "3": "three",
        "4": "four",
        "5": "five",
        "6": "six",
        "7": "seven",
        "8": "eight",
        "9": "nine",
        "10": "ten",
        "11": "eleven",
        "12": "twelve",
        "13": "thirteen",
        "14": "fourteen",
        "15": "fifteen",
        "16": "sixteen",
        "17": "seventeen",
        "18": "eighteen",
        "19": "nineteen",
        "20": "twenty",
        "30": "thirty",
        "40": "forty",
        "50": "fifty",
        "60": "sixty",
        "70": "seventy",
        "80": "eighty",
        "90": "ninety",
        "\(pow(10, 2))": "hundred",
        "\(pow(10, 3))": "thousand",
    ]
    if type == .indian {
        _indianSpecific.forEach { (k,v) in _baseNumsToStrMap[k] = v }
    } else {
        _englishSpecific.forEach { (k,v) in _baseNumsToStrMap[k] = v }
    }
    var baseNumsToStrMap: [Int: String] = [:]
    
    for v in _baseNumsToStrMap.keys {
        baseNumsToStrMap[Int(v)!] = _baseNumsToStrMap[v]
    }
    return baseNumsToStrMap
}
var indianBaseNumsToStrMap = getBaseNumsToStrMap(type: .indian)

let indianBaseOrderedKeys = indianBaseNumsToStrMap.keys.sorted()

var englishBaseNumsToStrMap = getBaseNumsToStrMap(type: .english)

let englishBaseOrderedKeys = englishBaseNumsToStrMap.keys.sorted()

func getBrokenNumber(input: Int, type: ConversionType) -> [Int] {
    var input = input
    var ans: [Int] = []
    if input == 0 {
        ans.append(0)
        return ans
    }
    var idx = type == .indian ? indianBaseOrderedKeys.count - 1 : englishBaseOrderedKeys.count - 1
    while input > 0 {
        let divisor = type == .indian ? indianBaseOrderedKeys[idx] : englishBaseOrderedKeys[idx]
        let dividend = input / divisor
        let remainder = input % divisor
        if dividend > 0 {
            if divisor >= 100 {
                for v in getBrokenNumber(input: dividend, type: type) {
                    ans.append(v)
                }
            }
            ans.append(divisor)
        }
        
        input = remainder
        idx -= 1
    }
    return ans
}

func numToStr(input: Int, type: ConversionType) -> String {
    let brokenNumber = getBrokenNumber(input: input, type: type)
    var ans = ""
    
    for num in brokenNumber {
        var suffix = " "
        if num >= 100 {
            suffix = "\n"
        }
        var str = type == .indian ? indianBaseNumsToStrMap[num]! : englishBaseNumsToStrMap[num]!
        str = Array(str)[0].uppercased() + str.dropFirst(1)
        ans += str + suffix
    }
    ans = String(ans.dropLast(1))
    return ans
}

