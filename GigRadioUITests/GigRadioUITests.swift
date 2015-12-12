//
//  GigRadioUITests.swift
//  GigRadioUITests
//
//  Created by Michael Forrest on 11/12/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import XCTest

class GigRadioUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScreenshots() {
        
        
    }
    
}
