//
//  Feature.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS

// MARK: - Feature

/// Describe an item (feature) that will be observed.
struct Feature: Codable {

  /// If true, then this feature can be observed while off transect (not observing).
  let allowOffTransectObservations: Bool

  /// A list of the feature's attributes.
  let attributes: [Attribute]?

  /// Describes the look and feel feature attribute editor.
  let dialog: Dialog?

  /// Describes how these features should be labeled on the map.
  let label: Label?

  /// A list of the permitted techniques for specifying the location of an observation.
  let locations: [Location]

  /// A short unique identifier for this feature, i.e. the item being observed.
  let name: String

  /// The graphical representation of the feature.
  let symbology: AGSRenderer

  enum CodingKeys: String, CodingKey {
    case allowOffTransectObservations = "allow_off_transect_observations"
    case attributes = "attributes"
    case dialog = "dialog"
    case label = "label"
    case locations = "locations"
    case name = "name"
    case symbology = "symbology"
  }
}

//MARK: - Feature Codable
// Custom coding/decoding to have AGSRenderer as property
// AGSRenderer is a closed source objC object that does not implement Codeable

extension Feature {

  init(from decoder: Decoder) throws {

    func corruptError(message: String) -> DecodingError {
      return DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: message
        )
      )
    }

    let container = try decoder.container(keyedBy: CodingKeys.self)
    let allowOffTransectObservations = try container.decodeIfPresent(
      Bool.self, forKey: .allowOffTransectObservations)
      ?? false
    let attributes = try container.decodeIfPresent([Attribute].self, forKey: .attributes)
    let dialog = try container.decodeIfPresent(Dialog.self, forKey: .dialog)
    let label = try container.decodeIfPresent(Label.self, forKey: .label)
    let locations = try container.decode([Location].self, forKey: .locations)
    let name = try container.decode(String.self, forKey: .name)

    var renderer: AGSRenderer? = nil
    // Version 2 Symbology
    if let agsJSON:AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .symbology) {
      renderer = try AGSRenderer.fromAnyJSON(agsJSON, codingPath: decoder.codingPath)
    }
    // Version 1 Symbology
    if renderer == nil {
      if let symbology = try container.decodeIfPresent(SimpleSymbology.self, forKey: .symbology) {
        renderer = AGSSimpleRenderer(for: .features, color: symbology.color, size: symbology.size)
      }
    }

    // Validate name
    if name.count == 0 || name.count > 10 {
      let message = "Cannot initialize name with an invalid value \(name)"
      throw corruptError(message: message)
    }
    // Validate attributes
    if let attributes = attributes {
      if attributes.count == 0 {
        let message = "Cannot initialize attributes with an empty list"
        throw corruptError(message: message)
      }
      // Validate attributes: unique elements (based on type)
      let attributeNames = attributes.map { $0.name.lowercased() }
      if Set(attributeNames).count != attributeNames.count {
        let message = "Cannot initialize locations with duplicate names in the list \(attributes)"
        throw corruptError(message: message)
      }
    }
    // Validate locations: not empty
    if locations.count == 0 {
      let message = "Cannot initialize locations with an empty list"
      throw corruptError(message: message)
    }
    // Validate locations: unique elements (based on type)
    let locationsTypes = locations.map { $0.type }
    if Set(locationsTypes).count != locationsTypes.count {
      let message = "Cannot initialize locations with duplicate types in the list \(locations)"
      throw corruptError(message: message)
    }
    // Validate 1) if we have a label, we must have attributes
    // 2) if definition is not provided, then field is in attributes
    // (label will not decode if both field and definition are missing)
    if let label = label {
      guard let attributes = attributes else {
        let message = "Cannot initialize feature with label \(label) and no attributes"
        throw corruptError(message: message)
      }
      if let field = label.field, label.definition == nil {
        let attributeNames = attributes.map { $0.name.lowercased() }

        if !attributeNames.contains(field.lowercased()) {
          let message =
            "Cannot initialize feature when label field \(field) is not in attributes \(attributeNames)"
          throw corruptError(message: message)
        }
      }
    }

    self.init(
      allowOffTransectObservations: allowOffTransectObservations,
      attributes: attributes,
      dialog: dialog,
      label: label,
      locations: locations,
      name: name,
      symbology: renderer ?? AGSSimpleRenderer(for: .features))
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(allowOffTransectObservations, forKey: .allowOffTransectObservations)
    try container.encodeIfPresent(attributes, forKey: .attributes)
    try container.encodeIfPresent(dialog, forKey: .dialog)
    try container.encodeIfPresent(label, forKey: .label)
    try container.encodeIfPresent(locations, forKey: .locations)
    try container.encodeIfPresent(name, forKey: .name)
    try container.encode(AnyJSON(value: symbology.toJSON()), forKey: .symbology)
  }

}

