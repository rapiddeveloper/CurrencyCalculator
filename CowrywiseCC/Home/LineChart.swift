//
//  LineChart.swift
//  CowrywiseCC
//
//  Created by Admin on 12/19/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
/*
 Abstract: A uikit view that displays a line chart in SwiftUI
 */

import SwiftUI
import Charts

struct LineChart: UIViewRepresentable {

    let lineChart = LineChartView()
    var entries: [ChartDataEntry]
    @Binding var pos: CGPoint
    @Binding var x: String
    @Binding var y: String
    
    let dateFormatter = DateFormatter()

    func makeUIView(context: Context) -> LineChartView {
      
        dateFormatter.locale = .current
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "dd MMM"
        
        lineChart.delegate = context.coordinator
        let customXAxisRenderer = XAxisRendererWithTicks(viewPortHandler: self.lineChart.viewPortHandler, axis: lineChart.xAxis, transformer: self.lineChart.getTransformer(forAxis: .left))
        
        let customYAxisRenderer = YAxisRendererWithTicks(viewPortHandler: lineChart.viewPortHandler, axis: lineChart.leftAxis, transformer: self.lineChart.getTransformer(forAxis: .left))
         
        lineChart.xAxisRenderer = customXAxisRenderer
        lineChart.leftYAxisRenderer = customYAxisRenderer
        lineChart.xAxis.valueFormatter = XAxisFormatter(representable: self)
        return lineChart
    }

    func updateUIView(_ uiView: LineChartView, context: Context) {
        
         let dataSet = LineChartDataSet(entries: entries)
         let salesChartData = LineChartData(dataSet: dataSet)
        
        if self.pos == .zero {
            uiView.highlightValue(nil)
        }
        
         uiView.data = salesChartData
         uiView.marker = Tooltip(representable: self)
         
         // customization
         configureChart(uiView)
         formatDataset(dataSet)
         formatLegend(uiView.legend)
         uiView.notifyDataSetChanged()
    }
    
    func makeCoordinator() -> Coordinator {
         Coordinator(parent: self)
    }
}

fileprivate class Tooltip: MarkerImage {
    
    
   // @Binding var point: CGPoint
    var representable: LineChart
    
    init(representable: LineChart) {
        self.representable = representable
    }
    
    override func draw(context: CGContext, point: CGPoint) {
        self.representable.pos = point
        
    }
    
    
}

fileprivate class XAxisFormatter: IndexAxisValueFormatter {
    
    var representable: LineChart
    
    init(representable: LineChart) {
        self.representable = representable
        super.init()
    }
    
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
 

        let date = Date(timeIntervalSince1970: value)

        return representable.dateFormatter.string(from: date)
    }
    
    
}

class XAxisRendererWithTicks: XAxisRenderer {

    override func drawLabel(context: CGContext, formattedLabel: String, x: CGFloat, y: CGFloat, attributes: [NSAttributedString.Key: Any], constrainedTo constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat) {

        super.drawLabel(context: context, formattedLabel: formattedLabel, x: x, y: y, attributes: attributes, constrainedTo: constrainedToSize, anchor: anchor, angleRadians: angleRadians)
        let boundary = CGRect(x: x-1, y: y - 4, width: 3, height: 3)
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.clear.cgColor)
        
        
         context.beginPath()

        context.move(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: x, y: self.viewPortHandler.contentBottom))
        context.addEllipse(in: boundary)
       // context.strokePath()
        context.drawPath(using: .fillStroke)
     }
}

class YAxisRendererWithTicks: YAxisRenderer {
    
    override func drawYLabels(context: CGContext, fixedPosition: CGFloat, positions: [CGPoint], offset: CGFloat, textAlign: NSTextAlignment) {
         
        super.drawYLabels(context: context, fixedPosition: 16, positions: positions, offset: 0, textAlign: .center)
        
     //   print(positions)
        for position in positions {
            let x = position.x + 20
            let y = position.y
            let boundary = CGRect(x: x, y: y, width: 30, height: 30)
             context.setFillColor(UIColor.red.cgColor)
 
              context.beginPath()

             context.move(to: CGPoint(x: x, y: y))
              context.addEllipse(in: boundary)
             context.strokePath()
             context.drawPath(using: .fillStroke)
        }
        
    }
}

 // MARK - sends values back to swiftui
class Coordinator: NSObject, ChartViewDelegate  {
    
