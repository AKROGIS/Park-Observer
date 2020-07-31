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
  case cancel  // aborts and undos a create new feature process
  case `default` // form closed by tap on map or back button (pick save or cancel)
  case delete
  case move(AGSGraphic)
  case save  // saves changes
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
  @Published private(set) var closeAction = CloseAction.default
  @Published private(set) var closeAllowed = true
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
  private var editContext: NSManagedObjectContext? = nil
  private var entity: NSManagedObject? = nil
  private var graphic: AGSGraphic? = nil
  private var gpsDisabled = false
  private var gpsPoint: GpsPoint? = nil
  private var locationMethod: LocationMethod.TypeEnum? = .gps
  private var mapTouch: AGSPoint? = nil
  private var mapReference: MapReference? = nil
  private var mission: Mission? = nil
  private var name: String?
  private var observationClass: ObservationClass? = nil
  private var observing: Bool? = nil
  private var survey: Survey? = nil
  private var template: MissionProperty? = nil

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
    timestamp = Date()
    updateAwaitingGps()
  }

  //MARK: - Published Actions

  func initiateMoveToGps() {
    print("initiateMoveToGps not implemented.")
    // set locationMethod = .gps
    // set awaitingGPS = true
    // surveyController.requestGpsAsync
    // Do not close
  }

  func initiateMoveToTouch() {
    print("initiateMoveToTouch not implemented.")
    if let graphic = graphic {
      // set surveyController.movingGraphic = true
      // set surveyController.isShowingSlideout = false
      // set surveyController.message.info("Tap on map to move graphic")
      // tap will callback to self.moveGraphic(to:)
      closeAllowed = true
      closeAction = .move(graphic)
    } else {
      // Set error message
      closeAllowed = false
    }
  }

  func save() {
    // validate - show errors set denyClose
    // attempt to save - show errors set deny Close
    closeAllowed = true
    closeAction = .save
    print("save not implemented.")
  }

  func cancel() {
    print("cancel not implemented.")
    // delete the editContext
    closeAction = .cancel
  }

  func delete() {
    if let entity = entity, let graphic = graphic {
      if let context = entity.managedObjectContext {
        context.delete(entity)
      }
      if let overlay = graphic.graphicsOverlay {
        overlay.graphics.remove(graphic)
      }
      closeAllowed = true
      closeAction = .delete
    } else {
      // Set an error message
      closeAllowed = false
    }
  }

  func moveGraphic(to mapPoint: AGSPoint) {
    if let graphic = graphic {
      graphic.move(to: mapPoint)
    }
  }

}

//MARK: - Initializers

extension ObservationPresenter {

  static func create(
    survey: Survey?, mission: Mission?, mapTouch: AGSPoint, mapReference: MapReference?
  ) -> ObservationPresenter {
    let op = ObservationPresenter()
    op.presentationMode = .new
    op.survey = survey
    op.mission = mission
    op.mapReference = mapReference
    op.initWith(mapTouch)
    return op
  }

  static func create(
    survey: Survey?, mission: Mission?, observationClass: ObservationClass,
    template: MissionProperty? = nil, observing: Bool? = nil
  )
    -> ObservationPresenter
  {
    let op = ObservationPresenter()
    op.presentationMode = .new
    op.survey = survey
    op.mission = mission
    op.template = template
    op.observing = observing
    op.initWith(observationClass)
    return op
  }

  static func show(survey: Survey?, graphic: AGSGraphic) -> ObservationPresenter {
    let op = ObservationPresenter()
    op.survey = survey
    op.initWith(graphic)
    return op
  }

  private func initWith(_ graphic: AGSGraphic) {
    self.graphic = graphic
    self.name = graphic.graphicsOverlay?.overlayID
    updateObservationClass(with: self.name)
    updateTimestamp(with: graphic)
    updateEntity(from: survey?.viewContext, with: self.timestamp)
    updateLocationProperties(from: entity)
    updateAttributeForm()
    updateAngleDistanceForm()
    updateTitle()
  }

  private func initWith(_ mapPoint: AGSPoint) {
    self.mapTouch = mapPoint
    locationMethod = .mapTouch
    updateAwaitingGps()
    updateAwaitingFeature()
    // Do not do anything more until we get both the ObservationClass and GpsPoint
    // Specifically do not create the adhocLocation, since the ObservationClass selector may
    // cancel the creation/presentation of a new observation
  }

  private func initWith(_ observationClass: ObservationClass) {
    self.observationClass = observationClass
    updateName(with: observationClass)
    updateLocationMethod(with: observationClass)
    updateAwaitingGps()
    // Do not do anything more until we get the GpsPoint
    // Specifically do not create the entity.  It will be easier to cleanup if we abort
    // before getting the gpsPoint
  }

}

//MARK: - Entity Creation

extension ObservationPresenter {

  private func createAdHocLocation(in context: NSManagedObjectContext) {
    // depends on gpsPoint or timestamp, mapToucn, mapReference
    if let mapTouch = mapTouch, let map = mapReference {
      let adhocLocation = AdhocLocation.new(in: context)
      adhocLocation.location = mapTouch.toCLLocationCoordinate2D()
      adhocLocation.timestamp = gpsPoint?.timestamp ?? timestamp
      adhocLocation.map = map
      self.adhocLocation = adhocLocation
    }
  }

