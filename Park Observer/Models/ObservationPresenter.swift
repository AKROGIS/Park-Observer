//
//  ObservationPresenter.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/28/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS  // For AGSGraphic
import CoreData  // For NSManagedObject
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

enum CloseAction {
  case save  // saves changes
  case discard  // discards any changes made in this presentation
  case cancel  // aborts and undos a create new feature process
}

enum ObservationClass {
  case mission
  case feature(Feature)
}

enum PresentationMode {
  case edit
  case new
  case review
}

final class ObservationPresenter: ObservableObject {

  @Published var isEditing = false {
    didSet {
      updateEditing()
    }
  }

  //TODO: Support cancel-on-top

  @Published private(set) var angleDistanceForm: AngleDistanceFormDefinition? = nil
  @Published private(set) var attributeForm: AttributeFormDefinition? = nil
  @Published private(set) var awaitingGps = false
  @Published private(set) var awaitingFeature = false
  @Published private(set) var hasAngleDistanceForm = false
  @Published private(set) var hasAttributeForm = false
  @Published private(set) var isDeletable = false
  @Published private(set) var isEditable = true
  @Published private(set) var isMoveableToGps = false
  @Published private(set) var isMoveableToTouch = false
  @Published private(set) var presentationMode: PresentationMode = .review
  @Published private(set) var timestamp = Date()  //: Date? = nil //ObservationSelectorView needs this to be not nil
  @Published private(set) var title = "Observation"

  //TODO: Ensure the published state is updated if these variables change
  private var adhocLocation: AdhocLocation? = nil
  private var angleDistanceLocation: AngleDistanceLocation? = nil
  private var entity: NSManagedObject? = nil
  private var graphic: AGSGraphic? = nil
  private var gpsDisabled = false
  private var gpsPoint: GpsPoint? = nil
  private var locationMethod: LocationMethod.TypeEnum? = .gps
  private var mission: Mission? = nil
  private var name: String?
  private var observationClass: ObservationClass? = nil
  private var survey: Survey? = nil

  //MARK: - Public setters

  //I'm using these public setters so I can differentiate
  //when the properties are set from outside or inside the class
  func setObservationClass(observationClass: ObservationClass?) {
    self.observationClass = observationClass
    //TODO: - call appropriate updaters
    updateAwaitingFeature()
  }

  func setGpsPoint(gpsPoint: GpsPoint?) {
    self.gpsPoint = gpsPoint
    //TODO: - call appropriate updaters
    updateAwaitingGps()
  }

  func setGpsDisabled() {
    gpsDisabled = true
    awaitingGps = false
  }

  //MARK: - Published Actions

  func initiateMoveToGps() {
    print("initiateMoveToGps not implemented.")
  }

  func initiateMoveToTouch() {
    print("initiateMoveToTouch not implemented.")
    // set surveyController.movingGraphic = true
    // set surveyController.isShowingSlideout = false
    // set surveyController.message.info("Tap on map to move graphic")
    // tap will callback to self.moveGraphic(to:)
  }

  func save() {
    print("save not implemented.")
  }

  func cancel() {
    print("cancel not implemented.")
  }

  func delete() {
    print("delete not implemented.")
  }

  func moveGraphic(to mapPoint: AGSPoint) {
    if let graphic = graphic {
      graphic.move(to: mapPoint)
    }
  }

}

//MARK: - Initializers

extension ObservationPresenter {

  static func create(survey: Survey?, mission: Mission?, mapTouch: AGSPoint) -> ObservationPresenter
  {
    let op = ObservationPresenter()
    op.presentationMode = .new
    op.survey = survey
    op.mission = mission
    op.initWith(mapTouch)
    return op
  }

  static func create(survey: Survey?, mission: Mission?, observationClass: ObservationClass)
    -> ObservationPresenter
  {
    let op = ObservationPresenter()
    op.presentationMode = .new
    op.survey = survey
    op.mission = mission
    op.initWith(observationClass)
    return op
  }

  static func show(survey: Survey?, graphic: AGSGraphic) -> ObservationPresenter {
    let op = ObservationPresenter()
    op.survey = survey
    op.initWith(graphic)
    return op
  }

  private func initWith(_ mapTouch: AGSPoint) {
    //TODO: Setup
  }

  private func initWith(_ observationClass: ObservationClass) {
    //TODO: Setup
  }

  private func initWith(_ graphic: AGSGraphic) {
    self.graphic = graphic
    self.name = graphic.graphicsOverlay?.overlayID
    updateObservationClass(with: self.name)
    updateTimestamp(with: graphic)
    updateEntityFromTimestamp()
    updateAttributeForm()
    updateLocationProperties()
    updateAngleDistanceForm()
    updateTitle()
  }

}

