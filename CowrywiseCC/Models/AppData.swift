//
//  AppData.swift
//  CowrywiseCC
//
//  Created by Admin on 12/15/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import Foundation
import Combine
import Charts
import Alamofire

enum ConversionType: Int, Hashable {
    case baseToTarget = 1
    case targetToBase = 2
}

enum CurrencyType: String, Hashable {
    case target = "target"
    case base = "base"
}

enum NetworkStatus: String {
    case pending = "pending"
    case failed = "failed"
    case completed = "completed"
}

// known errors that could occur in the app and for formatting error title and message in the ErrorViewModel
enum ErrorType: String {
    case rate = "rate"
    case timeseries = "timeseries"
    case networkFailure = "network"
    case currencies = "currencies"
}

enum RateError: Int {
    
    case code104 = 104
    case code106 = 106
    case code102 = 102
    case code201 = 201
    
}


struct RateResponse: Codable {
    var success: Bool
    var timestamp: Double
    var historical: Bool
    var base: String
    var date: String
    var rates: [String: Double]
 }

struct ErrorInfo: Codable {
    var code: Int
    var type: String
}

struct ResponseSuccess: Codable {
    var success: Bool 
}

struct FailureResponse: Codable {
    var success: Bool
    var error: ErrorInfo
}

struct ErrorViewModel {
    
    var error: ErrorInfo
   // var networkError: Error?
    var type: ErrorType
    
    var message: String {
        var msg = ""
        switch type {
            case .rate:
                 let temp = error.type.replacingOccurrences(of: "_", with: " ")
                 msg = temp.capitalized
            case .timeseries:
                 msg = "No results available"
            case .networkFailure:
                 msg = "Cuurency Converter seems to be offline"
            case .currencies:
                        let temp = error.type.replacingOccurrences(of: "_", with: " ")
                        msg = temp.capitalized
           
        }
       
        return msg
    }
    
    var title: String {
        
        var title = ""
        
        switch type {
            case .rate:
                 title = "Conversion Rate Unavailable"
            case .timeseries:
                title = "Timeseries Unavailable"
            case .networkFailure:
                title = "Network Failure"
            case .currencies:
                title = "Currencies Unavailable"
          
        }
        
        return title
    }
    
    
}

struct CurrenciesResponse: Codable {
   var success: Bool
   var symbols: [String:String]
}

struct TimeseriesResponse: Codable {
   var motd: [String:String]
   var success: Bool
   var timeseries: Bool
   var base: String
   var start_date: String
   var end_date: String
   var rates: [String: [String:Double]]
}

struct Flag: Codable {
    var flag: String
}

struct Rate {
    var date: Double
    var value: Double
}

 

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
           // currencies = currencyCodesAndNames.map({"\($0.0) - \($0.1)"})
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
    
  }
       

enum ConversionErrors: Error {
    case divisionByZero
}

class AppData: ObservableObject {
    
    @Published var conversionInfo: ConversionInfoViewModel!
    @Published var currencyListOpened = false
    @Published var exchangeName = ""
    @Published var conversionResult: Double? = 0.0
    
    
    @Published var timeseriesNetworkStatus: NetworkStatus = .completed
    @Published var currenciesNetworkStatus: NetworkStatus = .completed
    @Published var rateNetworkStatus: NetworkStatus = .completed

    @Published var errorMsgDisplayed = false
    @Published var error: ErrorViewModel = ErrorViewModel(
                                                            error: ErrorInfo(code: 0, type: ""),
                                                          //  networkError: Error,
                                                            type: .rate
                                                          
                                                        )
    @Published var currenciesErrorDisplayed = false

    
    var ratePublisher: AnyCancellable?
    var conversionType: ConversionType = .baseToTarget
   
    let APIKey = "1d4bb84c085abdc2dd12645046fb3ab3" //"9e01c5fa47031db88531e4fb4bffa919"
    let timeSeriesEndpoint = "timeseries"
    let currenciesEndpoint = "symbols"
    var currenciesURL = "" 
    var selectedCurrencyType: CurrencyType = .base
    var isOffline = false
    
    
    var baseCurrencyFlagURL: String {
        let currency = conversionInfo.baseCurrency.lowercased()
        let start = currency.startIndex
        let end = currency.index(after: start)
        let countryCode = currency[start...end]
        return "https://www.countryflags.io/\(countryCode)/flat/64.png"
    }
    
    var targetCurrencyFlagURL: String {
             let currency = conversionInfo.targetCurrency.lowercased()
             let start = currency.startIndex
             let end = currency.index(after: start)
             let countryCode = currency[start...end]
             return "https://www.countryflags.io/\(countryCode)/flat/64.png"
    }
    
