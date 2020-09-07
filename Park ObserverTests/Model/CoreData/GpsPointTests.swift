//
//  GpsPointTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 6/4/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreLocation
import XCTest

@testable import Park_Observer

class GpsPointTests: XCTestCase {

  func testGpsPoint() {
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
          // Do fetch tests first, since they assume they start with an empty survey
          self.testFetches(with: survey)
          self.testInit(with: survey)
          self.testDelete1(with: survey)
          self.testDelete2(with: survey)
          self.testLocation(with: survey)

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

  func testInit(with survey: Survey) {
    let mission = Mission.new(in: survey.viewContext)
    let location = CLLocation(latitude: 62.0, longitude: -142.0)
    let point = GpsPoint.new(in: survey.viewContext)
    XCTAssertNil(point.mission)
    XCTAssertNil(point.latitude)
    XCTAssertNil(point.longitude)
    point.initializeWith(mission: mission, location: location)
    XCTAssertNotNil(point.mission)
    XCTAssertNotNil(point.latitude)
    XCTAssertNotNil(point.longitude)
    if let lat = point.latitude, let lon = point.longitude {
      XCTAssertEqual(lat, location.coordinate.latitude, accuracy: 0.0001)
      XCTAssertEqual(lon, location.coordinate.longitude, accuracy: 0.0001)
    }
  }

  func testDelete1(with survey: Survey) {
    let n0 = try? survey.viewContext.count(for: GpsPoints.fetchRequest)
    XCTAssertNotNil(n0)
    let point = GpsPoint.new(in: survey.viewContext)
    let n1 = try? survey.viewContext.count(for: GpsPoints.fetchRequest)
    XCTAssertNotNil(n1)
    XCTAssertNotEqual(n1, n0)
    point.delete()
    let n2 = try? survey.viewContext.count(for: GpsPoints.fetchRequest)
    XCTAssertNotNil(n2)
    XCTAssertEqual(n2, n0)
  }

  func testDelete2(with survey: Survey) {
    let mission = Mission.new(in: survey.viewContext)
    let n = try? survey.viewContext.count(for: GpsPoints.fetchRequest)
    XCTAssertNotNil(n)
    if let n0 = n {
      let point = GpsPoint.new(in: survey.viewContext)
      point.latitude = 60.0
      point.longitude = -145.0
      point.timestamp = Date()
      point.mission = mission
      XCTAssertNoThrow(try survey.save())
      let n = try? survey.viewContext.count(for: GpsPoints.fetchRequest)
      XCTAssertNotNil(n)
      if let n1 = n {
        XCTAssertEqual(n1, n0 + 1)
      }
      point.delete()
      XCTAssertNoThrow(try survey.save())
      let n2 = try? survey.viewContext.count(for: GpsPoints.fetchRequest)
      XCTAssertNotNil(n)
      if let n2 = n2 {
        XCTAssertEqual(n2, n0)
      }
    }
  }

  func testLocation(with survey: Survey) {

    // Test GpsPoint.location getter
    let point = GpsPoint.new(in: survey.viewContext)
    XCTAssertNil(point.latitude)
    XCTAssertNil(point.longitude)
    XCTAssertNil(point.location)
    let lat = 62.1234
    let lon = -154.3210
    point.latitude = lat
    XCTAssertNotNil(point.latitude)
    XCTAssertNil(point.longitude)
    XCTAssertNil(point.location)
    point.longitude = lon
    XCTAssertNotNil(point.latitude)
    XCTAssertNotNil(point.longitude)
    XCTAssertNotNil(point.location)
    if let loc = point.location {
      XCTAssertEqual(loc.latitude, lat, accuracy: 0.0001)
      XCTAssertEqual(loc.longitude, lon, accuracy: 0.0001)
    }

    // GpsPoint.location has no setter

  }

  func testFetches(with survey: Survey) {
    let n = try? survey.viewContext.count(for: GpsPoints.fetchRequest)
    XCTAssertNotNil(n)
    XCTAssertEqual(n, 0)

    let mission = Mission.new(in: survey.viewContext)
    let now = Date()
    let points = [
      (now.addingTimeInterval(1), 61.1, -145.1),
      (now.addingTimeInterval(2), 61.2, -145.2),
      (now.addingTimeInterval(3), 61.3, -145.3),
      (now.addingTimeInterval(4), 61.4, -145.4),
      (now.addingTimeInterval(5), 61.5, -145.5),
      (now.addingTimeInterval(6), 61.6, -145.6),
      (now.addingTimeInterval(7), 61.7, -145.7),
    ]
    for point in points {
      let gps = GpsPoint.new(in: survey.viewContext)
      gps.timestamp = point.0
      gps.latitude = point.1
      gps.longitude = point.2
      gps.mission = mission
    }
    XCTAssertNoThrow(try survey.save())

    // Test Fetch allOrderByTime

    let all = try? survey.viewContext.fetch(GpsPoints.allOrderByTime)
    XCTAssertNotNil(all)
    if let all = all {
      XCTAssertEqual(all.count, 7)
      XCTAssertNotNil(all[0].latitude)
      XCTAssertNotNil(all[6].longitude)
      if let lat = all[0].latitude, let lon = all[6].longitude {
        XCTAssertEqual(lat, 61.1, accuracy: 0.0001)
        XCTAssertEqual(lon, -145.7, accuracy: 0.0001)
      }
    }

    // Test Fetch firstPoint

    let first = try? survey.viewContext.fetch(GpsPoints.firstPoint)
    XCTAssertNotNil(first)
    if let first = first {
      XCTAssertEqual(first.count, 1)
      XCTAssertNotNil(first[0].latitude)
      if let lat = first[0].latitude {
        XCTAssertEqual(lat, 61.1, accuracy: 0.0001)
      }
    }


    // Test Fetch lastPoint

    let last = try? survey.viewContext.fetch(GpsPoints.lastPoint)
    XCTAssertNotNil(last)
    if let last = last {
      XCTAssertEqual(last.count, 1)
      XCTAssertNotNil(last[0].latitude)
      if let lat = last[0].latitude {
        XCTAssertEqual(lat, 61.7, accuracy: 0.0001)
      }
    }

    // Test Fetch pointsSince()
    // order of points is not guaranteed

    let many = try? survey.viewContext.fetch(GpsPoints.pointsSince(now.addingTimeInterval(5)))
    XCTAssertNotNil(many)
    if let many = many {
      XCTAssertEqual(many.count, 3)
      var foundBadPoint = false
      for point in many {
        guard let lat = point.latitude else {
          foundBadPoint = true
          break
        }
        if lat < 61.5 {
          foundBadPoint = true
        }
      }
      XCTAssertFalse(foundBadPoint)
    }

  }
}
