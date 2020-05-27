//
//  CSVFormatter.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/26/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import Foundation  // for Date and TimeInterval

// IMPORTANT: The code in these extensions may be called on a CoreData background context.
// Therefore they cannot use any managed objects from another context.  All CoreData used
// in these functions should be freshly retrieved from the current context.

enum ExportError: Error {
  case noConfig
}

//MARK: - Survey

extension Survey {

  func csvFiles() throws -> [String: String] {
    guard let format = self.config.csv else {
      //TODO: The csvFormat is optional, so provide a default if missing
      throw ExportError.noConfig
    }

    var contentByName = [String: String]()

    // GPSPoints
    let gpsHeader = GpsPoints.csvHeader(with: format.gpsPoints)
    let gpsBody = try GpsPoints.csvBody(with: format.gpsPoints)
    contentByName[format.gpsPoints.name] = gpsHeader + "\n" + gpsBody + "\n"

    // Features (observations)
    for feature in self.config.features {
      let featureHeader = Observations.csvHeader(for: feature, with: format.features)
      let featureBody = try Observations.csvBody(for: feature, with: format.features)
      contentByName[feature.name] = featureHeader + "\n" + featureBody + "\n"
    }

    // TrackLogs
    let missionAttributes = self.config.mission?.attributes ?? []
    let missionAttributeNames = missionAttributes.map { $0.name }
    let trackHeader = TrackLogs.csvHeader(
      with: format.trackLogs, attributeNames: missionAttributeNames)
    let trackBody = try TrackLogs.csvBody(
      with: format.trackLogs, attributeNames: missionAttributeNames)
    contentByName[format.trackLogs.name] = trackHeader + "\n" + trackBody + "\n"

    return contentByName
  }

}

//MARK: - GpsPoints

extension GpsPoints {

  static func csvHeader(with format: CSVGpsPoints) -> String {
    return format.fieldNames.joined(separator: ",")
  }

  static func csvBody(with format: CSVGpsPoints) throws -> String {
    let gpsPoints = try GpsPoints.allOrderByTime.execute()
    return gpsPoints.map { $0.asCsv(format: format) }.joined(separator: "\n")
  }

}

extension GpsPoint {

  func asCsv(format: CSVGpsPoints) -> String {

    //TODO: Use the format to structure which fields are returned

    let fields: [String] = [
      DateFormattingHelper.shared.formatUtcIso(timestamp) ?? "",
      String.formatOptional(format: "%0.6f", value: latitude?.doubleValue),
      String.formatOptional(format: "%0.6f", value: longitude?.doubleValue),
      "WGS84",
      String.formatOptional(format: "%g", value: horizontalAccuracy?.doubleValue),
      String.formatOptional(format: "%g", value: course?.doubleValue),
      String.formatOptional(format: "%g", value: speed?.doubleValue),
      String.formatOptional(format: "%g", value: altitude?.doubleValue),
      String.formatOptional(format: "%g", value: verticalAccuracy?.doubleValue),
    ]
    return fields.joined(separator: ",")
  }

}

//MARK: - Features

extension Observations {

  static func csvHeader(for feature: Feature, with format: CSVFeatures) -> String {
    guard let attributes = feature.attributes, attributes.count > 0 else {
      return format.header
    }
    let header = attributes.map { $0.name }.joined(separator: ",")
    return header + "," + format.header
  }

  static func csvBody(for feature: Feature, with format: CSVFeatures) throws -> String {
    let observations = try Observations.fetchAll(for: feature.name).execute()
    return observations.map {
      $0.asCsv(feature: feature, format: format)
    }.joined(separator: "\n")
  }

}

extension Observation {

