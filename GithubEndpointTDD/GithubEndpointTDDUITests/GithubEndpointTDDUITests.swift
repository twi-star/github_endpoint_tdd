//
//  GithubEndpointTDDUITests.swift
//  GithubEndpointTDDUITests
//
//  Created by Julian on 2021/2/17.
//

import XCTest

class GithubEndpointTDDUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        _ = app.wait(for: .runningBackground, timeout: 3)
        let oldTitle = app.navigationBars.staticTexts
        _ = app.wait(for: .runningForeground, timeout: 7)
        let newTitle = app.navigationBars.staticTexts
        XCTAssertTrue(oldTitle != newTitle, "未完成首页endpoint数据刷新")
        
        app.navigationBars.buttons["HISTORY"].tap()
        app.swipeDown()
        _ = app.wait(for: .runningBackground, timeout: 7)
        app.terminate()
    }
}
