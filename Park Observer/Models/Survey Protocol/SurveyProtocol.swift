//
//  SurveyProtocol.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// An immutable struct and decoder for representing the configuration information typically provided as JSON.
/// This struct is the root of a hierarchy of other immutable structs.  The entire Survey Protocol struct is readonly.
/// Most of the hierarchy uses custom decoders to provide default values and additional validation.
///
/// This file was originally generated from protocol.v2.schema.json using quicktype (https://app.quicktype.io)
/// It was subsequently refactored to encapsulate functionality and reduce file size.

import Foundation  // for JSONDecoder, Data, URL

/// Describes the survey data, data collection methods, and application configuration for the NPS iPad Park Observer application.
struct SurveyProtocol {
  /// Should the cancel/delete button be on the top of the editing form?
  /// default: false
  let cancelOnTop: Bool

  /// The format for exporting survey data to CSV files.
  let csv: CsvFormat?

  /// The publication date of the protocol file.
  let date: Date?

  /// A description for this protocol.
  let protocolDescription: String?

  /// A list of objects that describe the features that will be observed.
  let features: [Feature]

  /// The number of seconds between saving successive GPS points to the tracklog.
  let gpsInterval: Double?

  /// The schema used by the protocol file.
  let metaName: String

  /// The version of the schema used by the protocol file.
  let metaVersion: SurveyProtocolVersion

  /// An object for describing segments of the survey.
  let mission: ProtocolMission?

  /// An identifier (name) for this protocol.
  let name: String

  /// An optional message to display on screen when track logging (recording) but not observing
  /// (off transect).
  let notObservingMessage: String?

  /// An optional message to display on screen when observing (on transect).
  let observingMessage: String?

  /// The font size for the observing/not observing messages.
  /// Default: 16.0
  let statusMessageFontsize: Double

  /// Determines if tracklogs are required, optional, or not wanted.
  let tracklogs: TracklogPreference

  /// Determines if being on-transect (observing) is required to make an observation.
  let transects: TransectPreference

  /// Determines if being on-transect (observing) is required to make an observation.
  let transectLabel: String

  /// The version of this named protocol.
  private let version: Double

}

//MARK: SurveyProtocol - Defaults

extension SurveyProtocol {
  static var defaultCancelOnTop: Bool { false }
  static var defaultStatusMessageFontsize: Double { 16.0 }
  static var defaultTracklogs: TracklogPreference { .required }
  static var defaultTransects: TransectPreference { .perFeature }
  static var defaultTransectLabel: String { "Survey" }
}

//MARK: SurveyProtocol - Codable

extension SurveyProtocol: Codable {

  enum CodingKeys: String, CodingKey {
    case cancelOnTop = "cancel_on_top"
    case csv = "csv"
    case date = "date"
    case protocolDescription = "description"
    case features = "features"
    case gpsInterval = "gps_interval"
    case metaName = "meta-name"
    case metaVersion = "meta-version"
    case mission = "mission"
    case name = "name"
    case notObservingMessage = "notobserving"
    case observingMessage = "observing"
    case statusMessageFontsize = "status_message_fontsize"
    case tracklogs = "tracklogs"
    case transects = "transects"
    case transectLabel = "transect-label"
    case version = "version"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // Important, if any of the standard decoder values are manipulated, then
    // add tests to verify the behavior (standard behavior does not need to be tested)

    let metaName = try container.decode(String.self, forKey: .metaName)
    // Fail on wrong metaName before trying to do any more decoding
    if metaName != "NPS-Protocol-Specification" {
      throw DecodingError.dataCorruptedError(
        forKey: .metaName, in: container,
        debugDescription:
          "Cannot initialize SurveyProtocol with \(CodingKeys.metaName) \(metaName)")
    }

    let metaVersion = try container.decode(SurveyProtocolVersion.self, forKey: .metaVersion)
    // Fail on wrong metaVersion before trying to do any more decoding
    // Set known version in options before decoding any children
    if metaVersion == .unknown {
      throw DecodingError.dataCorruptedError(
        forKey: .metaVersion, in: container,
        debugDescription:
          "Cannot initialize SurveyProtocol with \(CodingKeys.metaVersion) \(metaVersion)")
    }
    // Set metaVersion in userInfo for use by children
    // and get the validation behavior
    var validationEnabled = true
    if let options = decoder.userInfo[SurveyProtocolCodingOptions.key]
      as? SurveyProtocolCodingOptions
    {
      options.version = metaVersion
      validationEnabled = !options.skipValidation
    }

    let cancelOnTop = try container.decodeIfPresent(Bool.self, forKey: .cancelOnTop)
    let csv = try container.decodeIfPresent(CsvFormat.self, forKey: .csv)
    let dateString = try container.decodeIfPresent(String.self, forKey: .date)
    let protocolDescription = try container.decodeIfPresent(
      String.self, forKey: .protocolDescription)
    let features = try container.decode([Feature].self, forKey: .features)
    let gpsInterval = try container.decodeIfPresent(Double.self, forKey: .gpsInterval)
    let mission = try container.decodeIfPresent(ProtocolMission.self, forKey: .mission)
    let name = try container.decode(String.self, forKey: .name)
    let notObservingMessage = try container.decodeIfPresent(
      String.self, forKey: .notObservingMessage)
    let observingMessage = try container.decodeIfPresent(String.self, forKey: .observingMessage)
    let statusMessageFontsize = try container.decodeIfPresent(
      Double.self, forKey: .statusMessageFontsize)
    let tracklogs = try container.decodeIfPresent(TracklogPreference.self, forKey: .tracklogs)
    let transects = try container.decodeIfPresent(TransectPreference.self, forKey: .transects)
    let transectLabel = try container.decodeIfPresent(String.self, forKey: .transectLabel)
    let version = try container.decode(Double.self, forKey: .version)

