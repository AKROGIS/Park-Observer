//
//  Mission.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS

/// An object for describing segments of the survey.
struct Mission: Codable {

  /// A list of the mission's attributes.
  let attributes: [Attribute]?

  /// Describes the look and feel of the mission attribute editor.
  let dialog: Dialog?

  /// If true, the mission attributes editor will be displayed when the start observing button is first pushed.
  let editAtStartFirstObserving: Bool

  /// If true, the mission attributes editor will be displayed when the start recording button is pushed.
  let editAtStartRecording: Bool

  /// If true, the mission attributes editor will be displayed when the start observing button is pushed after the first push.
  let editAtStartReobserving: Bool

  /// If true, the mission attributes editor will be displayed when the stop observing button is pushed.
  let editAtStopObserving: Bool

  /// If true, the mission attributes editor will be displayed for the start of the segment when the stop observing button is pushed.
  let editPriorAtStopObserving: Bool

  /// The graphical representation of the gps points along the track log.
  let gpsSymbology: AGSRenderer

  /// The graphical representation of the track log when not observing (off-transect).
  let offSymbology: AGSRenderer

  /// The graphical representation of the track log when observing (on-transect).
  let onSymbology: AGSRenderer

  /// The graphical representation of the points when the mission properties were edited.
  let symbology: AGSRenderer

  /// An object used to define the text summarizing the mission so far.
  let totalizer: MissionTotalizer?

  enum CodingKeys: String, CodingKey {
    case attributes = "attributes"
    case dialog = "dialog"
    case editAtStartFirstObserving = "edit_at_start_first_observing"
    case editAtStartRecording = "edit_at_start_recording"
    case editAtStartReobserving = "edit_at_start_reobserving"
    case editAtStopObserving = "edit_at_stop_observing"
    case editPriorAtStopObserving = "edit_prior_at_stop_observing"
    case gpsSymbology = "gps-symbology"
    case offSymbology = "off-symbology"
    case onSymbology = "on-symbology"
    case symbology = "symbology"
    case totalizer = "totalizer"
  }

}

//MARK: - Mission Codable
// Custom coding/decoding to have AGSRenderer as property
// AGSRenderer is a closed source objC object that does not implement Codeable

extension Mission {

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let attributes = try container.decodeIfPresent([Attribute].self, forKey: .attributes)
    let dialog = try container.decodeIfPresent(Dialog.self, forKey: .dialog)
    let editAtStartFirstObserving = try container.decodeIfPresent(
      Bool.self, forKey: .editAtStartFirstObserving) ?? false
    let editAtStartRecording = try container.decodeIfPresent(
      Bool.self, forKey: .editAtStartRecording) ?? false
    let editAtStartReobserving = try container.decodeIfPresent(
      Bool.self, forKey: .editAtStartReobserving) ?? false
    let editAtStopObserving = try container.decodeIfPresent(Bool.self, forKey: .editAtStopObserving)
      ?? false
    let editPriorAtStopObserving = try container.decodeIfPresent(
      Bool.self, forKey: .editPriorAtStopObserving) ?? false
    let totalizer = try container.decodeIfPresent(MissionTotalizer.self, forKey: .totalizer)

