//
//  FixerAPIManager.swift
//  CowrywiseCC
//
//  Created by Admin on 1/11/21.
//  Copyright © 2021 rapid interactive. All rights reserved.
//

import Foundation
import Alamofire

class FixerAPIManager {
    
    static let shared = FixerAPIManager()
    
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
        // configuration.timeoutIntervalForRequest = 30
        // configuration.waitsForConnectivity = true
        let interceptor = FixerRequestInterceptor()
        return Session(configuration: configuration,  interceptor: interceptor, cachedResponseHandler: responseCacher)
    }()
    
    func loadConversionRate(apiKey: String,
                            baseCurrency: String,
                            targetCurrency: String,
                            completion: @escaping(AFDataResponse<Data?>)->()) {
        
       
        let today = Date(timeIntervalSinceNow: TimeInterval(-1 * 24 * 60 * 60) )
        let formatter = DateFormatter()
        
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        
        let formattedDate = formatter.string(from: today)
        let conversionRateURL = "http://data.fixer.io/api/\(formattedDate)"
        let parameters = ["access_key": apiKey, "base": baseCurrency, "target": targetCurrency]
        
        sessionManager.request(conversionRateURL, parameters: parameters).response { response in
            completion(response)
        }
        
    }
}
