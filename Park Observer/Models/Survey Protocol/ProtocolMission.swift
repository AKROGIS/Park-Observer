//
//  ProtocolMission.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// Immutable structs and decoders for representing a portion of the configuration file (see SurveyProtocol.swift)

import ArcGIS

/// An object for describing segments of the survey.
struct ProtocolMission: Codable {

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

//MARK: - ProtocolMission Codable
// Custom coding/decoding to have AGSRenderer as property
// AGSRenderer is a closed source objC object that does not implement Codeable

extension ProtocolMission {

  init(from decoder: Decoder) throws {
    var validationEnabled = true
    if let options = decoder.userInfo[SurveyProtocolCodingOptions.key]
      as? SurveyProtocolCodingOptions
    {
      validationEnabled = !options.skipValidation
    }

    let container = try decoder.container(keyedBy: CodingKeys.self)
    let attributes = try container.decodeIfPresent([Attribute].self, forKey: .attributes)
    let dialog = try container.decodeIfPresent(Dialog.self, forKey: .dialog)
    let editAtStartFirstObserving =
      try container.decodeIfPresent(Bool.self, forKey: .editAtStartFirstObserving) ?? false
    let editAtStartRecording =
      try container.decodeIfPresent(Bool.self, forKey: .editAtStartRecording) ?? true
    let editAtStartReobserving =
      try container.decodeIfPresent(Bool.self, forKey: .editAtStartReobserving) ?? true
    let editAtStopObserving =
      try container.decodeIfPresent(Bool.self, forKey: .editAtStopObserving)
      ?? false
    let editPriorAtStopObserving =
      try container.decodeIfPresent(Bool.self, forKey: .editPriorAtStopObserving) ?? false
    let totalizer = try container.decodeIfPresent(MissionTotalizer.self, forKey: .totalizer)

    // Symbology
    var gpsRenderer: AGSRenderer? = nil
    // Version 2 Symbology
    if let agsJSON: AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .gpsSymbology) {
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
    if let agsJSON: AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .onSymbology) {
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
    if let agsJSON: AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .offSymbology) {
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
    if let agsJSON: AnyJSON = try container.decodeIfPresent(AnyJSON.self, forKey: .symbology) {
      renderer = try AGSRenderer.fromAnyJSON(agsJSON, codingPath: decoder.codingPath)
    }
    // Version 1 Symbology
    if renderer == nil {
      if let symbology = try container.decodeIfPresent(SimpleSymbology.self, forKey: .symbology) {
        renderer = AGSSimpleRenderer(for: .mission, color: symbology.color, size: symbology.size)
      }
    }

    if validationEnabled {
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

      // Totalizer.fields requires a dialog, and all fields must be dialog.attribute.names
      if let fields = totalizer?.fields {
        guard let dialog = dialog else {
          throw DecodingError.dataCorruptedError(
            forKey: .attributes, in: container,
            debugDescription:
              "Cannot initialize Mission with totalizer fields and no dialog")

        }
        let dialogNames = dialog.allAttributeNames
        let missingNames = fields.filter { !dialogNames.contains($0) }
        if missingNames.count > 0 {
          throw DecodingError.dataCorruptedError(
            forKey: .attributes, in: container,
            debugDescription:
              "Cannot initialize Mission with totalizer fields \(missingNames) not in the dialog")
        }
      }

      // Every 'required' attribute must have a matching attribute in the dialog
      if let attributes = attributes {
        let requiredAttributeNames = attributes.filter { $0.required }.map { $0.name }
        if requiredAttributeNames.count > 0 {
          guard let dialog = dialog else {
            throw DecodingError.dataCorruptedError(
              forKey: .attributes, in: container,
              debugDescription:
                "Cannot initialize Mission with required attribute(s) and no dialog")
          }
          let dialogNames = dialog.allAttributeNames
          for name in requiredAttributeNames {
            if !dialogNames.contains(name) {
              throw DecodingError.dataCorruptedError(
                forKey: .attributes, in: container,
                debugDescription:
                  "Cannot initialize Mission with required attribute \(name) not in dialog")
            }
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
                "Cannot initialize Mission with dialog fields and no attributes")
          }
          let (missingNames, namesMissingTypes) = dialog.validate(with: attributes)
          if missingNames.count > 0 {
            throw DecodingError.dataCorruptedError(
              forKey: .attributes, in: container,
              debugDescription:
                "Cannot initialize Mission with dialog attributes \(missingNames) not in the attributes list"
            )
          }
          if namesMissingTypes.count > 0 {
            throw DecodingError.dataCorruptedError(
              forKey: .attributes, in: container,
              debugDescription:
                "Cannot initialize Mission when type for dialog attributes \(namesMissingTypes) do not match type in attribute list"
            )
          }
        }
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
    try container.encode(AnyJSON(value: symbology.toJSON()), forKey: .symbology)
    try container.encode(AnyJSON(value: gpsSymbology.toJSON()), forKey: .gpsSymbology)
    try container.encode(AnyJSON(value: onSymbology.toJSON()), forKey: .onSymbology)
    try container.encode(AnyJSON(value: offSymbology.toJSON()), forKey: .offSymbology)
    try container.encodeIfPresent(totalizer, forKey: .totalizer)
  }

}
