//
//  UIKIT_TMDBUITests.swift
//  UIKIT-TMDBUITests
//
//  Created by Marina De Pazzi on 12/05/22.
//

import XCTest

class UIKIT_TMDBUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGoingFromHomeScreenToDetails() {
        let app = XCUIApplication()
        app.launch()
        
        app.tables.staticTexts["The Contractor"].tap()
        app.navigationBars["Details"].buttons["Movies"].tap()
    }
    
    func testSearchMovieInSearchBarAndGoToDetails() {
        let app = XCUIApplication()
        app.launch()

        app.navigationBars["Movies"].searchFields["Search"].tap()
        app.searchFields["Search"].typeText("Uncharted")
        app.tables.staticTexts["Uncharted"].tap()
        app.navigationBars["Details"].buttons["Movies"].tap()

    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
