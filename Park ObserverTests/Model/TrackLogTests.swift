//
//  TrackLogTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/29/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreData  // for NSManagedObjectContext
import XCTest

@testable import Park_Observer

class TrackLogTests: XCTestCase {

  /// We are testing all of the following functions under various conditions in one test,
  /// because there is a lot of boilerplate code (and time wasted) setting up the
  /// CoreData ManagedContext required for these functions to be testable
  ///  * TrackLog building
  ///      - init with properties and points.append
  ///  * TrackLog.duration
  ///  * TrackLog.length
  ///  * TrackLogs.fetchAll()
  /// Conditions:
  ///  * No points
  ///  * one point
  ///  * two points
  ///  * two duplicate points (throw on add?)
  ///  * three points
  ///  * out of order points (throw on add?)
  ///
  /// These functions will also get additional exercise in the CSV export tests

  func testBuildingTrackLogs() {
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
      try? FileManager.default.deleteProtocol(with: protocolName)
    }
    guard let newSurveyName = try? Survey.create(surveyName, from: protocolName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? FileManager.default.deleteSurvey(with: newSurveyName)
    }
    //When:
    // survey created, lets try and load it
    let expectation1 = expectation(description: "Survey \(newSurveyName) was loaded")
    Survey.load(newSurveyName) { (result) in
      switch result {
      case .success(let survey):

        // Then:
        do {
          // Create a number of entities in the viewContext
          let mission = Mission.new(in: survey.viewContext)
          let mp = MissionProperty.new(in: survey.viewContext)
          mp.observing = false
          mp.mission = mission
          let point1 = GpsPoint.new(in: survey.viewContext)
          point1.latitude = 62.0
          point1.longitude = -153.0
          point1.timestamp = Date()
          point1.mission = mission
          point1.missionProperty = mp
          let trackLog = TrackLog(properties: mp)
          XCTAssertEqual(trackLog.points.count, 0)
          XCTAssertNil(trackLog.length)
          XCTAssertNil(trackLog.duration)
          trackLog.points.append(point1)
          XCTAssertEqual(trackLog.points.count, 1)
          XCTAssertEqual(trackLog.length, 0)
          XCTAssertEqual(trackLog.duration, 0)

          // Add a second point 100 meters north (see AngleDistanceHelperTests for more info)
          // The Tracklog length is a shape preserving geodetic (which may be slightly different
          // than the UTM zone length.
          let point2 = GpsPoint.new(in: survey.viewContext)
          point2.latitude = 62.0008973
          point2.longitude = -153.0
          point2.timestamp = point1.timestamp?.addingTimeInterval(50)
          point2.mission = mission
          trackLog.points.append(point2)
          XCTAssertEqual(trackLog.points.count, 2)
          XCTAssertNotNil(trackLog.length)
          XCTAssertNotNil(trackLog.duration)
          if let length = trackLog.length, let duration = trackLog.duration {
            XCTAssertEqual(length, 100, accuracy: 0.001)
            XCTAssertEqual(duration, 50, accuracy: 0.001)
          }

          // Save
          try survey.save()
          // rebuild in private context
          let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
          privateContext.persistentStoreCoordinator = survey.viewContext.persistentStoreCoordinator
          privateContext.perform {
            let trackLogs = try? TrackLogs.fetchAll()
            XCTAssertNotNil(trackLogs)
            XCTAssertEqual(trackLogs?.count, 1)
            XCTAssertEqual(trackLogs?[0].points.count, 2)
            XCTAssertNotNil(trackLogs?[0].properties)
            XCTAssertEqual(trackLogs?[0].properties.observing, false)
            XCTAssertNotNil(trackLogs?[0].length)
            XCTAssertNotNil(trackLogs?[0].duration)
            if let length = trackLogs?[0].length, let duration = trackLogs?[0].duration {
              XCTAssertEqual(length, 100, accuracy: 0.001)
              XCTAssertEqual(duration, 50, accuracy: 0.001)
            }
            survey.close()  // So we can delete it without errors
            expectation1.fulfill()
          }
        } catch {
          XCTAssertFalse(true)
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
