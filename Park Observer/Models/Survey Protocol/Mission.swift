//
//  Mission.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// An object for describing segments of the survey.
struct Mission: Codable {

  /// A list of the mission's attributes.
  let attributes: [Attribute]?

  /// Describes the look and feel of the mission attribute editor.
  let dialog: Dialog?

  /// If true, the mission attributes editor will be displayed when the start observing button is first pushed.
  private let editAtStartFirstObservingOptional: Bool?

  /// If true, the mission attributes editor will be displayed when the start recording button is pushed.
  private let editAtStartRecordingOptional: Bool?

  /// If true, the mission attributes editor will be displayed when the start observing button is pushed after the first push.
  private let editAtStartReobservingOptional: Bool?

  /// If true, the mission attributes editor will be displayed when the stop observing button is pushed.
  private let editAtStopObservingOptional: Bool?

  /// If true, the mission attributes editor will be displayed for the start of the segment when the stop observing button is pushed.
  private let editPriorAtStopObservingOptional: Bool?

  /// The graphical representation of the gps points along the track log.
  private let gpsSymbologyOptional: Symbology?

  /// The graphical representation of the track log when not observing (off-transect).
  private let offSymbologyOptional: Symbology?

  /// The graphical representation of the track log when observing (on-transect).
  private let onSymbologyOptional: Symbology?

  /// The graphical representation of the points when the mission properties were edited.
  private let symbologyOptional: Symbology?

  /// An object used to define the text summarizing the mission so far.
  let totalizer: MissionTotalizer?

  enum CodingKeys: String, CodingKey {
    case attributes = "attributes"
    case dialog = "dialog"
    case editAtStartFirstObservingOptional = "edit_at_start_first_observing"
    case editAtStartRecordingOptional = "edit_at_start_recording"
    case editAtStartReobservingOptional = "edit_at_start_reobserving"
    case editAtStopObservingOptional = "edit_at_stop_observing"
    case editPriorAtStopObservingOptional = "edit_prior_at_stop_observing"
    case gpsSymbologyOptional = "gps-symbology"
    case offSymbologyOptional = "off-symbology"
    case onSymbologyOptional = "on-symbology"
    case symbologyOptional = "symbology"
    case totalizer = "totalizer"
  }

}

//MARK: - Defaults

extension Mission {
  var editAtStartFirstObserving: Bool { editAtStartFirstObservingOptional ?? false}
  var editAtStartRecording: Bool { editAtStartRecordingOptional ?? false}
  var editAtStartReobserving: Bool { editAtStartReobservingOptional ?? false}
  var editAtStopObserving: Bool { editAtStopObservingOptional ?? false}
  var editPriorAtStopObserving: Bool { editPriorAtStopObservingOptional ?? false}
  var symbology: Symbology { symbologyOptional ?? Symbology(.point, size:12.0, color:.green)}
  var gpsSymbology: Symbology { gpsSymbologyOptional ?? Symbology(.point, size:6.0, color:.blue)}
  var onSymbology: Symbology { onSymbologyOptional ?? Symbology(.line, size:3.0, color:.red)}
  var offSymbology: Symbology { offSymbologyOptional ?? Symbology(.line, size:1.5, color:.gray)}
}
