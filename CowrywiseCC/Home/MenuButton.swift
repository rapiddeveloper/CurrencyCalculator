//
//  MenuButton.swift
//  CowrywiseCC
//
//  Created by Admin on 12/25/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import SwiftUI

struct MenuButton: View {
    
    let spacing: CGFloat
    let lineWidth: CGFloat
    let stroke: Color
    
    var body: some View {
         
        GeometryReader { proxy in
            Button(action: {
                    
                }, label: {
                    VStack(alignment: .leading, spacing: self.spacing) {
                        Line()
                            .stroke(self.stroke, lineWidth: self.lineWidth)
                            .frame(width: proxy.size.width, height: self.lineWidth)
                        Line()
                            .stroke(self.stroke, lineWidth: self.lineWidth)
                            .frame(width: proxy.size.width, height: self.lineWidth)
                        Line()
                            .stroke(self.stroke, lineWidth: self.lineWidth)
                             .frame(width: proxy.size.width * 0.6, height: self.lineWidth)
                    }
            })
        }
        
    }
}

struct MenuButton_Previews: PreviewProvider {
    static var previews: some View {
        MenuButton(spacing: 8, lineWidth: 5, stroke: .blue)
        //.scaledToFit()
        .frame(width: 48)
    }
}