  private func createAngleDistanceLocation(in context: NSManagedObjectContext, feature: Feature) {
    // depends on gpsPoint, locationMethod
    if let gpsPoint = gpsPoint, let locationMethod = locationMethod,
      locationMethod == .angleDistance
    {
      let angleDistanceLocation = AngleDistanceLocation.new(in: context)
      angleDistanceLocation.direction = gpsPoint.course
      self.angleDistanceLocation = angleDistanceLocation
    }
  }

  private func createEntity(for observationClass: ObservationClass) {
    //TODO: provide an editing context, or a copy of the attributes, in case the user cancels editing
    guard let survey = survey, let mission = mission else {
      print("Unable to create feature. No survey or mission")
      return
    }
    switch observationClass {
    case .mission:
      createMissionProperty(to: survey.viewContext, config: survey.config, mission: mission)
      break
    case .feature(let feature):
      createFeature(to: survey.viewContext, feature: feature, mission: mission)
      break
    }
  }

  private func createFeature(to context: NSManagedObjectContext, feature: Feature, mission: Mission)
  {
    // depends on gpsPoint, adhocLocation, angleDistanceLocation
    let defaults = feature.dialog?.defaultValues
    let uniqueIdAttribute = feature.attributes?.uniqueIdAttribute
    entity = Observation.new(
      feature, mission: mission, gpsPoint: gpsPoint, adhocLocation: adhocLocation,
      angleDistanceLocation: angleDistanceLocation, defaults: defaults,
      uniqueIdAttribute: uniqueIdAttribute, in: context)
  }

  private func createMissionProperty(
    to context: NSManagedObjectContext, config: SurveyProtocol, mission: Mission
  ) {
    // depends on template, fields, gpsPoint, adhocLocation, observing
    let defaults: [String: Any]? = {
      return template == nil ? config.mission?.dialog?.defaultValues : nil
    }()
    var mpTemplate: (MissionProperty, [Attribute])? = nil
    if let template = template, let attrs = fields {
      mpTemplate = (template, attrs)
    }
    let uniqueIdAttribute = fields?.uniqueIdAttribute
    entity = MissionProperty.new(
      mission: mission, gpsPoint: gpsPoint, adhocLocation: adhocLocation, observing: observing,
      defaults: defaults, template: mpTemplate, uniqueIdAttribute: uniqueIdAttribute,
      in: context)
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

  //TODO: Update presentation of cancel/Save based on validation or edit status?

  private func updateEditing() {
    if isEditing {
      //TODO: isDeletable depends on ObservationClass and presentationMode
      //TODO: Delete requires entity and graphic
      isDeletable = true
      //TODO: is dependent on locationMethod and entity location properties
      isMoveableToTouch = true
      isMoveableToGps = true
      if presentationMode == .review {
        //TODO: create an edit context and update the entity
        presentationMode = .edit
      }
    } else {
      //Note: this branch only occurs during setup. It cannot be called by the view/user,
      // so I do not need to worry about saving or canceling edits
      isDeletable = false
      isMoveableToGps = false
      isMoveableToTouch = false
      presentationMode = .review
    }
  }

  private func updateEntity(from context: NSManagedObjectContext?, with timestamp: Date) {
    // depends on observationClass
    guard let context = context else {
      print("No context provided to ObservationPresenter.updateEntity(from:with:)")
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

  private func updateLocationMethod(with observationClass: ObservationClass) {
    // This should not be called when creating from touch; locationMethod wil be set manually
    // Only called with Create at GPS; but if a feature allows A/D this will override GPS.
    locationMethod = .gps
    switch observationClass {
    case .feature(let feature):
      if feature.allowAngleDistance {
        locationMethod = .angleDistance
      }
      break
    default:
      break
    }
  }

  private func updateLocationProperties(from entity: NSManagedObject?) {
    locationMethod = .gps  //default
    guard let entity = entity else {
      print("No entity provided to ObservationPresenter.updateLocationProperties(from:)")
      return
    }
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
    // depends on name, fields, entity
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
    // depends on observationClass
    switch observationClass {
    case .feature(let feature):
      return feature.angleDistanceConfig
    default:
      return nil
    }
  }

  private var angleDistanceFormDefinition: AngleDistanceFormDefinition? {
    // depends on angleDistanceDefinition, angleDistanceLocation
    guard let definition = angleDistanceDefinition,
      let angleDistanceLocation = angleDistanceLocation
    else {
      return nil
    }
    return AngleDistanceFormDefinition(
      definition: definition, angleDistanceLocation: angleDistanceLocation)
  }

  private var attributeFormDefinition: AttributeFormDefinition? {
    // depends on dialog, entity, fields
    guard let dialog = dialog, let entity = entity, let fields = fields else {
      return nil
    }
    return dialog.form(with: entity, fields: fields)
  }

  private var dialog: Dialog? {
    // depends on observationClass, survey
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
    // depends on observationClass, survey
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
