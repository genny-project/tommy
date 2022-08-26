//
//  FastlaneScreenshots.swift
//  FastlaneScreenshots
//
//  Created by Chen on 26/8/2022.
//

import XCTest

class FastlaneScreenshots: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        snapshot("01Welcome")
        
        app.buttons["Login"].tap()
        app.alerts["“tommy” Wants to Use “gada.io” to Sign In"].scrollViews.otherElements.buttons["Continue"].tap()
        snapshot("02LoginScreen")
        
        let logInToLojingElement = app/*@START_MENU_TOKEN@*/.webViews/*[[".otherElements[\"BrowserView?WebViewProcessID=31163\"].webViews",".webViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.webViews.webViews.otherElements["Log in to lojing"]
        logInToLojingElement.children(matching: .textField).element.tap()
        logInToLojingElement.children(matching: .secureTextField).element.tap()
        app/*@START_MENU_TOKEN@*/.webViews.webViews.webViews.buttons["Log In"]/*[[".otherElements[\"BrowserView?WebViewProcessID=31163\"].webViews.webViews.webViews",".otherElements[\"Log in to lojing\"].buttons[\"Log In\"]",".buttons[\"Log In\"]",".webViews.webViews.webViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        snapshot("03Dashboard")
        
        let openNavigationMenuButton = app.buttons["Open navigation menu"]
        openNavigationMenuButton.tap()
        snapshot("04Navigation")
        
        let addPropertyButton = app.buttons["Add Property"]
        addPropertyButton.tap()
        snapshot("05AddProperty")
        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
