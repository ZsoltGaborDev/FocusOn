//
//  ProgressTests.swift
//  FocusONTests
//
//  Created by zsolt on 04/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import XCTest
@testable import FocusON
@testable import SwiftCharts

class ProgressTests: XCTestCase {

    var controller: ProgressVC!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.controller = (storyboard.instantiateViewController(withIdentifier: "progress") as! ProgressVC)
        self.controller.loadView()
        self.controller.viewDidLoad()
        self.controller.viewDidLayoutSubviews()
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testHasATimeSegment() {
        XCTAssertNotNil(controller.timeSegment)
    }
    func testTitleIsFocusOnProgress() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "progress") as! ProgressVC
        let _ = controller.view
        XCTAssertEqual("FocusOn Progress", controller.pageTitleLabel!.text!)
    }

}
