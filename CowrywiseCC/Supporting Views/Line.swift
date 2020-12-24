//
//  Line.swift
//  CowrywiseCC
//
//  Created by Admin on 12/24/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import SwiftUI

struct Line: Shape {
     
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        let width = rect.width
     
        let posX = rect.origin.x
        let posY = rect.origin.y
        
        path.move(to: CGPoint(x: posX, y: posY))
        path.addLine(to: CGPoint(x: posX + width, y: posY))
        
         return path
    }
}
