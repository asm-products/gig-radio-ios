//
//  GigRadioUITests.swift
//  GigRadioUITests
//
//  Created by Michael Forrest on 11/12/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import XCTest

class GigRadioUITests: XCTestCase {
    
    var server: TestingWebServer?
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        startFixturesWebServer(app)
        app.launch()
        print("App.launchEnvironment \(app.launchEnvironment)")
    }
    
    func startFixturesWebServer(app:XCUIApplication){
        server?.stop()
        let s = TestingWebServer(fixturesDirectory: "SnapshotFixtures")
        s.startWithPort(4000)
        app.launchEnvironment = [
            "SONGKICK_BASE_URL": "http://localhost:4000/songkick",
            "SOUNDCLOUD_BASE_URL": "http://localhost:4000/soundcloud",
            "RESET_ALL": "YES",
            "INITIAL_DATE": "2015-06-05"
        ]
        server = s
    }
    func testScreenshots() {
        
        let app = XCUIApplication()
        let okayButton = app.buttons["Okay"]
        okayButton.tap()
        okayButton.tap()
        okayButton.tap()
        snapshot("01_Onboarding")
        app.buttons["Got it!"].tap()
        
        snapshot("02_MainScreen")
        app.buttons["pause"].tap()
        
        app.collectionViews.buttons["8:00 PM at Loophole, Berlin, 0.3 mi away"].tap()
        
        app.tables.buttons["settings"].tap()
        app.buttons["Apple Maps"].tap()
        snapshot("03_GigDetail")
        
        app.navigationBars["Gig Info"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(1).tap()
        app.buttons["info button"].tap()
        
//        app.tables.otherElements["INFO"].tap()// should scroll to make this section visible automatically
        
        snapshot("04_Settings")
        
        app.navigationBars["Info and Preferences"].buttons["Done"].tap()
        app.collectionViews.buttons["star"].tap()
        
        app.buttons["menu"].tap()
        snapshot("05_SavedGigs")
        
        app.navigationBars["Saved gigs"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(1).tap()
        
    }
    
}
