//
//  MapInfo.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import Foundation  //For Date, Data, URL, FileManager, Codable, JSONEncoder, JSONDecoder

/// Metadata about a local background map
struct MapInfo {
  /// Name of the person or organization that created the map
  let author: String
  /// Publication date of the map
  let date: Date?
  /// Title of the map
  let title: String
  // Thumbnail?
}

//MARK: - Codable

extension MapInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case author = "author"
    case date = "date"
    case title = "title"
  }
}

//MARK: - Convenience Initializers

extension MapInfo {

  /// Create a new instance from the map name
  init(from mapName: String) {
    if mapName.starts(with: "Esri ") {
      self = MapInfo(esriName: mapName)
    } else {
      self = MapInfo(tpkName: mapName)
    }
  }

  private init(esriName name: String) {
    self.init(
      author: "Esri Service",
      date: Date(),
      title: name
    )
  }

  private init(tpkName name: String) {
    if let mapInfoURL = FileManager.default.mapInfoURL(with: name),
      let mapInfo = try? MapInfo(from: mapInfoURL)
    {
      self = mapInfo
    } else {
      let url = AppFile(type: .map, name: name).url
      let date = FileManager.default.modificationDate(url: url)
      self.init(
        author: "Unknown",
        date: date,
        title: name
      )
    }
  }

  /// Create a copy of a MapInfo object with selected properties changed
  func with(
    author: String? = nil,
    date: Date? = nil,
    title: String? = nil
  ) -> MapInfo {
    return MapInfo(
      author: author ?? self.author,
      date: date ?? self.date,
      title: title ?? self.title
    )
  }

  //MARK: - Decoders

  /// Create a new instance from the data containing a MapInfo in JSON format
  init(data: Data) throws {
    let decoder = JSONDecoder()
    self = try decoder.decode(MapInfo.self, from: data)
  }

  /// Create a new instance from the URL of a saved JSON encoded MapInfo
  init(from url: URL) throws {
    try self.init(data: try Data(contentsOf: url))
  }

  //MARK: - Encoders

  /// Encodes the instance to JSON data
  func jsonData() throws -> Data {
    let encoder = JSONEncoder()
    return try encoder.encode(self)
  }

  /// Encodes the instance to a JSON string
  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    return String(data: try self.jsonData(), encoding: encoding)
  }

  /// Encodes the instance to JSON and writes it to the URL
  func write(to url: URL) throws {
    try self.jsonData().write(to: url)
  }

}
