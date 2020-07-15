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
  let author: String
  let date: Date?
  let title: String
  //TODO: Thumbnail
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

  init(mapName: String) {
    if mapName.starts(with: "Esri ") {
      self = MapInfo(esriName: mapName)
    } else {
      self = MapInfo(tpkName: mapName)
    }
  }

  init(esriName name: String) {
    self.init(
      author: "Esri Service",
      date: Date(),
      title: name
    )
  }

  init(tpkName name: String) {
    if let mapInfoURL = FileManager.default.mapInfoURL(with: name),
      let mapInfo = try? MapInfo(fromURL: mapInfoURL)
    {
      self = mapInfo
    } else {
      let url = FileManager.default.mapURL(with: name)
      let date = FileManager.default.modificationDate(url: url)
      self.init(
        author: "Unknown",
        date: date,
        title: name
      )
    }
  }

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

  init(data: Data) throws {
    let decoder = JSONDecoder()
    self = try decoder.decode(MapInfo.self, from: data)
  }

  init(fromURL url: URL) throws {
    try self.init(data: try Data(contentsOf: url))
  }

  //MARK: - Encoders

  func jsonData() throws -> Data {
    let encoder = JSONEncoder()
    return try encoder.encode(self)
  }

  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    return String(data: try self.jsonData(), encoding: encoding)
  }

  func write(to url: URL) throws {
    try self.jsonData().write(to: url)
  }

}
