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
  let locationMethods: [LocationMethod]

  /// A short unique identifier for this feature, i.e. the item being observed.
  let name: String

  /// The graphical representation of the feature.
  let symbology: AGSRenderer

  enum CodingKeys: String, CodingKey {
    case allowOffTransectObservations = "allow_off_transect_observations"
    case attributes = "attributes"
    case dialog = "dialog"
    case label = "label"
    case locationMethods = "locations"
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

    var validationEnabled = true
    if let options = decoder.userInfo[SurveyProtocolCodingOptions.key]
      as? SurveyProtocolCodingOptions
    {
      validationEnabled = !options.skipValidation
    }

    let container = try decoder.container(keyedBy: CodingKeys.self)
    let allowOffTransectObservations = try container.decodeIfPresent(
      Bool.self, forKey: .allowOffTransectObservations)
      ?? false
    let attributes = try container.decodeIfPresent([Attribute].self, forKey: .attributes)
    let dialog = try container.decodeIfPresent(Dialog.self, forKey: .dialog)
    let label = try container.decodeIfPresent(Label.self, forKey: .label)
    let locationMethods = try container.decode([LocationMethod].self, forKey: .locationMethods)
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

    if validationEnabled {
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
          let message =
            "Cannot initialize locationMethods with duplicate names in the list \(attributes)"
          throw corruptError(message: message)
        }
      }
      // Validate locationMethods: not empty
      if locationMethods.count == 0 {
        let message = "Cannot initialize locationMethods with an empty list"
        throw corruptError(message: message)
      }
      // Validate locationMethods: unique elements (based on type)
      let locationsTypes = locationMethods.map { $0.type }
      if Set(locationsTypes).count != locationsTypes.count {
        let message =
          "Cannot initialize locationMethods with duplicate types in the list \(locationMethods)"
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

      // Every dialog bind name must match the name and type of an attribute in attributes.
      if let dialog = dialog {
        let dialogNames = dialog.allAttributeNames
        if dialogNames.count > 0 {
          guard let attributes = attributes else {
            throw DecodingError.dataCorruptedError(
              forKey: .attributes, in: container,
              debugDescription:
                "Cannot initialize Feature with dialog fields and no attributes")
          }
          let (missingNames, namesMissingTypes) = dialog.validate(with: attributes)
          if missingNames.count > 0 {
            throw DecodingError.dataCorruptedError(
              forKey: .attributes, in: container,
              debugDescription:
                "Cannot initialize Feature with dialog attributes \(missingNames) not in the attributes list"
            )
          }
          if namesMissingTypes.count > 0 {
            throw DecodingError.dataCorruptedError(
              forKey: .attributes, in: container,
              debugDescription:
                "Cannot initialize Feature when type for dialog attributes \(namesMissingTypes) do not match type in attribute list"
            )
          }
        }
      }
    }

    self.init(
      allowOffTransectObservations: allowOffTransectObservations,
      attributes: attributes,
      dialog: dialog,
      label: label,
      locationMethods: locationMethods,
      name: name,
      symbology: renderer ?? AGSSimpleRenderer(for: .features))
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(allowOffTransectObservations, forKey: .allowOffTransectObservations)
    try container.encodeIfPresent(attributes, forKey: .attributes)
    try container.encodeIfPresent(dialog, forKey: .dialog)
    try container.encodeIfPresent(label, forKey: .label)
    try container.encodeIfPresent(locationMethods, forKey: .locationMethods)
    try container.encodeIfPresent(name, forKey: .name)
    try container.encode(AnyJSON(value: symbology.toJSON()), forKey: .symbology)
  }

}

//MARK: - Feature Calculated Properties

extension Feature {

  var angleDistanceConfig: LocationMethod? {
    return locationMethods.filter { $0.type == .angleDistance }.first
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
extension Attribute.AttributeType {

  var isIntegral: Bool {
    self == .int16 || self == .int32 || self == .int64
  }

  var isFractional: Bool {
    self == .double || self == .float || self == .decimal
  }

}

extension Attribute {

  static func typesLookup(from attributes: [Attribute]) -> [String: AttributeType]? {
    // Keys must be unique or Dictionary will throw a runtime error
    let keys = attributes.map { $0.name }
    let values = attributes.map { $0.type }
    guard Set(keys).count == keys.count, values.count == keys.count else {
      return nil
    }
    let dict = Dictionary(uniqueKeysWithValues: zip(keys, values))
    return dict
  }

}

//MARK: - Attribute Codable
// Custom decoding to have limit name
// per spec name must match the regex: "([a-z,A-Z])+"

extension Attribute {

  static func isValid(name: String) -> Bool {
    return name.count >= 1 && name.count <= 30
      && name.range(of: #"^[a-zA-Z_][a-zA-Z0-9_]*$"#, options: .regularExpression) != nil
  }

  init(from decoder: Decoder) throws {
    var validationEnabled = true
    if let options = decoder.userInfo[SurveyProtocolCodingOptions.key]
      as? SurveyProtocolCodingOptions
    {
      validationEnabled = !options.skipValidation
    }

    let container = try decoder.container(keyedBy: CodingKeys.self)
    let name = try container.decode(String.self, forKey: .name)
    let type = try container.decode(AttributeType.self, forKey: .type)

    if validationEnabled {
      //validate name matches regex: i.e. does not have any non-word characters
      if !Attribute.isValid(name: name) {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Cannot initialize Attribute.Name from invalid String value \(name)"
          )
        )
      }
    }
    self.init(
      name: name,
      type: type)
  }

}

// MARK: - LocationMethod

struct LocationMethod: Codable {

