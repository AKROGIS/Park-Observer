//
//  ObservationPresenter.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/28/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS  // For AGSGraphic
import Foundation  // For ObservableObject

// SurveyController creates an ObservationPresenter and shows the ObservationView
//  - when user taps on map (new)
//  - when user taps on a feature (edit/review)
//  - when the user taps on several features (edit/review) - an array is created
//  - when user taps on a new properties/feature buttons
//  - when the user starts/stops tracklogging/observing (if editing is appropriate)
// SurveyController requests gpsPoint, and feature type as needed.  When the SurveyContoller
//   receives them, it updates the ObservationPresenter which updates the ObservationView
// ? SurveyController create a new graphic on the correct layer (without attributes) at the
//   correct location when apropriate and provides it to the ObservationPresenter
//   ?? issues: needs feature (layer), and gpsPoint/angle/distance from ObservationPresenter
//    which may take a while (or never) to collect
// ObservationPresenter can create/edit/save/delete entites as needed
// ObservationPresenter can update/move/copy/delete graphics.
// ObservationPresenter will have save/cancel buttons which will set the state of the
//   ObservationPresenter, and then trigger a close view event
// ObservationView (or a parent view) can ask the SurveyController to close the view.
//   SurveyController will ask the ObservationView if that is ok.  If ok, then the work
//   is saved or discarded based on state of ObservationPresenter
//   SurveyController deletes the ObservationPresenter

final class ObservationPresenter: ObservableObject {

  @Published var isEditing = false

  @Published private(set) var hasAngleDistanceForm = false
  @Published private(set) var hasAttributeForm = false
  @Published private(set) var isDeletable = false
  @Published private(set) var isEditable = false
  @Published private(set) var isMoveableToGps = false
  @Published private(set) var isMoveableToTouch = false

  @Published private(set) var angleDistanceForm: AngleDistanceFormDefinition? = nil
  @Published private(set) var attributeForm: AttributeFormDefinition? = nil

  var gpsPoint: GpsPoint? = nil {
    didSet {}
  }
  var observationClass: ObservationClass? = nil {
    didSet {}
  }
  var graphic: AGSGraphic? = nil {
    didSet {}
  }

  private let survey: Survey
  private let mission: Mission
  private let locationMethod: LocationMethod.TypeEnum
  private var presentationMode: PresentationMode = .review
  private var entity: NSObject? = nil
  private var adhocLocation: AdhocLocation? = nil
  private var angleDistanceLocation: AngleDistanceLocation? = nil

  init(survey: Survey, mission: Mission, locationMethod: LocationMethod.TypeEnum) {
    self.survey = survey
    self.mission = mission
    self.locationMethod = locationMethod
  }

  func initiateMoveToGps() {}
  func initiateMoveToTouch() {}
  func save() {}
  func cancel() {}
  func delete() {}

}

//MARK: - Initializers

extension ObservationPresenter {

  //static func review(survey: Survey, graphic: AGSGraphic) -> EditableObservation {}
  //static func edit(survey: Survey, graphic: AGSGraphic) -> EditableObservation {}
  //static func new(survey: Survey, feature: Feature, locationMethod: LocationMethod.TypeEnum) -> EditableObservation {}
  //static func new(survey: Survey, properties: MissionProperty, locationMethod: LocationMethod.TypeEnum) -> EditableObservation {}
  //static func newTouch(survey: Survey) -> EditableObservation {}

}

enum ObservationClass {
  case mission
  case feature(Feature)
}

enum CloseAction {
  case save  // saves changes
  case discard  // discards any changes made in this presentation
  case cancel  // aborts and undos a create new feature process
}

enum PresentationMode {
  case edit
  case new
  case review
}