  func asCsv(feature: Feature, format: CSVFeatures) -> String {

    //TODO: Use the format to structure which fields are returned

    var customFields = [String]()
    if let attributes = feature.attributes, attributes.count > 0 {
      customFields = attributes.map { attribute in
        let name = .attributePrefix + attribute.name
        guard let value = self.value(forKey: name) else { return "" }
        if let text = value as? String {
          return text.escapeForCsv
        }
        return "\(value)"
      }
    }

    // Standard Fields
    let julian = Date.julianDate(timestamp: timestamp)
    let locationOfObserver = requestLocationOfObserver()
    let standardFields: [String] = [
      DateFormattingHelper.shared.formatUtcIso(timestamp) ?? "",
      DateFormattingHelper.shared.formatLocalIso(timestamp) ?? "",
      julian.year == nil ? "" : "\(julian.year!)",
      julian.day == nil ? "" : "\(julian.day!)",
      String.formatOptional(format: "%0.6f", value: locationOfFeature.latitude?.doubleValue),
      String.formatOptional(format: "%0.6f", value: locationOfFeature.longitude?.doubleValue),
      String.formatOptional(format: "%0.6f", value: locationOfObserver.latitude?.doubleValue),
      String.formatOptional(format: "%0.6f", value: locationOfObserver.longitude?.doubleValue),
      "WGS84",
    ]

    // Map Touch Fields
    var mapFields = ["", "", ""]
    if let map:MapReference = adhocLocation?.map {
      mapFields = [
        map.name ?? "",
        map.author ?? "",
        map.date == nil ? "" : "\(map.date!)",
      ]
    }

    // AngleDistanceFields
    var adFields = ["", "", ""]
    if let angleDistance = angleDistanceLocation, let config = feature.angleDistanceConfig {
      let adHelper = AngleDistanceHelper(
        config: config,
        deadAhead: angleDistance.direction?.doubleValue,
        distanceInMeters: angleDistance.distance?.doubleValue,
        absoluteAngle: angleDistance.angle?.doubleValue)
      adFields = [
        adHelper.userAngle == nil ? "" : "\(adHelper.userAngle!)",
        adHelper.distanceInUserUnits == nil ? "" : "\(adHelper.distanceInUserUnits!)",
        String.formatOptional(format: "%g", value: adHelper.perpendicularMeters),
      ]
    }

    return (customFields + standardFields + mapFields + adFields).joined(separator: ",")
  }

}

//MARK: - TrackLogs

extension TrackLogs {

  static func csvHeader(with format: CSVTrackLogs, attributeNames: [String]) -> String {
    let headerNames = attributeNames + format.fieldNames
    return headerNames.joined(separator: ",")
  }

  static func csvBody(with format: CSVTrackLogs, attributeNames: [String]) throws -> String {
    let tracklogs = TrackLogs.fetchAll()
    let trackLogCsv = tracklogs.map { $0.asCsv(format: format, attributeNames: attributeNames) }
    return trackLogCsv.joined(separator: "\n")
  }

}

extension TrackLog {

  func asCsv(format: CSVTrackLogs, attributeNames: [String]) -> String {

    //TODO: Use the format to structure which fields are returned

    var customFields = [String]()
    customFields = attributeNames.map { attributeName in
      let name = .attributePrefix + attributeName
      guard let value = self.properties.value(forKey: name) else { return "" }
      if let text = value as? String {
        return text.escapeForCsv
      }
      return "\(value)"
    }

    // Standard Fields
    let start = points.first
    let end = points.last
    let julian = Date.julianDate(timestamp: start?.timestamp)
    var duration: TimeInterval?
    if let endTime = end?.timestamp, let startTime = start?.timestamp {
      duration = endTime.timeIntervalSince(startTime)
    }
    let standardFields: [String] = [
      (properties.observing?.boolValue ?? false) ? "No" : "Yes",
      DateFormattingHelper.shared.formatUtcIso(start?.timestamp) ?? "",
      DateFormattingHelper.shared.formatLocalIso(start?.timestamp) ?? "",
      julian.year == nil ? "" : "\(julian.year!)",
      julian.day == nil ? "" : "\(julian.day!)",
      DateFormattingHelper.shared.formatUtcIso(end?.timestamp) ?? "",
      DateFormattingHelper.shared.formatLocalIso(end?.timestamp) ?? "",
      String.formatOptional(format: "%0.2f", value: duration),
      String.formatOptional(format: "%0.6f", value: start?.latitude?.doubleValue),
      String.formatOptional(format: "%0.6f", value: start?.longitude?.doubleValue),
      String.formatOptional(format: "%0.6f", value: end?.latitude?.doubleValue),
      String.formatOptional(format: "%0.6f", value: end?.longitude?.doubleValue),
      "WGS84",
      String.formatOptional(format: "%0.1f", value: length),
    ]

    return (customFields + standardFields).joined(separator: ",")
  }

}
