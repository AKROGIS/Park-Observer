//
//  SymbologyTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class SymbologyTests: XCTestCase {

  struct TestJson: Codable {
    let symbology: SimpleSymbology
  }

  func testSimpleV1protocol() {
    // Given:
    let jsonData = Data(
      """
      {
        "symbology":{
          "color":"#CC00CC",
          "size":13
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertNotNil(test.symbology.color)
      XCTAssertEqual(test.symbology.color?.hex6, "#CC00CC")
      XCTAssertNotNil(test.symbology.size)
      XCTAssertEqual(test.symbology.size ?? 0.0, 13.0, accuracy: 0.001)
    }
  }
}
