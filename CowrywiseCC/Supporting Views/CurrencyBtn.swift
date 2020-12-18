//
//  CurrencyBtn.swift
//  CowrywiseCC
//
//  Created by Admin on 12/17/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import SwiftUI

struct CurrencyBtn: View {
    
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        HStack(spacing: 12) {
            Image("countryflag")
                .resizable()
                .renderingMode(.original)
                .scaledToFill()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            Text(appData.conversionInfo.baseCurrency)
                .font(.headline)
            Button(action: {
               
                
            }, label: {
                Image(systemName: "chevron.down")
            })
          
        }
        .padding(8)
        .foregroundColor(Color(UIColor.systemGray2))
        .overlay(
            RoundedRectangle(cornerRadius: 2.0)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1.0)
        )
        
    
    }
}

struct CurrencyBtn_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyBtn()
        .environmentObject(AppData())
    }
}
