//
//  CurrenciesError.swift
//  CowrywiseCC
//
//  Created by Admin on 1/1/21.
//  Copyright © 2021 rapid interactive. All rights reserved.
//

import SwiftUI

struct CurrenciesError: View {
    
    @EnvironmentObject var appData: AppData
    let msg: String
    
    var body: some View {
        VStack(alignment: .center, spacing:  32) {
            Text(msg)
                .font(.subheadline)
                .foregroundColor(.gray)
            Button(action: {
                self.appData.loadCurrencies(completion: {})
            }, label:  {
                Text("Load Currencies")
            })
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct CurrenciesError_Previews: PreviewProvider {
    static var previews: some View {
        CurrenciesError(msg: "Currency Converter is offline")
        .environmentObject(AppData())
    }
}
