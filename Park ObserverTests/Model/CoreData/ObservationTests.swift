//
//  ObservationTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 6/4/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class ObservationTests: XCTestCase {

  /// We are testing all of the following functions in one test, because there is a lot of boilerplate code (and time wasted)
  /// Setting up the CoreData ManagedContext required for these functions to be testable
  ///  * Observation.timestamp
  ///  * Observation.locationOfFeature
  ///  * Observation.requestLocationOfObserver()
  ///
  func testTimestampAndLocation() {
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
        do {

          // Then:
          let lat_g = NSNumber(value: 62.0)  // location of gps/observer for angledistance and gpsLocation
          let lon_g = NSNumber(value: -153.0)
          let lat_m = NSNumber(value: 87.6543)  // touch location
          let lon_m = NSNumber(value: 45.6789)
          let lat_gm = NSNumber(value: 12.3456)  // Location of GPS when map touch is made
          let lon_gm = NSNumber(value: -65.4321)
          let date_g = Date()
          let date_m = date_g.addingTimeInterval(100.0)
          let lat_ad_o = lat_g
          let lon_ad_o = lon_g
          let adLoc = AngleDistanceLocation.new(in: survey.viewContext)
          adLoc.angle = 45.0
          adLoc.distance = 100.0
          // See the AngleDistanceHelperTests for a discussion of the angle/distance offset
          let lat_ad_f = NSNumber(value: lat_ad_o.doubleValue + 0.0006347)
          let lon_ad_f = NSNumber(value: lon_ad_o.doubleValue + 0.0013500)
          let point1 = GpsPoint.new(in: survey.viewContext)
          point1.timestamp = date_g
          point1.latitude = lat_g
          point1.longitude = lon_g
          let point2 = GpsPoint.new(in: survey.viewContext)
          point2.timestamp = date_m
          point2.latitude = lat_gm
          point2.longitude = lon_gm
          let mapLoc = AdhocLocation.new(in: survey.viewContext)
          mapLoc.timestamp = date_m
          mapLoc.latitude = lat_m
          mapLoc.longitude = lon_m
          let feature = survey.config.features[0]
          let obs = Observation.new(feature, in: survey.viewContext)
          XCTAssertNil(obs.timestamp)
          XCTAssertNil(obs.locationOfFeature)
          XCTAssertNil(obs.requestLocationOfObserver(in: survey.viewContext))

          // Just an adhoc location
          obs.adhocLocation = mapLoc
          XCTAssertNotNil(obs.timestamp)
          XCTAssertNotNil(obs.locationOfFeature)
          var observer = obs.requestLocationOfObserver(in: survey.viewContext)
          XCTAssertNotNil(observer)
          if let date = obs.timestamp, let loc = obs.locationOfFeature, let obsLoc = observer {
            XCTAssertEqual(date, date_m)
            XCTAssertEqual(loc.latitude, lat_m.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(loc.longitude, lon_m.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(obsLoc.latitude, lat_gm.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(obsLoc.longitude, lon_gm.doubleValue, accuracy: 0.0001)
          }

          // Just a gpsPoint
          obs.adhocLocation = nil
          XCTAssertNil(obs.timestamp)
          XCTAssertNil(obs.locationOfFeature)
          XCTAssertNil(obs.requestLocationOfObserver(in: survey.viewContext))
          obs.gpsPoint = point1
          XCTAssertNotNil(obs.timestamp)
          XCTAssertNotNil(obs.locationOfFeature)
          observer = obs.requestLocationOfObserver(in: survey.viewContext)
          XCTAssertNotNil(observer)
          if let date = obs.timestamp, let loc = obs.locationOfFeature, let obsLoc = observer {
            XCTAssertEqual(date, date_g)
            XCTAssertEqual(loc.latitude, lat_g.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(loc.longitude, lon_g.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(obsLoc.latitude, lat_g.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(obsLoc.longitude, lon_g.doubleValue, accuracy: 0.0001)
          }

          // When an observation has both a gpsPoint and an adhocLocation
          // Then the observation was originally tapped on the map and later corrected to the gps.
          // You cannot go the other way (i.e. move a gps location to an arbitrary location on the
          // map). The observation's gpsPoint determines the location of the feature, but the
          // gps location with the same timestamp as the adhoctimestamp determine the location
          // of the observer. For historic compatibility, the time of the observation is the
          // corrected (gps) observation
          // Note that by looking at the gps point of the observer location, you can determine
          // the time of the original location, however the location of the original map touch
          // is lost in the CSV export.
          obs.gpsPoint = nil
          XCTAssertNil(obs.timestamp)
          XCTAssertNil(obs.locationOfFeature)
          XCTAssertNil(obs.requestLocationOfObserver(in: survey.viewContext))
          obs.gpsPoint = point1
          obs.adhocLocation = mapLoc
          XCTAssertNotNil(obs.timestamp)
          XCTAssertNotNil(obs.locationOfFeature)
          observer = obs.requestLocationOfObserver(in: survey.viewContext)
          XCTAssertNotNil(observer)
          if let date = obs.timestamp, let loc = obs.locationOfFeature, let obsLoc = observer {
            XCTAssertEqual(date, date_g)
            XCTAssertEqual(loc.latitude, lat_g.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(loc.longitude, lon_g.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(obsLoc.latitude, lat_gm.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(obsLoc.longitude, lon_gm.doubleValue, accuracy: 0.0001)
          }

          // An observation could also have an angleDistance property,
          // but it has no timestamp, so it has no influence on the observation's timestamp
          // but it does trump the location of the feature and observer based on the adhoc
          // or gps locations
          obs.angleDistanceLocation = adLoc
          XCTAssertNotNil(obs.locationOfFeature)
          observer = obs.requestLocationOfObserver(in: survey.viewContext)
          XCTAssertNotNil(observer)
          if let loc = obs.locationOfFeature, let obsLoc = observer {
            XCTAssertEqual(loc.latitude, lat_ad_f.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(loc.longitude, lon_ad_f.doubleValue, accuracy: 0.0001)
            // When an observation has both an angleDistanceLocation and an adhocLocation
            // which should never happen; the observer location is based on the adhocLocation
            XCTAssertEqual(obsLoc.latitude, lat_gm.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(obsLoc.longitude, lon_gm.doubleValue, accuracy: 0.0001)
          }
          // The adhoc location should have no influence on the angle distance location
          obs.adhocLocation = nil
          XCTAssertNotNil(obs.locationOfFeature)
          observer = obs.requestLocationOfObserver(in: survey.viewContext)
          XCTAssertNotNil(observer)
          if let loc = obs.locationOfFeature, let obsLoc = observer {
            XCTAssertEqual(loc.latitude, lat_ad_f.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(loc.longitude, lon_ad_f.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(obsLoc.latitude, lat_g.doubleValue, accuracy: 0.0001)
            XCTAssertEqual(obsLoc.longitude, lon_g.doubleValue, accuracy: 0.0001)
          }
          // The angle distance location is dependent on the gps location
          obs.gpsPoint = nil
          XCTAssertNotNil(obs.angleDistanceLocation)
          XCTAssertNil(obs.locationOfFeature)
          XCTAssertNil(obs.requestLocationOfObserver(in: survey.viewContext))

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
