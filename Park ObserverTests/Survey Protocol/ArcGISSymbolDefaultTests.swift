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

//MARK: - Simple Marker Symbol

  func testMinimalSimpleMarkerSymbol() {

    let jsonData = Data(
      """
      {
        "type": "esriSMS"
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let markerSymbol = try AGSSimpleMarkerSymbol.fromJSON(JSON) as! AGSSimpleMarkerSymbol
      printAGSSimpleMarkerSymbol(markerSymbol)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func testMinimalSimpleMarkerSymbol2() {

    let jsonData = Data(
      """
      {
        "type": "esriSMS",
        "outline": {}
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let markerSymbol = try AGSSimpleMarkerSymbol.fromJSON(JSON) as! AGSSimpleMarkerSymbol
      printAGSSimpleMarkerSymbol(markerSymbol)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func testExampleSimpleMarkerSymbol() {

    let jsonData = Data(
      """
      {
        "type": "esriSMS",
        "style": "esriSMSSquare",
        "color": [76,115,0,255],
        "size": 8,
        "angle": 0,
        "xoffset": 0,
        "yoffset": 0,
        "outline": {
          "color": [152,230,0,255],
          "width": 1
        }
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let markerSymbol = try AGSSimpleMarkerSymbol.fromJSON(JSON) as! AGSSimpleMarkerSymbol
      printAGSSimpleMarkerSymbol(markerSymbol)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func printAGSSimpleMarkerSymbol(_ symbol: AGSSimpleMarkerSymbol) {
    print("AGSSimpleMarkerSymbol properties")
    print("  style: \(symbol.style) \(symbol.style.rawValue)")
    print("  color: \(symbol.color)")
    print("  size: \(symbol.size)")
    print("  angle: \(symbol.angle)")
    print("  xoffset: \(symbol.offsetX)")
    print("  yoffset: \(symbol.offsetY)")
    print("  outline.color: \(String(describing: symbol.outline?.color))")
    print("  outline.width: \(String(describing: symbol.outline?.width))")
    print("Properties not settable in JSON")
    print("  angleAlignment: \(symbol.angleAlignment) \(symbol.angleAlignment.rawValue)")
    print("  leaderOffsetX: \(symbol.leaderOffsetX)")
    print("  leaderOffsetY: \(symbol.leaderOffsetY)")
    print("  outline.style: \(String(describing: symbol.outline?.style)) \(String(describing: symbol.outline?.style.rawValue))")
    print("Issues")
    print("  unknownJSON: \(String(describing: symbol.unknownJSON))")
    print("  unsupportedJSON: \(String(describing: symbol.unsupportedJSON))")
  }


//MARK: - Picture Symbol


  func testMinimalPictureSymbol() {

    let jsonData = Data(
      """
      {
        "type": "esriPMS"
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let pictureSymbol = try AGSPictureMarkerSymbol.fromJSON(JSON) as! AGSPictureMarkerSymbol
      printAGSPictureMarkerSymbol(pictureSymbol)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func testExamplePictureSymbol() {

    let jsonData = Data(
      """
      {
        "type": "esriPMS",
        "url" : "471E7E31",
        "imageData" : "iVBORw0KGgoAAAANSUhEUgAAABoAAAAaCAYAAACpSkzOAAAAAXNSR0IB2cksfwAAAAlwSFlzAAAOxAAADsQBlSsOGwAAAMNJREFUSIntlcENwyAMRZ+lSMyQFcI8rJA50jWyQuahKzCDT+6h0EuL1BA1iip8Qg/Ex99fYuCkGv5bKK0EcB40YgSE7bnTxsa58LeOnMd0QhwGXkxB3L0w0IDxPaMqpBFxjLMuaSVmRjurWIcRDHxaiWZuEbRcEhpZpSNhE9O81GiMN5E0ZRt2M0iVjshek8UkTQfZy8JqGHYP/rJhODD4T6wehtbB9zD0MPQwlOphaAxD/uPLK7Z8MB5gFet+WKcJPQDx29XkRhqr/AAAAABJRU5ErkJggg==",
        "contentType" : "image/png",
        "width" : 19.5,
        "height" : 19.5,
        "angle" : 0,
        "xoffset" : 0,
        "yoffset" : 0
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let pictureSymbol = try AGSPictureMarkerSymbol.fromJSON(JSON) as! AGSPictureMarkerSymbol
      printAGSPictureMarkerSymbol(pictureSymbol)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func printAGSPictureMarkerSymbol(_ symbol: AGSPictureMarkerSymbol) {
    print("AGSPictureMarkerSymbol properties")
    print("  url: \(String(describing: symbol.url))")
    print("  imageData: \(String(describing: symbol.image))")
    print("  contentType: \(String(describing: symbol.image))")
    print("  width: \(symbol.width)")
    print("  height: \(symbol.height)")
    print("  angle: \(symbol.angle)")
    print("  xoffset: \(symbol.offsetX)")
    print("  yoffset: \(symbol.offsetY)")
    print("Properties not settable in JSON")
    print("  angleAlignment: \(symbol.angleAlignment) \(symbol.angleAlignment.rawValue)")
    print("  leaderOffsetX: \(symbol.leaderOffsetX)")
    print("  leaderOffsetY: \(symbol.leaderOffsetY)")
    print("  opacity: \(symbol.opacity)")
    print("Issues")
    print("  unknownJSON: \(String(describing: symbol.unknownJSON))")
    print("  unsupportedJSON: \(String(describing: symbol.unsupportedJSON))")
  }


  //MARK: - Simple Line Symbol


  func testMinimalSimpleLineSymbol() {

    let jsonData = Data(
      """
      {
        "type": "esriSLS"
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let markerSymbol = try AGSSimpleLineSymbol.fromJSON(JSON) as! AGSSimpleLineSymbol
      printAGSSimpleLineSymbol(markerSymbol)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func testExampleSimpleLineSymbol() {

    let jsonData = Data(
      """
      {
        "type": "esriSLS",
        "style": "esriSLSDot",
        "color": [115,76,0,255],
        "width": 1
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let markerSymbol = try AGSSimpleLineSymbol.fromJSON(JSON) as! AGSSimpleLineSymbol
      printAGSSimpleLineSymbol(markerSymbol)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func printAGSSimpleLineSymbol(_ symbol: AGSSimpleLineSymbol) {
    print("AGSSimpleLineSymbol properties")
    print("  style: \(symbol.style) \(symbol.style.rawValue)")
    print("  color: \(symbol.color)")
    print("  width: \(symbol.width)")
    print("Properties not settable in JSON")
    print("  antialias: \(symbol.antialias)")
    print("  markerPlacement: \(symbol.markerPlacement) \(symbol.markerPlacement.rawValue)")
    print("  markerStyle: \(symbol.markerStyle) \(symbol.markerStyle.rawValue)")
    print("Issues")
    print("  unknownJSON: \(String(describing: symbol.unknownJSON))")
    print("  unsupportedJSON: \(String(describing: symbol.unsupportedJSON))")
  }


  //MARK: - Text Symbol


  func testMinimalTextSymbol() {

    let jsonData = Data(
      """
      {
        "type": "esriTS"
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
    print("  angleAlignment: \(symbol.angleAlignment) \(symbol.angleAlignment.rawValue)")
    print("  leaderOffsetX: \(symbol.leaderOffsetX)")
    print("  leaderOffsetY: \(symbol.leaderOffsetY)")
    print("Issues")
    print("  unknownJSON: \(String(describing: symbol.unknownJSON))")
    print("  unsupportedJSON: \(String(describing: symbol.unsupportedJSON))")
  }


  //MARK: - Simple Renderer


  func testMinimalSimpleRenderer() {

    let jsonData = Data(
      """
      {
        "type": "simple"
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let renderer = try AGSSimpleRenderer.fromJSON(JSON) as! AGSSimpleRenderer
      printAGSSimpleRenderer(renderer)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func testExampleSimpleRenderer() {

    let jsonData = Data(
      """
      {
        "type": "simple",
        "symbol": {
          "type": "esriSMS",
          "style": "esriSMSCircle",
          "color": [255,0,0,255],
          "size": 5,
          "angle": 0,
          "xoffset": 0,
          "yoffset": 0,
          "outline": {
            "color": [0,0,0,255],
            "width": 1
          }
        },
        "label": "",
        "description": "",
        "rotationType": "geographic",
        "rotationExpression": "[Rotation] * 2"
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let renderer = try AGSSimpleRenderer.fromJSON(JSON) as! AGSSimpleRenderer
      printAGSSimpleRenderer(renderer)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func printAGSSimpleRenderer(_ renderer: AGSSimpleRenderer) {
    print("AGSSimpleRenderer properties")
    print("  type: simple")
    print("  symbol: \(String(describing: renderer.symbol))")
    print("  label: \(renderer.label)")
    print("  description: \(renderer.rendererDescription)")
    print("  rotationType: \(renderer.rotationType) \(renderer.rotationType.rawValue)")
    print("  rotationExpression: \(renderer.rotationExpression)")
    print("Properties not settable in JSON")
    print("  sceneProperties: \(String(describing: renderer.sceneProperties))")
    print("Issues")
    print("  unknownJSON: \(String(describing: renderer.unknownJSON))")
    print("  unsupportedJSON: \(String(describing: renderer.unsupportedJSON))")
  }


//MARK: - Unique Value Renderer


  func testMinimalUniqueValueRenderer() {

    let jsonData = Data(
      """
      {
        "type": "uniqueValue"
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let renderer = try AGSUniqueValueRenderer.fromJSON(JSON) as! AGSUniqueValueRenderer
      printAGSUniqueValueRenderer(renderer)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func testMinimalUsefulUniqueValueRenderer() {
    //        "field2": "age",

    let jsonData = Data(
      """
      {
        "type": "uniqueValue",
        "field1": "name",
        "defaultSymbol": {"type":"esriSMS", "size": 5},
        "uniqueValueInfos": [{
          "value": "bob",
          "symbol": {"type":"esriSMS", "size": 10}
        },{
          "value": "BOB",
          "symbol": {"type":"esriSMS", "size": 20}
        }]
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let renderer = try AGSUniqueValueRenderer.fromJSON(JSON) as! AGSUniqueValueRenderer
      printAGSUniqueValueRenderer(renderer)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }
  func testExampleUniqueValueRenderer() {

    let jsonData = Data(
      """
      {
        "type" : "uniqueValue",
        "field1" : "SubtypeCD",
        "field2" : null,
        "field3" : null,
        "fieldDelimiter" : ", ",
        "defaultSymbol" :
        {
          "type" : "esriSLS",
          "style" : "esriSLSSolid",
          "color" : [130,130,130,255],
          "width" : 1
        },
        "defaultLabel" : "<Other values>",
        "uniqueValueInfos" : [
          {
            "value" : "1",
            "label" : "Duct Bank",
            "description" : "Duct Bank description",
            "symbol" :
            {
              "type" : "esriSLS",
              "style" : "esriSLSDash",
              "color" : [76,0,163,255],
              "width" : 1
            }
          },
          {
            "value" : "2",
            "label" : "Trench",
            "description" : "Trench description",
            "symbol" :
            {
              "type" : "esriSLS",
              "style" : "esriSLSDot",
              "color" : [115,76,0,255],
              "width" : 1
            }
          }
        ],
        "rotationType": "geographic",
        "rotationExpression": "[Rotation] * 2"
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let renderer = try AGSUniqueValueRenderer.fromJSON(JSON) as! AGSUniqueValueRenderer
      printAGSUniqueValueRenderer(renderer)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func printAGSUniqueValueRenderer(_ renderer: AGSUniqueValueRenderer) {
    print("AGSUniqueValueRenderer properties")
    print("  type: uniqueValue")
    print("  field1: \(renderer.fieldNames)")
    print("  field2: \(renderer.fieldNames)")
    print("  field3: \(renderer.fieldNames)")
    print("  fieldDelimiter: not used")
    print("  defaultSymbol: \(String(describing: renderer.defaultSymbol))")
    print("  defaultLabel: \(renderer.defaultLabel)")
    print("  rotationType: \(renderer.rotationType) \(renderer.rotationType.rawValue)")
    print("  rotationExpression: \(renderer.rotationExpression)")
    print("  uniqueValueInfos count: \(renderer.uniqueValues.count)")
    for (i, uniqueValues) in renderer.uniqueValues.enumerated() {
      print("    uniqueValue #\(i+1)")
      print("    value: \(uniqueValues.values)")
      print("    label: \(uniqueValues.label)")
      print("    description: \(uniqueValues.valueDescription)")
      print("    symbol: \(String(describing: uniqueValues.symbol))")
      print("    unknownJSON: \(String(describing: uniqueValues.unknownJSON))")
      print("    unsupportedJSON: \(String(describing: uniqueValues.unsupportedJSON))")
    }
    print("Properties not settable in JSON")
    print("  sceneProperties: \(String(describing: renderer.sceneProperties))")
    print("Issues")
    print("  unknownJSON: \(String(describing: renderer.unknownJSON))")
    print("  unsupportedJSON: \(String(describing: renderer.unsupportedJSON))")
  }


//MARK: - Class Breaks Renderer


  func testMinimalClassBreaksRenderer() {

    let jsonData = Data(
      """
      {
        "type": "classBreaks"
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let renderer = try AGSClassBreaksRenderer.fromJSON(JSON) as! AGSClassBreaksRenderer
      printAGSClassBreaksRenderer(renderer)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func testMinimalUsefulClassBreaksRenderer() {

    let jsonData = Data(
      """
      {
        "type": "classBreaks",
        "field": "age",
        "minValue" : 0,
        "defaultSymbol": {"type":"esriSMS", "size": 5},
        "classBreakInfos": [{
          "classMaxValue": 25,
          "symbol": {"type":"esriSMS", "size": 10}
        },{
          "classMaxValue": 100,
          "symbol": {"type":"esriSMS", "size": 20}
        }]
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let renderer = try AGSClassBreaksRenderer.fromJSON(JSON) as! AGSClassBreaksRenderer
      printAGSClassBreaksRenderer(renderer)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func testExampleClassBreaksRenderer() {

    let jsonData = Data(
      """
      {
        "type" : "classBreaks",
        "field" : "Shape.area",
        "classificationMethod" : "esriClassifyManual",
        "defaultSymbol": {
          "type": "esriSFS",
          "style": "esriSFSDiagonalCross",
          "color": [255,0,0,255],
          "outline": {
            "type": "esriSLS",
            "style": "esriSLSSolid",
            "color": [110,110,110,255],
            "width": 0.5
          }
        }
        "minValue" : 10.0,
        "classBreakInfos" : [
          {
            "classMaxValue" : 1000,
            "label" : "10.0 - 1000.000000",
            "description" : "10 to 1000",
            "symbol" :
            {
              "type" : "esriSFS",
              "style" : "esriSFSSolid",
              "color" : [236,252,204,255],
              "outline" :
              {
                "type" : "esriSLS",
                "style" : "esriSLSSolid",
                "color" : [110,110,110,255],
                "width" : 0.4
              }
            }
          },
          {
            "classMaxValue" : 8000,
            "label" : "1000.000001 - 8000.000000",
            "description" : "1000 to 8000",
            "symbol" :
            {
              "type" : "esriSFS",
              "style" : "esriSFSSolid",
              "color" : [218,240,158,255],
              "outline" :
              {
                "type" : "esriSLS",
                "style" : "esriSLSSolid",
                "color" : [110,110,110,255],
                "width" : 0.4
              }
            }
          },
          {
            "classMaxValue" : 10000,
            "label" : "8000.000001 - 10000.000000",
            "description" : "8000 to 10000",
            "symbol" :
            {
              "type" : "esriSFS",
              "style" : "esriSFSSolid",
              "color" : [255,255,0,255],
              "outline" :
              {
                "type" : "esriSLS",
                "style" : "esriSLSSolid",
                "color" : [110,110,110,255],
                "width" : 0.4
              }
            }
          }
        ],
        "rotationType": "geographic",
        "rotationExpression": "[Rotation] * 2"
      }
      """.utf8)

    do {
      let JSON = try JSONSerialization.jsonObject(
        with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
      let renderer = try AGSClassBreaksRenderer.fromJSON(JSON) as! AGSClassBreaksRenderer
      printAGSClassBreaksRenderer(renderer)
    } catch {
      print(error)
    }
    XCTAssertNotNil(jsonData)
  }

  func printAGSClassBreaksRenderer(_ renderer: AGSClassBreaksRenderer) {
    print("AGSClassBreaksRenderer properties")
    print("  type: simple")
    print("  field: \(renderer.fieldName)")
    print("  classificationMethod: \(renderer.classificationMethod) \(renderer.classificationMethod.rawValue)")
    print("  normalizationType: \(renderer.normalizationType) \(renderer.normalizationType.rawValue)")
    print("  normalizationField: \(renderer.normalizationField)")
    print("  normalizationTotal: \(renderer.normalizationTotal)")
    print("  defaultSymbol: \(String(describing: renderer.defaultSymbol))")
    print("  defaultLabel: \(renderer.defaultLabel)")
    print("  backgroundFillSymbol: \(String(describing: renderer.backgroundFillSymbol))")
    print("  minValue: \(renderer.minValue)")
    print("  rotationType: \(renderer.rotationType) \(renderer.rotationType.rawValue)")
    print("  rotationExpression: \(renderer.rotationExpression)")
    print("  classBreakInfos count: \(renderer.classBreaks.count)")
    for (i, classBreak) in renderer.classBreaks.enumerated() {
      print("    classBreak #\(i+1)")
      print("    classMinValue: \(classBreak.minValue)")
      print("    classMaxValue: \(classBreak.maxValue)")
      print("    label: \(classBreak.label)")
      print("    description: \(classBreak.breakDescription)")
      print("    symbol: \(String(describing: classBreak.symbol))")
      print("    unknownJSON: \(String(describing: classBreak.unknownJSON))")
      print("    unsupportedJSON: \(String(describing: classBreak.unsupportedJSON))")
    }
    print("Properties not settable in JSON")
    print("  sceneProperties: \(String(describing: renderer.sceneProperties))")
    print("Issues")
    print("  unknownJSON: \(String(describing: renderer.unknownJSON))")
    print("  unsupportedJSON: \(String(describing: renderer.unsupportedJSON))")
  }


//MARK: - Label Definition

// The AGSLabelDefinition object has no properties to inspect.
// There is no way to be sure of which properties are optional
// except by testing. A guess can be made based on
// the defaults for the other objects above.

}