    func rateTimeseriesURL(daysPast: Int) -> String {
       
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        
        let today = Date()
        let daysAgo =  Date(timeIntervalSinceNow: TimeInterval(-daysPast * 24 * 60 * 60) )
        let startDate = formatter.string(from: daysAgo)
        let endDate = formatter.string(from: today)
        
         let symbol = conversionInfo.targetCurrency
         let base = conversionInfo.baseCurrency
        
        return "https://api.exchangerate.host/\(timeSeriesEndpoint)?start_date=\(startDate)&end_date=\(endDate)&base=\(base)&symbols=\(symbol)"
    }
    
    var rateEndpoint: String {
 
        let today = Date(timeIntervalSinceNow: TimeInterval(-1 * 24 * 60 * 60) ) //Date()
        let formatter = DateFormatter()
       
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        
        let formattedDate = formatter.string(from: today)
        
        return   "http://data.fixer.io/api/\(formattedDate)?access_key=\(APIKey)&base=\(conversionInfo.baseCurrency)&symbols=\(conversionInfo.targetCurrency)"
    }
    
    init() {
        currenciesURL = "http://data.fixer.io/api/\(currenciesEndpoint)?access_key=\(APIKey)"
        self.conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: 0, targetCurrencyAmt: 0, baseCurrency: "EUR", targetCurrency: "NGN", rate: nil, mode: 0, pos: .zero))
        
        
//        loadRate(url: rateEndpoint) { rate in
//            self.updateConversionInfo(with: rate)
//          
//            self.loadCurrencies(url: self.currenciesURL) { currencies in
//                if let currencies = currencies {
//                    self.updateConversionInfo(currencies: currencies.sorted(by: {$0.0 < $1.0 }) )
//
//                 }
//            }
//        }
        
    }
    
