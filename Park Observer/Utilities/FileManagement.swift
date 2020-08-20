//
//  FileManagement.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/11/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// This is a collection of extensions (mostly on FileManager) for interacting with the file system
/// There are also a few enums, and one data struct for returning the file name and type.
/// This file declares some public constants, but has no mutating public state.

import Foundation
import Zip

extension FileManager {

  func createNewTempDirectory() throws -> URL {
    let url = temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    try createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
    return url
  }

  var documentDirectory: URL {
    urls(for: .documentDirectory, in: .userDomainMask)[0]
  }

  var libraryDirectory: URL {
    urls(for: .libraryDirectory, in: .userDomainMask)[0]
  }

  func filenames(in directory: URL, with pathExtension: String) -> [String] {
    // Return an empty array if any errors are encountered
    if let contents = try? contentsOfDirectory(
      at: directory, includingPropertiesForKeys: [], options: [])
    {
      let matches = contents.filter { $0.pathExtension == pathExtension }
      return matches.map { $0.deletingPathExtension().lastPathComponent }
    } else {
      return []
    }
  }

  //MARK: - File Dates

  func modificationDate(url: URL) -> Date? {
    guard let attrs = try? attributesOfItem(atPath: url.path) else {
      return nil
    }
    return attrs[.modificationDate] as? Date
  }

  func creationDate(url: URL) -> Date? {
    guard let attrs = try? attributesOfItem(atPath: url.path) else {
      return nil
    }
    return attrs[.creationDate] as? Date
  }

}

//MARK: - Survey Bundles

extension String {
  // Name of private folder where survey bundles are kept
  fileprivate static let surveyDirectoryName = "Surveys"

  // Filenames internal to a survey bundle; maintain for compatibility with legacy surveys

  fileprivate static let surveyInfoFilename = "properties.plist"
  fileprivate static let surveyProtocolFilename = "protocol.obsprot"
  fileprivate static let surveyOldDatabaseFilename = "survey.coredata/StoreContent/persistentStore"
  fileprivate static let surveyDatabaseFilename = "database.sqlite3"
}

extension FileManager {

  var hasSurveyDirectory: Bool {
    let surveyDirectory = AppFileType.survey.directoryUrl.path
    return fileExists(atPath: surveyDirectory)
  }

  func createSurveyDirectory() throws {
    let surveyDirectory = AppFileType.survey.directoryUrl
    // Do not fail if surveyDirectory exists (withIntermediateDirectories == true)
    try createDirectory(at: surveyDirectory, withIntermediateDirectories: true, attributes: nil)
  }

