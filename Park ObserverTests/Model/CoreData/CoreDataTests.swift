//
//  CoreDataTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreData  // For NSManagedObjectContext
import XCTest

@testable import Park_Observer

class CoreDataTests: XCTestCase {

  func testManagedObjectModel() {
    // Given:
    let testBundle = Bundle(for: type(of: self))  //Get the test bundle
    let url = testBundle.bundleURL.appendingPathComponent("Legacy Protocols/sample.obsprot")

    // When:
    guard let surveyProtocol = try? SurveyProtocol(fromURL: url) else {
      XCTAssertTrue(false)
      return
    }
    guard let mom = surveyProtocol.mergedManagedObjectModel(bundles: [testBundle]) else {
      XCTAssertTrue(false)
      return
    }

    // Then:
    XCTAssertEqual(mom.entities.count, 10)  // 7 standard + 3 features
    let missionEntity = mom.entitiesByName[.entityNameMissionProperty]
    XCTAssertNotNil(missionEntity)
    if let missionEntity = missionEntity {
      XCTAssertEqual(missionEntity.properties.count, 12)  // 1 standard + 8 custom + 3 relations
    }
    var featureEntity = mom.entitiesByName[.observationPrefix + "Birds"]
    XCTAssertNotNil(featureEntity)
    if let featureEntity = featureEntity {
      XCTAssertEqual(featureEntity.properties.count, 12)  // 0 standard + 8 custom + 4 relations
    }
    featureEntity = mom.entitiesByName[.observationPrefix + "Nests"]
    XCTAssertNotNil(featureEntity)
    if let featureEntity = featureEntity {
      XCTAssertEqual(featureEntity.properties.count, 7)  // 0 standard + 3 custom + 4 relations
    }
    featureEntity = mom.entitiesByName[.observationPrefix + "Cabins"]
    XCTAssertNotNil(featureEntity)
    if let featureEntity = featureEntity {
      XCTAssertEqual(featureEntity.properties.count, 6)  // 0 standard + 2 custom + 4 relations
    }
  }

  // MARK: - Core Data Defaults

