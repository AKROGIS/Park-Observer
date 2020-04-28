//
//  ArcGISSymbolDefaultTessymbol.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/28/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import Foundation
import XCTest

@testable import Park_Observer

class ArcGISSymbolDefaultTests: XCTestCase {

  func testMinimalTextSymbol() {

    let jsonData = Data(
      """
      {
        "type": "esriTS",
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let textSymbol = try AGSTextSymbol.fromJSON(JSON) as! AGSTextSymbol
      printAGSTextSymbol(textSymbol)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)  // Failed parsing; JSON is invalid

  }

  func testExampleTextSymbol() {

    let jsonData = Data(
      """
      {
        "type": "esriTS",
        "color": [78,78,78,255],
        "backgroundColor": [0,0,0,0],
        "borderLineSize": 2,
        "borderLineColor": [255,0,255,255],
        "haloSize": 2,
        "haloColor": [0,255,0,255],
        "verticalAlignment": "bottom",
        "horizontalAlignment": "left",
        "rightToLeft": false,
        "angle": 0,
        "xoffset": 0,
        "yoffset": 0,
        "kerning": true,
        "font": {
          "family": "Arial",
          "size": 12,
          "style": "normal",
          "weight": "bold",
          "decoration": "none"
        }
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let textSymbol = try AGSTextSymbol.fromJSON(JSON) as! AGSTextSymbol
      printAGSTextSymbol(textSymbol)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)  // Failed parsing; JSON is invalid

  }

  func printAGSTextSymbol(_ symbol: AGSTextSymbol) {
    print("AGSTextSymbol properties")
    print("  color: \(symbol.color)")
    print("  backgroundColor: \(symbol.backgroundColor)")
    print("  borderLineSize: \(symbol.outlineWidth)")
    print("  borderLineColor: \(String(describing: symbol.outlineColor))")
    print("  haloSize: \(symbol.haloWidth)")
    print("  haloColor: \(String(describing: symbol.haloColor))")
    print("  verticalAlignment: \(symbol.verticalAlignment) \(symbol.verticalAlignment.rawValue)")
    print(
      "  horizontalAlignment: \(symbol.horizontalAlignment) \(symbol.horizontalAlignment.rawValue)")
    print("  angle: \(symbol.angle)")
    print("  xoffset: \(symbol.offsetX)")
    print("  yoffset: \(symbol.offsetY)")
    print("  kerning: \(symbol.isKerningEnabled)")
    print("  font.family: \(symbol.fontFamily)")
    print("  font.size: \(symbol.size)")
    print("  font.style: \(symbol.fontStyle) \(symbol.fontStyle.rawValue)")
    print("  font.weight: \(symbol.fontWeight) \(symbol.fontWeight.rawValue)")
    print("  font.decoration: \(symbol.fontDecoration) \(symbol.fontDecoration.rawValue)")
    print("  text: \(symbol.text)")
    print("Properties not settable in JSON")
    print("  angleAlignment \(symbol.angleAlignment) \(symbol.angleAlignment.rawValue)")
    print("  leaderOffsetX \(symbol.leaderOffsetX)")
    print("  leaderOffsetY \(symbol.leaderOffsetY)")
    print("Issues")
    print("  unknownJSON \(String(describing: symbol.unknownJSON))")
    print("  unsupportedJSON \(String(describing: symbol.unsupportedJSON))")
  }

}