    // Symbology
    var gpsRenderer: AGSRenderer? = nil
    // Version 2 Symbology
    if let agsJSON:AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .gpsSymbology) {
      gpsRenderer = try AGSRenderer.fromAnyJSON(agsJSON, codingPath: decoder.codingPath)
    }
    // Version 1 Symbology
    if gpsRenderer == nil {
      if let symbology = try container.decodeIfPresent(SimpleSymbology.self, forKey: .gpsSymbology)
      {
        gpsRenderer = AGSSimpleRenderer(for: .gps, color: symbology.color, size: symbology.size)
      }
    }
    var onRenderer: AGSRenderer? = nil
    // Version 2 Symbology
    if let agsJSON:AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .onSymbology) {
      onRenderer = try AGSRenderer.fromAnyJSON(agsJSON, codingPath: decoder.codingPath)
    }
    // Version 1 Symbology
    if onRenderer == nil {
      if let symbology = try container.decodeIfPresent(SimpleSymbology.self, forKey: .onSymbology) {
        onRenderer = AGSSimpleRenderer(
          for: .onTransect, color: symbology.color, size: symbology.size)
      }
    }
    var offRenderer: AGSRenderer? = nil
    // Version 2 Symbology
    if let agsJSON:AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .offSymbology) {
      offRenderer = try AGSRenderer.fromAnyJSON(agsJSON, codingPath: decoder.codingPath)
    }
    // Version 1 Symbology
    if offRenderer == nil {
      if let symbology = try container.decodeIfPresent(SimpleSymbology.self, forKey: .offSymbology)
      {
        offRenderer = AGSSimpleRenderer(
          for: .offTransect, color: symbology.color, size: symbology.size)
      }
    }
    var renderer: AGSRenderer? = nil
    // Version 2 Symbology
    if let agsJSON:AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .symbology) {
      renderer = try AGSRenderer.fromAnyJSON(agsJSON, codingPath: decoder.codingPath)
    }
    // Version 1 Symbology
    if renderer == nil {
      if let symbology = try container.decodeIfPresent(SimpleSymbology.self, forKey: .symbology) {
        renderer = AGSSimpleRenderer(for: .mission, color: symbology.color, size: symbology.size)
      }
    }

    // Validate attributes
    if let attributes = attributes {
      if attributes.count == 0 {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Cannot initialize attributes with an empty list"
          )
        )
      }
      // Validate attributes: unique elements (based on type)
      let attributeNames = attributes.map { $0.name.lowercased() }
      if Set(attributeNames).count != attributeNames.count {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription:
              "Cannot initialize locations with duplicate names in the list \(attributes)"
          )
        )
      }
    }

    self.init(
      attributes: attributes,
      dialog: dialog,
      editAtStartFirstObserving: editAtStartFirstObserving,
      editAtStartRecording: editAtStartRecording,
      editAtStartReobserving: editAtStartReobserving,
      editAtStopObserving: editAtStopObserving,
      editPriorAtStopObserving: editPriorAtStopObserving,
      gpsSymbology: gpsRenderer ?? AGSSimpleRenderer(for: .gps),
      offSymbology: offRenderer ?? AGSSimpleRenderer(for: .offTransect),
      onSymbology: onRenderer ?? AGSSimpleRenderer(for: .onTransect),
      symbology: renderer ?? AGSSimpleRenderer(for: .mission),
      totalizer: totalizer)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(attributes, forKey: .attributes)
    try container.encodeIfPresent(dialog, forKey: .dialog)
    try container.encode(editAtStartFirstObserving, forKey: .editAtStartFirstObserving)
    try container.encode(editAtStartRecording, forKey: .editAtStartRecording)
    try container.encode(editAtStartReobserving, forKey: .editAtStartReobserving)
    try container.encode(editAtStopObserving, forKey: .editAtStopObserving)
    try container.encode(editPriorAtStopObserving, forKey: .editPriorAtStopObserving)
    if let renderer = gpsSymbology as? AGSSimpleRenderer {
      if let symbol = renderer.symbol as? AGSSimpleMarkerSymbol {
        let symbology = SimpleSymbology(color: symbol.color, size: Double(symbol.size))
        try container.encodeIfPresent(symbology, forKey: .symbology)
      }
    }
    if let renderer = offSymbology as? AGSSimpleRenderer {
      if let symbol = renderer.symbol as? AGSSimpleLineSymbol {
        let symbology = SimpleSymbology(color: symbol.color, size: Double(symbol.width))
        try container.encodeIfPresent(symbology, forKey: .symbology)
      }
    }
    if let renderer = onSymbology as? AGSSimpleRenderer {
      if let symbol = renderer.symbol as? AGSSimpleLineSymbol {
        let symbology = SimpleSymbology(color: symbol.color, size: Double(symbol.width))
        try container.encodeIfPresent(symbology, forKey: .symbology)
      }
    }
    if let renderer = symbology as? AGSSimpleRenderer {
      if let symbol = renderer.symbol as? AGSSimpleMarkerSymbol {
        let symbology = SimpleSymbology(color: symbol.color, size: Double(symbol.size))
        try container.encodeIfPresent(symbology, forKey: .symbology)
      }
    }
    try container.encodeIfPresent(totalizer, forKey: .totalizer)
  }

}
