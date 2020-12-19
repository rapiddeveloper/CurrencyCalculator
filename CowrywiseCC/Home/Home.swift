//
//  Home.swift
//  CowrywiseCC
//
//  Created by Admin on 12/17/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import SwiftUI

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
                        Image("countryflag")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFill()
                            .frame(width: 24, height: 24)
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
                        Image("countryflag")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFill()
                            .frame(width: 24, height: 24)
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
            CurrencyHistoryTrend()
            Spacer()
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

struct CurrencyHistoryTrend: View {
     
    var body: some View {
        Text("Currency Btn")
    }
}

 
