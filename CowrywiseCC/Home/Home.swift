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

struct Home: View {
    
     @EnvironmentObject var appData: AppData
    
    var body: some View {
        VStack {
            HStack {
                Text("Menu")
                Text("Sign Up")
            }
            Text("Currency Calculator")
            TextField("", text: .constant("Base"))
            TextField("", text: .constant("Target"))
            HStack {
                CurrencyBtn(
                    currencyType: .base,
                    label: {
                        KFImage(URL(string: appData.baseCurrencyFlagURL))
                            //.resizable()
                            //.scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    },
                    action: {
                          self.appData.selectedCurrencyType = .base
                          self.appData.currencyListOpened = true
                    }
                )
                   
                
                CurrencyBtn(
                    currencyType: .target,
                    label: {
                           KFImage(URL(string: appData.targetCurrencyFlagURL))
                           // .resizable()
                            //.scaledToFit()
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
                
            }, label: {
                Text("Convert")
            })
            HStack {
                Text("link")
               // Image(systemName: ".info")
            }
            PieTrend()
            CurrencyHistoryTrend()
            
            Spacer()
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(AppData())
    }
}

struct CurrencyHistoryTrend: View {
    
    var body: some View {
        Text("Currency Btn")
    }
}

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

 
