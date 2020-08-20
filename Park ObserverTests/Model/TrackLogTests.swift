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
          point1.missionProperty = nil
          // Cannot start a Tracklog without a mission property
          XCTAssertThrowsError(try TrackLog(point: point1))
          point1.missionProperty = mp
          point1.mission = nil
          // Cannot start a Tracklog without a mission
          XCTAssertThrowsError(try TrackLog(point: point1))
          point1.mission = mission
          point1.timestamp = nil
          // Cannot start a Tracklog with a without a timestamp
          XCTAssertThrowsError(try TrackLog(point: point1))
          point1.timestamp = Date()
          //point has all required properties, should start a tracklog
          if let trackLog = try? TrackLog(point: point1) {
            XCTAssertEqual(trackLog.points.count, 1)
            XCTAssertEqual(trackLog.length, 0)
            XCTAssertEqual(trackLog.duration, 0)

            let dateBefore = point1.timestamp?.addingTimeInterval(-50)
            let dateSame = point1.timestamp
            let dateAfter = point1.timestamp?.addingTimeInterval(50)
            let anotherMission = Mission.new(in: survey.viewContext)
            let anotherMissionProperty = MissionProperty.new(in: survey.viewContext)
            anotherMissionProperty.mission = mission

            // Add a second point 100 meters north (see AngleDistanceHelperTests for more info)
            // The Tracklog length is a shape preserving geodetic (which may be slightly different
            // than the UTM zone length.
            let point2 = GpsPoint.new(in: survey.viewContext)
            point2.latitude = 62.0008973
            point2.longitude = -153.0
            point2.timestamp = dateAfter
            point2.mission = mission
            // Note: a missionProperty can have only one gps point, so if I assign mp to point2
            // it will be removed from point1 (making point1 invalid for starting a tracklog)
            // This reveals the weakness of building a data structure with mutable data;
            // I could easily circumvent tracklogs's restrictions by changing the objects
            // after they have been used to build the tracklog.
            point2.missionProperty = anotherMissionProperty
            // Cannot add a point with the a mission property
            XCTAssertThrowsError(try trackLog.append(point2))
            point2.missionProperty = nil
            point2.mission = anotherMission
            // Cannot add a point with a different mission
            XCTAssertThrowsError(try trackLog.append(point2))
            point2.mission = mission
            point2.timestamp = nil
            // Cannot add a point without a date
            XCTAssertThrowsError(try trackLog.append(point2))
            point2.timestamp = dateBefore
            // Cannot add a point with an earlier date
            XCTAssertThrowsError(try trackLog.append(point2))
            point2.timestamp = dateSame
            // Cannot add a point with the same date
            XCTAssertThrowsError(try trackLog.append(point2))
            point2.timestamp = dateAfter
            // Valid point can be added.
            XCTAssertNoThrow(try trackLog.append(point2))
            XCTAssertEqual(trackLog.points.count, 2)
            XCTAssertNotNil(trackLog.length)
            XCTAssertNotNil(trackLog.duration)
            if let length = trackLog.length, let duration = trackLog.duration {
              XCTAssertEqual(length, 100, accuracy: 0.001)
              XCTAssertEqual(duration, 50, accuracy: 0.001)
            }
            let point3 = GpsPoint.new(in: survey.viewContext)
            point3.latitude = 62.0008973
            point3.longitude = -153.0
            point3.timestamp = point2.timestamp?.addingTimeInterval(50)
            point3.mission = mission
            point3.missionProperty = anotherMissionProperty
            // a valid point can have the same location
            // A valid point can have a mission property if it ends the tracklog
            XCTAssertThrowsError(try trackLog.append(point3))
            XCTAssertNoThrow(try trackLog.appendLast(point3))
            XCTAssertEqual(trackLog.points.count, 3)
            XCTAssertNotNil(trackLog.length)
            XCTAssertNotNil(trackLog.duration)
            if let length = trackLog.length, let duration = trackLog.duration {
              XCTAssertEqual(length, 100, accuracy: 0.001)
              XCTAssertEqual(duration, 100, accuracy: 0.001)
            }
            let point4 = GpsPoint.new(in: survey.viewContext)
            point4.latitude = 62.0
            point4.longitude = -153.0
            point4.timestamp = point3.timestamp?.addingTimeInterval(50)
            point4.mission = mission
            // Cannot add a point after the end
            XCTAssertThrowsError(try trackLog.append(point4))
            XCTAssertThrowsError(try trackLog.appendLast(point4))
            XCTAssertEqual(trackLog.points.count, 3)
            // Remove point4 from the context before saving, or else it will
            // be used when create tracklogs in the next step (which will yield different results)
            point4.delete()
            // Remove the mission property from point3 so it does not start a 2nd tracklog.
            point3.missionProperty = nil
          } else {
            XCTAssertTrue(false)
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
            if let count = trackLogs?.count, count > 0 {
              XCTAssertEqual(trackLogs?[0].points.count, 3)
              XCTAssertNotNil(trackLogs?[0].properties)
              XCTAssertEqual(trackLogs?[0].properties.observing, false)
              XCTAssertNotNil(trackLogs?[0].length)
              XCTAssertNotNil(trackLogs?[0].duration)
              if let length = trackLogs?[0].length, let duration = trackLogs?[0].duration {
                XCTAssertEqual(length, 100, accuracy: 0.001)
                XCTAssertEqual(duration, 100, accuracy: 0.001)
              }
            }
            survey.close()  // So we can delete it without errors
            expectation1.fulfill()
          }
        } catch {
          print(error)
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
