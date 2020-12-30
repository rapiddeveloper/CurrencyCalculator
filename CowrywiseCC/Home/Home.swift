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
    
    @State var baseCurrencyAmt: String = "1.0"
    @State var targetCurrencyAmt: String = "0.0"
    let inputFieldWidth: CGFloat = UIScreen.main.bounds.width * 0.95
    
                   
    
    var body: some View {
       
        return ScrollView {
            VStack {
                HStack {
                    MenuButton(spacing: 5, lineWidth: 4, stroke: Color.red)
                         .frame(width: 32)
                    Spacer()
                    
                    Text("Sign Up")
                }
                Text("Currency Calculator")
                VStack {
//                    TextField("", text: $homeData.baseCurrencyAmt)
//                    TextField("", text: $homeData.targetCurrencyAmt)
 
                
                        CurrencyTextField(text: self.$baseCurrencyAmt,
                                          currencyPlaceHolder: self.appData.conversionInfo.baseCurrency,
                                          width: inputFieldWidth,
                                          onCommit: {})
                            .cornerRadius(5)
                            .frame(width: inputFieldWidth, height: 56)
                    
                        
                        CurrencyTextField(
                                    text:  self.$targetCurrencyAmt,
                                    currencyPlaceHolder: self.appData.conversionInfo.targetCurrency,
                                     width: inputFieldWidth,
                                    onCommit: {})
                            .cornerRadius(5)
                            .frame(width: inputFieldWidth, height: 56)
                    
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
                    
                    Image(systemName: "chevron.left")
                        .font(.subheadline)
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                    
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
                
                Button(action: {
                 
                    self.appData.updateConversionInfo(newBaseCurrencyAmt: self.baseCurrencyAmt,
                                           newTargetCurrencyAmt: self.targetCurrencyAmt
//                    self.appData.updateConversionInfo(newBaseCurrencyAmt: self.homeData.baseCurrencyAmt,
//                        newTargetCurrencyAmt: self.homeData.targetCurrencyAmt
                    )
                    self.appData.convertAmount(conversionType: .baseToTarget)
                    
                }, label: {
                    Text("Convert")
                })
                .disabled((baseCurrencyAmt == "" && targetCurrencyAmt == "") || baseCurrencyAmt == "")
                
                HStack {
                    Text("link")
                }
                RateTrend()
                    .frame(height: 560)
                Spacer()
            }
           //.padding()
            .onReceive(appData.$conversionResult, perform: { value in
              
                // update amount to show result of conversion
                var temp = ""
                if let result = value {
                    temp = String(result)
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

//struct Home_Previews: PreviewProvider {
//    static var previews: some View {
//        Home().environmentObject(AppData())
//    }
//}

struct PieTrend: View {
    
    @State private var pieChartEntries: [PieChartDataEntry] = []
    @State private var category: Wine.Category = .variety
    
    var body: some View {
        VStack {
            PieChart(entries: Wine.entriesForWines(Wine.allWines, category: category), category: $category)
                .scaledToFit()
                .frame(width: 400)
            Picker("Category", selection: $category, content: {
                Text(Wine.Category.variety.rawValue.uppercased())
                    .tag(Wine.Category.variety)
                Text(Wine.Category.winery.rawValue.uppercased())
                    .tag(Wine.Category.winery)
            })
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

 
