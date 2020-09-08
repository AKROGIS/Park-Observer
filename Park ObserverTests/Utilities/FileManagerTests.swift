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

  //MARK: - General Test

  //NOTE: the following methods will get extensive testing from other tests:
  // FileManager.default.createNewTempDirectory()
  // FileManager.default.documentDirectory
  // FileManager.default.libraryDirectory

  // FileManager.default.filenames(in: with:)

  //NOTE: filenames with good URL is tested indirectly in other tests
  func testFilenamesBadUrl() {
    let url = URL(fileURLWithPath: "/my/dumb/path")
    let names = FileManager.default.filenames(in: url, with: "??")
    XCTAssertEqual(names.count, 0)
  }

  // FileManager.default.modificationDate(url:)
  // FileManager.default.creationDate(url:)

  func testDates() {
    let contents = "I'm data"
    let newContents = "I'm new data"
    guard let tempDir = try? FileManager.default.createNewTempDirectory() else {
      XCTAssertTrue(false)
      return
    }
    defer {
      XCTAssertNoThrow(try FileManager.default.removeItem(at: tempDir))
    }
    let url = tempDir.appendingPathComponent("proto.obsprot")
    let date1 = Date()
    XCTAssertNoThrow(try contents.write(to: url, atomically: true, encoding: .utf8))
    let creationDate = FileManager.default.creationDate(url: url)
    let date3 = Date()
    XCTAssertNoThrow(try newContents.write(to: url, atomically: true, encoding: .utf8))
    let modificationDate = FileManager.default.modificationDate(url: url)
    let date5 = Date()
    XCTAssertNotNil(creationDate)
    XCTAssertNotNil(modificationDate)
    if let date2 = creationDate, let date4 = modificationDate {
      XCTAssertTrue(date1 < date2)
      XCTAssertTrue(date2 < date3)
      XCTAssertTrue(date3 < date4)
      XCTAssertTrue(date4 < date5)
    }
  }

  func testDatesBadUrl() {
    let url = URL(fileURLWithPath: "/my/dumb/path")
    XCTAssertNil(FileManager.default.creationDate(url: url))
    XCTAssertNil(FileManager.default.modificationDate(url: url))
  }

  // FileManager.default.hasSurveyDirectory
  // FileManager.default.createSurveyDirectory()

  // A SurveyDirectory test is done in AppDelegateTests.
  // If they are done here (and if these tests delete the survey directory)
  // the app delegate tests will fail; and the app folder will be left in an invalid
  // state. i.e. default sample survey will be missing.

