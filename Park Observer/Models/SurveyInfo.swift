//
//  SurveyInfo.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/11/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// An immutable struct and initializers for encoding/decoding survey metadata
/// For example information about the survey that may be presented to the user without reading the
/// configuration file or opening the database.
/// This struct is typically persisted in an XML property list file.  This struct needs to retain
/// compatibility with plists created by the original park observer.
/// Convenience initializers are provided for creating a new struct from an existing one.
/// For example when the title or save date of a survey changes.

import Foundation

struct SurveyInfo {

  let creationDate: Date?  // n/a in legacy, but never nil in new
  let exportDate: Date?
  let modificationDate: Date?  // Legacy is never nil
  let syncDate: Date?
  let state: SurveyState
  let title: String
  let version: Int  // Legacy = 1; new = 2

  // For compatibility with legacy files; do not change meaning of values 0..4
  enum SurveyState: Int, Codable {
    case unborn = 0
    case corrupt = 1
    case created = 2
    case modified = 3
    case saved = 4
  }

}

//MARK: - Codable

extension SurveyInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case version = "codingversion"  // Legacy
    case title = "title"  // Legacy
    case state = "state"  // Legacy
    case creationDate = "creationdate"

    case modificationDate = "date"  // Legacy
    case syncDate = "syncdate"  // Legacy (optional)
    case exportDate = "exportdate"
  }
}

//MARK: - Convenience Initializers

extension SurveyInfo {
  init(data: Data) throws {
    let decoder = PropertyListDecoder()
    self = try decoder.decode(SurveyInfo.self, from: data)
  }

  init(_ plist: String, using encoding: String.Encoding = .utf8) throws {
    guard let data = plist.data(using: encoding) else {
      let description = "Property List string not properly encoded as \(encoding)"
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: [],
          debugDescription: description))
    }
    try self.init(data: data)
  }

  init(fromURL url: URL) throws {
    try self.init(data: try Data(contentsOf: url))
  }

  init(named name: String) {
    self.init(
      creationDate: Date(),
      exportDate: nil,
      modificationDate: nil,
      syncDate: nil,
      state: .unborn,
      title: name,
      version: 2
    )
  }

  func with(
    creationDate: Date? = nil,
    exportDate: Date? = nil,
    modificationDate: Date? = nil,
    syncDate: Date? = nil,
    state: SurveyState? = nil,
    title: String? = nil,
    version: Int? = nil
  ) -> SurveyInfo {
    return SurveyInfo(
      creationDate: creationDate ?? self.creationDate,
      exportDate: exportDate ?? self.exportDate,
      modificationDate: modificationDate ?? self.modificationDate,
      syncDate: syncDate ?? self.syncDate,
      state: state ?? self.state,
      title: title ?? self.title,
      version: version ?? self.version
    )
  }

  func plistData() throws -> Data {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    return try encoder.encode(self)
  }

  func plistString(encoding: String.Encoding = .utf8) throws -> String? {
    return String(data: try self.plistData(), encoding: encoding)
  }

  func write(to url: URL) throws {
    try self.plistData().write(to: url)
  }

}
