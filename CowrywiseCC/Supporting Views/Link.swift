//
//  Link.swift
//  CowrywiseCC
//
//  Created by Admin on 12/24/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
/*
 A view that displays an hyperlink
 */

import Foundation
import SwiftUI

struct Link: View {
    
    let text: String
    let destination: String
    let lineColor: Color
    let textColor: Color
    let lineWidth: CGFloat
    
    var body: some View {
         Button(action: {
            if let url = URL(string: self.destination) {
                UIApplication.shared.open(url)
            }
         }) {
             Text(text)
                .font(.subheadline)
                 .foregroundColor(textColor)
                 .background(
                     GeometryReader { proxy in
                         Line()
                            .stroke(self.lineColor, lineWidth: self.lineWidth)
                             .frame(width: proxy.size.width, height: proxy.size.height)
                             .offset(x: 0, y: proxy.size.height)
                     }
             )
          }
          .buttonStyle(PlainButtonStyle())
    }
}


struct Link_Previews: PreviewProvider {
    static var previews: some View {
        Link(text: "help", destination: "", lineColor: .blue, textColor: .blue, lineWidth: 1)
    }
}
