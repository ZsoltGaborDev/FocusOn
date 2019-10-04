//
//  HistoryTests.swift
//  FocusONTests
//
//  Created by zsolt on 03/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import XCTest
@testable import FocusON

class HistoryTests: XCTestCase {

    var controller: HistoryVC!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.controller = (storyboard.instantiateViewController(withIdentifier: "history") as! HistoryVC)
        self.controller.loadView()
        self.controller.viewDidLoad()
        self.controller.viewDidAppear(true)
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_title_is_FocusOn_History() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "history") as! HistoryVC
        let _ = controller.view
        XCTAssertEqual("FocusOn History", controller.viewTitle!.text!)
    }
    func test_title_is_FocusOn_Progress() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "progress") as! ProgressVC
        let _ = controller.view
        XCTAssertEqual("FocusOn Progress", controller.pageTitleLabel!.text!)
    }
    func testHasATableView() {
        XCTAssertNotNil(controller.tableView)
    }
    func testTableViewHasDelegate() {
        XCTAssertNotNil(controller.tableView.delegate)
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
        if let cell = (controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? HistoryCell) {
            let actualReuseIdentifer = cell.reuseIdentifier
            let expectedReuseIdentifier = "historyCell"
            XCTAssertEqual(actualReuseIdentifer, expectedReuseIdentifier)
        }
        if let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? HelpHistoryCell {
            let actualReuseIdentifer = cell.reuseIdentifier
            let expectedReuseIdentifier = "helpHistoryCell"
            XCTAssertEqual(actualReuseIdentifer, expectedReuseIdentifier)
        }
    }
    func testTableViewCellHeaderText() {
        var section = 0
        if section == 0 {
            let actualHeaderText = controller.tableView(controller.tableView, titleForHeaderInSection: 0)
            let expectedHeaderText = "Today"
            XCTAssertEqual(actualHeaderText, expectedHeaderText)
        }
        section = 1
        if section == 1 {
            let actualHeaderText = controller.tableView(controller.tableView, titleForHeaderInSection: 1)
            let expectedHeaderText = "Last period..."
            XCTAssertEqual(actualHeaderText, expectedHeaderText)
        }
    }
    func testTableViewHasCells() {
        if let cell = controller.tableView.dequeueReusableCell(withIdentifier: "historyCell") {
            XCTAssertNotNil(cell,
                            "TableView should be able to dequeue cell with identifier: 'historyCell'")
        }
        if let cell = controller.tableView.dequeueReusableCell(withIdentifier: "helpHistoryCell") {
            XCTAssertNotNil(cell,
                            "TableView should be able to dequeue cell with identifier: 'helpHistoryCell'")
        }
        
    }
}
