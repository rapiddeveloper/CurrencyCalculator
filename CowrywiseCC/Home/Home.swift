//
//  Home.swift
//  CowrywiseCC
//
//  Created by Admin on 12/17/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import SwiftUI
import KingfisherSwiftUI
import Charts
import Alamofire

class HomeData: ObservableObject {
    @Published var baseCurrencyAmt: String = "1.0"
    @Published var targetCurrencyAmt: String = "0.0"
}

struct Home: View {
    
    @EnvironmentObject var appData: AppData
    //@ObservedObject var homeData = HomeData()
    @State var baseCurrencyAmt: String = "1"
    @State var targetCurrencyAmt: String = "0.0"
    let inputFieldWidth: CGFloat = UIScreen.main.bounds.width * 0.75
    
                   
    
    var body: some View {
       
        return ScrollView {
            Group {
                VStack {
                    HStack {
                        MenuButton(spacing: 5, lineWidth: 4, stroke: Color("PrimaryColor"))
                            .frame(width: 24)
                        
                        Spacer()
                        
                        Text("Sign up")
                          .font(.custom("MontserratAlternates-SemiBold", size: 17))
                        .foregroundColor(Color("PrimaryColor"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Currency")
                           
                        HStack(alignment: .bottom) {
                            Text("Calculator")
                            Circle()
                                .fill(Color("PrimaryColor"))
                                .frame(width: 8, height: 8)
                                .offset(x: -8, y: -8)
                        }
                        
                    }
                    .font(.custom("MontserratAlternates-Bold", size: 34))
                    .foregroundColor(Color("SecondaryColor"))
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
                        //                    TextField("", text: $homeData.baseCurrencyAmt)
                        //                    TextField("", text: $homeData.targetCurrencyAmt)
                        
                        CurrencyTextField(text: self.$baseCurrencyAmt,
                                          currencyPlaceHolder: self.appData.conversionInfo.baseCurrency,
                                          isResultDisplayed: false,
                                          onCommit: {}
                        )
                            .cornerRadius(5)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 56)
                                              
                
                        CurrencyTextField(
                            text:  self.$targetCurrencyAmt,
                            currencyPlaceHolder: self.appData.conversionInfo.targetCurrency,
                            isResultDisplayed: true,
                            onCommit: {}
                        )
                            .cornerRadius(5)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 56)
                    }
                    
                    HStack {
                        CurrencyBtn(
                            currencyType: .base,
                            label: {
                                KFImage(URL(string: appData.baseCurrencyFlagURL))
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            },
                                action: {
                                    self.appData.selectedCurrencyType = .base
                                    self.appData.currencyListOpened = true
                            }
                        )
                        Spacer()
                        Image(systemName: "chevron.left")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                        Spacer()
                        CurrencyBtn(
                            currencyType: .target,
                            label: {
                                KFImage(URL(string: appData.targetCurrencyFlagURL))
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                        },
                            action: {
                                self.appData.selectedCurrencyType = .target
                                self.appData.currencyListOpened = true
                        }
                        )
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    
                    Button(action: {
                        
                        self.appData.updateConversionInfo(newBaseCurrencyAmt: self.baseCurrencyAmt,
                                                          newTargetCurrencyAmt: self.targetCurrencyAmt
                            //                    self.appData.updateConversionInfo(newBaseCurrencyAmt: self.homeData.baseCurrencyAmt,
                            //                        newTargetCurrencyAmt: self.homeData.targetCurrencyAmt
                        )
                        self.appData.loadConversionRate {
                            if self.appData.rateNetworkStatus == .completed && self.appData.isRateAvailable {
                                self.appData.convert(from: .baseToTarget)
                            }  else {
                                self.targetCurrencyAmt = ""
                                self.appData.updateConversionInfo(newBaseCurrencyAmt: self.baseCurrencyAmt, newTargetCurrencyAmt: self.targetCurrencyAmt)
                            }
                        }
                        
                    }, label: {
                        Text("Convert")
                         .font(.custom("MontserratAlternates-SemiBold", size: 17))
                    })
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 48)
                        .background(Color.gray)
                    .disabled((baseCurrencyAmt == "" && targetCurrencyAmt == "") || baseCurrencyAmt == "")
                    
                    
                    HStack(spacing: 16) {
                        Link(text: "Mid-market exchange rate at 13:38 UTC", destination: "", lineColor: .blue, textColor: .blue, lineWidth: 1.0)
                        Group {
                            Image(systemName: "info")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .background(
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 18,height: 18)
                            )
                        }
                    }
                }
                .padding(16.0)
                //.frame(minWidth: 0, maxWidth: .infinity)
                //.padding(.horizontal, 32)
                RateTrend()
                Spacer()
            }
 
            .onReceive(appData.$conversionResult, perform: { value in
              
                // update amount to show result of conversion
                var temp = ""
                if let result = value {
                    temp = String(format: "%.6f",  result)
                }
                
                // select currency textfield to put result
                if self.appData.conversionType == .baseToTarget {
                    self.targetCurrencyAmt = temp
                } else {
                    self.baseCurrencyAmt = temp
                }
            })
            .onReceive(appData.$exchangeName, perform: { value in
              
                let group = DispatchGroup()
                let queue = DispatchQueue.global()
               
                self.appData.updateConversionInfo(newBaseCurrencyAmt: self.baseCurrencyAmt, newTargetCurrencyAmt: self.targetCurrencyAmt)
                
                group.enter()
                queue.async(group: group, execute: {
                    self.appData.loadConversionRate {
                        if self.appData.rateNetworkStatus == .completed && self.appData.isRateAvailable {
                            self.appData.convert(from: .baseToTarget)
                        }
                        else {
                            self.targetCurrencyAmt = ""
                            self.appData.updateConversionInfo(newBaseCurrencyAmt: self.baseCurrencyAmt, newTargetCurrencyAmt: self.targetCurrencyAmt)
                        }
                        group.leave()
                    }
                })
                
                group.enter()
                queue.async(group: group, execute: {
                    self.appData.loadRateTimeseries {
                        group.leave()
                    }
                })
                
                group.notify(queue: .main, execute: {
                    print("Tasks complete")
                })
            })
        }
     }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(AppData())
    }
}

 
