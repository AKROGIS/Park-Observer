//
//  AppDelegateTests.swift
//  Park ObserverTests
//
//  Created by Regan Sarwas on 8/28/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class AppDelegateTests: XCTestCase {

  func testSampleSurveyExists() {
    let protocolPath = AppFile.init(type: .surveyProtocol, name: "Sample").url.path
    XCTAssertTrue(FileManager.default.fileExists(atPath: protocolPath))
    let surveyPath = AppFile.init(type: .survey, name: "Sample Survey").url.path
    XCTAssertTrue(FileManager.default.fileExists(atPath: surveyPath))
  }

  func testLoadSampleSurvey() {
    // Given:
    let surveyName = "Sample Survey"
    let expectation1 = expectation(description: "Survey \(surveyName) was loaded")

    print("Loading \(surveyName)...")
    Survey.load(surveyName) { (result) in
      switch result {
      case .success(let survey):
        survey.close()
        break
      case .failure(let error):
        print(error)
        XCTAssertTrue(false)
        break
      }
      expectation1.fulfill()
    }

    waitForExpectations(timeout: 1) { error in
      if let error = error {
        XCTFail("Test timed out waiting unmet expectationns: \(error)")
      }
    }
  }

}
