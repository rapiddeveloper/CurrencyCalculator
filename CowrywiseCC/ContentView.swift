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
             print("home view")
           return  NavigationView {
                 Home()
                    .sheet(isPresented: $appData.currencyListOpened, content: {
                        CurrencyList().environmentObject(self.appData)
                     })
                    .alert(isPresented: $appData.errorMsgDisplayed, content: {
                        Alert(title: Text(self.appData.error.title), message:  Text(self.appData.error.message), dismissButton: .default(Text("OK"), action: {
                           // self.appData.toggleErrorMsg()
                        }))
                    })
            }
      }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(AppData())
    }
}
