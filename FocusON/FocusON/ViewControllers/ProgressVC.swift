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
    let dataController = DataController()
    var task = Task()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.insertShadow()
        
        let data = self.dataController.fetchTask(date: dataController.today)
        task = data as! Task
        progressBar(isGoal: false)
        
    }
    @IBAction func timeSegmentValueChanged(_ sender: Any) {
        if timeSegment.selectedSegmentIndex == 0 {
            chart.clearView()
            progressBar(isGoal: false)
        } else  if timeSegment.selectedSegmentIndex == 1 {
            chart.clearView()
            progressBar(isGoal: true)
        }
    }
    func catchTaskNumber(date: Date) -> Double {
        if task.achievedTasks != nil {
            let temp = task.achievedTasks as! [String]
            return Double(temp.count)
        } else {
            return 0
        }
    }
    func catchGoalNumber(date: Date) -> Double {
        if task.achievedGoal != nil {
            return 1
        } else {
            return 0
        }
    }
    func progressBar(isGoal: Bool) {
        let chartConfig = BarsChartConfig(
            valsAxisConfig: ChartAxisConfig(from: 0, to: 8, by: 1)
        )
        let frame = CGRect(x: 10, y: 50, width: chartView.frame.width - 30, height: chartView.frame.height - 60)
        let yTitle: String
        let bars: [(String, Double)]
        if isGoal {
            yTitle = "Achieved Goal"
            bars = [
                ("\(dataController.dateCaption(for: dataController.today))", catchGoalNumber(date:dataController.today)  )]
        } else {
            yTitle = "Achieved Tasks"
            bars = [
                ("\(dataController.dateCaption(for: dataController.today))", catchTaskNumber(date: dataController.today)  )]
        }
        let chart = BarsChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Date",
            yTitle: yTitle,
            bars: bars,
//                ("B", 4.5),
//                ("C", 3),
//                ("D", 5.4),
//                ("E", 6.8),
//                ("F", 0.5)
            color: UIColor.red,
            barWidth: 20
        )
        chartView.addSubview(chart.view)
        self.chart = chart
    }
}
