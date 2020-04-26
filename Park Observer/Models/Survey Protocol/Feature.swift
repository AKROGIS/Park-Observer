//
//  Feature.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import CoreData

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
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let allowOffTransectObservations = try container.decodeIfPresent(
      Bool.self, forKey: .allowOffTransectObservations)
      ?? false
    let attributes = try container.decodeIfPresent([Attribute].self, forKey: .attributes)
    let dialog = try container.decodeIfPresent(Dialog.self, forKey: .dialog)
    let label = try container.decodeIfPresent(Label.self, forKey: .label)
    let locations = try container.decode([Location].self, forKey: .locations)
    let name = try container.decode(String.self, forKey: .name)
    var renderer: AGSRenderer = AGSSimpleRenderer(for: .features)
    do {
      if let symbology = try container.decodeIfPresent(SimpleSymbology.self, forKey: .symbology) {
        renderer = AGSSimpleRenderer(for: .features, color: symbology.color, size: symbology.size)
      }
    }
    self.init(
      allowOffTransectObservations: allowOffTransectObservations,
      attributes: attributes,
      dialog: dialog,
      label: label,
      locations: locations,
      name: name,
      symbology: renderer)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(allowOffTransectObservations, forKey: .allowOffTransectObservations)
    try container.encodeIfPresent(attributes, forKey: .attributes)
    try container.encodeIfPresent(dialog, forKey: .dialog)
    try container.encodeIfPresent(label, forKey: .label)
    try container.encodeIfPresent(locations, forKey: .locations)
    try container.encodeIfPresent(name, forKey: .name)
    if let renderer = symbology as? AGSSimpleRenderer {
      if let symbol = renderer.symbol as? AGSSimpleMarkerSymbol {
        let symbology = SimpleSymbology(color: symbol.color, size: Double(symbol.size))
        try container.encodeIfPresent(symbology, forKey: .symbology)
      }
    }
  }

}

// MARK: - Attribute

/// The attributes (descriptive properties) of a feature; they will be columns in  database
struct Attribute: Codable {

  /// The unique column name for the attribute (no spaces, numbers, or weird characters).
  let name: String

  /// Identifies the kind of data the attribute stores (from NSAttributeType).
  let type: Int

  enum CodingKeys: String, CodingKey {
    case name = "name"
    case type = "type"
  }
}

//TODO: Validate restrictions on name and type in the decoder
//TODO: use NSAttributeType (CoreData) for type

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
    let locationDefault = try container.decodeIfPresent(Bool.self, forKey: .locationDefault) ?? false
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
    let decoded = try  container.decode(String.self)
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
struct Label: Codable {

  /// The color of the text as a hexidecimal triplet of red, green and blue values. `#RRGGBB`;
  /// 00 = 0 (none), FF = 255 (full).
  let color: String?  //FIXME: This is the wrong type (should be UIColor)

  /// An attribute name (from Attributes) that will be used as the text of the label.
  let field: String

  /// The font size of the text; in points (1/72 of an inch).
  let size: Double?

  /// An esri text symbol object, see
  /// https://developers.arcgis.com/documentation/common-data-types/symbol-objects.htm
  let symbol: SimpleSymbology  //FIXME: This is the wrong type (Should be AGSLabelDefinition)

  enum CodingKeys: String, CodingKey {
    case color = "color"
    case field = "field"
    case size = "size"
    case symbol = "symbol"
  }
}

//TODO: Build decoder for the label; support esri JSON
