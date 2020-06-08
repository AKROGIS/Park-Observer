//
//  Symbology.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// Immutable structs and decoders for representing a portion of the configuration file (see SurveyProtocol.swift)
/// All related to simple symbology (defined by the config file), or ArcGIS symbology classes.

import ArcGIS

//MARK: - Default AGS Renderers

extension AGSSimpleRenderer {
  enum DefaultRenderer {
    /// points for observed features
    case features

    /// points for mission properties, i.e. tracklog observations
    case mission

    /// gps points
    case gps

    /// line segments while tracklogging but not observing, i.e. off transect
    case onTransect

    /// line segments while tracklogging but not observing, i.e. off transect
    case offTransect
  }

  convenience init(for style: DefaultRenderer, color: UIColor? = nil, size: Double? = nil) {
    switch style {
    case .features:
      let color = color ?? .red
      let size = CGFloat(size ?? 14.0)
      let symbol = AGSSimpleMarkerSymbol(style: .circle, color: color, size: size)
      self.init(symbol: symbol)
    case .mission:
      let color = color ?? .green
      let size = CGFloat(size ?? 12.0)
      let symbol = AGSSimpleMarkerSymbol(style: .circle, color: color, size: size)
      self.init(symbol: symbol)
    case .gps:
      let color = color ?? .blue
      let size = CGFloat(size ?? 6.0)
      let symbol = AGSSimpleMarkerSymbol(style: .circle, color: color, size: size)
      self.init(symbol: symbol)
    case .onTransect:
      let color = color ?? .red
      let size = CGFloat(size ?? 3.0)
      let symbol = AGSSimpleLineSymbol(style: .solid, color: color, width: size)
      self.init(symbol: symbol)
    case .offTransect:
      let color = color ?? .gray
      let size = CGFloat(size ?? 1.5)
      let symbol = AGSSimpleLineSymbol(style: .solid, color: color, width: size)
      self.init(symbol: symbol)
    }
  }

}

extension AGSTextSymbol {

  static func label(color: UIColor? = nil, size: Double? = nil) -> AGSTextSymbol {
    let label = AGSTextSymbol(
      text: "",
      color: color ?? .white,
      size: CGFloat(size ?? 14.0),
      horizontalAlignment: .left,
      verticalAlignment: .bottom)
    label.offsetX = 6.0
    label.offsetY = 1.0
    return label
  }

}

//MARK: - Simple Symbology
// For support of symbology in version 1 of protocol

struct SimpleSymbology {
  let color: UIColor?
  let size: Double?
}

extension SimpleSymbology: Codable {

  enum CodingKeys: String, CodingKey {
    case color = "color"
    case size = "size"
  }

  init(from decoder: Decoder) throws {
    var validationEnabled = true
    if let options = decoder.userInfo[SurveyProtocolCodingOptions.key]
      as? SurveyProtocolCodingOptions
    {
      validationEnabled = !options.skipValidation
    }

    let container = try decoder.container(keyedBy: CodingKeys.self)
    var color: UIColor?
    let hex = try container.decodeIfPresent(String.self, forKey: .color)
    let size = try container.decodeIfPresent(Double.self, forKey: .size)
    if let hex = hex {
      color = UIColor(hex: hex)
    }

    if validationEnabled {
      if let hex = hex, color == nil {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Cannot initialize color with String value \(hex)"
          )
        )
      }

      if let size = size, size < 0 {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Cannot initialize size with a negative number \(size)"
          )
        )
      }
    }

    self.init(color: color, size: size)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(color?.hex6, forKey: .color)
    try container.encodeIfPresent(size, forKey: .size)
  }

}

//MARK: - UIColor
// Extend UIColor to read/write hex colors of the form: #RRGGBB (ignores alpha component)

