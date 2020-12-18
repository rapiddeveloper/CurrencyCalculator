//
//  AppData.swift
//  CowrywiseCC
//
//  Created by Admin on 12/15/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import Foundation
import Combine

enum ConversionType: Int, Hashable {
    case baseToTarget = 1
    case targetToBase = 2
}

enum CurrencyType: String, Hashable {
    case target = "target"
    case base = "base"
}



struct RateResponse: Codable {
    var success: Bool
    var timestamp: Double
    var historical: Bool
    var base: String
    var date: String
    var rates: [String: Double]
 }

struct CurrenciesResponse: Codable {
   var success: Bool
   var symbols: [String:String]
}

struct ConversionInfo {
    var baseCurrencyAmt: Double?
    var targetCurrencyAmt: Double?
    var baseCurrency: String
    var targetCurrency: String
    var currencies: [(String,String)]?
    var rate: [String: Double]?
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
            currencies = currencyCodesAndNames.map({"\($0.0) - \($0.1)"})
        }
        
        return currencies
    }
       
}

enum ConversionErrors: Error {
    case divisionByZero
}

class AppData: ObservableObject {
    
    @Published var conversionInfo: ConversionInfoViewModel!
    
    var ratePublisher: AnyCancellable?
    
    
    var conversionType: ConversionType = .baseToTarget
    let APIKey = "9e01c5fa47031db88531e4fb4bffa919"
    let currenciesEndpoint = "symbols"
    var currenciesURL = ""
    var selectedBaseCurrencyIdx = 0
    var selectedTargetCurrencyIdx = 1
    var selectedCurrencyType: CurrencyType = .base
    
    var rateEndpoint: String {
 
        let today = Date()
        let formatter = DateFormatter()
       
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        
        let formattedDate = formatter.string(from: today)
        
        return   "http://data.fixer.io/api/\(formattedDate)?access_key=\(APIKey)&base=\(conversionInfo.baseCurrency)&symbols=\(conversionInfo.targetCurrency)"
    }
    
