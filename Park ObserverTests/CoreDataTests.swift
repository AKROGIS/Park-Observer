//
//  CoreDataTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreData
import XCTest

@testable import Park_Observer

class CoreDataTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

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

  func testLoadLegacySurvey() {
    // Given:
    let surveyTests = [
      //(filename, name of survey in archive, number of gps points in survey)
      ("ARCN Bears.poz", "ARCN Bears", 696),  // has invalid protocol (by new tests)
      //("LACL Bear Trends.poz", "LACL Bear Trends", 11250), // does not unpack into a sub folder
      //("SEAN KIMU Protocol (BIG).poz", "SEAN KIMU Protocol", 39237),
      ("SEAN KIMU Protocol.poz", "SEAN KIMU Protocol", 800),  // survey name clash with previous
      ("Sheep Transects Short.poz", "Sheep Transects Short", 180),
      ("Test Protocol Version 2.poz", "Test Protocol Version 2", 41),
      ("Test Protocol.poz", "Test Protocol", 0),
    ]
    for test in surveyTests {
      let existingPoz = "/Legacy Archives/" + test.0
      let existingSurveyName = test.1
      let gpsPointCount = test.2
      // Get exisitng POZ
      let testBundle = Bundle(for: type(of: self))
      let existingPath = testBundle.resourcePath! + existingPoz
      let existingUrl = URL(fileURLWithPath: existingPath)
      // Copy POZ to the App
      guard let archive = try? FileManager.default.addToApp(url: existingUrl) else {
        XCTAssertTrue(false)
        return
      }
      defer {
        try? FileManager.default.deleteArchive(with: archive.name)
      }
      // Unpack the POZ as a survey
      guard let surveyName = try? FileManager.default.importSurvey(from: archive.name) else {
        XCTAssertTrue(false)
        return
      }

      // Then:
      // survey exists, lets try and load it
      let expectation1 = expectation(description: "Survey \(existingSurveyName) was loaded")

      Survey.load(surveyName) { (result) in
        switch result {
        case .success(let survey):
          let request: NSFetchRequest<GpsPoint> = GpsPoint.fetchRequest()
          let results = try? survey.viewContext.fetch(request)
          XCTAssertNotNil(results)
          if let gpsPoint = results {
            XCTAssertEqual(gpsPoint.count, gpsPointCount)
          }
          break
        case .failure(let error):
          print(error)
          XCTAssertTrue(false)
          break
        }
        expectation1.fulfill()
      }
    }

    waitForExpectations(timeout: 5) { error in
      if let error = error {
        XCTFail("Test timed out waiting unmet expectationns: \(error)")
      }
    }
    for test in surveyTests {
      try? FileManager.default.deleteSurvey(with: test.1)
    }

  }

}
