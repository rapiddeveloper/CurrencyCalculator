//
//  RateTrend.swift
//  CowrywiseCC
//
//  Created by Admin on 12/22/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import SwiftUI

struct RoundedCorner: SwiftUI.Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct RateTrend: View {
    
    @EnvironmentObject var appData: AppData
    
    @State private var pos: CGPoint = .zero
    @State private var x: String = ""
    @State private var y: String = ""
   // @State private var mode: Int = 0 // 30 days

    let width: CGFloat = 100
    let height: CGFloat = 100
    let dotWidth: CGFloat = 16
    let dotHeight: CGFloat = 16
    
    var tooltipBaseInfo: String {
         return "1 \(appData.conversionInfo.baseCurrency) = \(y)"
    }

    
    var activeDotPos: CGPoint {
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        if pos.x > 0 {
            x = pos.x// - (dotWidth * 0.25)
        } else {
            x = pos.x
        }
        
        if pos.y > 0 {
            y = pos.y - (dotHeight * 0.5)
        }else {
            y = pos.y
        }
        
        return CGPoint(x: x, y: y)
        
    }
    
    var tooltipPos: CGPoint {
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        if activeDotPos.x > 0 {
            x = activeDotPos.x + 72
        } else {
            x = activeDotPos.x
        }
        
        if activeDotPos.y > 0 {
            y = activeDotPos.y - 56
        } else {
            y = activeDotPos.y
        }
        
        return CGPoint(x: x, y: y)
        
    }
    
    var mode: Int {
        appData.conversionInfo.timeframeMode
    }
    
    var body: some View {
        
        VStack {
            HStack {
                Button(action: {
                    self.pos = .zero
                    //self.mode = 0
                    self.appData.updateConversionInfo(mode: 0)
                    self.appData.getRateTimeseries()

                }, label: {
                    VStack(alignment: .center, spacing: 8) {
                        Text("30 Days Past")
                            .fontWeight(.medium)
                            .foregroundColor(mode == 0 ? Color.white : Color.gray)
                        Circle()
                            .fill(mode == 0 ? Color.green : Color.clear)
                            .frame(width: 10, height: 10)
                    }
                })
                Spacer()
                Button(action: {
                    self.pos = .zero
                    //self.mode = 1
                    self.appData.updateConversionInfo(mode: 1)
                    self.appData.getRateTimeseries()
                }, label: {
                    VStack(alignment: .center, spacing: 8) {
                        Text("90 Days Past")
                            .fontWeight(.medium)
                            .foregroundColor(mode == 1 ? Color.white : Color.gray)
                        Circle()
                            .fill(mode == 1 ? Color.green : Color.clear)
                            .frame(width: 10, height: 10)
                    }
                })
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 32)
           
            LineChart(entries: appData.conversionInfo.entries, pos: $pos, x: $x, y: $y)
                .overlay (
                    GeometryReader { proxy in
                        if self.pos != .zero {
                            Tooltip(x: self.x, y: self.tooltipBaseInfo, cornerRadius: 20, fill: .green)
                                // .frame(width: self.width)
                                .position(self.tooltipPos)
                            Group {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: self.dotWidth, height: self.dotHeight)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 1.0)
                                )
                            }
                            .position(self.activeDotPos)
                        }
                    }
            )
        }
       .background(Color(red: 4/255, green: 96/255, blue: 209/255))
       
    }
}

struct RateTrend_Previews: PreviewProvider {
    static var previews: some View {
        RateTrend().environmentObject(AppData())
    }
}


fileprivate struct Tooltip: View {
    
    let x: String
    let y: String
    let cornerRadius: CGFloat
    let fill: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
           Text(x)
                .fontWeight(.medium)
           Text(y)
           
        }
        .font(.caption)
        .foregroundColor(.white)
        .padding()
         .background(
            RoundedCorner(radius: cornerRadius, corners: [.bottomRight, .topLeft, .topRight])
            .fill(fill)
        )
    }
}