  func testCoreDataModelDefaults() {
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

          // MapReference

          let map = MapReference.new(in: survey.viewContext)
          // defaults: None
          XCTAssertNil(map.name)
          XCTAssertNil(map.author)
          XCTAssertNil(map.date)
          // Relationship should exist and be empty
          XCTAssertNotNil(map.adhocLocations)
          XCTAssertEqual(map.adhocLocations?.count, 0)
          // constraints:
          //   name is not nil
          XCTAssertThrowsError(try map.validateForInsert())
          map.name = ""  // Bad idea, but not prohibited
          XCTAssertNoThrow(try map.validateForInsert())
          map.name = "Alaska"
          XCTAssertNoThrow(try map.validateForInsert())

          // AdhocLocation

          let loc = AdhocLocation.new(in: survey.viewContext)
          // defaults: None
          XCTAssertNil(loc.latitude)
          XCTAssertNil(loc.longitude)
          XCTAssertNil(loc.timestamp)
          // Relationships should be nil
          XCTAssertNil(loc.map)
          XCTAssertNil(loc.missionProperty)
          XCTAssertNil(loc.observation)
          // constraints:
          //   latitude is not nil and is in -90..90
          //   longitiude is not nil and is in -180..180
          //   map is not nil
          XCTAssertThrowsError(try loc.validateForInsert())
          loc.latitude = 90.0
          XCTAssertThrowsError(try loc.validateForInsert())
          loc.longitude = 180.0
          XCTAssertThrowsError(try loc.validateForInsert())
          XCTAssertEqual(map.adhocLocations?.count, 0)
          loc.map = map
          XCTAssertEqual(map.adhocLocations?.count, 1)
          XCTAssertNoThrow(try loc.validateForInsert())
          loc.latitude = -100.0
          XCTAssertThrowsError(try loc.validateForInsert())
          loc.latitude = 100.0
          XCTAssertThrowsError(try loc.validateForInsert())
          loc.latitude = -90.0
          loc.longitude = -180.0
          XCTAssertNoThrow(try loc.validateForInsert())
          loc.longitude = -200.0
          XCTAssertThrowsError(try loc.validateForInsert())
          loc.longitude = 200.0
          XCTAssertThrowsError(try loc.validateForInsert())
          loc.longitude = 0.0
          XCTAssertNoThrow(try loc.validateForInsert())

          // Mission

          let mission = Mission.new(in: survey.viewContext)
          // No attributes - ergo no defaults or constraints to test
          // Relationships should exist and be empty
          XCTAssertNotNil(mission.gpsPoints)
          XCTAssertNotNil(mission.missionProperties)
          XCTAssertNotNil(mission.observations)
          XCTAssertEqual(mission.gpsPoints?.count, 0)
          XCTAssertEqual(mission.missionProperties?.count, 0)
          XCTAssertEqual(mission.observations?.count, 0)

          // MissionProperty

          let mp = MissionProperty.new(in: survey.viewContext)
          // defaults: None
          XCTAssertNil(mp.observing)
          // Relationships should be nil
          XCTAssertNil(mp.gpsPoint)
          XCTAssertNil(mp.adhocLocation)
          XCTAssertNil(mp.mission)
          // constraints:
          //   mission is not nil
          XCTAssertThrowsError(try mp.validateForInsert())
          XCTAssertEqual(mission.missionProperties?.count, 0)
          mp.mission = mission
          XCTAssertEqual(mission.missionProperties?.count, 1)
          XCTAssertNoThrow(try mp.validateForInsert())

          // Observation (Birds)

          let feature = survey.config.features[0]
          let obs = Observation.new(feature, in: survey.viewContext)
          // No attributes - ergo no defaults or constraints to test
          // Relationships should be nil
          XCTAssertNil(obs.mission)
          XCTAssertNil(obs.gpsPoint)
          XCTAssertNil(obs.adhocLocation)
          XCTAssertNil(obs.angleDistanceLocation)
          // Constraints
          //   mission is not nil
          //   An observation should have at least one location but this is not enforced
          XCTAssertThrowsError(try obs.validateForInsert())
          XCTAssertEqual(mission.observations?.count, 0)
          obs.mission = mission
          XCTAssertEqual(mission.observations?.count, 1)
          XCTAssertNoThrow(try obs.validateForInsert())
          obs.adhocLocation = loc
          XCTAssertNoThrow(try obs.validateForInsert())

          // AngleDistance

          let ad = AngleDistanceLocation.new(in: survey.viewContext)
          // defaults: angle: 0, direction: 0, distance: 0
          XCTAssertEqual(ad.angle, 0)
          XCTAssertEqual(ad.direction, 0)
          XCTAssertEqual(ad.distance, 0)
          // Relationships should be nil
          XCTAssertNil(ad.observation)
          // constraints:
          //   angle is not nil
          //   direction is not nil
          //   distance is not nil and is in 0...
          //   observation is not nil (no default - must be set by user)
          XCTAssertThrowsError(try ad.validateForInsert())
          XCTAssertNil(obs.angleDistanceLocation)
          ad.observation = obs
          XCTAssertNotNil(obs.angleDistanceLocation)
          XCTAssertNoThrow(try ad.validateForInsert())
          ad.distance = -1.0
          XCTAssertThrowsError(try ad.validateForInsert())
          ad.distance = 10
          XCTAssertNoThrow(try ad.validateForInsert())
          ad.angle = 100
          XCTAssertNoThrow(try ad.validateForInsert())
          ad.direction = 1.0
          XCTAssertNoThrow(try ad.validateForInsert())

          // GpsPoint

          let point = GpsPoint.new(in: survey.viewContext)
          // defaults: altitude, course, horizontalAccuracy, speed, verticalAccuracy: -1
          XCTAssertEqual(point.altitude, -1)
          XCTAssertEqual(point.course, -1)
          XCTAssertEqual(point.horizontalAccuracy, -1)
          XCTAssertNil(point.latitude)
          XCTAssertNil(point.longitude)
          XCTAssertEqual(point.speed, -1)
          XCTAssertNil(point.timestamp)
          XCTAssertEqual(point.verticalAccuracy, -1)
          // Relationships should be nil
          XCTAssertNil(point.mission)
          XCTAssertNil(point.missionProperty)
          XCTAssertNil(point.observation)
          // constraints:
          //   latitude, longitude are not nil (no contraint on range)
          //   timestamp is not nil
          //   mission is not nil
          XCTAssertThrowsError(try point.validateForInsert())
          point.latitude = -200
          point.longitude = -200
          point.timestamp = Date()
          XCTAssertThrowsError(try point.validateForInsert())
          XCTAssertEqual(mission.gpsPoints?.count, 0)
          point.mission = mission
          XCTAssertEqual(mission.gpsPoints?.count, 1)
          XCTAssertNoThrow(try point.validateForInsert())
          point.latitude = -200
          point.longitude = -200
          XCTAssertNoThrow(try point.validateForInsert())
          point.latitude = nil
          XCTAssertThrowsError(try point.validateForInsert())
          point.latitude = 12.0
          XCTAssertNoThrow(try point.validateForInsert())
          point.longitude = nil
          XCTAssertThrowsError(try point.validateForInsert())
          point.longitude = -12.0
          XCTAssertNoThrow(try point.validateForInsert())
          point.timestamp = nil
          XCTAssertThrowsError(try point.validateForInsert())
          point.timestamp = ISO8601DateFormatter().date(from: "2020-05-11T15:30:26Z")
          XCTAssertNoThrow(try point.validateForInsert())

          // Save and fetch on main thread
          XCTAssertTrue(survey.viewContext.hasChanges)
          try survey.save()
          XCTAssertFalse(survey.viewContext.hasChanges)
          survey.viewContext.reset()
          // The next line does not work: execute() must be called within a context block
          // let points = try? GpsPoints.allOrderByTime.execute()
          let points = try? survey.viewContext.fetch(GpsPoints.allOrderByTime)
          XCTAssertNotNil(points)
          XCTAssertEqual(points?.count, 1)
          XCTAssertNotNil(points?[0].mission)
          XCTAssertEqual(points?[0].latitude, 12.0)
          XCTAssertEqual(points?[0].longitude, -12.0)
          XCTAssertEqual(
            ISO8601DateFormatter().string(from: points?[0].timestamp ?? Date()),
            "2020-05-11T15:30:26Z")
          XCTAssertEqual(points?[0].mission?.gpsPoints?.count, 1)
          XCTAssertEqual(points?[0].mission?.missionProperties?.count, 1)
          XCTAssertEqual(points?[0].mission?.observations?.count, 1)
          let maybeObs = points?[0].mission?.observations?.first { _ in true } as? Observation
          XCTAssertNotNil(maybeObs)
          if let obs = maybeObs {
            XCTAssertEqual(obs.angleDistanceLocation?.angle, 100.0)
            XCTAssertEqual(obs.angleDistanceLocation?.distance, 10.0)
            XCTAssertEqual(obs.angleDistanceLocation?.direction, 1.0)
            XCTAssertEqual(obs.adhocLocation?.map?.name, "Alaska")
          }
          // Test fetching all observations
          var featureRequest = Observations.fetchAll(for: survey.config.features[1])
          let nests = try? survey.viewContext.fetch(featureRequest)
          XCTAssertNotNil(nests)
          XCTAssertEqual(nests?.count, 0)
          featureRequest = Observations.fetchAll(for: feature)
          let birds = try? survey.viewContext.fetch(featureRequest)
          XCTAssertNotNil(birds)
          XCTAssertEqual(birds?.count, 1)

          // fetch on background thread
          let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
          privateContext.persistentStoreCoordinator = survey.viewContext.persistentStoreCoordinator
          privateContext.perform {
            let points = try? GpsPoints.allOrderByTime.execute()
            XCTAssertNotNil(points)
            XCTAssertEqual(points?.count, 1)
            XCTAssertNotNil(points?[0].mission)
            XCTAssertEqual(points?[0].latitude, 12.0)
            XCTAssertEqual(points?[0].longitude, -12.0)
            let birds = try? featureRequest.execute()
            XCTAssertNotNil(birds)
            XCTAssertEqual(birds?.count, 1)
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