    var representable: LineChart
    init(parent: LineChart/*, tooltip: Tooltip*/) {
        self.representable = parent
     }
    

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry,  highlight: Highlight) {
        
        let timeInterval = entry.value(forKey: "x") as! Double
        let sales = entry.value(forKey: "y") as! Double
        let date = Date(timeIntervalSince1970: timeInterval)
        
        representable.x = representable.dateFormatter.string(from: date)
        representable.y = String(format: "%.5f", sales)
    }
    
}

func configureChart(_ uiView: LineChartView) {
    
    uiView.dragEnabled = false
    uiView.doubleTapToZoomEnabled = false
 
    uiView.xAxis.drawGridLinesEnabled = false
    uiView.xAxis.labelPosition = .bottom
    uiView.xAxis.drawAxisLineEnabled = false
    uiView.xAxis.setLabelCount(5, force: true)
    uiView.xAxis.labelTextColor = UIColor.white
    
    uiView.rightAxis.enabled = false
    uiView.leftAxis.drawGridLinesEnabled = false
    uiView.leftAxis.drawAxisLineEnabled = false
    uiView.leftAxis.drawLabelsEnabled = false
    
    uiView.minOffset = 16
}

func formatDataset( _ dataset: LineChartDataSet) {
    
    let gradientColors = [
                          ChartColorTemplates.colorFromString("#0A79FE").cgColor,
                          ChartColorTemplates.colorFromString("#4C9EFF").cgColor,
                          ChartColorTemplates.colorFromString("#4C9EFF").cgColor]
    let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
    
    dataset.fillAlpha = 1
    dataset.fill = LinearGradientFill(gradient: gradient, angle: 90)
    dataset.mode = .cubicBezier
    dataset.drawValuesEnabled = false
    dataset.setColor(.clear)
    dataset.drawCirclesEnabled = false
    dataset.drawFilledEnabled = true
    dataset.drawVerticalHighlightIndicatorEnabled = false
    dataset.drawHorizontalHighlightIndicatorEnabled = false
}

func formatLegend(_ uiView: Legend) {
    uiView.enabled = false
    
}

struct LineChart_Previews: PreviewProvider {
    
    static var appData: AppData {
        let appData = AppData()
        return appData
    }
    
    static var previews: some View {
        
        /* {
               "date": "1/1/2019",
               "total_sales": 4745.181
           },
           {
               "date": "1/10/2019",
               "total_sales": 3560.949
           },
           {
               "date": "1/11/2019",
               "total_sales": 2114.9625
           },
           {
               "date": "1/12/2019",
               "total_sales": 5184.7635
           },
           {
               "date": "1/13/2019",
           "total_sales": 2451.204
         },
         {
           "date": "1/14/2019",
           "total_sales": 3966.6165
         },
         {
           "date": "1/15/2019",
           "total_sales": 5944.26
         },
         {
           "date": "1/16/2019",
           "total_sales": 4289.082
         },
         {
           "date": "1/17/2019",
           "total_sales": 3142.755
         },
         {
           "date": "1/18/2019",
           "total_sales": 2780.4735
         },
         {
           "date": "1/19/2019",
           "total_sales": 4914.7245
         },
         {
           "date": "1/2/2019",
           "total_sales": 1945.503
         },
         {
           "date": "1/20/2019",
           "total_sales": 3655.449
         },
         {
           "date": "1/21/2019",
           "total_sales": 2392.0995
         },
         {
           "date": "1/22/2019",
           "total_sales": 1704.7695
         },
         {
           "date": "1/23/2019",
           "total_sales": 5994.1875
         },
         {
           "date": "1/24/2019",
           "total_sales": 5402.0505
         },
         {
           "date": "1/25/2019",
           "total_sales": 4700.367
         },
         {
           "date": "1/26/2019",
           "total_sales": 4457.5125
         },
         {
           "date": "1/27/2019",
           "total_sales": 4635.897
         },
         {
           "date": "1/28/2019",
           "total_sales": 4999.7115
         },
         {
           "date": "1/29/2019",
           "total_sales": 3516.5655
         },
         {
           "date": "1/3/2019",
           "total_sales": 2078.1285
         },
         {
           "date": "1/30/2019",
           "total_sales": 2558.262
         },
         {
           "date": "1/31/2019",
           "total_sales": 5232.4965
         }*/
     
      //  print("showing")
     //   print(appData.conversionInfo.entries)
        return VStack {
            Text("Chart")
            LineChart(entries: appData.conversionInfo.entries, pos: .constant(.zero), x: .constant(""), y: .constant(""))
        }
    }
}
 