//MARK: - Private Updaters

extension ObservationPresenter {

  private func updateAngleDistanceForm() {
    angleDistanceForm = angleDistanceFormDefinition
    hasAngleDistanceForm = angleDistanceForm != nil
  }

  private func updateAttributeForm() {
    attributeForm = attributeFormDefinition
    hasAttributeForm = attributeForm != nil
  }

  private func updateAwaitingGps() {
    awaitingGps = !gpsDisabled && gpsPoint == nil && presentationMode == .new
  }

  private func updateAwaitingFeature() {
    awaitingFeature = observationClass == nil && presentationMode == .new
  }

  private func updateEditing() {
    if isEditing {
      isDeletable = true
      //TODO: is dependent on locationMethod and entity location properties
      isMoveableToTouch = true
      isMoveableToGps = true
      presentationMode = .edit
    } else {
      isDeletable = false
      isMoveableToGps = false
      isMoveableToTouch = false
      presentationMode = .review
    }
  }

  private func updateEntityFromTimestamp() {
    guard let context = survey?.viewContext else {
      entity = nil
      return
    }
    switch observationClass {
    case .mission:
      entity = MissionProperties.fetchFirst(at: timestamp, in: context)
      break
    case .feature(let feature):
      entity = Observations.fetchFirst(feature, at: timestamp, in: context)
      break
    case .none:
      entity = nil
    }
  }

  private func updateLocationProperties() {
    locationMethod = .gps  //default
    if let missionProperty = entity as? MissionProperty {
      if let location = missionProperty.adhocLocation {
        adhocLocation = location
        locationMethod = .mapTouch
      }
      gpsPoint = missionProperty.gpsPoint
    }
    if let observation = entity as? Observation {
      if let location = observation.angleDistanceLocation {
        angleDistanceLocation = location
        locationMethod = .angleDistance
      }
      if let location = observation.adhocLocation {
        adhocLocation = location
        locationMethod = .mapTouch
      }
      gpsPoint = observation.gpsPoint
    }
  }

  private func updateName(with observationClass: ObservationClass?) {
    guard let observationClass = observationClass else {
      name = nil
      return
    }
    switch observationClass {
    case .mission:
      name = .entityNameMissionProperty
    case .feature(let feature):
      name = feature.name
    }
  }

  private func updateObservationClass(with name: String?) {
    guard let name = name else {
      observationClass = nil
      return
    }
    observationClass = nil  // default
    if name == .layerNameMissionProperties {
      observationClass = .mission
    } else {
      for feature in survey?.config.features ?? [Feature]() {
        if feature.name == name {
          observationClass = .feature(feature)
        }
      }
    }
  }

  private func updateTimestamp(with entity: NSManagedObject) {
    //TODO: Get timestamp from gps if PresentationMode == .new else
    //  otherwise get timestamp from entity
  }

  private func updateTimestamp(with graphic: AGSGraphic) {
    if let timestamp = graphic.attributes[String.attributeKeyTimestamp] as? Date {
      self.timestamp = timestamp
    }
  }

  private func updateTitle() {
    if let name = name {
      title = name
      let fields = self.fields ?? [Attribute]()
      //TODO: If feature has a map label defined, use that (it may be the id)
      if let idFieldName = fields.first(where: { $0.type == .id })?.name,
        let id = entity?.value(forKey: .attributePrefix + idFieldName) as? Int
      {
        title = "\(name) #\(id)"
      }
      //TODO: If feature has no label or id, then use Timestamp
    }
  }

}

//MARK: - Computed Properties

extension ObservationPresenter {

  private var angleDistanceDefinition: LocationMethod? {
    switch observationClass {
    case .feature(let feature):
      return feature.angleDistanceConfig
    default:
      return nil
    }
  }

  private var angleDistanceFormDefinition: AngleDistanceFormDefinition? {
    guard let definition = angleDistanceDefinition,
      let angleDistanceLocation = angleDistanceLocation
    else {
      return nil
    }
    return AngleDistanceFormDefinition(
      definition: definition, angleDistanceLocation: angleDistanceLocation)
  }

  private var attributeFormDefinition: AttributeFormDefinition? {
    guard let dialog = dialog, let entity = entity, let fields = fields else {
      return nil
    }
    return dialog.form(with: entity, fields: fields)
  }

  private var dialog: Dialog? {
    switch observationClass {
    case .mission:
      return survey?.config.mission?.dialog
    case .feature(let feature):
      return feature.dialog
    case .none:
      return nil
    }
  }

  private var fields: [Attribute]? {
    switch observationClass {
    case .mission:
      return survey?.config.mission?.attributes
    case .feature(let feature):
      return feature.attributes
    case .none:
      return nil
    }
  }

}
