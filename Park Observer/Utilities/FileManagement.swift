//
//  FileManagement.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/11/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import Foundation
import Zip

//MARK: - Discovering Files

extension String {
  static let surveyExtension = "obssurv"
  static let surveyArchiveExtension = "poz"
  static let surveyProtocolExtension = "obsprot"
  static let tileCacheExtension = "tpk"
}

extension FileManager {

  var documentDirectory: URL {
    urls(for: .documentDirectory, in: .userDomainMask)[0]
  }

  var libraryDirectory: URL {
    urls(for: .libraryDirectory, in: .userDomainMask)[0]
  }

  var archiveDirectory: URL {
    return documentDirectory
  }

  var mapDirectory: URL {
    return documentDirectory
  }

  var protocolDirectory: URL {
    return documentDirectory
  }

  var surveyDirectory: URL {
    return libraryDirectory.appendingPathComponent(.surveyDirectory, isDirectory: true)
  }

  var archiveNames: [String] {
    return filenames(in: archiveDirectory, with: .surveyArchiveExtension)
  }

  var mapNames: [String] {
    return filenames(in: mapDirectory, with: .tileCacheExtension)
  }

  var protocolNames: [String] {
    return filenames(in: protocolDirectory, with: .surveyProtocolExtension)
  }

  var surveyNames: [String] {
    return filenames(in: surveyDirectory, with: .surveyExtension)
  }

  func archiveURL(with name: String) -> URL {
    return archiveDirectory.appendingPathComponent(name).appendingPathExtension(
      .surveyArchiveExtension)
  }

  func mapURL(with name: String) -> URL {
    return mapDirectory.appendingPathComponent(name).appendingPathExtension(
      .tileCacheExtension)
  }

  func protocolURL(with name: String) -> URL {
    return protocolDirectory.appendingPathComponent(name).appendingPathExtension(
      .surveyProtocolExtension)
  }

  func surveyURL(with name: String) -> URL {
    return surveyDirectory.appendingPathComponent(name).appendingPathExtension(
      .surveyExtension)
  }

  func deleteArchive(with name: String) throws {
    try removeItem(at: archiveURL(with: name))
  }

  func deleteMap(with name: String) throws {
    try removeItem(at: mapURL(with: name))
  }

  func deleteProtocol(with name: String) throws {
    try removeItem(at: protocolURL(with: name))
  }

  func deleteSurvey(with name: String) throws {
    try removeItem(at: surveyURL(with: name))
  }

  func filenames(in directory: URL, with pathExtension: String) -> [String] {
    // return empty array if any errors are encountered
    if let contents = try? contentsOfDirectory(
      at: directory, includingPropertiesForKeys: [], options: [])
    {
      let matches = contents.filter { $0.pathExtension == pathExtension }
      return matches.map { $0.deletingPathExtension().lastPathComponent }
    } else {
      return []
    }
  }

}

//MARK: - Survey Bundles

extension String {
  // Name of private folder where survey bundles are kept
  static let surveyDirectory = "Surveys"

  // Filenames internal to a survey bundle; maintain for compatibility with legacy surveys

  static let surveyInfoFilename = "properties.plist"
  static let surveyProtocolFilename = "protocol.obsprot"
  static let surveyDatabaseFilename = "survey.coredata/StoreContent/persistentStore"
}

extension FileManager {

  func createSurveyDirectory() throws {
    // Do not fail if surveyDirectory exists (withIntermediateDirectories == true)
    try createDirectory(at: surveyDirectory, withIntermediateDirectories: true, attributes: nil)
  }

  func surveyDatabaseURL(with name: String) -> URL {
    return surveyURL(with: name).appendingPathComponent(.surveyDatabaseFilename)
  }

  func surveyInfoURL(with name: String) -> URL {
    return surveyURL(with: name).appendingPathComponent(.surveyInfoFilename)
  }

  func surveyProtocolURL(with name: String) -> URL {
    return surveyURL(with: name).appendingPathComponent(.surveyProtocolFilename)
  }

}

//MARK: - Adding Files

enum ImportError: Error {
  case exists
  case unknownType
  case invalidArchive
}

enum ConflictResolution {
  case fail
  case keepBoth
  case replace
}

enum AppFileType {
  case archive
  case map
  case surveyProtocol
  case survey

  init?(from url: URL) {
    switch url.pathExtension.lowercased() {
    case "poz":
      self = .archive
      break
    case "tpk":
      self = .map
      break
    case "obsprot":
      self = .surveyProtocol
      break
    case "obssurv":
      self = .survey
      break
    default:
      return nil
    }
  }
}

struct AppFile {
  let type: AppFileType
  let name: String
}

extension AppFile {
  init?(from url: URL) {
    let maybeType = AppFileType(from: url)
    if maybeType == nil { return nil }
    type = maybeType!
    name = url.deletingPathExtension().lastPathComponent
  }
}

extension FileManager {

  func addToApp(url: URL, conflict: ConflictResolution = .fail) throws -> AppFile {
    guard let appFile = AppFile(from: url) else {
      throw ImportError.unknownType
    }
    let newURL: URL = {
      switch appFile.type {
      case .archive:
        return archiveURL(with: appFile.name)
      case .map:
        return mapURL(with: appFile.name)
      case .survey:
        return surveyURL(with: appFile.name)
      case .surveyProtocol:
        return protocolURL(with: appFile.name)
      }
    }()
    do {
      try copyItem(at: url, to: newURL)
    } catch let error as NSError {
      if error.code == NSFileWriteFileExistsError {
        switch conflict {
        case .replace:
          try removeItem(at: newURL)
          try copyItem(at: url, to: newURL)
          break
        case .keepBoth:
          let newURL = try copyUniqueItem(at: url, to: newURL)
          let name = newURL.deletingPathExtension().lastPathComponent
          return AppFile(type: appFile.type, name: name)
        default:
          throw error
        }
      } else {
        throw error
      }
    }
    return appFile
  }

  func importSurvey(from archive: String, conflict: ConflictResolution = .fail) throws -> String {
    let zipURL = archiveURL(with: archive)
    let tempURL = temporaryDirectory.appendingPathComponent("zip_unpack", isDirectory: true)
    try createDirectory(at: tempURL, withIntermediateDirectories: false, attributes: nil)
    defer { try? removeItem(at: tempURL) }
    Zip.addCustomFileExtension(.surveyArchiveExtension)
    do {
      try Zip.unzipFile(zipURL, destination: tempURL, overwrite: true, password: nil, progress: nil)
    } catch ZipError.unzipFail {
      throw ImportError.invalidArchive
    }
    let names = filenames(in: tempURL, with: .surveyExtension)
    guard names.count == 1 else {
      throw ImportError.invalidArchive
    }
    let name = names[0]
    let surveyURL = tempURL.appendingPathComponent(name).appendingPathExtension(.surveyExtension)
    let appFile = try addToApp(url: surveyURL, conflict: conflict)
    return appFile.name
  }

  func copyUniqueItem(at url: URL, to destURL: URL) throws -> URL {
    // This method assumes that newURL exists
    let ext = destURL.pathExtension
    let name = destURL.deletingPathExtension().lastPathComponent
    let baseURL = destURL.deletingLastPathComponent()
    var newURL = destURL
    for counter in 2... {
      let newName = "\(name) \(counter)"
      newURL = baseURL.appendingPathComponent(newName).appendingPathExtension(ext)
      do {
        try copyItem(at: url, to: newURL)
        break
      } catch CocoaError.fileWriteFileExists {
        //Do nothing; increase the counter and try again
        //Any other errors will be thrown
      }
    }
    return newURL
  }

}
