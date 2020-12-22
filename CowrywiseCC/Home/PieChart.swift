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
    @Binding var category: Wine.Category
    
    func makeUIView(context: Context) -> PieChartView {
        pieChart.delegate = context.coordinator
    
        return pieChart
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        
         let dataSet = PieChartDataSet(entries: entries)
         let pieChartData = PieChartData(dataSet: dataSet)
        // customization
         dataSet.colors = ChartColorTemplates.material()
         uiView.data = pieChartData
         configureChart(uiView)
         formatCenter(uiView)
         formatDescription(uiView.chartDescription)
         formatLegend(uiView.legend)
         formatDataset(dataSet)
         uiView.notifyDataSetChanged()
    }
    
    class Coordinator: NSCoder, ChartViewDelegate {
        
        var parent: PieChart
        init(parent: PieChart) {
            self.parent = parent
        }
        
        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            let labelText = entry.value(forKey: "label") as! String
            let value = Int(entry.value(forKey: "value") as! Double)
            parent.pieChart.centerText = """
                \(labelText)
                \(value)
                """
        }
    }
    
    func makeCoordinator() -> Coordinator {
         Coordinator(parent: self)
    }
    

    
    // functions to customize chart data
    
    func configureChart(_ pieChart: PieChartView) {
        pieChart.rotationEnabled = false
        pieChart.animate(xAxisDuration: 0.5, easingOption: .easeInOutCirc)
        pieChart.drawEntryLabelsEnabled = false
        pieChart.highlightValue(x: -1, dataSetIndex: 0, callDelegate: false)
    }
    
    func formatCenter(_ pieChart: PieChartView) {
        pieChart.centerText = category.rawValue.capitalized
        // center the centerText
        pieChart.centerTextRadiusPercent = 0.95
    }
    
    func formatDescription(_ description: Description) {
        description.text = category.rawValue.capitalized
        description.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    func formatLegend(_ legend: Legend) {
        legend.enabled = false
    }
    
    func formatDataset(_ dataSet: ChartDataSet) {
        dataSet.drawValuesEnabled = false
    }
    
    
}

struct PieChart_Previews: PreviewProvider {
     
    static var previews: some View {
        PieChart(entries: Wine.entriesForWines(Wine.allWines, category: .variety), category: .constant(.variety))
    }
}