//  func testSurveyDirectory() {
//    // NOTE: the survey directory may already exist
//    let removeSurveyDirectory = !FileManager.default.hasSurveyDirectory
//    // It doesn't hurt to try and create it if iti exists
//    XCTAssertNotNil(try FileManager.default.createSurveyDirectory())
//    XCTAssertTrue(FileManager.default.hasSurveyDirectory)
//    XCTAssertNotNil(try FileManager.default.removeItem(at: AppFileType.survey.directoryUrl))
//    XCTAssertFalse(FileManager.default.hasSurveyDirectory)
//    XCTAssertNotNil(try FileManager.default.createSurveyDirectory())
//    XCTAssertTrue(FileManager.default.hasSurveyDirectory)
//    XCTAssertNotNil(try FileManager.default.createSurveyDirectory())
//    XCTAssertTrue(FileManager.default.hasSurveyDirectory)
//    if removeSurveyDirectory {
//      XCTAssertNotNil(try FileManager.default.removeItem(at: AppFileType.survey.directoryUrl))
//    }
//
//  }

  // MARK: - File lists

  func testArchiveDocuments() {
    var names = AppFileType.archive.existingNames
    print("Existing Archives: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = AppFile(type: .archive, name: testName).url
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
      names = AppFileType.archive.existingNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try AppFile(type: .archive, name: testName).delete()
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = AppFileType.archive.existingNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  func testMapDocuments() {
    var names = AppFileType.map.existingNames
    print("Existing Maps: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = AppFile(type: .map, name: testName).url
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
      names = AppFileType.map.existingNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try AppFile(type: .map, name: testName).delete()
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = AppFileType.map.existingNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  func testProtocolDocuments() {
    var names = AppFileType.surveyProtocol.existingNames
    print("Existing Protocols: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = AppFile(type: .surveyProtocol, name: testName).url
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
      names = AppFileType.surveyProtocol.existingNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try AppFile(type: .surveyProtocol, name: testName).delete()
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = AppFileType.surveyProtocol.existingNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  func testSurveyDocuments() {
    let path = AppFileType.survey.directoryUrl.path
    XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    var names = AppFileType.survey.existingNames
    print("Existing Surveys: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = AppFile(type: .survey, name: testName).url
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
      names = AppFileType.survey.existingNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try AppFile(type: .survey, name: testName).delete()
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = AppFileType.survey.existingNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  //MARK: - Test Add File To App

  func testAddUnknown() {
    // Given:
    guard let tempDir = try? FileManager.default.createNewTempDirectory() else {
      XCTAssertTrue(false)
      return
    }
    defer {
      XCTAssertNoThrow(try FileManager.default.removeItem(at: tempDir))
    }
    let url = tempDir.appendingPathComponent("newFile.junk")
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
    XCTAssertFalse(AppFileType.archive.existingNames.contains(existingName))
    var maybeFile: AppFile? = nil
    XCTAssertNoThrow(maybeFile = try FileManager.default.addToApp(url: existingUrl))
    XCTAssertNotNil(maybeFile)
    guard let newFile = maybeFile else { return }
    XCTAssertEqual(newFile.type, .archive)
    let archiveName = newFile.name

    // Then:
    XCTAssertTrue(AppFileType.archive.existingNames.contains(archiveName))

    // Cleanup:
    XCTAssertNoThrow(try AppFile(type: .archive, name: archiveName).delete())
    XCTAssertFalse(AppFileType.archive.existingNames.contains(archiveName))
  }

  func testAddArchiveWithConflictFail() {
    // Given:
    let existingName = "Test Protocol"
    let existingPoz = "/Legacy Archives/Test Protocol.poz"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)

    // When:
    XCTAssertFalse(AppFileType.archive.existingNames.contains(existingName))
    XCTAssertNoThrow(try FileManager.default.addToApp(url: existingUrl))
    XCTAssertTrue(AppFileType.archive.existingNames.contains(existingName))

    // Then:
    XCTAssertThrowsError(try FileManager.default.addToApp(url: existingUrl))
    XCTAssertThrowsError(try FileManager.default.addToApp(url: existingUrl, conflict: .fail))
    XCTAssertTrue(AppFileType.archive.existingNames.contains(existingName))

    // Cleanup:
    XCTAssertNoThrow(try AppFile(type: .archive, name: existingName).delete())
    XCTAssertFalse(AppFileType.archive.existingNames.contains(existingName))
  }

  func testAddArchiveWithConflictReplace() {
    // Given:
    let existingName = "Test Protocol"
    let existingPoz = "/Legacy Archives/Test Protocol.poz"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)

    // When:
    XCTAssertFalse(AppFileType.archive.existingNames.contains(existingName))
    XCTAssertNoThrow(try FileManager.default.addToApp(url: existingUrl))
    XCTAssertTrue(AppFileType.archive.existingNames.contains(existingName))
    let count = AppFileType.archive.existingNames.count

    // Then:
    XCTAssertNoThrow(try FileManager.default.addToApp(url: existingUrl, conflict: .replace))
    XCTAssertTrue(AppFileType.archive.existingNames.contains(existingName))
    XCTAssertEqual(count, AppFileType.archive.existingNames.count)
    //Note: map test below ensures that old file was actually replaced by new file

    // Cleanup:
    XCTAssertNoThrow(try AppFile(type: .archive, name: existingName).delete())
    XCTAssertFalse(AppFileType.archive.existingNames.contains(existingName))
  }

  func testAddArchiveWithConflictKeepBoth() {
    // Given:
    let existingName = "Test Protocol"
    let existingPoz = "/Legacy Archives/Test Protocol.poz"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)

    // When:
    let count = AppFileType.archive.existingNames.count
    XCTAssertFalse(AppFileType.archive.existingNames.contains(existingName))
    XCTAssertNoThrow(try FileManager.default.addToApp(url: existingUrl))
    XCTAssertTrue(AppFileType.archive.existingNames.contains(existingName))
    XCTAssertEqual(count + 1, AppFileType.archive.existingNames.count)

    // Then:
    // Create second
    var maybeFile: AppFile? = nil
    XCTAssertNoThrow(
      maybeFile = try FileManager.default.addToApp(url: existingUrl, conflict: .keepBoth))
    XCTAssertNotNil(maybeFile)
    guard let newFile = maybeFile else { return }
    XCTAssertEqual(newFile.type, .archive)
    let archiveName = newFile.name
    XCTAssertTrue(AppFileType.archive.existingNames.contains(existingName))
    XCTAssertTrue(AppFileType.archive.existingNames.contains(archiveName))
    XCTAssertNotEqual(existingName, archiveName)
    XCTAssertEqual(count + 2, AppFileType.archive.existingNames.count)

    // Create third
    XCTAssertNoThrow(
      maybeFile = try FileManager.default.addToApp(url: existingUrl, conflict: .keepBoth))
    XCTAssertNotNil(maybeFile)
    guard let newFile2 = maybeFile else { return }
    XCTAssertEqual(newFile2.type, .archive)
    let archiveName2 = newFile2.name
    XCTAssertTrue(AppFileType.archive.existingNames.contains(existingName))
    XCTAssertTrue(AppFileType.archive.existingNames.contains(archiveName2))
    XCTAssertNotEqual(existingName, archiveName2)
    XCTAssertEqual(count + 3, AppFileType.archive.existingNames.count)

    // Cleanup:
    XCTAssertNoThrow(try AppFile(type: .archive, name: existingName).delete())
    XCTAssertFalse(AppFileType.archive.existingNames.contains(existingName))
    XCTAssertNoThrow(try AppFile(type: .archive, name: archiveName).delete())
    XCTAssertFalse(AppFileType.archive.existingNames.contains(archiveName))
    XCTAssertNoThrow(try AppFile(type: .archive, name: archiveName2).delete())
    XCTAssertFalse(AppFileType.archive.existingNames.contains(archiveName2))
  }

  //Map and Protocol code is nearly identical to Archive; don't need complete suite of tests
  func testAddMapWithConflictReplace() {
    // Given:
    let name = "map"
    let oldContents = "I'm an existing map"
    let newContents = "I'm new data"
    guard let tempDir = try? FileManager.default.createNewTempDirectory() else {
      XCTAssertTrue(false)
      return
    }
    defer {
      XCTAssertNoThrow(try FileManager.default.removeItem(at: tempDir))
    }
    let url = tempDir.appendingPathComponent("map.tpk")
    XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    XCTAssertNoThrow(try newContents.write(to: url, atomically: true, encoding: .utf8))
    XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

    // When:
    let url2 = AppFile(type: .map, name: name).url
    XCTAssertFalse(AppFileType.map.existingNames.contains(name))
    XCTAssertNoThrow(try oldContents.write(to: url2, atomically: true, encoding: .utf8))
    XCTAssertTrue(AppFileType.map.existingNames.contains(name))
    let count = AppFileType.map.existingNames.count

    // Then:
    var maybeFile: AppFile? = nil
    XCTAssertNoThrow(maybeFile = try FileManager.default.addToApp(url: url, conflict: .replace))
    XCTAssertNotNil(maybeFile)
    guard let newFile = maybeFile else { return }
    let newName = newFile.name
    XCTAssertEqual(newFile.type, .map)
    XCTAssertEqual(newName, name)
    XCTAssertTrue(AppFileType.map.existingNames.contains(newName))
    XCTAssertEqual(count, AppFileType.map.existingNames.count)
    // Check Contents
    let contents = try? String(
      contentsOf: AppFile(type: .map, name: newName).url, encoding: .utf8)
    XCTAssertNotNil(contents)
    if let contents = contents {
      XCTAssertEqual(contents, newContents)
    }

    // Cleanup:
    XCTAssertNoThrow(try AppFile(type: .map, name: newName).delete())
    XCTAssertFalse(AppFileType.map.existingNames.contains(newName))
  }

  func testAddProtocolWithConflictKeepBoth() {
    // Given:
    let name = "proto"
    let oldContents = "I'm an existing map"
    let newContents = "I'm new data"
    guard let tempDir = try? FileManager.default.createNewTempDirectory() else {
      XCTAssertTrue(false)
      return
    }
    defer {
      XCTAssertNoThrow(try FileManager.default.removeItem(at: tempDir))
    }
    let url = tempDir.appendingPathComponent("proto.obsprot")
    XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    XCTAssertNoThrow(try newContents.write(to: url, atomically: true, encoding: .utf8))
    XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

    // When:
    let url2 = AppFile(type: .surveyProtocol, name: name).url
    XCTAssertFalse(AppFileType.surveyProtocol.existingNames.contains(name))
    XCTAssertNoThrow(try oldContents.write(to: url2, atomically: true, encoding: .utf8))
    XCTAssertTrue(AppFileType.surveyProtocol.existingNames.contains(name))
    let count = AppFileType.surveyProtocol.existingNames.count

    // Then:
    var maybeFile: AppFile? = nil
    XCTAssertNoThrow(maybeFile = try FileManager.default.addToApp(url: url, conflict: .keepBoth))
    XCTAssertNotNil(maybeFile)
    guard let newFile = maybeFile else { return }
    let newName = newFile.name
    XCTAssertEqual(newFile.type, .surveyProtocol)
    XCTAssertNotEqual(newName, name)
    XCTAssertTrue(AppFileType.surveyProtocol.existingNames.contains(name))
    XCTAssertTrue(AppFileType.surveyProtocol.existingNames.contains(newName))
    XCTAssertEqual(count + 1, AppFileType.surveyProtocol.existingNames.count)
    // Check Contents
    var contents = try? String(
      contentsOf: AppFile(type: .surveyProtocol, name: name).url, encoding: .utf8)
    XCTAssertNotNil(contents)
    if let contents = contents {
      XCTAssertEqual(contents, oldContents)
    }
    contents = try? String(
      contentsOf: AppFile(type: .surveyProtocol, name: newName).url, encoding: .utf8)
    XCTAssertNotNil(contents)
    if let contents = contents {
      XCTAssertEqual(contents, newContents)
    }

    // Cleanup:
    XCTAssertNoThrow(try AppFile(type: .surveyProtocol, name: newName).delete())
    XCTAssertFalse(AppFileType.surveyProtocol.existingNames.contains(newName))
    XCTAssertNoThrow(try AppFile(type: .surveyProtocol, name: name).delete())
    XCTAssertFalse(AppFileType.surveyProtocol.existingNames.contains(name))
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
    XCTAssertTrue(AppFileType.archive.existingNames.contains(archiveName))
    defer {
      XCTAssertNoThrow(try AppFile(type: .archive, name: archiveName).delete())
      XCTAssertFalse(AppFileType.archive.existingNames.contains(archiveName))
    }

    // When:
    var maybeName: String? = nil
    XCTAssertNoThrow(maybeName = try FileManager.default.importSurvey(from: archiveName))
    XCTAssertNotNil(maybeName)
    guard let surveyName = maybeName else { return }

    // Then:
    // survey exists
    XCTAssertEqual(existingSurveyName, surveyName)
    XCTAssertTrue(AppFileType.survey.existingNames.contains(surveyName))
    // archive not removed
    XCTAssertTrue(AppFileType.archive.existingNames.contains(archiveName))

    // Cleanup
    XCTAssertNoThrow(try AppFile(type: .survey, name: surveyName).delete())
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))
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
    XCTAssertTrue(AppFileType.archive.existingNames.contains(archiveName))
    defer {
      XCTAssertNoThrow(try AppFile(type: .archive, name: archiveName).delete())
      XCTAssertFalse(AppFileType.archive.existingNames.contains(archiveName))
    }

    // When:
    XCTAssertFalse(AppFileType.survey.existingNames.contains(existingSurveyName))
    XCTAssertNoThrow(try FileManager.default.importSurvey(from: archiveName))
    XCTAssertTrue(AppFileType.survey.existingNames.contains(existingSurveyName))
    XCTAssertThrowsError(try FileManager.default.importSurvey(from: archiveName))
    XCTAssertThrowsError(try FileManager.default.importSurvey(from: archiveName, conflict: .fail))
    XCTAssertTrue(AppFileType.survey.existingNames.contains(existingSurveyName))

    // Then:
    // survey exists
    var maybeName: String? = nil
    XCTAssertNoThrow(
      maybeName = try FileManager.default.importSurvey(from: archiveName, conflict: .replace))
    XCTAssertNotNil(maybeName)
    guard let surveyName = maybeName else { return }
    defer {
      XCTAssertNoThrow(try AppFile(type: .survey, name: surveyName).delete())
      XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))
    }
    XCTAssertEqual(existingSurveyName, surveyName)
    XCTAssertTrue(AppFileType.survey.existingNames.contains(surveyName))
    XCTAssertNoThrow(
      maybeName = try FileManager.default.importSurvey(from: archiveName, conflict: .keepBoth))
    XCTAssertNotNil(maybeName)
    guard let surveyName2 = maybeName else { return }
    XCTAssertNotEqual(existingSurveyName, surveyName2)
    XCTAssertTrue(AppFileType.survey.existingNames.contains(surveyName2))

    // Cleanup
    XCTAssertNoThrow(try AppFile(type: .survey, name: surveyName2).delete())
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName2))
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
    XCTAssertTrue(AppFileType.archive.existingNames.contains(archiveName))
    let count = AppFileType.survey.existingNames.count

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
    XCTAssertEqual(count, AppFileType.survey.existingNames.count)

    // Cleanup:
    XCTAssertNoThrow(try AppFile(type: .archive, name: archiveName).delete())
    XCTAssertFalse(AppFileType.archive.existingNames.contains(archiveName))
  }

  func testUnpackNotArchive() {
    // Given:
    let testName = "myWeirdTestName123"
    let url = AppFile(type: .archive, name: testName).url
    XCTAssertNoThrow(try "I'm not Zip data".write(to: url, atomically: true, encoding: .utf8))

    // When:
    let count = AppFileType.survey.existingNames.count

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
    XCTAssertEqual(count, AppFileType.survey.existingNames.count)

    // Cleanup:
    XCTAssertNoThrow(try AppFile(type: .archive, name: testName).delete())
    XCTAssertFalse(AppFileType.archive.existingNames.contains(testName))
  }

  //MARK: - New Survey

  func testSanitizeCleanFilename() {
    // Given:
    let dirtyName = "My Toy Boat's Cool!"
    let expecting = "My Toy Boat's Cool!"

    // When:
    let cleanName = dirtyName.sanitizedFileName

    // Then:
    XCTAssertEqual(expecting, cleanName)
  }

  func testSanitizeDirtyFilename() {
    // Given:
    let dirtyName = #"M/y| \T:o?y% *B"o<a>t's Cool!"#
    let expecting = "M_y_ _T_o_y_ _B_o_a_t's Cool!"

    // When:
    let cleanName = dirtyName.sanitizedFileName

    // Then:
    XCTAssertEqual(expecting, cleanName)
  }

  func testNewSurveyDirectoryOK() {
    // Given:
    let dirtyName = #"M/y| \T:o?y% *B"o<a>t's Cool!"#
    let expecting = "M_y_ _T_o_y_ _B_o_a_t's Cool!"

    // When:
    XCTAssertFalse(AppFileType.survey.existingNames.contains(dirtyName))
    XCTAssertFalse(AppFileType.survey.existingNames.contains(expecting))
    guard let newSurveyName = try? FileManager.default.newSurveyDirectory(dirtyName) else {
      XCTAssertTrue(false)
      return
    }

    // Then:
    XCTAssertEqual(expecting, newSurveyName)
    XCTAssertTrue(AppFileType.survey.existingNames.contains(newSurveyName))

    // Cleanup
    try? AppFile(type: .survey, name: newSurveyName).delete()
  }

  func testNewSurveyDirectoryEmptyName() {
    // Given:
    let surveyName = ""

    // When:
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))

    // Then:
    XCTAssertThrowsError(try FileManager.default.newSurveyDirectory(surveyName))
  }

  func testNewSurveyDirectoryConflict() {
    // Given:
    let desiredName = "My New Survey"
    // Create one that will pre-exist, may not have the desired name
    guard let newSurveyName = try? FileManager.default.newSurveyDirectory(desiredName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: newSurveyName).delete()
    }

    // When:
    XCTAssertTrue(AppFileType.survey.existingNames.contains(newSurveyName))

    // Then:
    XCTAssertThrowsError(try FileManager.default.newSurveyDirectory(newSurveyName, conflict: .fail))
    XCTAssertThrowsError(try FileManager.default.newSurveyDirectory(newSurveyName))
  }

  func testNewSurveyDirectoryReplace() {
    // Given:
    let desiredName = "My New Survey"
    // Create a file in the survey that should get removed
    guard let _ = try? FileManager.default.newSurveyDirectory(desiredName) else {
      XCTAssertTrue(false)
      return
    }
    let surveyFileURL = AppFile(type: .survey, name: desiredName).url.appendingPathComponent(
      "file.txt")
    XCTAssertNoThrow(try "Junk Data".write(to: surveyFileURL, atomically: false, encoding: .utf8))
    defer {
      try? AppFile(type: .survey, name: desiredName).delete()
    }

    // When:
    XCTAssertTrue(AppFileType.survey.existingNames.contains(desiredName))
    XCTAssertTrue(FileManager.default.fileExists(atPath: surveyFileURL.path))
    guard
      let newSurveyName = try? FileManager.default.newSurveyDirectory(
        desiredName, conflict: .replace)
    else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: newSurveyName).delete()
    }

    // Then:
    XCTAssertEqual(desiredName, newSurveyName)
    XCTAssertTrue(AppFileType.survey.existingNames.contains(newSurveyName))
    XCTAssertFalse(FileManager.default.fileExists(atPath: surveyFileURL.path))
  }

  func testNewSurveyDirectoryKeepBoth() {
    // Given:
    let desiredName = "My New Survey"
    // Create one that will pre-exist
    guard let _ = try? FileManager.default.newSurveyDirectory(desiredName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: desiredName).delete()
    }

    // When:
    // Create 2
    XCTAssertTrue(AppFileType.survey.existingNames.contains(desiredName))
    guard
      let newSurveyName = try? FileManager.default.newSurveyDirectory(
        desiredName, conflict: .keepBoth)
    else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: newSurveyName).delete()
    }
    // Create 3
    XCTAssertTrue(AppFileType.survey.existingNames.contains(desiredName))
    guard
      let newSurveyName2 = try? FileManager.default.newSurveyDirectory(
        desiredName, conflict: .keepBoth)
    else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: newSurveyName2).delete()
    }

    // Then:
    XCTAssertNotEqual(desiredName, newSurveyName)
    XCTAssertTrue(AppFileType.survey.existingNames.contains(desiredName))
    XCTAssertTrue(AppFileType.survey.existingNames.contains(newSurveyName))
    XCTAssertTrue(AppFileType.survey.existingNames.contains(newSurveyName2))
  }
}