    // Parse Date  (note the DateDecoding Strategy does not work when implementing a custom decoder)
    var date: Date? = nil
    if let dateString = dateString {
      guard let innerDate = Formatter.iso8601.date(from: dateString) else {
        throw DecodingError.dataCorruptedError(
          forKey: .date, in: container,
          debugDescription:
            "Cannot initialize SurveyProtocol; \(dateString) is not a valid date")
      }
      date = innerDate
    }

    if validationEnabled {
      // Validate feature names are unique across features
      if features.count == 0 {
        throw DecodingError.dataCorruptedError(
          forKey: .features, in: container,
          debugDescription:
            "Cannot initialize SurveyProtocol with an empty features list")
      }
      // Validate attributes: unique elements (based on type)
      let featureNames = features.map { $0.name.lowercased() }
      if Set(featureNames).count != featureNames.count {
        throw DecodingError.dataCorruptedError(
          forKey: .features, in: container,
          debugDescription:
            "Cannot initialize SurveyProtocol with duplicate feature names")
      }

      // Validate feature attributes with the same name have the same type
      // Build a dictionary with lowercased names as keys and a set of Bind types as values
      // Any entry with a values with length > 1 is a problem
      let allAttributes = features.compactMap { $0.attributes }.flatMap { $0 }
      let pairs = allAttributes.map { ($0.name.lowercased(), Set([$0.type])) }
      let dict = Dictionary(pairs, uniquingKeysWith: { $0.union($1) })
      let problems = dict.filter { (_, value) in value.count > 1 }
      if problems.count > 0 {
        throw DecodingError.dataCorruptedError(
          forKey: .features, in: container,
          debugDescription:
            "Cannot initialize SurveyProtocol; duplicate feature names \(problems.keys) must have the same type"
        )
      }
    }

    self.init(
      cancelOnTop: cancelOnTop ?? SurveyProtocol.defaultCancelOnTop,
      csv: csv,
      date: date,
      protocolDescription: protocolDescription,
      features: features,
      gpsInterval: gpsInterval,
      metaName: metaName,
      metaVersion: metaVersion,
      mission: mission,
      name: name,
      notObservingMessage: notObservingMessage,
      observingMessage: observingMessage,
      statusMessageFontsize: statusMessageFontsize ?? SurveyProtocol.defaultStatusMessageFontsize,
      tracklogs: tracklogs ?? SurveyProtocol.defaultTracklogs,
      transects: transects ?? SurveyProtocol.defaultTransects,
      transectLabel: transectLabel ?? SurveyProtocol.defaultTransectLabel,
      version: version)
  }

}

// MARK: SurveyProtocol convenience initializers and mutators

// Important: use the following convenience functions.
// The following may fail
//    let surveyProtocol = try? JSONDecoder().decode(SurveyProtocol.self, from: jsonData)
// if the child objects require custom context set on the default decoder

extension SurveyProtocol {
  init(data: Data, skipValidation: Bool = false) throws {
    let decoder = JSONDecoder()
    let options = SurveyProtocolCodingOptions()
    options.skipValidation = skipValidation
    decoder.userInfo[SurveyProtocolCodingOptions.key] = options
    self = try decoder.decode(SurveyProtocol.self, from: data)
  }

  init(_ json: String, using encoding: String.Encoding = .utf8, skipValidation: Bool = false) throws
  {
    guard let data = json.data(using: encoding) else {
      let description = "JSON string not properly encoded as \(encoding)"
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: [],
          debugDescription: description))
    }
    try self.init(data: data, skipValidation: skipValidation)
  }

  init(fromURL url: URL, skipValidation: Bool = false) throws {
    try self.init(data: try Data(contentsOf: url), skipValidation: skipValidation)
  }

  func jsonData() throws -> Data {
    return try JSONEncoder().encode(self)
  }

  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    return String(data: try self.jsonData(), encoding: encoding)
  }
}

//MARK: - Computed Properties

extension SurveyProtocol {

  var majorVersion: Int { Int(version) }

  var minorVersion: Int {
    let temp = (version - Double(majorVersion)) * 10.0
    return Int(temp.rounded())
  }

}

//MARK: - Decoder extension

// Read iso date only string as full date time
extension Formatter {
  static let iso8601: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate]
    return formatter
  }()
}

//MARK: - Coding options

// This object provides context to help the decode decode child objects.
// It needs to be a reference type so that the top level object can set the version

class SurveyProtocolCodingOptions {

  /// The version of the protocol being decoded
  var version: SurveyProtocolVersion = .unknown

  var skipValidation: Bool = false

  static let key = CodingUserInfoKey(rawValue: "gov.doi.nps.akr.gis.parkobserver")!

}

enum SurveyProtocolVersion: Int, Codable {
  case unknown = 0
  case version1 = 1
  case version2 = 2
}

/// Determines if tracklogs are required, optional, or not wanted.
enum TracklogPreference: String, Codable {
  /// The start/stop track log button is not available, and track logs are never collected.
  case none = "none"

  /// The user can start/stop observing regardless of the state of track logging.
  case optional = "optional"

  /// The user must start a track log before they can start observing.
  case required = "required"
}

/// Determines if being on-transect (observing) is required to make an observation.
enum TransectPreference: String, Codable {
  ///The start/stop survey (observing/transect) button is not available; default to always observing unless track logs are required.
  case none = "none"

  /// The user can add an observation at any time, regardless of the state of surveying (observing/transect).
  case optional = "optional"

  /// The user must start a survey (observing/transect) before they can add an observation.
  case required = "required"

  /// The user can add an observation of a feature based on the state of the feature's properties.
  case perFeature = "per-feature"
}
