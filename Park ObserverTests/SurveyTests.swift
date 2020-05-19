//
//  SurveyTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/19/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreData
import XCTest

@testable import Park_Observer

class SurveyTests: XCTestCase {

  func testLoadLegacySurvey() {
    // Given:
    let surveyTests = [
      //(filename, name of survey in archive, number of gps points in survey)
      ("ARCN Bears.poz", 696),  // has invalid protocol (by new tests)
      ("LACL Bear Trends.poz", 11250),  // does not unpack into a sub folder
      ("SEAN KIMU Protocol (BIG).poz", 39237),
      ("SEAN KIMU Protocol.poz", 800),  // survey name clash with previous
      ("Sheep Transects Short.poz", 180),
      ("Test Protocol Version 2.poz", 41),
      ("Test Protocol.poz", 0),
    ]
    var surveysToDelete = [String]()
    for test in surveyTests {
      let existingPoz = "/Legacy Archives/" + test.0
      let gpsPointCount = test.1
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
      guard
        let surveyName = try? FileManager.default.importSurvey(
          from: archive.name, conflict: .keepBoth)
        else {
          XCTAssertTrue(false)
          return
      }
      surveysToDelete.append(surveyName)

      // Then:
      // survey exists, lets try and load it
      let expectation1 = expectation(description: "Survey \(surveyName) was loaded")

      print("Loading \(surveyName)...")
      Survey.load(surveyName) { (result) in
        switch result {
        case .success(let survey):
          let request: NSFetchRequest<GpsPoint> = GpsPoint.fetchRequest()
          let results = try? survey.viewContext.fetch(request)
          XCTAssertNotNil(results)
          if let gpsPoint = results {
            XCTAssertEqual(gpsPoint.count, gpsPointCount)
          }
          survey.close()
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
    for name in surveysToDelete {
      try? FileManager.default.deleteSurvey(with: name)
    }

  }

}
