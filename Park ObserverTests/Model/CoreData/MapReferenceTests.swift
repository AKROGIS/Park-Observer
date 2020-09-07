//
//  MapReferenceTests.swift
//  Park ObserverTests
//
//  Created by Regan Sarwas on 9/7/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class MapReferenceTests: XCTestCase {

  func testMapReference() {
    // Given:
    // Create a new survey from a protocol file
    let surveyName = "My Survey"
    let existingProtocol = "/Sample Protocols/Sample Protocol.v2minimal.obsprot"
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

          // Test MapReference.findOrNew (also new and fetchRequest)

          let n0 = try? survey.viewContext.count(for: MapReference.fetchRequest)
          XCTAssertEqual(n0, 0)
          let emptyMap = MapReference.new(in: survey.viewContext)
          let n1 = try? survey.viewContext.count(for: MapReference.fetchRequest)
          XCTAssertEqual(n1, 1)

          // MapInfo does not match exisiting map, should be added
          let info1 = MapInfo(author: "", date: nil, title: "")
          let map1 = MapReference.findOrNew(matching: info1, in: survey.viewContext)
          let n2 = try? survey.viewContext.count(for: MapReference.fetchRequest)
          XCTAssertEqual(n2, 2)
          XCTAssertNotEqual(emptyMap.objectID, map1.objectID)
          XCTAssertEqual(map1.author, "")
          XCTAssertEqual(map1.name, "")
          XCTAssertNil(map1.date)

          // MapInfo does not match exisiting map, should be added
          let dateText = "2020-05-11T15:30:26Z"
          let date = ISO8601DateFormatter().date(from: dateText)
          let info2 = MapInfo(author: "author", date: date, title: "title")
          let map2 = MapReference.findOrNew(matching: info2, in: survey.viewContext)
          let n3 = try? survey.viewContext.count(for: MapReference.fetchRequest)
          XCTAssertEqual(n3, 3)
          XCTAssertNotEqual(emptyMap.objectID, map2.objectID)
          XCTAssertNotEqual(map1.objectID, map2.objectID)
          XCTAssertEqual(map2.author, "author")
          XCTAssertEqual(map2.name, "title")
          XCTAssertEqual(ISO8601DateFormatter().string(from: map2.date ?? Date()), dateText)

          // MapInfo matches exisiting map, should return existing; no add
          let info3 = MapInfo(author: "", date: nil, title: "")
          let map3 = MapReference.findOrNew(matching: info3, in: survey.viewContext)
          let n4 = try? survey.viewContext.count(for: MapReference.fetchRequest)
          XCTAssertEqual(n4, 3)
          XCTAssertEqual(map1.objectID, map3.objectID)
          XCTAssertEqual(map1.author, "")
          XCTAssertEqual(map1.name, "")
          XCTAssertNil(map1.date)

          // MapInfo matches exisiting map, should return existing; no add
          let info4 = MapInfo(author: "author", date: date, title: "title")
          let map4 = MapReference.findOrNew(matching: info4, in: survey.viewContext)
          let n5 = try? survey.viewContext.count(for: MapReference.fetchRequest)
          XCTAssertEqual(n5, 3)
          XCTAssertEqual(map2.objectID, map4.objectID)
          XCTAssertEqual(map4.author, "author")
          XCTAssertEqual(map4.name, "title")
          XCTAssertEqual(ISO8601DateFormatter().string(from: map4.date ?? Date()), dateText)

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
