//
//  ContentView.swift
//  CowrywiseCC
//
//  Created by Admin on 12/15/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var appData: AppData
    
    var body: some View {
           return  NavigationView {
            if !appData.showHomescreen {
                VStack(alignment: .center) {
                    Text("Currency Converter is not connected to the internet. Go online to get started")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                }
               .padding(64)
               .padding(.top, 128)
            } else {
                Home()
                    .sheet(isPresented: $appData.currencyListOpened, content: {
                        CurrencyList().environmentObject(self.appData)
                            .alert(isPresented: self.$appData.currenciesErrorDisplayed, content: {
                                Alert(title: Text(self.appData.error.title), message:  Text(self.appData.error.message), dismissButton: .default(Text("OK"), action: {
                                    
                                }))
                            })
                    })
                    .alert(isPresented: self.$appData.errorMsgDisplayed, content: {
                        Alert(title: Text(self.appData.error.title), message:  Text(self.appData.error.message), dismissButton: .default(Text("OK")))
                    })
            }
              
            }
      }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(AppData())
    }
}