//    func setErrorMsg(errorCode: RateError)  {
//         errorMsg = "The only supported base currency is Euro (EUR)"
//    }
    
    func loadCurrencies(completion: @escaping ()->()) {
        
        Alamofire.request(currenciesURL).response { response in
            // check if there was an error reaching the server and network error is currently not displayed
            if let networkError = response.error  {
                self.updateError(newNetworkError: networkError)
                self.currenciesErrorDisplayed = true
            }
            
            let decoder = JSONDecoder()
            if let data = response.data {
                  if  let result = try? decoder.decode(CurrenciesResponse.self, from: data) {
                    self.updateConversionInfo(currencies: result.symbols.sorted(by: {$0.0 < $1.0 }))
                } else if let result = try? decoder.decode(FailureResponse.self, from: data) {
                    self.updateError(newRateError: result.error)
                    self.currenciesErrorDisplayed.toggle()
                } else {}
            }
             
        }
    }
    
    func toggleErrorMsg() {
        errorMsgDisplayed.toggle()
    }
    
    func getRateTimeseries(daysPast: Int) {
        let url = rateTimeseriesURL(daysPast: daysPast)
        self.loadRateTimeseries(url: url) { rates in
            if let rates = rates {
                self.conversionInfo.conversionInfo.rates = rates
               // print(self.conversionInfo.entries)
            }
        }
    }
    
    
    func getRateTimeseries() {
        let url = rateTimeseriesURL(daysPast: conversionInfo.conversionInfo.mode == 0 ? 30 : 90)
           self.loadRateTimeseries(url: url) { rates in
               if let rates = rates {
                   self.conversionInfo.conversionInfo.rates = rates
                  // print(self.conversionInfo.entries)
               }
           }
       }
    
    ///  Fetches timeseries of an exchange rate using the timeseries url and execute the completion handler
    func loadRateTimeseries(completion: @escaping ()->()) {
        
        DispatchQueue.main.async {
            self.timeseriesNetworkStatus = .pending
        }
        
        let url = rateTimeseriesURL(daysPast: conversionInfo.conversionInfo.mode == 0 ? 30 : 90)
        Alamofire.request(url).response { response in
            if let error = response.error {
                self.updateError(newNetworkError: error)
                self.conversionInfo.conversionInfo.rates = nil
                self.timeseriesNetworkStatus = .failed
            }
            
            let decoder = JSONDecoder()
            if let responseData = response.data,
                let result = try? decoder.decode(TimeseriesResponse.self, from: responseData) {
                if result.success {
                    self.conversionInfo.conversionInfo.rates = result.rates
                } else  {
                    self.conversionInfo.conversionInfo.rates = nil
                }
                self.timeseriesNetworkStatus = .completed
            }
            completion()
        }
    }
    
    /// Fetches conversion rate using the conversion rate url and updates conversionInfo view model with it
    
    func loadConversionRate(completion: @escaping ()->()) {
         
        Alamofire.request(rateEndpoint).response { response in
            if let error = response.error {
                self.updateError(newNetworkError: error)
                if !self.isErrorAlertDisplayed() {
                         
                    self.toggleErrorMsg()
                
                }
            }
            
            let decoder = JSONDecoder()
            if let responseData = response.data {
                if let result = try? decoder.decode(RateResponse.self, from: responseData) {
                    self.updateConversionInfo(with: result.rates)
                    if ((try? self.convert(from: .baseToTarget)) == nil) {
                        self.updateConversionInfo(with: nil)
                    }
                } else if let result = try? decoder.decode(FailureResponse.self, from: responseData) {
                    self.updateError(newRateError: result.error)
                    self.toggleErrorMsg()
                } else {}
            }
            completion()
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
        } else if newTargetCurrencyAmt.isEmpty  && !newBaseCurrencyAmt.isEmpty {
            conversionInfo.conversionInfo.targetCurrencyAmt = 0
        } else {
            conversionInfo.conversionInfo.targetCurrencyAmt = nil
        }
        
    }
    
    func updateConversionInfo(newBaseCurrency: String, newTargetCurrency: String)  {
        conversionInfo.conversionInfo.baseCurrency = newBaseCurrency
        conversionInfo.conversionInfo.targetCurrency = newTargetCurrency
    }
    
    func updateConversionInfo(mode: Int) {
        self.conversionInfo.conversionInfo.mode = mode
    }
    
    func updateConversionInfo(with newRate: [String: Double]?) {
        conversionInfo.conversionInfo.rate = newRate
    }
    
    func updateConversionInfo(currencies: [(String, String)]?) {
        conversionInfo.conversionInfo.currencies = currencies
    }
    
    func updateConversionInfo(newBaseCurrencyFlag: String) {
        conversionInfo.conversionInfo.baseCurrencyFlag = newBaseCurrencyFlag
    }
    
    func updateConversionInfo(newTargetCurrencyFlag: String) {
           conversionInfo.conversionInfo.targetCurrencyFlag = newTargetCurrencyFlag
       }
    
    func setExchangeName( ) {
        exchangeName = "\(conversionInfo.baseCurrency) - \(conversionInfo.targetCurrency)"
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
            let targetAmt = conversionInfo.conversionInfo.targetCurrencyAmt else { conversionResult = nil; return}
        
        // validation
        if conversionType == .baseToTarget {
            conversionInfo.conversionInfo.targetCurrencyAmt = baseAmt * exchangeRate
            conversionResult = baseAmt * exchangeRate
        } else if conversionType == .targetToBase && exchangeRate == 0 {
            throw ConversionErrors.divisionByZero
        } else {
            conversionInfo.conversionInfo.baseCurrencyAmt = targetAmt / exchangeRate
            conversionResult = targetAmt / exchangeRate
        }
    }
    
    
    func convertAmount(conversionType: ConversionType) {
        
        self.loadRate(url: self.rateEndpoint) { rates in
            self.updateConversionInfo(with: rates)
           // print(rates!)
            do {
              try self.convert(from: conversionType)
            }catch {
               self.updateConversionInfo(with: nil)
            }
           
        }
    }
  
    
    func loadRateTimeseries(url: String, completed: @escaping ([String: [String:Double]]?)->()) {
        
            if let url = URL(string: url) {
               let urlRequest = URLRequest(url: url)
               let session = URLSession.shared
               ratePublisher = session.dataTaskPublisher(for: urlRequest)
               .tryMap({ data, response -> Data? in
                   if let res = response as? HTTPURLResponse {
                       
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
                    if let responseData = data {
                        do {
                           let result = try decoder.decode(TimeseriesResponse.self, from: responseData)
                            completed(result.rates)
                        } catch {
                            print(error)
                        }
                    }
                 
               })
           }
       }
       
    
    
    func loadRate(url: String, completed: @escaping ([String: Double]?)->()) {
       
         if let url = URL(string: url) {
            let urlRequest = URLRequest(url: url)
            let session = URLSession.shared
            ratePublisher = session.dataTaskPublisher(for: urlRequest)
            .tryMap({ data, response -> Data? in
                if let res = response as? HTTPURLResponse {
                   
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
    
    func loadFlag(url: String, completed: @escaping (Flag?) -> ()) {
            if let url = URL(string: url) {
               let urlRequest = URLRequest(url: url)
               let session = URLSession.shared
               ratePublisher = session.dataTaskPublisher(for: urlRequest)
               .tryMap({ data, response -> Data? in
                   if let res = response as? HTTPURLResponse {
                       
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
                       let result = try? decoder.decode([Flag].self, from: responseData) {
                        completed(result.first)
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
    
    // updates error view model with error from rate conversion endpoint
    func updateError(newRateError: ErrorInfo) {
        error.type = .rate
        error.error = newRateError
    }
    
    func updateError(newCurrenciesError: ErrorInfo) {
           error.type = .currencies
           error.error = newCurrenciesError
       }
    
    func updateError(newNetworkError: Error?) {
        error.type = .networkFailure
        //Alamofire.SessionManager.default.session.invalidateAndCancel()
    }
    
    func isErrorAlertDisplayed()->Bool {
       return errorMsgDisplayed
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

 
    

  

 
    
