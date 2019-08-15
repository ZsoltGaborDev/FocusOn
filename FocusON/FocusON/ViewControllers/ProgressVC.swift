//
//  ProgressVC.swift
//  FocusON
//
//  Created by zsolt on 09/07/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import SwiftCharts
import CoreData


class ProgressVC: UIViewController {

    @IBOutlet weak var timeSegment: UISegmentedControl!
    @IBOutlet weak var chartView: UIView!
    
    var chart: Chart!
    var dataBase: [tableStruct]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.insertShadow()
        test()
        let history = HistoryVC()
        dataBase = history.tableArray

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func timeSegmentValueChanged(_ sender: Any) {
        
    }
    
    func test() {
        let chartConfig = BarsChartConfig(
            valsAxisConfig: ChartAxisConfig(from: 0, to: 8, by: 1)
        )
        
        let frame = CGRect(x: 10, y: 50, width: chartView.frame.width - 30, height: chartView.frame.height - 60)
        
        let chart = BarsChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Date",
            yTitle: "Achieved Tasks",
            bars: [
                ("A", 2),
                ("B", 4.5),
                ("C", 3),
                ("D", 5.4),
                ("E", 6.8),
                ("F", 0.5)
            ],
            color: UIColor.red,
            barWidth: 20
        )
        
        chartView.addSubview(chart.view)
        self.chart = chart
    }
}