// MARK: - Attribute

/// The attributes (descriptive properties) of a feature; they will be columns in  database
struct Attribute: Codable {

  /// The unique column name for the attribute (no spaces, numbers, or weird characters).
  let name: String

  /// Identifies the kind of data the attribute stores (from NSAttributeType).
  let type: AttributeType

  enum CodingKeys: String, CodingKey {
    case name = "name"
    case type = "type"
  }

  // Aligns to NSAttributeType in CoreData (except id = 0)
  enum AttributeType: Int, Codable {
    case id = 0
    case int16 = 100
    case int32 = 200
    case int64 = 300
    case decimal = 400  // not supported
    case double = 500
    case float = 600
    case string = 700
    case bool = 800
    case datetime = 900
    case blob = 1000  // Not supported
  }
}

//MARK: - Attribute Codable
// Custom decoding to have limit name
// per spec name must match the regex: "([a-z,A-Z])+"

extension Attribute {

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let name = try container.decode(String.self, forKey: .name)
    let type = try container.decode(AttributeType.self, forKey: .type)
    //validate name matches regex: i.e. does not have any non-word characters
    guard
      name.count >= 2 && name.count <= 30
        && name.range(of: #"^[a-zA-Z_][a-zA-Z0-9_]+$"#, options: .regularExpression) != nil
    else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Cannot initialize Attribute.Name from invalid String value \(name)"
        )
      )
    }
    self.init(
      name: name,
      type: type)
  }

}

// MARK: - Location

struct Location: Codable {

  /// Defines whether this type of location method is allowed.
  let allow: Bool

  /// A deprecated synonym for deadAhead
  private let baseline: Double

  /// The angle measurement in degrees that means the feature is dead ahead. Only used with type angleDistance.
  let deadAhead: Double

  /// Designates this location method as the default method if multiple are allowed.
  let locationDefault: Bool

  /// Defines whether angles increase in the clockwise (cw) or counter-clockwise (ccw) direction. Only used with type angleDistance.
  let direction: Direction

  /// The kind of location method described by this location.
  let type: TypeEnum

  /// Units of distance measurements to the feature. Only used with type angleDistance.
  let units: LocationUnits

  enum CodingKeys: String, CodingKey {
    case allow = "allow"
    case deadAhead = "deadAhead"
    case baseline = "baseline"
    case locationDefault = "default"
    case direction = "direction"
    case type = "type"
    case units = "units"
  }

  /// Defines whether angles increase in the clockwise (cw) or counter-clockwise (ccw) direction. Only used with type angleDistance.
  enum Direction: String, Codable {
    case ccw = "ccw"
    case cw = "cw"
  }

  /// The kind of location method described by this location.
  enum TypeEnum: String, Codable {
    case angleDistance = "angleDistance"
    case gps = "gps"
    case mapTarget = "mapTarget"
    case mapTouch = "mapTouch"
  }

  /// Units of distance measurements to the feature. Only used with type angleDistance.
  enum LocationUnits: String, Codable {
    case feet = "feet"
    case meters = "meters"
    case yards = "yards"
  }

}

//MARK: - Location Codable
// Custom decoding to support deprecated properties/values

