//
//  DialogTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class DialogTests: XCTestCase {

  // No need to test standard decoding.
  // The following properties have special decoding that should be tested
  // Dialog.grouped
  // DialogElement.attributeName
  // DialogElement.attributeType
  // DialogElement.autocapitalizationType
  // DialogElement.defaultBool
  // DialogElement.disableAutocorrection
  // DialogElement.keyboardType
  // DialogElement.defaultInt
  // DialogElement.minimumInt
  // DialogElement.maximumInt

  //MARK: - Dialog.grouped

  func testDialogGrouped() {
    // Given:
    struct Test: Codable {
      let dialogs: [Dialog]
    }
    let jsonData = Data(
      """
      {
        "dialogs": [
          {"title": "a",                   "sections": [{"elements": [{"type": "QLabelElement"}]}]},
          {"title": "a", "grouped": false, "sections": [{"elements": [{"type": "QLabelElement"}]}]},
          {"title": "a", "grouped": true,  "sections": [{"elements": [{"type": "QLabelElement"}]}]}
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertFalse(test.dialogs[0].grouped)
      XCTAssertFalse(test.dialogs[1].grouped)
      XCTAssertTrue(test.dialogs[2].grouped)
    }
  }

  //MARK: - Dialog Section

  func testSectionNoDuplicateAttributeNames() {
    // Given:
    struct Test: Codable {
      let section: DialogSection
    }
    let jsonData = Data(
      """
      {
        "section": {
          "elements":[
            {"type": "QDecimalElement", "bind": "numberValue:name"},
            {"type": "QEntryElement",   "bind": "textValue:NAME"}
          ]
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - DialogElement.attributeName/Type

  func testElementTypeMatching() {
    // Given:
    // When:
    let element = DialogElement(
      attributeType: .index, attributeName: "Name", autocapitalizationType: .none, defaultBool: nil,
      defaultIndex: nil, defaultNumber: nil, disableAutocorrection: true, fractionDigits: nil,
      items: nil, keyboardType: .default, maximumValue: nil, minimumValue: nil, placeholder: nil,
      title: nil, type: .defaultPicker)

    // Then:
    XCTAssertTrue(element.matches(attributeType: .int32))
    XCTAssertFalse(element.matches(attributeType: .id))
  }

  func testDialogElementAttributeNameType() {
    // Given:
    struct Test: Codable {
      let elements: [DialogElement]
    }
    let jsonData = Data(
      """
      {
        "elements": [
          {"type": "QBooleanElement", "bind": "boolValue:name"},
          {"type": "QIntegerElement", "bind": "numberValue:_name"},
          {"type": "QRadioElement",   "bind": "selected:NAME2", "items":["a","b"]},
          {"type": "QRadioElement",   "bind": "selectedItem:_1name", "items":["a","b"]},
          {"type": "QEntryElement",   "bind": "textValue:Name_15"},
          {"type": "QLabelElement",   "bind": "value:New"},
          {"type": "QLabelElement"}
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertEqual(test.elements[0].attributeName!, "name")
      XCTAssertEqual(test.elements[1].attributeName!, "_name")
      XCTAssertEqual(test.elements[2].attributeName!, "NAME2")
      XCTAssertEqual(test.elements[3].attributeName!, "_1name")
      XCTAssertEqual(test.elements[4].attributeName!, "Name_15")
      XCTAssertEqual(test.elements[5].attributeName!, "New")
      XCTAssertNil(test.elements[6].attributeName)
      XCTAssertEqual(test.elements[0].attributeType!, .bool)
      XCTAssertEqual(test.elements[1].attributeType!, .number)
      XCTAssertEqual(test.elements[2].attributeType!, .index)
      XCTAssertEqual(test.elements[3].attributeType!, .item)
      XCTAssertEqual(test.elements[4].attributeType!, .text)
      XCTAssertEqual(test.elements[5].attributeType!, .id)
      XCTAssertNil(test.elements[6].attributeType)
    }
  }

  func testDialogElementAttributeNameShort() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QLabelElement", "bind": "value:A"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testDialogElementAttributeNameLong() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QLabelElement", "bind": "value:ABCDEFGHIJK_LMNOPQRSTUVWXYZ_1234"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testDialogElementAttributeNameSpace() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QLabelElement", "bind": "value:My Name"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testDialogElementAttributeNameSpecial() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QLabelElement", "bind": "value:Name!"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testDialogElementAttributeTypeInvalid() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QBooleanElement", "bind":"QLabelElement", "bind": "bool:Name"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testDialogElementAttributeNameTypeMissingColon() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "type": "QLabelElement", "bind": "value_Name"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testDialogElementAttributeNameTypeExtraColon() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "type": "QLabelElement", "bind": "value::Name"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - DialogElement.autocapitalizationType

  func testDialogElementAutocapitalizationType() {
    // Given:
    struct Test: Codable {
      let elements: [DialogElement]
    }
    let jsonData = Data(
      """
      {
        "elements": [
          {"type": "QEntryElement", "bind": "textValue:Name"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocapitalizationType": "AllCharacters"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocapitalizationType": "Sentences"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocapitalizationType": "Words"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocapitalizationType": "words"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocapitalizationType": "WORDS"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocapitalizationType": "None"}
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertEqual(test.elements[0].autocapitalizationType, .none)
      XCTAssertEqual(test.elements[1].autocapitalizationType, .allCharacters)
      XCTAssertEqual(test.elements[2].autocapitalizationType, .sentences)
      XCTAssertEqual(test.elements[3].autocapitalizationType, .words)
      XCTAssertEqual(test.elements[4].autocapitalizationType, .words)
      XCTAssertEqual(test.elements[5].autocapitalizationType, .words)
      XCTAssertEqual(test.elements[6].autocapitalizationType, .none)
    }
  }

  func testDialogElementAutocapitalizationTypeWrong() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QEntryElement", "bind": "textValue:Name", "autocapitalizationType": "Yes"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - DialogElement.defaultBool

  func testDialogElementDefaultBool() {
    // Given:
    struct Test: Codable {
      let elements: [DialogElement]
    }
    let jsonData = Data(
      """
      {
        "elements": [
          {"type": "QBooleanElement", "bind": "boolValue:Name"},
          {"type": "QBooleanElement", "bind": "boolValue:Name", "boolValue": 1},
          {"type": "QBooleanElement", "bind": "boolValue:Name", "boolValue": 101},
          {"type": "QBooleanElement", "bind": "boolValue:Name", "boolValue": 0}
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertNil(test.elements[0].defaultBool)
      XCTAssertEqual(test.elements[1].defaultBool!, true)
      XCTAssertEqual(test.elements[2].defaultBool!, true)
      XCTAssertEqual(test.elements[3].defaultBool!, false)
    }
  }

  func testDialogElementDefaultBoolWrong() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QBooleanElement", "bind": "boolValue:Name", "boolValue": true
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  // boolValue should only be used with QBooleanElement
  // Verify another type throws
  func testTextEntryWithBoolValue() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QEntryElement", "bind": "textValue:Name", "boolValue": 1
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - DialogElement.disableAutocorrection

  func testDialogElementDisableAutocorrection() {
    // Given:
    struct Test: Codable {
      let elements: [DialogElement]
    }
    let jsonData = Data(
      """
      {
        "elements": [
          {"type": "QEntryElement", "bind": "textValue:Name"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocorrectionType": "Default"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocorrectionType": "Yes"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocorrectionType": "yes"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocorrectionType": "YES"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocorrectionType": "No"},
          {"type": "QEntryElement", "bind": "textValue:Name", "autocorrectionType": "no"}
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertFalse(test.elements[0].disableAutocorrection)
      XCTAssertFalse(test.elements[1].disableAutocorrection)
      XCTAssertFalse(test.elements[2].disableAutocorrection)
      XCTAssertFalse(test.elements[3].disableAutocorrection)
      XCTAssertFalse(test.elements[4].disableAutocorrection)
      XCTAssertTrue(test.elements[5].disableAutocorrection)
      XCTAssertTrue(test.elements[6].disableAutocorrection)
    }
  }

  func testDialogElementDisableAutocorrectionWrong() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QEntryElement", "bind": "textValue:Name", "autocorrectionType": "Maybe"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - DialogElement.keyboardType

  func testDialogElementKeyboardType() {
    // Given:
    struct Test: Codable {
      let elements: [DialogElement]
    }
    let jsonData = Data(
      """
      {
        "elements": [
          {"type": "QEntryElement", "bind": "textValue:Name"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "Alphabet"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "ASCIICapable"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "ASCIICapableNumberPad"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "DecimalPad"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "default"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "Default"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "DEFAULT"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "EmailAddress"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "NamePhonePad"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "NumberPad"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "NumbersAndPunctuation"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "PhonePad"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "Twitter"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "URL"},
          {"type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "WebSearch"},
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertEqual(test.elements[0].keyboardType, .default)
      XCTAssertEqual(test.elements[1].keyboardType, .asciiCapable)
      XCTAssertEqual(test.elements[2].keyboardType, .asciiCapable)
      XCTAssertEqual(test.elements[3].keyboardType, .asciiCapableNumberPad)
      XCTAssertEqual(test.elements[4].keyboardType, .decimalPad)
      XCTAssertEqual(test.elements[5].keyboardType, .default)
      XCTAssertEqual(test.elements[6].keyboardType, .default)
      XCTAssertEqual(test.elements[7].keyboardType, .default)
      XCTAssertEqual(test.elements[8].keyboardType, .emailAddress)
      XCTAssertEqual(test.elements[9].keyboardType, .namePhonePad)
      XCTAssertEqual(test.elements[10].keyboardType, .numberPad)
      XCTAssertEqual(test.elements[11].keyboardType, .numbersAndPunctuation)
      XCTAssertEqual(test.elements[12].keyboardType, .phonePad)
      XCTAssertEqual(test.elements[13].keyboardType, .twitter)
      XCTAssertEqual(test.elements[14].keyboardType, .URL)
      XCTAssertEqual(test.elements[15].keyboardType, .webSearch)
    }
  }

  func testDialogElementKeyboardTypeWrong() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QEntryElement", "bind": "textValue:Name", "keyboardType": "Numbers"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - DialogElement.defaultInt/minimumInt/maximumInt

  func testDialogElementDefaultMinMaxInt() {
    // Given:
    struct Test: Codable {
      let elements: [DialogElement]
    }
    let jsonData = Data(
      """
      {
        "elements": [
          {"type": "QIntegerElement", "bind": "numberValue:Name"},
          {"type": "QIntegerElement", "bind": "numberValue:Name",
           "numberValue": -5, "minimumValue": -10, "maximumValue": -1},
          {"type": "QIntegerElement", "bind": "numberValue:Name",
           "numberValue": 10.0, "minimumValue": 0.0, "maximumValue": 100.0},
          {"type": "QDecimalElement", "bind": "numberValue:Name",
           "numberValue": 43.99, "minimumValue": 12.99, "maximumValue": 56.01},
          {"type": "QDecimalElement", "bind": "numberValue:Name",
           "numberValue": 43.21, "minimumValue": 12.34, "maximumValue": 56.78}
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertNil(test.elements[0].defaultNumber)
      XCTAssertNil(test.elements[0].minimumValue)
      XCTAssertNil(test.elements[0].maximumValue)
      XCTAssertNil(test.elements[0].defaultInt)
      XCTAssertNil(test.elements[0].minimumInt)
      XCTAssertNil(test.elements[0].maximumInt)

      XCTAssertEqual(test.elements[1].defaultNumber!, -5.0, accuracy: 0.001)
      XCTAssertEqual(test.elements[1].minimumValue!, -10.0, accuracy: 0.001)
      XCTAssertEqual(test.elements[1].maximumValue!, -1.0, accuracy: 0.001)
      XCTAssertEqual(test.elements[1].defaultInt!, -5)
      XCTAssertEqual(test.elements[1].minimumInt!, -10)
      XCTAssertEqual(test.elements[1].maximumInt!, -1)

      XCTAssertEqual(test.elements[2].defaultNumber!, 10.0, accuracy: 0.001)
      XCTAssertEqual(test.elements[2].minimumValue!, 0.0, accuracy: 0.001)
      XCTAssertEqual(test.elements[2].maximumValue!, 100.0, accuracy: 0.001)
      XCTAssertEqual(test.elements[2].defaultInt!, 10)
      XCTAssertEqual(test.elements[2].minimumInt!, 0)
      XCTAssertEqual(test.elements[2].maximumInt!, 100)

      XCTAssertEqual(test.elements[3].defaultNumber!, 43.99, accuracy: 0.001)
      XCTAssertEqual(test.elements[3].minimumValue!, 12.99, accuracy: 0.001)
      XCTAssertEqual(test.elements[3].maximumValue!, 56.01, accuracy: 0.001)
      XCTAssertEqual(test.elements[3].defaultInt!, 44)
      XCTAssertEqual(test.elements[3].minimumInt!, 13)
      XCTAssertEqual(test.elements[3].maximumInt!, 56)

      XCTAssertEqual(test.elements[4].defaultNumber!, 43.21, accuracy: 0.001)
      XCTAssertEqual(test.elements[4].minimumValue!, 12.34, accuracy: 0.001)
      XCTAssertEqual(test.elements[4].maximumValue!, 56.78, accuracy: 0.001)
      XCTAssertEqual(test.elements[4].defaultInt!, 43)
      XCTAssertEqual(test.elements[4].minimumInt!, 12)
      XCTAssertEqual(test.elements[4].maximumInt!, 57)
    }
  }

  func testDialogElementMinGreaterThanMax() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QDecimalElement", "bind": "numberValue:Name",
           "minimumValue": 10.0, "maximumValue": 0.0
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testDialogElementDefaultGreaterThanMax() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QDecimalElement", "bind": "numberValue:Name",
           "numberValue": 100.0, "maximumValue": 10.0
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testDialogElementDefaultLessThanMin() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QDecimalElement", "bind": "numberValue:Name",
           "numberValue": 10.0, "minimumValue": 100.0
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  // Test that Number Properties (min/default/max) only on QInteger and QDecimal
  // Valid cases were verified in testDialogElementDefaultMinMaxInt()
  // Here I test a few bad combinations for failure
  func testNumberValueOnlyOnNumbers() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QBooleanElement", "bind": "boolValue:Name",
           "numberValue": 43.21
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testMinimumValueOnlyOnNumbers() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QRadioElement", "bind": "selected:Name", "items": ["a", "b", "c"],
           "minimumValue": 12.34
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testMaximumValueOnlyOnNumbers() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
           "type": "QEntryElement", "bind": "textValue:Name",
           "maximumValue": 56.78
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - DialogElement Validation

  //MARK: - Bind

  func testBindMissing() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QDecimalElement"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  // There are 48 permutations (8 types, 6 binds) to check
  // I will verify all the valid ones succeed,
  // and randomly test a few of the expected failures
  func testBindTypeMatch() {
    // Given:
    struct Test: Codable {
      let elements: [DialogElement]
    }
    let jsonData = Data(
      """
      {
        "elements": [
          {"type": "QBooleanElement",   "bind": "boolValue:Name1"},
          {"type": "QDecimalElement",   "bind": "numberValue:Name2"},
          {"type": "QEntryElement",     "bind": "textValue:Name3"},
          {"type": "QIntegerElement",   "bind": "numberValue:Name4"},
          {"type": "QLabelElement",     "bind": "value:Name5"},
          {"type": "QLabelElement"},
          {"type": "QMultilineElement", "bind": "textValue:Name6"},
          {"type": "QRadioElement",     "bind": "selected:Name7", "items":["a","b"]},
          {"type": "QRadioElement",     "bind": "selectedItem:Name8", "items":["a","b"]},
          {"type": "QSegmentedElement", "bind": "selected:Name9", "items":["a","b"]},
          {"type": "QSegmentedElement", "bind": "selectedItem:Name10", "items":["a","b"]}
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
  }

  func testBindMisMatch1() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QDecimalElement", "bind": "textValue:Name"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testBindMisMatch2() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QEntyElement", "bind": "boolValue:Name"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testBindMisMatch3() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QBooleanElement", "bind": "numberValue:Name"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - DialogElement Pickers

  func testSelectedNotInt() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QRadioElement", "bind": "selected:Name",
          "selected": 2.3, "items": ["a","b", "c"]
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testSelectedTooSmall() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QRadioElement", "bind": "selected:Name",
          "selected": -1, "items": ["a","b", "c"]
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testSelectedTooLarge() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QRadioElement", "bind": "selected:Name",
          "selected": 3, "items": ["a", "b", "c"]
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testSelectedJustRight() {
    // Given:
    struct Test: Codable {
      let elements: [DialogElement]
    }
    let jsonData = Data(
      """
      {
        "elements":[
          {"type": "QRadioElement", "bind": "selected:Name",
          "selected": 0, "items": ["a", "b", "c"]},
          {"type": "QRadioElement", "bind": "selectedItem:Name2",
          "selected": 1, "items": ["a", "b", "c"]},
          {"type": "QSegmentedElement", "bind": "selected:Name3",
          "selected": 2, "items": ["a","b", "c"]}
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertEqual(test.elements[0].defaultIndex, 0)
      XCTAssertEqual(test.elements[1].defaultIndex, 1)
      XCTAssertEqual(test.elements[2].defaultIndex, 2)
    }
  }

  // Test that Picker Properties (items) only used with Pickers
  // Valid cases were verified in testSelectedJustRight()
  // Here I test a few bad combinations for failure
  func testPicker1WithNoItems() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QRadioElement", "bind": "selected:Name"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testPicker2WithNoItems() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QSegmentedElement", "bind": "selected:Name"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testTextEntryWithItems() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QEntryElement", "bind": "textValue:Name", "items": ["a", "b", "c"]
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - DialogElement FractionDigits

  func testFractionDigitsTooSmall() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QDecimalElement", "bind": "numberValue:Name", "fractionDigits": -1
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testFractionDigitsToolarge() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QDecimalElement", "bind": "numberValue:Name", "fractionDigits": 9
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testFractionDigitsJustRight() {
    // Given:
    struct Test: Codable {
      let elements: [DialogElement]
    }
    let jsonData = Data(
      """
      {
        "elements":[
          {"type": "QDecimalElement", "bind": "numberValue:Name1", "fractionDigits": 0},
          {"type": "QDecimalElement", "bind": "numberValue:Name2", "fractionDigits": 2},
          {"type": "QDecimalElement", "bind": "numberValue:Name3", "fractionDigits": 8}
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertEqual(test.elements[0].fractionDigits!, 0)
      XCTAssertEqual(test.elements[1].fractionDigits!, 2)
      XCTAssertEqual(test.elements[2].fractionDigits!, 8)
    }
  }

  func testTextEntryWithFractionDigits() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QEntryElement", "bind": "textValue:Name", "fractionDigits": 2
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - Text Properties

  func testTextPoperties() {
    // Given:
    struct Test: Codable {
      let elements: [DialogElement]
    }
    let jsonData = Data(
      """
      {
        "elements":[
          {"type": "QEntryElement", "bind": "textValue:Name1",
           "autocapitalizationType": "Words", "autocorrectionType": "No",
           "keyboardType": "Default", "placeholder": "hello1"},
          {"type": "QMultilineElement", "bind": "textValue:Name2",
           "autocapitalizationType": "Words", "autocorrectionType": "No",
           "keyboardType": "EmailAddress", "placeholder": "hello2"},
          {"type": "QDecimalElement", "bind": "numberValue:Name3",
           "keyboardType": "DecimalPad", "placeholder": "°F"},
          {"type": "QIntegerElement", "bind": "numberValue:Name4",
           "keyboardType": "NumberPad", "placeholder": "Qty"}
        ]
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertEqual(test.elements[0].placeholder!, "hello1")
      XCTAssertEqual(test.elements[1].placeholder!, "hello2")
      XCTAssertEqual(test.elements[2].placeholder!, "°F")
      XCTAssertEqual(test.elements[3].placeholder!, "Qty")
    }
  }

  // verify autocorrect, autocaps only on text
  //  keyboard, placeholder on int, dec, text
  func testNoKeyboardOnBoolean() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QBooleanElement", "bind": "boolValue:Name", "keyboardType": "NumberPad"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testNoAutocorrectOnInteger() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QIntegerElement", "bind": "numberValue:Name", "autocorrectionType": "Yes"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testNoAutocapitalsOnDecimal() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QDecimalElement", "bind": "numberValue:Name", "autocapitalizationType": "Words"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testNoplaceholderOnPicker() {
    // Given:
    struct Test: Codable {
      let element: DialogElement
    }
    let jsonData = Data(
      """
      {
        "element": {
          "type": "QRadioElement", "bind": "selected:Name",
          "items": ["a", "b", "c"], "placeholder": "Qty"
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

}
