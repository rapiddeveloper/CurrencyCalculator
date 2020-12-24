//
//  CurrencyList.swift
//  CowrywiseCC
//
//  Created by Admin on 12/18/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
/*
 Abstract: A view that shows a list of currencies
 */

import SwiftUI

struct CurrencyList: View {
    @EnvironmentObject var appData: AppData
    @State private var tempSelectedCurrency: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Select \(appData.selectedCurrencyType.rawValue.capitalized) Currency")
                Spacer()
                Button("Done", action: {
                    let newCurrencies = self.getNewCurrencies()
                    if let newBaseCurrency = newCurrencies[CurrencyType.base],
                        let newTargetCurrency = newCurrencies[CurrencyType.target] {
                        self.appData.updateConversionInfo(newBaseCurrency: newBaseCurrency, newTargetCurrency: newTargetCurrency)
                        self.appData.setExchangeName()
                    }
                    //self.appData.currencyListOpened = false
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
            .padding()
            List {
                ForEach(appData.conversionInfo.currencies, id: \.self) { currency in
                    Text(currency)
                        .font(.subheadline)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.tempSelectedCurrency = currency
                    }
                    .listRowBackground(self.tempSelectedCurrency == currency ? Color.gray : Color.clear)
                }
            }
        }
        .onAppear {
            if self.appData.selectedCurrencyType == .base {
                self.tempSelectedCurrency = self.appData.conversionInfo.baseCurrency
            } else {
                self.tempSelectedCurrency = self.appData.conversionInfo.targetCurrency
            }
        }
        
        .onDisappear {
            // todo:
        }
    }
    
    func getNewCurrencies() -> [CurrencyType: String] {
        
        var newBaseCurrency = ""
        var newTargetCurrency = ""
        let currBaseCurrency = self.appData.conversionInfo.conversionInfo.baseCurrency
        let currTargetCurrency = self.appData.conversionInfo.conversionInfo.targetCurrency
        
        if self.appData.selectedCurrencyType == .base &&
            self.tempSelectedCurrency == currTargetCurrency {
            newBaseCurrency = self.tempSelectedCurrency
            newTargetCurrency = currBaseCurrency
        } else if self.appData.selectedCurrencyType == .base &&
            self.tempSelectedCurrency != currTargetCurrency {
            newBaseCurrency = self.tempSelectedCurrency
            newTargetCurrency = currTargetCurrency
        } else if self.appData.selectedCurrencyType == .target &&
            self.tempSelectedCurrency == currBaseCurrency {
            newBaseCurrency = currTargetCurrency
            newTargetCurrency = self.tempSelectedCurrency
        } else {
            newBaseCurrency = currBaseCurrency
            newTargetCurrency = self.tempSelectedCurrency
        }
        
        return [CurrencyType.base: newBaseCurrency, CurrencyType.target: newTargetCurrency]
    }
    
    func getNewCurrenciesTester() {
        
        /* should return base currency with target currency swapped when baseCurrency is selected
        *  and selected currency matches the current target currency
        */
        
        /*appData.conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: 3, targetCurrencyAmt: 10, baseCurrency: "EUR", targetCurrency: "NGN", rate: ["NGN":461]))
        appData.selectedCurrencyType = .base
        selectedCurrency = "NGN"
        let newCurrencies = getNewCurrencies()
        if newCurrencies[CurrencyType.base] == "NGN" &&
           newCurrencies[CurrencyType.target] == "EUR"{
            print("currencies swapped")
        }*/
        
        /* should return base currency with target currency swapped when targetCurrency is selected
         *  and selected currency matches the current base currency
         */
        appData.conversionInfo = ConversionInfoViewModel(conversionInfo: ConversionInfo(baseCurrencyAmt: 3, targetCurrencyAmt: 10, baseCurrency: "EUR", targetCurrency: "USD", rate: ["USD":1.6], mode: 0, pos: .zero))
        appData.selectedCurrencyType = .target
        tempSelectedCurrency = "EUR"
        let newCurrencies = getNewCurrencies()
        if newCurrencies[CurrencyType.base] == "USD" &&
           newCurrencies[CurrencyType.target] == "EUR"{
            print("currencies swapped")
        }
    }
    
     
}

struct CurrencyList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CurrencyList()
                .environmentObject(AppData())
        }
    }
}
