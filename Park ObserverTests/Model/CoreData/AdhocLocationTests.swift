//
//  AdhocLocationTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 6/5/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class AdhocLocationTests: XCTestCase {

  func testLocation() {
    // Given:
    // Create a new survey from a protocol file
    let surveyName = "My Survey"
    let existingProtocol = "/Sample Protocols/Sample Protocol.v2.obsprot"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingProtocol
    let existingUrl = URL(fileURLWithPath: existingPath)
    let newFile = try? FileManager.default.addToApp(url: existingUrl)
    guard let file = newFile, file.type == .surveyProtocol else {
      XCTAssertTrue(false)
      return
    }
    let protocolName = file.name
    defer {
      try? file.delete()
    }
    guard let newSurveyName = try? Survey.create(surveyName, from: protocolName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: newSurveyName).delete()
    }
    //When:
    // survey created, lets try and load it
    let expectation1 = expectation(description: "Survey \(newSurveyName) was loaded")
    Survey.load(newSurveyName) { (result) in
      switch result {
      case .success(let survey):
        do {

          // Then:

          // Test AdhocLocation.location getter
          let adhoc = AdhocLocation.new(in: survey.viewContext)
          XCTAssertNil(adhoc.latitude)
          XCTAssertNil(adhoc.longitude)
          XCTAssertNil(adhoc.location)
          let lat = 62.1234
          let lon = -154.3210
          adhoc.latitude = lat
          XCTAssertNotNil(adhoc.latitude)
          XCTAssertNil(adhoc.longitude)
          XCTAssertNil(adhoc.location)
          adhoc.longitude = lon
          XCTAssertNotNil(adhoc.latitude)
          XCTAssertNotNil(adhoc.longitude)
          XCTAssertNotNil(adhoc.location)
          if let loc = adhoc.location {
            XCTAssertEqual(loc.latitude, lat, accuracy: 0.0001)
            XCTAssertEqual(loc.longitude, lon, accuracy: 0.0001)
          }

          // Test AdhocLocation.location setter
          adhoc.latitude = nil
          adhoc.longitude = nil
          XCTAssertNil(adhoc.latitude)
          XCTAssertNil(adhoc.longitude)
          XCTAssertNil(adhoc.location)
          let location = Location(latitude: lat, longitude: lon)
          adhoc.location = location
          XCTAssertNotNil(adhoc.latitude)
          XCTAssertNotNil(adhoc.longitude)
          if let alat = adhoc.latitude, let alon = adhoc.longitude {
            XCTAssertEqual(alat, lat, accuracy: 0.0001)
            XCTAssertEqual(alon, lon, accuracy: 0.0001)
          }

          survey.close()  // So we can delete it without errors
          expectation1.fulfill()
        }
        break
      case .failure(let error):
        print(error)
        XCTAssertTrue(false)
        expectation1.fulfill()
        break
      }
    }

    waitForExpectations(timeout: 1) { error in
      if let error = error {
        XCTFail("Test timed out awaiting unmet expectations: \(error)")
      }
    }
  }

}
