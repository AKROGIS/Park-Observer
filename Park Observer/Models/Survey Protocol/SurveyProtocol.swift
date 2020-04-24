// This file was originally generated from protocol.v2.schema.json using quicktype (https://app.quicktype.io)
// It was subsequently refactored to encapsulate functionality and reduce file size.

//
//   let surveyProtocol = try? newJSONDecoder().decode(SurveyProtocol.self, from: jsonData)

import Foundation  // for JSONDecoder, Data, URL

/// Describes the survey data, data collection methods, and application configuration for the
/// NPS iPad Park Observer application.
// MARK: - SurveyProtocol
struct SurveyProtocol: Codable {
  /// Should the cancel/delete button be on the top of the editing form?
  /// default: false
  private let cancelOnTopOptional: Bool?

  /// The format for exporting survey data to CSV files.
  let csv: CsvFormat?

  /// The publication date of the protocol file.
  let date: Date?

  /// A description for this protocol.
  let surveyProtocolDescription: String?

  /// A list of objects that describe the features that will be observed.
  let features: [Feature]

  /// The number of seconds between saving successive GPS points to the tracklog.
  let gpsInterval: Double?

  /// The schema used by the protocol file.
  let metaName: String

  /// The version of the schema used by the protocol file.
  let metaVersion: Int

  /// An object for describing segments of the survey.
  let mission: Mission?

  /// An identifier (name) for this protocol.
  let name: String

  /// An optional message to display on screen when track logging (recording) but not observing
  /// (off transect).
  let notObservingMessage: String?

  /// An optional message to display on screen when observing (on transect).
  let observingMessage: String?

  /// The font size for the observing/notobserving messages.
  /// Default: 16.0
  private let statusMessageFontsizeOptional: Double?

  /// The version of this named protocol.
  private let version: Double

  enum CodingKeys: String, CodingKey {
    case cancelOnTopOptional = "cancel_on_top"
    case csv = "csv"
    case date = "date"
    case surveyProtocolDescription = "description"
    case features = "features"
    case gpsInterval = "gps_interval"
    case metaName = "meta-name"
    case metaVersion = "meta-version"
    case mission = "mission"
    case name = "name"
    case notObservingMessage = "notobserving"
    case observingMessage = "observing"
    case statusMessageFontsizeOptional = "status_message_fontsize"
    case version = "version"
  }
}

// MARK: SurveyProtocol convenience initializers and mutators

extension SurveyProtocol {
  init(data: Data) throws {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601date
    self = try JSONDecoder().decode(SurveyProtocol.self, from: data)
  }

  init(_ json: String, using encoding: String.Encoding = .utf8) throws {
    guard let data = json.data(using: encoding) else {
      let description = "JSON string not properly encoded as \(encoding)"
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

  func jsonData() throws -> Data {
    return try JSONEncoder().encode(self)
  }

  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    return String(data: try self.jsonData(), encoding: encoding)
  }
}

//MARK: - Defaults

extension SurveyProtocol {
  var cancelOnTop: Bool { cancelOnTopOptional ?? false }
  var statusMessageFontsize: Double { statusMessageFontsizeOptional ?? 16.0 }
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

extension JSONDecoder.DateDecodingStrategy {
  static let iso8601date = custom {
    let container = try $0.singleValueContainer()
    let string = try container.decode(String.self)
    if let date = Formatter.iso8601.date(from: string) {
      return date
    }
    throw DecodingError.dataCorruptedError(
      in: container, debugDescription: "Invalid date: \(string)")
  }
}
