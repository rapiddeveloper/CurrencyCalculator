//
//  CurrencyBtn.swift
//  CowrywiseCC
//
//  Created by Admin on 12/17/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
/*
 Abstract: A view that shows a button that shows the base/target currency selected and allows the user perform a specified action
 */

import SwiftUI

struct CurrencyBtn<Content: View>: View {
    
    @EnvironmentObject var appData: AppData
    let currencyType: CurrencyType
    
    let label: Content
    let action: ()->()
    
    init(currencyType: CurrencyType, @ViewBuilder label:()->Content, action: @escaping ()->()) {
        self.currencyType = currencyType
        self.label = label()
        self.action = action
    }
    
    var body: some View {
      
        HStack(spacing: 12) {
            label
            Group {
                if currencyType == .base {
                    Text(appData.conversionInfo.baseCurrency)
                } else {
                    Text(appData.conversionInfo.targetCurrency)
                }
            }
            .font(.headline)
            
            Button(action: {
                self.action()
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
        CurrencyBtn(currencyType: .base, label: {EmptyView()},  action: {})
        .environmentObject(AppData())
    }
}
