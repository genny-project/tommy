//
//  tommyUITests.swift
//  tommyUITests
//
//  Created by Barad Ghimire on 17/11/20.
//

import XCTest

class tommyUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        let app = XCUIApplication()
             setupSnapshot(app)
             app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testExample() throws {
       
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        //app.launch()
        wait()
        wait()
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
           //  app.launch()
            XCUIDevice.shared.orientation = .portrait
        
        snapshot("00-tommy-splashscreen")
       
        app.buttons["Login"].tap()
        wait()
        snapshot("01-tommy-keycloak-prompt")
        wait()
//        app.alerts["“InternMatch” Wants to Use “gada.io” to Sign In"].scrollViews.otherElements.buttons["Continue"].tap()
      //  app.buttons.firstMatch.tap()
        app.children(matching: .button).element(boundBy: 1).tap()
    
        wait()
        
//      app.textFields["Login"].typeText("barad.ghimire+intern@outcomelife.com.au")
        snapshot("02-tommy-keycloak-login")
/*
        wait()
        let bKey = app/*@START_MENU_TOKEN@*/.keys["b"]/*[[".keyboards.keys[\"b\"]",".keys[\"b\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        bKey.tap()
        bKey.tap()
        
        let aKey = app/*@START_MENU_TOKEN@*/.keys["a"]/*[[".keyboards.keys[\"a\"]",".keys[\"a\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        aKey.tap()
        aKey.tap()
        
        let rKey = app/*@START_MENU_TOKEN@*/.keys["r"]/*[[".keyboards.keys[\"r\"]",".keys[\"r\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        rKey.tap()
        rKey.tap()
        aKey.tap()
        aKey.tap()
        
        let dKey = app/*@START_MENU_TOKEN@*/.keys["d"]/*[[".keyboards.keys[\"d\"]",".keys[\"d\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        dKey.tap()
        dKey.tap()
        
        let key = app/*@START_MENU_TOKEN@*/.keys["."]/*[[".keyboards.keys[\".\"]",".keys[\".\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key.tap()
        key.tap()
        
        let gKey = app/*@START_MENU_TOKEN@*/.keys["g"]/*[[".keyboards.keys[\"g\"]",".keys[\"g\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        gKey.tap()
        gKey.tap()
        
        let hKey = app/*@START_MENU_TOKEN@*/.keys["h"]/*[[".keyboards.keys[\"h\"]",".keys[\"h\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        hKey.tap()
        hKey.tap()
        
        let iKey = app/*@START_MENU_TOKEN@*/.keys["i"]/*[[".keyboards.keys[\"i\"]",".keys[\"i\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        iKey.tap()
        iKey.tap()
        
        let mKey = app/*@START_MENU_TOKEN@*/.keys["m"]/*[[".keyboards.keys[\"m\"]",".keys[\"m\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        mKey.tap()
        mKey.tap()
        iKey.tap()
        iKey.tap()
        rKey.tap()
        rKey.tap()
        
        let eKey = app/*@START_MENU_TOKEN@*/.keys["e"]/*[[".keyboards.keys[\"e\"]",".keys[\"e\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        eKey.tap()
        eKey.tap()
        
        let moreKey = app.keyboards.children(matching: .other).element.children(matching: .other).element/*@START_MENU_TOKEN@*/.children(matching: .key).matching(identifier: "more").element(boundBy: 0)/*[[".children(matching: .key).matching(identifier: \"numbers\").element(boundBy: 0)",".children(matching: .key).matching(identifier: \"more\").element(boundBy: 0)"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        moreKey.tap()
        moreKey.tap()
        
      
        app/*@START_MENU_TOKEN@*/.staticTexts["OK"]/*[[".keyboards",".buttons[\"OK\"].staticTexts[\"OK\"]",".staticTexts[\"OK\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let key2 = app/*@START_MENU_TOKEN@*/.keys["@"]/*[[".keyboards.keys[\"@\"]",".keys[\"@\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key2.tap()
        key2.tap()
        
        let deleteKey = app/*@START_MENU_TOKEN@*/.keys["delete"]/*[[".keyboards.keys[\"delete\"]",".keys[\"delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        deleteKey.tap()
        deleteKey.tap()
        
        let key3 = app/*@START_MENU_TOKEN@*/.keys["+"]/*[[".keyboards.keys[\"+\"]",".keys[\"+\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key3.tap()
        key3.tap()
        iKey.tap()
        iKey.tap()
        
        let nKey = app/*@START_MENU_TOKEN@*/.keys["n"]/*[[".keyboards.keys[\"n\"]",".keys[\"n\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        nKey.tap()
        nKey.tap()
        
        let tKey = app/*@START_MENU_TOKEN@*/.keys["t"]/*[[".keyboards.keys[\"t\"]",".keys[\"t\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        tKey.tap()
        tKey.tap()
        eKey.tap()
        eKey.tap()
        rKey.tap()
        rKey.tap()
        nKey.tap()
        nKey.tap()
        key2.tap()
        key2.tap()
        
        let oKey = app/*@START_MENU_TOKEN@*/.keys["o"]/*[[".keyboards.keys[\"o\"]",".keys[\"o\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        oKey.tap()
        oKey.tap()
        
        let uKey = app/*@START_MENU_TOKEN@*/.keys["u"]/*[[".keyboards.keys[\"u\"]",".keys[\"u\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        uKey.tap()
        tKey.tap()
        tKey.tap()
        
        let cKey = app/*@START_MENU_TOKEN@*/.keys["c"]/*[[".keyboards.keys[\"c\"]",".keys[\"c\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        cKey.tap()
        cKey.tap()
        oKey.tap()
        oKey.tap()
        mKey.tap()
        mKey.tap()
        eKey.tap()
        eKey.tap()
        app/*@START_MENU_TOKEN@*/.keys["l"]/*[[".keyboards.keys[\"l\"]",".keys[\"l\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        iKey.tap()
        app/*@START_MENU_TOKEN@*/.keys["f"]/*[[".keyboards.keys[\"f\"]",".keys[\"f\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        eKey.tap()
        eKey.tap()
        key.tap()
        cKey.tap()
        cKey.tap()
        oKey.tap()
        oKey.tap()
        mKey.tap()
        mKey.tap()
        key.tap()
        key.tap()
        aKey.tap()
        aKey.tap()
        uKey.tap()
        uKey.tap()
        app/*@START_MENU_TOKEN@*/.webViews/*[[".otherElements[\"BrowserView?WebViewProcessID=50346\"].webViews",".webViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.webViews.webViews.otherElements["Log in to internmatch"].children(matching: .secureTextField).element.tap()
        
        let pKey = app/*@START_MENU_TOKEN@*/.keys["p"]/*[[".keyboards.keys[\"p\"]",".keys[\"p\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        pKey.tap()
        pKey.tap()
        aKey.tap()
        aKey.tap()
        
        let sKey = app/*@START_MENU_TOKEN@*/.keys["s"]/*[[".keyboards.keys[\"s\"]",".keys[\"s\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        sKey.tap()
        sKey.tap()
        sKey.tap()
        app/*@START_MENU_TOKEN@*/.keys["w"]/*[[".keyboards.keys[\"w\"]",".keys[\"w\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        oKey.tap()
        rKey.tap()
        dKey.tap()
        dKey.tap()

        let key4 = app/*@START_MENU_TOKEN@*/.keys["1"]/*[[".keyboards.keys[\"1\"]",".keys[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        wait()
        snapshot("03-tommy-keycloak-password-entered")

        key4.tap()
        key4.tap()
        app/*@START_MENU_TOKEN@*/.webViews.webViews.webViews.buttons["Log In"]/*[[".otherElements[\"BrowserView?WebViewProcessID=50346\"].webViews.webViews.webViews",".otherElements[\"Log in to internmatch\"].buttons[\"Log In\"]",".buttons[\"Log In\"]",".webViews.webViews.webViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        wait()
        snapshot("04-tommy-dashboard")

        app.otherElements["View Journals\nTab 2 of 3"].tap()
        wait()
        snapshot("05-tommy-journals")

        app.otherElements["Approved(0)\nTab 2 of 3"].tap()
        wait()
        snapshot("06-tommy-approved")
                */
        //
        wait()
    }
    
    /*
    func myTestLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
     */
    func takeScreenShots() {
       /* do {
            try testExample()
         //   try mytestExample()
        } catch  {
            print("effed up")
        }
        */
    }
    
    
    
    func wait (){
        sleep(1)
    }
}
