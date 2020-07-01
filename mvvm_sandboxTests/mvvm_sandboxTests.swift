//
//  mvvm_sandboxTests.swift
//  mvvm_sandboxTests
//
//  Created by Omar Eduardo Gomez Padilla on 6/28/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import XCTest
@testable import mvvm_sandbox

class mvvm_sandboxTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHome() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expectation = self.expectation(description: "json data")
        
        var result: Home?
        URLSession.shared.doDecodeTask(Home.self, from: PPOCEndPoint.home.url) { home, error in
            result = home
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(result, "Home must not be nil")


    }

}
