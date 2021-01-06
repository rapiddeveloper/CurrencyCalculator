//
//  Responses.swift
//  CowrywiseCC
//
//  Created by Admin on 1/6/21.
//  Copyright © 2021 rapid interactive. All rights reserved.
/*
 Abstract: Models that represent data of api responses
 */


struct RateResponse: Codable {
    var success: Bool
    var timestamp: Double
    var historical: Bool
    var base: String
    var date: String
    var rates: [String: Double]
 }



struct ResponseSuccess: Codable {
    var success: Bool
}

struct FailureResponse: Codable {
    var success: Bool
    var error: ErrorInfo
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
