//
//  MissionPropertyTests.swift
//  Park ObserverTests
//
//  Created by Regan Sarwas on 9/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class MissionPropertyTests: XCTestCase {

  func testMissionProperty() {
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

          // Test MissionProperty.location getter (no setter)
          // A Mission Property has no real feature on the map,
          // just the observers location when the mission property was edited.
          // MP should only have adhoc if there is no GPS, however
          // GPS location trumps adhoc location if Mission Property has both
          // Unlike a feature where the gps is the observer and adhoc is the feature location
          let mp = MissionProperty.new(in: survey.viewContext)
          XCTAssertNil(mp.location)
          var lat = 62.0
          var lon = -154.0
          let adhoc = AdhocLocation.new(in: survey.viewContext)
          mp.adhocLocation = adhoc
          XCTAssertNil(mp.location)
          adhoc.latitude = lat
          adhoc.longitude = lon
          XCTAssertNotNil(mp.location)
          if let loc = mp.location {
            XCTAssertEqual(loc.latitude, lat, accuracy: 0.0001)
            XCTAssertEqual(loc.longitude, lon, accuracy: 0.0001)
          }
          // GPS location should trump adhoc location
          let gps = GpsPoint.new(in: survey.viewContext)
          mp.gpsPoint = gps
          // Since the gps.location is nil, the adhoc location will be returned
          XCTAssertNotNil(mp.location)
          lat = 64.0
          lon = -152.0
          gps.latitude = lat
          gps.longitude = lon
          XCTAssertNotNil(mp.location)
          if let loc = mp.location {
            XCTAssertEqual(loc.latitude, lat, accuracy: 0.0001)
            XCTAssertEqual(loc.longitude, lon, accuracy: 0.0001)
          }
          mp.adhocLocation = nil
          XCTAssertNotNil(mp.gpsPoint?.location)
          mp.gpsPoint = nil
          XCTAssertNil(mp.location)


          // Test MissionProperty.timestamp getter (no setter)
          // MP will only have adhoc if there is no GPS, however
          // gps timestamp trumps adhoc timestamp if Mission Property has both
          XCTAssertNil(mp.timestamp)
          let date = Date()
          adhoc.timestamp = date
          mp.adhocLocation = adhoc
          XCTAssertNotNil(mp.timestamp)
          XCTAssertEqual(mp.timestamp, date)
          let date2 = date.addingTimeInterval(10)
          gps.timestamp = date2
          mp.gpsPoint = gps
          XCTAssertNotNil(mp.timestamp)
          XCTAssertEqual(mp.timestamp, date2)
          mp.adhocLocation = nil
          XCTAssertNotNil(mp.timestamp)
          XCTAssertEqual(mp.timestamp, date2)
          mp.gpsPoint = nil
          XCTAssertNil(mp.timestamp)


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
