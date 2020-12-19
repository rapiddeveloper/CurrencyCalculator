//
//  RateChartView.swift
//  CowrywiseCC
//
//  Created by Admin on 12/19/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import SwiftUI
import Charts

struct PieChart: UIViewRepresentable {
    
    let pieChart = PieChartView()
    var entries: [PieChartDataEntry]
    
    
    func makeUIView(context: Context) -> PieChartView {
        pieChart.delegate = context.coordinator
        return pieChart
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        
         let dataSet = PieChartDataSet(entries: entries)
         let pieChartData = PieChartData(dataSet: dataSet)
         uiView.data = pieChartData
    }
    
    class Coordinator: NSCoder, ChartViewDelegate {
        
        var parent: PieChart
        init(parent: PieChart) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
         Coordinator(parent: self)
    }
    
    
}

struct PieChart_Previews: PreviewProvider {
     
    static var previews: some View {
        PieChart(entries: Wine.entriesForWines(Wine.allWines, category: .variety))
    }
}
