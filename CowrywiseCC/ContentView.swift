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
            NavigationView {
                 Home()
                    .sheet(isPresented: $appData.currencyListOpened, content: {
                        CurrencyList().environmentObject(self.appData)
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
