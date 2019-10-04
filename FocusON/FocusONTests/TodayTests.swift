//
//  TodayTests.swift
//  FocusONTests
//
//  Created by zsolt on 02/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import XCTest
@testable import FocusON

class TodayTests: XCTestCase {
    
     var controller: TodayVC!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.controller = (storyboard.instantiateViewController(withIdentifier: "today") as! TodayVC)
        self.controller.loadView()
        self.controller.viewDidLoad()
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_title_is_FocusON_Today() {
        XCTAssertEqual("FocusOn Today", controller.viewTitleLabel!.text!)
    }
    func test_goal_placeholder_is_your_goal_of_today_here() {
        XCTAssertEqual("your goal of today here...", controller.goalLabel!.text!)
    }
    func test_update_progress() {
        //no task
        controller.captionTaskArray = []
        controller.completedTaskArray = []
        controller.updateProgress()
        XCTAssertEqual(controller.progressLabel.text!, "It's lonely here - add some tasks!")
        
        //no completed task
        controller.captionTaskArray = ["one", "two"]
        controller.completedTaskArray = []
        let totalTask = controller.captionTaskArray.count
        controller.updateProgress()
        XCTAssertEqual(controller.progressLabel.text!, "Get started - \(totalTask) to go!")
        
        //all completed task
        controller.captionTaskArray = ["one", "two"]
        controller.completedTaskArray = ["one", "two"]
        controller.updateProgress()
        XCTAssertEqual(controller.progressLabel.text!, "Well done: GOAL completed!")
        
        //not all completed task
        controller.captionTaskArray = ["one", "two"]
        controller.completedTaskArray = ["one"]
        let completed = controller.completedTaskArray.count
        controller.updateProgress()
        XCTAssertEqual(controller.progressLabel.text!, "\(completed) down \(totalTask - completed) to go!")
    }
    func testHasATableView() {
        XCTAssertNotNil(controller.tableView)
    }
    func testTableViewHasDelegate() {
        XCTAssertNotNil(controller.tableView.delegate)
    }
    func testTableViewConfromsToTableViewDelegateProtocol() {
        XCTAssertTrue(controller.conforms(to: UITableViewDelegate.self))
        XCTAssertTrue(controller.responds(to: #selector(controller.tableView(_:didSelectRowAt:))))
    }
    func testTableViewHasDataSource() {
        XCTAssertNotNil(controller.tableView.dataSource)
    }
    func testTableViewConformsToTableViewDataSourceProtocol() {
        XCTAssertTrue(controller.conforms(to: UITableViewDataSource.self))
        XCTAssertTrue(controller.responds(to: #selector(controller.numberOfSections(in:))))
        XCTAssertTrue(controller.responds(to: #selector(controller.tableView(_:numberOfRowsInSection:))))
        XCTAssertTrue(controller.responds(to: #selector(controller.tableView(_:cellForRowAt:))))
    }
    func testTableViewCellHasReuseIdentifier() {
        let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? TaskTableViewCell
        let actualReuseIdentifer = cell?.reuseIdentifier
        let expectedReuseIdentifier = "taskCellID"
        XCTAssertEqual(actualReuseIdentifer, expectedReuseIdentifier)
    }
    func testTableCellHasCorrectLabelText() {
        
        for i in 0..<controller.captionTaskArray.count {
            let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: i, section: 0)) as? TaskTableViewCell
            XCTAssertEqual(cell?.taskLabel.text, controller.captionTaskArray[i])
        }
    }
}