    init() {
        currenciesURL = "http://data.fixer.io/api/\(currenciesEndpoint)?access_key=\(APIKey)"
        self.conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: 1, targetCurrencyAmt: 10, baseCurrency: "EUR", targetCurrency: "NGN", rate: nil))

        loadRate(url: rateEndpoint) { rate in
            self.updateConversionInfo(with: rate)
            // print(self.conversionInfo)
            self.loadCurrencies(url: self.currenciesURL) { currencies in
                if let currencies = currencies {
                    self.updateConversionInfo(currencies: currencies.sorted(by: {$0.0 < $1.0 }) )
                   // print(self.conversionInfo)
                }
            }
        }
        
    }
    
    func updateConversionInfo(newBaseCurrencyAmt: String, newTargetCurrencyAmt: String) {
        
        // validation
        if let baseAmt = Double(newBaseCurrencyAmt), baseAmt >= 0 {
            conversionInfo.conversionInfo.baseCurrencyAmt = baseAmt
        } else {
            conversionInfo.conversionInfo.baseCurrencyAmt = nil
        }
        
        if let targetAmt = Double(newTargetCurrencyAmt), targetAmt >= 0 {
            conversionInfo.conversionInfo.targetCurrencyAmt = targetAmt
        } else {
            conversionInfo.conversionInfo.targetCurrencyAmt = nil
        }
        
    }
    
    func updateConversionInfo(newBaseCurrency: String, newTargetCurrency: String)  {
         conversionInfo.conversionInfo.baseCurrency = newBaseCurrency
         conversionInfo.conversionInfo.targetCurrency = newTargetCurrency
    }
    
    func updateConversionInfo(with newRate: [String: Double]?) {
        conversionInfo.conversionInfo.rate = newRate
    }
    
    func updateConversionInfo(currencies: [(String, String)]?) {
        conversionInfo.conversionInfo.currencies = currencies
    }
    
    /*
     performs a conversion given a conversion type and updates the corresponding currency amount
     e.g .baseToTarget converts baseCurrencyAmount from base currency to target currency and updates the targetCurrencyAmount
     of conversionInfo
     */
    func convert(from conversionType: ConversionType) throws {
        
        guard let rate = conversionInfo.conversionInfo.rate,
              let exchangeRate = rate[conversionInfo.conversionInfo.targetCurrency] else {return}
        
        guard let baseAmt = conversionInfo.conversionInfo.baseCurrencyAmt,
              let targetAmt = conversionInfo.conversionInfo.targetCurrencyAmt else {return}
        
        // validation
        if conversionType == .baseToTarget {
            conversionInfo.conversionInfo.targetCurrencyAmt = baseAmt * exchangeRate
        } else if conversionType == .targetToBase && exchangeRate == 0 {
            throw ConversionErrors.divisionByZero
        } else {
            conversionInfo.conversionInfo.baseCurrencyAmt = targetAmt / exchangeRate
        }
    }
    
    func convertAmount(conversionType: ConversionType) {
        self.loadRate(url: self.rateEndpoint) { rates in
            
            self.updateConversionInfo(with: rates)
            do {
              try self.convert(from: conversionType)
            }catch {
               self.updateConversionInfo(with: nil)
            }
           
        }
    }
    
    
    func loadRate(url: String, completed: @escaping ([String: Double]?)->()) {
         if let url = URL(string: url) {
            let urlRequest = URLRequest(url: url)
            let session = URLSession.shared
            ratePublisher = session.dataTaskPublisher(for: urlRequest)
            .tryMap({ data, response -> Data? in
                if let res = response as? HTTPURLResponse {
                    print(res.statusCode)
                    if res.statusCode == 200 { // returned anything
                        return data
                    }
                }
                return nil
            })
            .receive(on: RunLoop.main)
            .assertNoFailure()
            .sink(receiveValue: { data in
                let decoder = JSONDecoder()
                if let responseData = data,
                    let result = try? decoder.decode(RateResponse.self, from: responseData) {
                    completed(result.rates)
                }
 
            })
        }
    }
    
    func loadCurrencies(url: String, completed: @escaping ([String: String]?)->()) {
            if let url = URL(string: url) {
               let urlRequest = URLRequest(url: url)
               let session = URLSession.shared
               ratePublisher = session.dataTaskPublisher(for: urlRequest)
               .tryMap({ data, response -> Data? in
                   if let res = response as? HTTPURLResponse {
                       print(res.statusCode)
                       if res.statusCode == 200 { // returned anything
                           return data
                       }
                   }
                   return nil
               })
               .receive(on: RunLoop.main)
               .assertNoFailure()
               .sink(receiveValue: { data in
                   let decoder = JSONDecoder()
                   if let responseData = data,
                       let result = try? decoder.decode(CurrenciesResponse.self, from: responseData) {
                       completed(result.symbols)
                   }
    
               })
           }
       }
    
 
    
    /*
    func convertTester() {
       // let appData = AppData()
         conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: 3, targetCurrencyAmt: 10, baseCurrency: "EUR", targetCurrency: "NGN", rate: ["NGN":461]))
        do {
            try convert(from: .baseToTarget)
            print(conversionInfo.targetCurrencyAmount)
        } catch  {
            print("Division By zero")
        }
        
        // should throw when rate is 0
        conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: 3, targetCurrencyAmt: 10, baseCurrency: "EUR", targetCurrency: "NGN", rate: ["NGN": 0]))
        do {
            try convert(from: .targetToBase)
            print(conversionInfo.targetCurrencyAmount)
        } catch  {
            print("Division By zero")
        }
        
        // target currency amount should be unchanged
        conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: nil, targetCurrencyAmt: 10, baseCurrency: "EUR", targetCurrency: "NGN", rate: ["NGN": 0]))
        try? convert(from: .baseToTarget)
        if conversionInfo.conversionInfo.targetCurrencyAmt == 10 {
            print("Base Amount in model invalid")
        }
        
        // base currency amount should be unchanged
               conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: 10, targetCurrencyAmt: nil, baseCurrency: "EUR", targetCurrency: "NGN", rate: ["NGN": 0]))
                try? convert(from: .targetToBase)
               if conversionInfo.conversionInfo.baseCurrencyAmt == 10 {
                   print("Target Amount in model invalid")
               }
    }
    
     func convertAmountTester() {
           // case 1: should update rate in model
             conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: 3, targetCurrencyAmt: 10, baseCurrency: "EUR", targetCurrency: "CAD", rate: nil))
           
           convertAmount(conversionType: .baseToTarget)
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if let rate = self.conversionInfo.conversionInfo.rate {
                     print(rate)
                }
           })
            
           // case 2: should perform conversion given a conversion type
            conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: 3, targetCurrencyAmt: 10, baseCurrency: "EUR", targetCurrency: "NGN", rate: nil))
            
            convertAmount(conversionType: .baseToTarget)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if let amt = self.conversionInfo.conversionInfo.targetCurrencyAmt {
                    print(amt)
                }
            })
       }*/
    
}

 
    

  

 
    