  /// Defines whether this type of location method is allowed.
  let allow: Bool

  /// A deprecated synonym for deadAhead
  private let baseline: Double

  /// The angle measurement in degrees that means the feature is dead ahead. Only used with type angleDistance.
  let deadAhead: Double

  /// Designates this location method as the default method if multiple are allowed.
  let defaultLocationMethod: Bool

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
    case defaultLocationMethod = "default"
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

//MARK: - LocationMethod Codable
// Custom decoding to support deprecated properties/values

extension LocationMethod {

  static var defaultAllow: Bool { true }
  static var defaultDeadAhead: Double { 0.0 }
  static var defaultLocationDefault: Bool { false }
  static var defaultDirection: Direction { .cw }
  static var defaultUnits: LocationUnits { .meters }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let allow = try container.decodeIfPresent(Bool.self, forKey: .allow)
      ?? LocationMethod.defaultAllow
    let baseline = try container.decodeIfPresent(Double.self, forKey: .baseline)
      ?? LocationMethod.defaultDeadAhead
    let deadAhead = try container.decodeIfPresent(Double.self, forKey: .deadAhead)
      ?? baseline
    let defaultLocationMethod = try container.decodeIfPresent(
      Bool.self, forKey: .defaultLocationMethod)
      ?? LocationMethod.defaultLocationDefault
    let direction = try container.decodeIfPresent(Direction.self, forKey: .direction)
      ?? LocationMethod.defaultDirection
    let units = try container.decodeIfPresent(LocationUnits.self, forKey: .units)
      ?? LocationMethod.defaultUnits
    let type = try container.decode(TypeEnum.self, forKey: .type)
    self.init(
      allow: allow,
      baseline: deadAhead,
      deadAhead: deadAhead,
      defaultLocationMethod: defaultLocationMethod,
      direction: direction,
      type: type,
      units: units)
  }

}

extension LocationMethod.TypeEnum {
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

    var validationEnabled = true
    if let options = decoder.userInfo[SurveyProtocolCodingOptions.key]
      as? SurveyProtocolCodingOptions
    {
      validationEnabled = !options.skipValidation
    }

    let container = try decoder.container(keyedBy: CodingKeys.self)

    let field = try container.decodeIfPresent(String.self, forKey: .field)
    let hex = try container.decodeIfPresent(String.self, forKey: .color)
    let size = try container.decodeIfPresent(Double.self, forKey: .size)
    let esriSymbolJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .symbol)
    let esriLabelJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .definition)

    var color: UIColor?
    if let hex = hex {
      color = UIColor(hex: hex)
    }
    var symbol: AGSSymbol? = nil
    // Version 2 Symbology
    if let json = esriSymbolJSON {
      symbol = try AGSSymbol.fromAnyJSON(json, codingPath: decoder.codingPath)
    }
    var definition: AGSLabelDefinition? = nil
    // Version 3 label definition
    if let json = esriLabelJSON {
      definition = try AGSLabelDefinition.fromAnyJSON(json, codingPath: decoder.codingPath)
    }

    if validationEnabled {
      // size, if provided must be positive
      if let size = size, size <= 0 {
        let message = "Cannot initialize size with a non-positive number \(size)"
        throw corruptError(message: message)
      }
      // color: hex, if provided, must produce a non nil color
      if let hex = hex, color == nil {
        let message = "Cannot initialize color with String value \(hex)"
        throw corruptError(message: message)
      }
      // esriSymbolJSON, if provided, must produce a non-nil symbol
      if esriSymbolJSON != nil {
        if symbol == nil {
          let message = "Cannot initialize Symbol with provided esriJSON"
          throw corruptError(message: message)
        } else {
          if !(symbol is AGSTextSymbol) {
            let message = "Cannot initialize symbol; it is not an esriTS"
            throw corruptError(message: message)
          }
        }

      }
      // esriLabelJSON, if provided, must produce a non-nil labelDefinition
      if esriLabelJSON != nil && definition == nil {
        let message = "Cannot initialize LabelDefinition with provided esriJSON"
        throw corruptError(message: message)
      }
      // field and definition cannot both be nil
      if field == nil && definition == nil {
        let message = "Cannot initialize label; one of field or definition must be provided"
        throw corruptError(message: message)
      }
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