extension Location {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let allow = try container.decodeIfPresent(Bool.self, forKey: .allow) ?? true
    let baseline = try container.decodeIfPresent(Double.self, forKey: .baseline) ?? 0.0
    let deadAhead = try container.decodeIfPresent(Double.self, forKey: .deadAhead) ?? baseline
    let locationDefault = try container.decodeIfPresent(Bool.self, forKey: .locationDefault)
      ?? false
    let direction = try container.decodeIfPresent(Direction.self, forKey: .direction) ?? .cw
    let units = try container.decodeIfPresent(LocationUnits.self, forKey: .units) ?? .meters
    let type = try container.decode(TypeEnum.self, forKey: .type)
    self.init(
      allow: allow,
      baseline: deadAhead,
      deadAhead: deadAhead,
      locationDefault: locationDefault,
      direction: direction,
      type: type,
      units: units)
  }

}

extension Location.TypeEnum {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let decoded = try container.decode(String.self)
    switch decoded {
    case "adhocTouch":
      self = .mapTouch
      break
    case "adhocTarget":
      self = .mapTarget
      break
    default:
      guard let value = Self(rawValue: decoded) else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Cannot initialize TypeEnum from invalid String value \(decoded)"
          )
        )
      }
      self = value
    }
  }
}

// MARK: - Label

/// Describes how these features should be labeled on the map.
struct Label {

  /// The color of the text as a hexidecimal triplet of red, green and blue values. `#RRGGBB`;
  /// 00 = 0 (none), FF = 255 (full).
  let color: UIColor?

  /// An attribute name (from Attributes) that will be used as the text of the label.
  let field: String?

  /// The font size of the text; in points (1/72 of an inch).
  let size: Double?

  /// An esri text symbol object, see
  /// https://developers.arcgis.com/documentation/common-data-types/symbol-objects.htm
  let symbol: AGSSymbol

  /// An esri label definition object (new in version 2.0), see
  /// https://developers.arcgis.com/documentation/common-data-types/labeling-objects.htm
  let definition: AGSLabelDefinition?

}

extension Label: Codable {

  enum CodingKeys: String, CodingKey {
    case color = "color"
    case field = "field"
    case size = "size"
    case symbol = "symbol"
    case definition = "definition"
  }

  init(from decoder: Decoder) throws {

    func corruptError(message: String) -> DecodingError {
      return DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: message
        )
      )
    }

    let container = try decoder.container(keyedBy: CodingKeys.self)

    // field
    let field = try container.decodeIfPresent(String.self, forKey: .field)

    // color
    var color: UIColor?
    if let hex = try container.decodeIfPresent(String.self, forKey: .color) {
      color = UIColor(hex: hex)
      if color == nil {
        let message = "Cannot initialize color with String value \(hex)"
        throw corruptError(message: message)
      }
    }

    // size
    let size: Double? = try container.decodeIfPresent(Double.self, forKey: .size)
    if let size = size, size < 0 {
      let message = "Cannot initialize size with a negative number \(size)"
      throw corruptError(message: message)
    }

    // Symbol
    var symbol: AGSSymbol? = nil
    // Version 2 Symbology
    if let agsJSON:AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .symbol) {
      symbol = try AGSSymbol.fromAnyJSON(agsJSON, codingPath: decoder.codingPath)
    }
    if container.contains(.symbol) && (symbol == nil || !(symbol is AGSTextSymbol)) {
      let message = "Cannot initialize symbol; it is not an esriTS"
      throw corruptError(message: message)
    }

    // LabelDefinition
    var definition: AGSLabelDefinition? = nil
    // Version 2 Symbology
    if let agsJSON:AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .definition) {
      definition = try AGSLabelDefinition.fromAnyJSON(agsJSON, codingPath: decoder.codingPath)
    }

    // field and definition cannot both be nil
    if field == nil && definition == nil {
      let message = "Cannot initialize label; one of field or definition must be provided"
      throw corruptError(message: message)
    }

    self.init(
      color: color,
      field: field,
      size: size,
      symbol: symbol ?? AGSTextSymbol.label(color: color, size: size),
      definition: definition
    )
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(field, forKey: .field)
    try container.encodeIfPresent(color?.hex6, forKey: .color)
    try container.encodeIfPresent(size, forKey: .size)
    try container.encode(AnyJSON(value: symbol.toJSON()), forKey: .symbol)
    if let definition = definition {
      try container.encode(AnyJSON(value: definition.toJSON()), forKey: .definition)
    }
  }

}