  func mapInfoURL(with name: String) -> URL? {
    //TODO: Implement folder for MapInfo data
    return nil
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

enum AppFileType: String {
  // rawValue is file extension
  case archive = "poz"
  case map = "tpk"
  case survey = "obssurv"
  case surveyProtocol = "obsprot"

  fileprivate init?(from url: URL) {
    self.init(rawValue: url.pathExtension.lowercased())
  }

  var pathExtension: String {
    return self.rawValue
  }

  var directoryUrl: URL {
    switch self {
    case .survey:
      let lib = FileManager.default.libraryDirectory
      return lib.appendingPathComponent(.surveyDirectoryName, isDirectory: true)
    default:
      return FileManager.default.documentDirectory
    }
  }

  var existingNames: [String] {
    return FileManager.default.filenames(in: self.directoryUrl, with: self.pathExtension)
  }

}

struct AppFile {
  let type: AppFileType
  let name: String
}

extension AppFile {
  fileprivate init?(from url: URL) {
    let maybeType = AppFileType(from: url)
    if maybeType == nil { return nil }
    type = maybeType!
    name = url.deletingPathExtension().lastPathComponent
  }

  var url: URL {
    return self.type.directoryUrl
      .appendingPathComponent(name)
      .appendingPathExtension(self.type.pathExtension)
  }

  func delete() throws {
    try FileManager.default.removeItem(at: self.url)
  }

}

struct SurveyBundle {
  let file: AppFile

  init(name: String) {
    self.file = AppFile(type: .survey, name: name)
  }

  var oldDatabaseURL: URL {
    return file.url.appendingPathComponent(.surveyOldDatabaseFilename)
  }

  var databaseURL: URL {
    return file.url.appendingPathComponent(.surveyDatabaseFilename)
  }

  var infoURL: URL {
    return file.url.appendingPathComponent(.surveyInfoFilename)
  }

  var protocolURL: URL {
    return file.url.appendingPathComponent(.surveyProtocolFilename)
  }

}


extension FileManager {

  func addToApp(url: URL, conflict: ConflictResolution = .fail) throws -> AppFile {
    // Creating an AppFile from a url only sets the type (from extension) and name
    // The actual path (url) is determined by the app.
    guard let appFile = AppFile(from: url) else {
      throw ImportError.unknownType
    }
    let appURL = appFile.url
    do {
      try copyItem(at: url, to: appURL)
    } catch let error as NSError {
      if error.code == NSFileWriteFileExistsError {
        switch conflict {
        case .replace:
          try removeItem(at: appURL)
          try copyItem(at: url, to: appURL)
          break
        case .keepBoth:
          let newURL = try copyUniqueItem(at: url, to: appURL)
          let newName = newURL.deletingPathExtension().lastPathComponent
          return AppFile(type: appFile.type, name: newName)
        default:
          throw error
        }
      } else {
        throw error
      }
    }
    return appFile
  }

  func importSurvey(from archiveName: String, conflict: ConflictResolution = .fail) throws -> String {
    let zipURL = AppFile(type: .archive, name: archiveName).url
    let tempURL = try createNewTempDirectory()
    let surveyExtension = AppFileType.survey.pathExtension
    defer {
      try? removeItem(at: tempURL)
    }
    Zip.addCustomFileExtension(AppFileType.archive.pathExtension)
    do {
      try Zip.unzipFile(zipURL, destination: tempURL, overwrite: true, password: nil, progress: nil)
    } catch ZipError.unzipFail {
      throw ImportError.invalidArchive
    }
    let names = filenames(in: tempURL, with: surveyExtension)
    guard names.count == 1 else {
      throw ImportError.invalidArchive
    }
    let name = names[0]
    let surveyURL = tempURL.appendingPathComponent(name).appendingPathExtension(surveyExtension)
    let appFile = try addToApp(url: surveyURL, conflict: conflict)
    return appFile.name
  }

  private func copyUniqueItem(at url: URL, to destURL: URL) throws -> URL {
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
        // Do nothing; increase the counter and try again
      }
      // All other errors will be thrown to caller
    }
    return newURL
  }

}

//MARK: - Create New Survey

extension String {

  var sanitizedFileName: String {
    return components(separatedBy: .init(charactersIn: #"/|\:?%*"<>"#)).joined(separator: "_")
  }

}

enum CreateError: Error {
  case noName
}

extension FileManager {

  func newSurveyDirectory(_ name: String, conflict: ConflictResolution = .fail) throws -> String {
    guard !name.isEmpty else {
      throw CreateError.noName
    }
    var newName = name.sanitizedFileName
    let potentialUrl = AppFile(type: .survey, name: newName).url
    do {
      try createDirectory(at: potentialUrl, withIntermediateDirectories: false, attributes: nil)
    } catch let error as NSError {
      if error.code == NSFileWriteFileExistsError {
        switch conflict {
        case .replace:
          try removeItem(at: potentialUrl)
          try createDirectory(at: potentialUrl, withIntermediateDirectories: false, attributes: nil)
          break
        case .keepBoth:
          for counter in 2... {
            newName = "\(name.sanitizedFileName) \(counter)"
            let potentialUrl = AppFile(type: .survey, name: newName).url
            do {
              try createDirectory(
                at: potentialUrl, withIntermediateDirectories: false, attributes: nil)
              break
            } catch CocoaError.fileWriteFileExists {
              // Do nothing; increase the counter and try again
            }
            // All other errors will be thrown to caller
          }
        default:
          throw error
        }
      } else {
        throw error
      }
    }
    return newName
  }

}

extension FileManager {
  // This zips the contents of the source folder (without the source folder)
  // While it would be simpler to archive the source folder,
  // this is done to match the legacy POZ format
  func archiveContents(of source: URL, to destination: URL) throws {
    let contents = try FileManager.default.contentsOfDirectory(
      at: source, includingPropertiesForKeys: [], options: [])
    Zip.addCustomFileExtension(AppFileType.archive.pathExtension)
    try Zip.zipFiles(paths: contents, zipFilePath: destination, password: nil, progress: nil)
  }
}
