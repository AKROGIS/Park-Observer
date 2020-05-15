//
//  FileManagerTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/11/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class FileManagerTests: XCTestCase {

  func testArchiveDocuments() {
    var names = FileManager.default.archiveNames
    print("Existing Archives: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = FileManager.default.archiveURL(with: testName)
    print("Last Path Component: \(url.lastPathComponent)")
    var ok = false
    do {
      try "DumbData".write(to: url, atomically: true, encoding: .utf8)
      ok = true
    } catch {
      print(error)
    }
    XCTAssertTrue(ok)
    if ok {
      names = FileManager.default.archiveNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try FileManager.default.deleteArchive(with: testName)
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = FileManager.default.archiveNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  func testMapDocuments() {
    var names = FileManager.default.mapNames
    print("Existing Maps: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = FileManager.default.mapURL(with: testName)
    print("Last Path Component: \(url.lastPathComponent)")
    var ok = false
    do {
      try "DumbData".write(to: url, atomically: true, encoding: .utf8)
      ok = true
    } catch {
      print(error)
    }
    XCTAssertTrue(ok)
    if ok {
      names = FileManager.default.mapNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try FileManager.default.deleteMap(with: testName)
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = FileManager.default.mapNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  func testProtocolDocuments() {
    var names = FileManager.default.protocolNames
    print("Existing Protocols: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = FileManager.default.protocolURL(with: testName)
    print("Last Path Component: \(url.lastPathComponent)")
    var ok = false
    do {
      try "DumbData".write(to: url, atomically: true, encoding: .utf8)
      ok = true
    } catch {
      print(error)
    }
    XCTAssertTrue(ok)
    if ok {
      names = FileManager.default.protocolNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try FileManager.default.deleteProtocol(with: testName)
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = FileManager.default.protocolNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  func testSurveyDocuments() {
    let path = FileManager.default.surveyDirectory.path
    XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    var names = FileManager.default.surveyNames
    print("Existing Surveys: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = FileManager.default.surveyURL(with: testName)
    print("Last Path Component: \(url.lastPathComponent)")
    var ok = false
    do {
      try FileManager.default.createDirectory(
        at: url, withIntermediateDirectories: false, attributes: nil)
      ok = true
    } catch {
      print(error)
    }
    XCTAssertTrue(ok)
    if ok {
      names = FileManager.default.surveyNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try FileManager.default.deleteSurvey(with: testName)
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = FileManager.default.surveyNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  //MARK: - Test Add File To App

  func testAddUnknown() {
    // Given:
    let url = FileManager.default.libraryDirectory.appendingPathComponent("newFile.junk")
    XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    XCTAssertNoThrow(try "I'm data".write(to: url, atomically: true, encoding: .utf8))
    XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

    // When:

    // Then:
    do {
      let _ = try FileManager.default.addToApp(url: url)
      XCTAssertTrue(false)
    } catch ImportError.unknownType {
      // expected path, do nothing
    } catch {
      XCTAssertTrue(false)
    }

    // Cleanup:
    XCTAssertNoThrow(try FileManager.default.removeItem(at: url))

  }

  func testAddArchiveWithoutConflict() {
    // Given:
    let existingName = "Test Protocol"
    let existingPoz = "/Legacy Archives/Test Protocol.poz"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)

    // When:
    XCTAssertFalse(FileManager.default.archiveNames.contains(existingName))
    var maybeFile: AppFile? = nil
    XCTAssertNoThrow(maybeFile = try FileManager.default.addToApp(url: existingUrl))
    XCTAssertNotNil(maybeFile)
    guard let newFile = maybeFile else { return }
    XCTAssertEqual(newFile.type, .archive)
    let archiveName = newFile.name

    // Then:
    XCTAssertTrue(FileManager.default.archiveNames.contains(archiveName))

    // Cleanup:
    XCTAssertNoThrow(try FileManager.default.deleteArchive(with: archiveName))
    XCTAssertFalse(FileManager.default.archiveNames.contains(archiveName))
  }

  func testAddArchiveWithConflictFail() {
    // Given:
    let existingName = "Test Protocol"
    let existingPoz = "/Legacy Archives/Test Protocol.poz"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)

    // When:
    XCTAssertFalse(FileManager.default.archiveNames.contains(existingName))
    XCTAssertNoThrow(try FileManager.default.addToApp(url: existingUrl))
    XCTAssertTrue(FileManager.default.archiveNames.contains(existingName))

    // Then:
    XCTAssertThrowsError(try FileManager.default.addToApp(url: existingUrl))
    XCTAssertThrowsError(try FileManager.default.addToApp(url: existingUrl, conflict: .fail))
    XCTAssertTrue(FileManager.default.archiveNames.contains(existingName))

    // Cleanup:
    XCTAssertNoThrow(try FileManager.default.deleteArchive(with: existingName))
    XCTAssertFalse(FileManager.default.archiveNames.contains(existingName))
  }

  func testAddArchiveWithConflictReplace() {
    // Given:
    let existingName = "Test Protocol"
    let existingPoz = "/Legacy Archives/Test Protocol.poz"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)

    // When:
    XCTAssertFalse(FileManager.default.archiveNames.contains(existingName))
    XCTAssertNoThrow(try FileManager.default.addToApp(url: existingUrl))
    XCTAssertTrue(FileManager.default.archiveNames.contains(existingName))
    let count = FileManager.default.archiveNames.count

    // Then:
    XCTAssertNoThrow(try FileManager.default.addToApp(url: existingUrl, conflict: .replace))
    XCTAssertTrue(FileManager.default.archiveNames.contains(existingName))
    XCTAssertEqual(count, FileManager.default.archiveNames.count)
    //Note: map test below ensures that old file was actually replaced by new file

    // Cleanup:
    XCTAssertNoThrow(try FileManager.default.deleteArchive(with: existingName))
    XCTAssertFalse(FileManager.default.archiveNames.contains(existingName))
  }

  func testAddArchiveWithConflictKeepBoth() {
    // Given:
    let existingName = "Test Protocol"
    let existingPoz = "/Legacy Archives/Test Protocol.poz"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)

    // When:
    let count = FileManager.default.archiveNames.count
    XCTAssertFalse(FileManager.default.archiveNames.contains(existingName))
    XCTAssertNoThrow(try FileManager.default.addToApp(url: existingUrl))
    XCTAssertTrue(FileManager.default.archiveNames.contains(existingName))
    XCTAssertEqual(count + 1, FileManager.default.archiveNames.count)

    // Then:
    var maybeFile: AppFile? = nil
    XCTAssertNoThrow(
      maybeFile = try FileManager.default.addToApp(url: existingUrl, conflict: .keepBoth))
    XCTAssertNotNil(maybeFile)
    guard let newFile = maybeFile else { return }
    XCTAssertEqual(newFile.type, .archive)
    let archiveName = newFile.name
    XCTAssertTrue(FileManager.default.archiveNames.contains(existingName))
    XCTAssertTrue(FileManager.default.archiveNames.contains(archiveName))
    XCTAssertNotEqual(existingName, archiveName)
    XCTAssertEqual(count + 2, FileManager.default.archiveNames.count)

    // Cleanup:
    XCTAssertNoThrow(try FileManager.default.deleteArchive(with: existingName))
    XCTAssertFalse(FileManager.default.archiveNames.contains(existingName))
    XCTAssertNoThrow(try FileManager.default.deleteArchive(with: archiveName))
    XCTAssertFalse(FileManager.default.archiveNames.contains(archiveName))
  }

  //Map and Protocol code is nearly identical to Archive; don't need complete suite of tests
  func testAddMapWithConflictReplace() {
    // Given:
    let name = "map"
    let oldContents = "I'm an existing map"
    let newContents = "I'm new data"
    let url = FileManager.default.libraryDirectory.appendingPathComponent("map.tpk")
    XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    XCTAssertNoThrow(try newContents.write(to: url, atomically: true, encoding: .utf8))
    XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

    // When:
    let url2 = FileManager.default.mapURL(with: name)
    XCTAssertFalse(FileManager.default.mapNames.contains(name))
    XCTAssertNoThrow(try oldContents.write(to: url2, atomically: true, encoding: .utf8))
    XCTAssertTrue(FileManager.default.mapNames.contains(name))
    let count = FileManager.default.mapNames.count

    // Then:
    var maybeFile: AppFile? = nil
    XCTAssertNoThrow(maybeFile = try FileManager.default.addToApp(url: url, conflict: .replace))
    XCTAssertNotNil(maybeFile)
    guard let newFile = maybeFile else { return }
    let newName = newFile.name
    XCTAssertEqual(newFile.type, .map)
    XCTAssertEqual(newName, name)
    XCTAssertTrue(FileManager.default.mapNames.contains(newName))
    XCTAssertEqual(count, FileManager.default.mapNames.count)
    // Check Contents
    let contents = try? String(
      contentsOf: FileManager.default.mapURL(with: newName), encoding: .utf8)
    XCTAssertNotNil(contents)
    if let contents = contents {
      XCTAssertEqual(contents, newContents)
    }

    // Cleanup:
    XCTAssertNoThrow(try FileManager.default.deleteMap(with: newName))
    XCTAssertFalse(FileManager.default.mapNames.contains(newName))
    XCTAssertNoThrow(try FileManager.default.removeItem(at: url))
  }

  func testAddProtocolWithConflictKeepBoth() {
    // Given:
    let name = "proto"
    let oldContents = "I'm an existing map"
    let newContents = "I'm new data"
    let url = FileManager.default.libraryDirectory.appendingPathComponent("proto.obsprot")
    XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    XCTAssertNoThrow(try newContents.write(to: url, atomically: true, encoding: .utf8))
    XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

    // When:
    let url2 = FileManager.default.protocolURL(with: name)
    XCTAssertFalse(FileManager.default.protocolNames.contains(name))
    XCTAssertNoThrow(try oldContents.write(to: url2, atomically: true, encoding: .utf8))
    XCTAssertTrue(FileManager.default.protocolNames.contains(name))
    let count = FileManager.default.protocolNames.count

    // Then:
    var maybeFile: AppFile? = nil
    XCTAssertNoThrow(maybeFile = try FileManager.default.addToApp(url: url, conflict: .keepBoth))
    XCTAssertNotNil(maybeFile)
    guard let newFile = maybeFile else { return }
    let newName = newFile.name
    XCTAssertEqual(newFile.type, .surveyProtocol)
    XCTAssertNotEqual(newName, name)
    XCTAssertTrue(FileManager.default.protocolNames.contains(name))
    XCTAssertTrue(FileManager.default.protocolNames.contains(newName))
    XCTAssertEqual(count + 1, FileManager.default.protocolNames.count)
    // Check Contents
    var contents = try? String(
      contentsOf: FileManager.default.protocolURL(with: name), encoding: .utf8)
    XCTAssertNotNil(contents)
    if let contents = contents {
      XCTAssertEqual(contents, oldContents)
    }
    contents = try? String(
      contentsOf: FileManager.default.protocolURL(with: newName), encoding: .utf8)
    XCTAssertNotNil(contents)
    if let contents = contents {
      XCTAssertEqual(contents, newContents)
    }

    // Cleanup:
    XCTAssertNoThrow(try FileManager.default.deleteProtocol(with: newName))
    XCTAssertFalse(FileManager.default.protocolNames.contains(newName))
    XCTAssertNoThrow(try FileManager.default.deleteProtocol(with: name))
    XCTAssertFalse(FileManager.default.protocolNames.contains(name))
    XCTAssertNoThrow(try FileManager.default.removeItem(at: url))
  }

  //MARK: - Test Unpack survey archive

  func testUnpackArchiveNoConflict() {
    // Given:
    let existingPoz = "/Legacy Archives/Test Protocol.poz"
    let existingSurveyName = "Test Protocol"  // base name for survey bundle in POZ
    // Get exisitng POZ
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)
    // Copy existing POZ to the App
    var maybeFile: AppFile? = nil
    XCTAssertNoThrow(maybeFile = try FileManager.default.addToApp(url: existingUrl))
    XCTAssertNotNil(maybeFile)
    guard let newFile = maybeFile else { return }
    let archiveName = newFile.name
    XCTAssertTrue(FileManager.default.archiveNames.contains(archiveName))
    defer {
      XCTAssertNoThrow(try FileManager.default.deleteArchive(with: archiveName))
      XCTAssertFalse(FileManager.default.archiveNames.contains(archiveName))
    }

    // When:
    var maybeName: String? = nil
    XCTAssertNoThrow(maybeName = try FileManager.default.importSurvey(from: archiveName))
    XCTAssertNotNil(maybeName)
    guard let surveyName = maybeName else { return }

    // Then:
    // survey exists
    XCTAssertEqual(existingSurveyName, surveyName)
    XCTAssertTrue(FileManager.default.surveyNames.contains(surveyName))
    // archive not removed
    XCTAssertTrue(FileManager.default.archiveNames.contains(archiveName))

    // Cleanup
    XCTAssertNoThrow(try FileManager.default.deleteSurvey(with: surveyName))
    XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName))
  }

  func testUnpackArchiveWithConflict() {
    // Given:
    let existingPoz = "/Legacy Archives/Test Protocol.poz"
    let existingSurveyName = "Test Protocol"  // base name for survey bundle in POZ
    // Get exisitng POZ
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)
    // Copy existing POZ to the App
    var maybeFile: AppFile? = nil
    XCTAssertNoThrow(maybeFile = try FileManager.default.addToApp(url: existingUrl))
    guard let newFile = maybeFile else { return }
    let archiveName = newFile.name
    XCTAssertTrue(FileManager.default.archiveNames.contains(archiveName))
    defer {
      XCTAssertNoThrow(try FileManager.default.deleteArchive(with: archiveName))
      XCTAssertFalse(FileManager.default.archiveNames.contains(archiveName))
    }

    // When:
    XCTAssertFalse(FileManager.default.surveyNames.contains(existingSurveyName))
    XCTAssertNoThrow(try FileManager.default.importSurvey(from: archiveName))
    XCTAssertTrue(FileManager.default.surveyNames.contains(existingSurveyName))
    XCTAssertThrowsError(try FileManager.default.importSurvey(from: archiveName))
    XCTAssertThrowsError(try FileManager.default.importSurvey(from: archiveName, conflict: .fail))
    XCTAssertTrue(FileManager.default.surveyNames.contains(existingSurveyName))

    // Then:
    // survey exists
    var maybeName: String? = nil
    XCTAssertNoThrow(
      maybeName = try FileManager.default.importSurvey(from: archiveName, conflict: .replace))
    XCTAssertNotNil(maybeName)
    guard let surveyName = maybeName else { return }
    defer {
      XCTAssertNoThrow(try FileManager.default.deleteSurvey(with: surveyName))
      XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName))
    }
    XCTAssertEqual(existingSurveyName, surveyName)
    XCTAssertTrue(FileManager.default.surveyNames.contains(surveyName))
    XCTAssertNoThrow(
      maybeName = try FileManager.default.importSurvey(from: archiveName, conflict: .keepBoth))
    XCTAssertNotNil(maybeName)
    guard let surveyName2 = maybeName else { return }
    XCTAssertNotEqual(existingSurveyName, surveyName2)
    XCTAssertTrue(FileManager.default.surveyNames.contains(surveyName2))

    // Cleanup
    XCTAssertNoThrow(try FileManager.default.deleteSurvey(with: surveyName2))
    XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName2))
  }

  func testUnpackArchiveWithoutSurvey() {
    // Given:
    let existingPoz = "/Legacy Archives/Bad Archive.poz"
    // Get exisitng POZ
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)
    // Copy existing POZ to the App
    var newFile: AppFile? = nil
    XCTAssertNoThrow(newFile = try FileManager.default.addToApp(url: existingUrl))
    guard let archiveName = newFile?.name else { return }

    // When:
    XCTAssertTrue(FileManager.default.archiveNames.contains(archiveName))
    let count = FileManager.default.surveyNames.count

    // Then:
    do {
      let _ = try FileManager.default.importSurvey(from: archiveName)
      XCTAssertTrue(false)
    } catch ImportError.invalidArchive {
      // expected path, do nothing
    } catch {
      print(error)
      XCTAssertTrue(false)
    }
    XCTAssertEqual(count, FileManager.default.surveyNames.count)

    // Cleanup:
    XCTAssertNoThrow(try FileManager.default.deleteArchive(with: archiveName))
    XCTAssertFalse(FileManager.default.archiveNames.contains(archiveName))
  }

  func testUnpackNotArchive() {
    // Given:
    let testName = "myWeirdTestName123"
    let url = FileManager.default.archiveURL(with: testName)
    XCTAssertNoThrow(try "I'm not Zip data".write(to: url, atomically: true, encoding: .utf8))

    // When:
    let count = FileManager.default.surveyNames.count

    // Then:
    do {
      let _ = try FileManager.default.importSurvey(from: testName)
      XCTAssertTrue(false)
    } catch ImportError.invalidArchive {
      // expected path, do nothing
    } catch {
      print(error)
      XCTAssertTrue(false)
    }
    XCTAssertEqual(count, FileManager.default.surveyNames.count)

    // Cleanup:
    XCTAssertNoThrow(try FileManager.default.deleteArchive(with: testName))
    XCTAssertFalse(FileManager.default.archiveNames.contains(testName))
  }

}
