//
//  ErrorInfo.swift
//  CowrywiseCC
//
//  Created by Admin on 1/6/21.
//  Copyright © 2021 rapid interactive. All rights reserved.
/*
 Abstract: Model and ViewModel that encapsulate data for any error that occurs
 */

import Foundation

struct ErrorInfo: Codable {
    var code: Int
    var type: String
}

struct ErrorViewModel {
    
    var error: ErrorInfo
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
                 msg = "Currency Converter seems to be offline"
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
