//
//  ConversionInfo.swift
//  CowrywiseCC
//
//  Created by Admin on 1/6/21.
//  Copyright © 2021 rapid interactive. All rights reserved.
/*
 Abstract: Model and ViewModel that encapsulate data that pertains to the conversion process
 */

import Foundation
import SwiftUI
import Charts

struct ConversionInfo {
    var baseCurrencyAmt: Double?
    var targetCurrencyAmt: Double?
    var baseCurrency: String
    var targetCurrency: String
    var currencies: [(String,String)]?
    var rate: [String: Double]?
    var targetCurrencyFlag: String?
    var baseCurrencyFlag: String?
    var rates: [String: [String:Double]]?
    var mode: Int
    var pos: CGPoint
}


struct ConversionInfoViewModel {
    
    var conversionInfo: ConversionInfo
    
    
    var baseCurrencyAmount: String {
        if let amt = conversionInfo.baseCurrencyAmt {
            return String(amt)
        } else {
            return ""
        }
    }
    
    var targetCurrencyAmount: String {
        if let amt = conversionInfo.targetCurrencyAmt {
            return String(amt)
        } else {
            return ""
        }
    }
    
    var baseCurrency: String {
        String(conversionInfo.baseCurrency.uppercased())
    }
    
    var targetCurrency: String {
        String(conversionInfo.targetCurrency.uppercased())
    }
    
    var currencies: [String] {
        
        var currencies: [String] = []
        
        if let currencyCodesAndNames = conversionInfo.currencies {
            currencies = currencyCodesAndNames.map({"\($0.0)"})
        }
        
        return currencies
    }
    
    var timeframeMode: Int {
        conversionInfo.mode
    }
    
    var tooltipPos: CGPoint {
        get {
            conversionInfo.pos
        }
        
        set {
            conversionInfo.pos = newValue
        }
    }
    
    var entries: [ChartDataEntry] {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        
        var ratelist = [ChartDataEntry]()
        
        if let rates = conversionInfo.rates {
            let dateKeys = Array(rates.keys)
            for dateKey in dateKeys {
                if let rate = rates[dateKey],
                    let rateValue = rate[conversionInfo.targetCurrency],
                    let date = formatter.date(from: dateKey) {
                    ratelist.append(ChartDataEntry(x: date.timeIntervalSince1970, y: rateValue))
                }
            }
            ratelist.sort(by: {$0.x < $1.x})
            
        }
        
        return ratelist
    }
    
    var rate: String {
        var result = ""
        
        if let rate = conversionInfo.rate, let rateValue = rate[targetCurrency] {
            result = String(rateValue)
        }
        return result
    }
    
}