extension UIColor {
  public convenience init?(hex: String) {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat

    if hex.hasPrefix("#") {
      let start = hex.index(hex.startIndex, offsetBy: 1)
      let hexColor = String(hex[start...])

      if hexColor.count == 6 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
          g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
          b = CGFloat((hexNumber & 0x0000ff)) / 255

          self.init(red: r, green: g, blue: b, alpha: 1.0)
          return
        }
      }
    }

    return nil
  }

  var hex6: String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return String(
        format: "#%02X%02X%02X", Int(red * 255.0), Int(green * 255.0), Int(blue * 255.0))
    } else {
      // Could not extract RGBA components:
      return "#??????"
    }
  }

}

//MARK: - AGSRenderer

extension AGSRenderer {

  // Try to get an esri Renderer from AnyJSON
  // If it doesn't appear to be JSON appropriate for AGSRenderer, then return nil
  // Only throw if it appears to be a renderer and is invalid
  static func fromAnyJSON(_ agsJSON: AnyJSON, codingPath: [CodingKey]) throws -> AGSRenderer? {

    func corruptError(message: String) -> DecodingError {
      return DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: message
        )
      )
    }

    if let agsObject = agsJSON.value as? [String: Any], agsObject.keys.contains("type"),
      let type = agsObject["type"] as? String
    {
      let validTypes = ["simple", "classBreaks", "uniqueValue"]
      guard validTypes.contains(type) else {
        let message =
          "Cannot initialize symbology with a renderer type of \(type), must be one of \(validTypes)"
        throw corruptError(message: message)
      }
      let object = try AGSRenderer.fromJSON(agsObject)
      guard let agsRenderer = object as? AGSRenderer else {
        let message = "Cannot initialize symbology. JSON provided was not an esri Renderer"
        throw corruptError(message: message)
      }
      if let issues = agsRenderer.unknownJSON, issues.count > 0 {
        let badKeys = issues.keys.joined(separator: ",")
        let message = "Cannot initialize symbology; invalid properties found \(badKeys)"
        throw corruptError(message: message)
      }
      return agsRenderer
    }
    return nil
  }
}

//MARK: - AGSSymbol

extension AGSSymbol {

  // Try to get an esri Symbol from AnyJSON
  // If it doesn't appear to be JSON appropriate for AGSSymbol, then return nil
  // Only throw if it appears to be a symbol and is invalid
  static func fromAnyJSON(_ agsJSON: AnyJSON, codingPath: [CodingKey]) throws -> AGSSymbol? {

    func corruptError(message: String) -> DecodingError {
      return DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: message
        )
      )
    }

    if let agsObject = agsJSON.value as? [String: Any], agsObject.keys.contains("type"),
      let type = agsObject["type"] as? String
    {
      let validTypes = ["esriSMS", "esriSLS", "esriSFS", "esriPMS", "esriPFS", "esriTS"]
      guard validTypes.contains(type) else {
        let message =
          "Cannot initialize Symbol type of \(type), must be one of \(validTypes)"
        throw corruptError(message: message)
      }
      let object = try AGSSymbol.fromJSON(agsObject)
      guard let symbol = object as? AGSSymbol else {
        let message = "Cannot initialize Symbol; JSON provided was not an esri Symbol"
        throw corruptError(message: message)
      }
      if let issues = symbol.unknownJSON, issues.count > 0 {
        let badKeys = issues.keys.joined(separator: ",")
        let message = "Cannot initialize Symbol; invalid properties found \(badKeys)"
        throw corruptError(message: message)
      }
      return symbol
    }
    return nil
  }
}

//MARK: - AGSLabelDefinition

extension AGSLabelDefinition {

  // Try to get an esri AGSLabelDefinition from AnyJSON
  // If it doesn't appear to be JSON appropriate for AGSLabelDefinition, then throw
  static func fromAnyJSON(_ agsJSON: AnyJSON, codingPath: [CodingKey]) throws -> AGSLabelDefinition
  {
    guard let value = agsJSON.value else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot initialize Label Definition with null"
        )
      )
    }
    let definition = try AGSLabelDefinition.fromJSON(value) as! AGSLabelDefinition
    if let issues = definition.unknownJSON, issues.count > 0 {
      let badKeys = issues.keys.joined(separator: ",")
      let message = "Cannot initialize Label Definition; invalid properties found \(badKeys)"
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: message
        )
      )
    }
    return definition
  }
}
