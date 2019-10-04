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
    @IBOutlet weak var chartView: ChartBaseView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    
    var chart: Chart!
    let dataController = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.insertShadow()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.progressBar(isGoal: false)
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
        if self.dataController.fetchTask(date: date) != nil {
            let data = self.dataController.fetchTask(date: date) as! Task
            if data.achievedTasks != nil {
                let temp = data.achievedTasks as! [String]
                return Double(temp.count)
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    func catchGoalNumber(date: Date) -> Double {
        if self.dataController.fetchTask(date: date) != nil {
            let data = self.dataController.fetchTask(date: date) as! Task
            if data.achievedGoal != nil {
                return 1
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    func progressBar(isGoal: Bool) {
        let chartConfig = BarsChartConfig(
            valsAxisConfig: ChartAxisConfig(from: 0, to: 8, by: 1)
        )
        let frame = CGRect(x: 10, y: 50, width: chartView.frame.size.width - 30 , height: chartView.frame.size.height - 60)
        let yTitle: String
        let bars: [(String, Double)]
        if isGoal {
            yTitle = "Achieved Goal"
            bars = [
                ("\(dataController.dateCaption(for: dataController.today))", catchGoalNumber(date: dataController.today)),
                ("\(dataController.dateCaption(for: dataController.yesterday))", catchGoalNumber(date: dataController.yesterday)),
                ("\(dataController.dateCaption(for: dataController.twoDaysAgo))", catchGoalNumber(date: dataController.twoDaysAgo)),
                ("\(dataController.dateCaption(for: dataController.threeDaysAgo))", catchGoalNumber(date: dataController.threeDaysAgo)),
            ]
        } else {
            yTitle = "Achieved Tasks"
            bars = [
                ("\(dataController.dateCaption(for: dataController.today))", catchTaskNumber(date: dataController.today)),
                ("\(dataController.dateCaption(for: dataController.yesterday))", catchTaskNumber(date: dataController.yesterday)),
                ("\(dataController.dateCaption(for: dataController.twoDaysAgo))", catchTaskNumber(date: dataController.twoDaysAgo)),
                ("\(dataController.dateCaption(for: dataController.threeDaysAgo))", catchTaskNumber(date: dataController.threeDaysAgo)),
            ]
        }
        let chart = BarsChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Date",
            yTitle: yTitle,
            bars: bars,
            color: UIColor.red,
            barWidth: 20
        )
        chartView.addSubview(chart.view)
        self.chart = chart
    }
}
