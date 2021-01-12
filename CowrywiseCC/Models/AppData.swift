//
//  AppData.swift
//  CowrywiseCC
//
//  Created by Admin on 12/15/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
/*
 Abstract: A model that encapsulates data that pertains to the app 
 */

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

/*
enum RateError: Int {
    
    case code104 = 104
    case code106 = 106
    case code102 = 102
    case code201 = 201
    
}*/

struct Flag: Codable {
    var flag: String
}



class FixerRequestInterceptor: RequestInterceptor {
    
    let retryLimit = 3
    let retryDelay: TimeInterval = 5
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        
        let response = request.task?.response as? HTTPURLResponse
        //
        print(error)
        if let response = response {
            print(response.statusCode)
        }
        if let response = response, response.statusCode != 200,
            request.retryCount < retryLimit {
                print(response.statusCode)
                completion(.retryWithDelay(retryDelay))
        } else {
              return completion(.doNotRetry)
        }
       
    }
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
                                                            type: .rate
                                                        )
    @Published var currenciesErrorDisplayed = false
    
    
    var ratePublisher: AnyCancellable?
    var conversionType: ConversionType = .baseToTarget
   
    var currenciesURL: URL?
    var selectedCurrencyType: CurrencyType = .base
    var isOffline = false
    
    var APIKey = ""
    
    let sessionManager: Session = {
          
          let configuration = URLSessionConfiguration.af.default
          
          configuration.requestCachePolicy = .returnCacheDataElseLoad
          
          let responseCacher = ResponseCacher(behavior: .modify { _, response in
              let userInfo = ["date": Date()]
              return CachedURLResponse(
                  response: response.response,
                  data: response.data,
                  userInfo: userInfo,
                  storagePolicy: .allowed)
              })
          
          let interceptor = FixerRequestInterceptor()
          return Session(configuration: configuration,  interceptor: interceptor, cachedResponseHandler: responseCacher)
      }()
    
    
    var baseCurrencyFlagURL: String {
        
        let currency = conversionInfo.baseCurrency.lowercased()
        return getFlagURL(of: currency)
    }
    
    var targetCurrencyFlagURL: String {
        
        let currency = conversionInfo.targetCurrency.lowercased()
        return getFlagURL(of: currency)
    }
    
    func getFlagURL(of currency: String) -> String {
        
        let start = currency.startIndex
        let end = currency.index(after: start)
        let countryCode = currency[start...end]
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.countryflags.io"
        components.path = "/\(countryCode)/flat/64.png"
        
        if let url = components.url {
            return url.absoluteString
        } else {
            return ""
        }
    }
    
    func rateTimeseriesURL(daysPast: Int) -> URL? {
       
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        
        let today = Date()
        let daysAgo =  Date(timeIntervalSinceNow: TimeInterval(-daysPast * 24 * 60 * 60) )
        let startDate = formatter.string(from: daysAgo)
        let endDate = formatter.string(from: today)
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.exchangerate.host"
        components.path = "/timeseries"
        components.queryItems = [
            URLQueryItem(name: "start_date", value: startDate),
            URLQueryItem(name: "end_date", value: endDate),
            URLQueryItem(name: "base", value: conversionInfo.baseCurrency),
            URLQueryItem(name: "symbols", value: conversionInfo.targetCurrency)
        ]
        
        return components.url
        
    }
    
    var rateURL: URL? {
 
        let today = Date(timeIntervalSinceNow: TimeInterval(-1 * 24 * 60 * 60) )
        let formatter = DateFormatter()
       
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        
        let formattedDate = formatter.string(from: today)
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "data.fixer.io"
        components.path = "/api/\(formattedDate)"
        components.queryItems = [
            URLQueryItem(name: "access_key", value: APIKey),
            URLQueryItem(name: "base", value: conversionInfo.baseCurrency),
            URLQueryItem(name: "symbols", value: conversionInfo.targetCurrency)
        ]
        
        return components.url
    }
    
    var isRateAvailable: Bool {
         conversionInfo.conversionInfo.rate != nil
    }
    
    init() {
        
        let plistFilename = "FIXER-Info"
        let plistKey = "FIXER-APIKEY"
        var components = URLComponents()
       
        APIKey = loadAPIKey(plistKey: plistKey, plistFilename: plistFilename)
        
        components.scheme = "http"
        components.host = "data.fixer.io"
        components.path = "/api/symbols"
        components.queryItems = [URLQueryItem(name: "access_key", value: APIKey)]
        currenciesURL = components.url
        
        self.conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: 0, targetCurrencyAmt: 0, baseCurrency: "EUR", targetCurrency: "NGN", rate: nil, mode: 0, pos: .zero))
        
        loadCurrencies()
        
    }
    
    ///  Fetches currencies from the currencies url and execute the completion handler
    func loadCurrencies(completion: @escaping ()->() = {}) {
        
        guard let url = currenciesURL else { return }
        //let parameters = ["access_key": APIKey]
        
        DispatchQueue.main.async {
            self.currenciesNetworkStatus = .pending
        }
        
        sessionManager.request(url).response { response in
            
            // check if there was an error reaching the server and network error is currently not displayed
               if let networkError = response.error  {
                   self.updateError(newNetworkError: networkError)
                   self.currenciesNetworkStatus = .failed
               }
            
               let decoder = JSONDecoder()
               if let data = response.data {
                     if  let result = try? decoder.decode(CurrenciesResponse.self, from: data) {
                       self.updateConversionInfo(currencies: result.symbols.sorted(by: {$0.0 < $1.0 }))
                       self.currenciesNetworkStatus = .completed
                   } else if let result = try? decoder.decode(FailureResponse.self, from: data) {
                       self.updateError(newRateError: result.error)
                        self.currenciesErrorDisplayed = true
                        self.currenciesNetworkStatus = .completed
                    } else {}
               }
               
               completion()
        }
        
    }
    
    func toggleErrorMsg() {
        errorMsgDisplayed.toggle()
    }
    
    func loadAPIKey(plistKey: String, plistFilename: String) -> String {
        
        guard let filePath = Bundle.main.path(forResource: plistFilename , ofType: "plist") else {
            fatalError("File \(plistFilename) does not exist")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: plistKey) as? String else {
            fatalError("Couldn't find API_KEY \(plistKey) in \(plistFilename).plist")
        }
        
        return value
    }
     
    ///  Fetches timeseries of an exchange rate using the timeseries url and execute the completion handler
    func loadRateTimeseries(completion: @escaping ()->() = {}) {
        
        guard let url = rateTimeseriesURL(daysPast: conversionInfo.conversionInfo.mode == 0 ? 30 : 90) else { return }
        
        DispatchQueue.main.async {
            self.timeseriesNetworkStatus = .pending
        }
        
        sessionManager.request(url).response { response in
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
        
        guard let url = rateURL else { return }
        
        DispatchQueue.main.async {
            self.rateNetworkStatus = .pending
        }
         
        sessionManager.request(url).response { response in
            if let error = response.error {
                self.updateConversionInfo(with: nil)
                self.updateError(newNetworkError: error)
                if !self.isErrorAlertDisplayed() {
                    self.toggleErrorMsg()
                }
                self.rateNetworkStatus = .failed
            }
            
            let decoder = JSONDecoder()
            if let responseData = response.data {
                if let result = try? decoder.decode(RateResponse.self, from: responseData) {
                    self.updateConversionInfo(with: result.rates)
                } else if let result = try? decoder.decode(FailureResponse.self, from: responseData) {
                    self.updateConversionInfo(with: nil)
                    self.updateError(newRateError: result.error)
                    self.toggleErrorMsg()
                } else {}
                
                  self.rateNetworkStatus = .completed
            }
            completion()
        }
    }
    
   
    
    // The following methods update properties of the conversion view model
    
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
     of conversionInfo model
     */
    func convert(from conversionType: ConversionType) {
        
        guard let rate = conversionInfo.conversionInfo.rate,
              let exchangeRate = rate[conversionInfo.conversionInfo.targetCurrency] else {return}
        
        guard let baseAmt = conversionInfo.conversionInfo.baseCurrencyAmt,
            let targetAmt = conversionInfo.conversionInfo.targetCurrencyAmt else { conversionResult = nil; return}
        
        // validation
        if conversionType == .baseToTarget {
            conversionInfo.conversionInfo.targetCurrencyAmt = baseAmt * exchangeRate
            conversionResult = baseAmt * exchangeRate
        } else {
            conversionInfo.conversionInfo.baseCurrencyAmt = targetAmt / exchangeRate
            conversionResult = targetAmt / exchangeRate
        }
    }
    
    func getCurrencyFlag(currency: String) -> String {
        
        let currency = currency.lowercased()
        let start = currency.startIndex
        let end = currency.index(after: start)
        let countryCode = currency[start...end]
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.countryflags.io"
        components.path = "/\(countryCode)/flat/64.png"
        
        if let url = components.url {
            return url.absoluteString
        } else {
            return ""
        }
        
        
    }
    
    // The following methods update properties of the Error view model
    
    /// updates error view model with error from rate conversion endpoint
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

 
    

  

 
    
