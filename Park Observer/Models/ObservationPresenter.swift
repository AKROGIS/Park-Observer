//
//  ObservationPresenter.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/28/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS  // For AGSGraphic, AGSPoint
import CoreData  // For NSManagedObject, NSManagedObjectContext
import Foundation  // For ObservableObject, @Published, Date

// SurveyController creates an ObservationPresenter and shows the ObservationView
//  - when user taps on map (new)
//  - when user taps on a feature (edit/review)
//  - when the user taps on several features (edit/review) - an array is created
//  - when user taps on a new properties/feature buttons
//  - when the user starts/stops tracklogging/observing (if editing is appropriate)
// SurveyController requests gpsPoint, and feature type as needed.  When the SurveyContoller
//   receives them, it updates the ObservationPresenter which updates the ObservationView
// ObservationPresenter will create/edit/save/delete entites in a disposible edit context
// ObservationPresenter will delete graphics when an existing entity is deleted.
// ObservationPresenter will update graphic attributes when an existing entity is saved.
// ObservationView can be dismissed in the following ways
//  tap Save button
//    - if no changes same as Cancel button
//    - save context
//    - update graphic attributes (if existing)
//    - if errors display and do not allow slideout to close
//    - if no errors allow slideout to close (or go back to selector?)
//    - flag Controller we saved (with new entity/observationClass)
//    - Controller creates new graphic from self.entity (if new)
//    - Controller releases self (context deleted)
//  tap Cancel button
//    - context has changes present confirmation alert?
//    - allow slideout to close (or go back to selector?)
//    - flag Controller we cancelled
//    - Controller releases self (context deleted)
//  tap MoveToMapTouch button
//    - only allowed for existing entities/graphics with map touch location
//    - self calls save
//    - if not close allowed
//      - done; error message will tell user why view did not close
//    - if close allowed
//      - flag Controller we moved
//      - Controller requests map tap (delegated to Controller)
//      - Controller request self try move
//        - self moves graphic, updates entity, saves context may throw
//      - Controller displays any errors
//      - Controller releases self (context deleted)
//  tap Delete button
//    - present confirmation alert?
//    - delete entity from context; save context
//    - delete graphic from it's overlay
//    - if errors display and do not close
//    - if no errors close slideout (or go back to selector?)
//    - flag Controller we deleted
//    - Controller releases self (context deleted)
//  tap Back buttton (when presented from selector)
//    - Same as tap background
//  tap background (to close slideout)
//    - assume the user did not want abandon changes
//    - Controller calls save() on self
//    - if not close allowed
//      - Controller set slideout to showing
//      - Controller does _NOT_ release self
//    - if close allowed
//      - Controller creates new graphic from self.entity (if new)
//      - Controller releases self (context deleted)
//
// The presenter always uses an edit context; even if opened for review, because the user
// might switch to edit mode.  The surveyController will use the edit context for creating
// GPS points for the observation presenter, so that if the creation is canceled, the GPS
// points are also removed (unless they are also part of a tracklog)

enum CloseAction {
  case cancel  // abort edit or observation creation
  case `default`  // form closed by tap on map or back button (pick save or cancel)
  case delete  // existing entity and graphic were deleted
  case move  // move the graphic/adhocLocation to a pending mapTouch location
  case save(ObservationClass?, NSManagedObject?)  // saves changes
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

  //TODO: request GPS Point for MoveToGps (Controller could listen to awaitingGps)
  //TODO: Cleanup/Improve Title (add label or id or timestamp)
  //TODO: Verify canceling Mission Property creation is done right
  //TODO: Support cancel-on-top
  //TODO: Validate on save
  //TODO: Error handling needs more work (clear error, set isEditing/isEditable)
  //TODO?: Alert "This cannot be undone" warning before delete or cancel(with changes)
  //TODO?: Update presentation of Save based on context.hasChanges and validation status
  //TODO?: The timestamp should be optional, but ObservationSelectorView doesn't like that

  // These properties are used in the view, may not all need to be published,
  // but it is nice insurance to know that the view will be updated if they do change.
  @Published private(set) var angleDistanceForm: AngleDistanceFormDefinition? = nil
  @Published private(set) var attributeForm: AttributeFormDefinition? = nil
  @Published private(set) var awaitingGps = false
  @Published private(set) var awaitingFeature = false
  @Published private(set) var closeAllowed = true
  @Published private(set) var errorMessage = "No survey available."
  @Published private(set) var hasAngleDistanceForm = false
  @Published private(set) var hasAttributeForm = false
  @Published private(set) var isDeletable = false
  @Published private(set) var isEditable = false
  @Published private(set) var isMoveableToGps = false
  @Published private(set) var isMoveableToTouch = false
  @Published private(set) var timestamp = Date()
  @Published private(set) var title = "Observation"

  // SurveyController needs to read these is to create GPS point in "cancelable" context
  private(set) var closeAction = CloseAction.default
  private(set) var editContext: NSManagedObjectContext? = nil

  private var adhocLocation: AdhocLocation? = nil
  private var angleDistanceLocation: AngleDistanceLocation? = nil
  private var awaitingGpsForMove = false
  private var entity: NSManagedObject? = nil
  private var gpsDisabled = false
  private var gpsPoint: GpsPoint? = nil
  private var graphic: AGSGraphic? = nil
  private var locationMethod: LocationMethod.TypeEnum? = .gps
  private var mapReference: MapReference? = nil
  private var mapTouch: AGSPoint? = nil
  private var mission: Mission? = nil
  private var name: String?
  private var observationClass: ObservationClass? = nil
  private var observing: Bool? = nil
  private var presentationMode: PresentationMode = .review
  private var survey: Survey? = nil
  private var template: MissionProperty? = nil

  //MARK: - Public setters

  //I'm using these public setters so I can differentiate
  //when the properties are set from outside or inside the class

  /// Set the observation class when it becomes known
  func setObservationClass(observationClass: ObservationClass?) {
    // This can only be called if the observationClass is nil
    guard self.observationClass == nil else {
      print("Error: Illegal attempt to reset the observationClass in ObservationPresenter")
      return
    }
    self.observationClass = observationClass
    updateName(with: observationClass)
    updateAwaitingFeature()

    // Create entities
    if let context = editContext, let oClass = observationClass {
      if locationMethod == .mapTouch && (gpsPoint != nil || gpsDisabled) {
        createAdHocLocation(in: context)
        createEntity(in: context, for: oClass)
      }
    }
    updateAttributeForm()
    updateTitle()
    isEditing = true
  }

  /// Set the GpsPoint async when provided by the Location Services
  func setGpsPoint(gpsPoint: GpsPoint?) {
    // This can only be executed if the gpsPoint is nil
    guard self.gpsPoint == nil else {
      print("Error: Illegal attempt to reset the gpsPoint in ObservationPresenter")
      return
    }

    if awaitingGpsForMove {
      awaitingGpsForMove = gpsPoint == nil
      self.gpsPoint = gpsPoint
      updateAwaitingGps()
      if let missionProperty = entity as? MissionProperty {
        missionProperty.gpsPoint = gpsPoint
      }
      if let observation = entity as? Observation {
        observation.gpsPoint = gpsPoint
      }
      if gpsPoint != nil { locationMethod = .gps }
      if let graphic = graphic, let location = gpsPoint?.location {
        graphic.move(to: AGSPoint(clLocationCoordinate2D: location))
      }
      updateMoveable()
    }

    // if locationMethod = .mapTouch, then the gps is only needed for the timestamp;
    // do not save it with the entity; do not delete it or we might get another GPS point
    self.gpsPoint = gpsPoint
    updateTimestamp(with: gpsPoint)
    updateAwaitingGps()

    // Create entities
    if let context = editContext, let oClass = observationClass, gpsPoint != nil {
      if locationMethod == .gps {
        createEntity(in: context, for: oClass)
      }
      if locationMethod == .angleDistance, case .feature(let feature) = oClass {
        createAngleDistanceLocation(in: context, feature: feature)
        createEntity(in: context, for: oClass)
        updateAngleDistanceForm()
      }
      if locationMethod == .mapTouch {
        createAdHocLocation(in: context)
        createEntity(in: context, for: oClass)
      }
      updateAttributeForm()
      updateTitle()
      isEditing = true
    }
  }

  func setGpsDisabled() {
    gpsDisabled = true
    timestamp = Date()
    updateAwaitingGps()
    if locationMethod == .mapTouch, let context = editContext, let oClass = observationClass {
      createAdHocLocation(in: context)
      createEntity(in: context, for: oClass)
    }
  }

  //MARK: - Published Actions

  func initiateMoveToGps() {
    if locationMethod == .mapTouch && entity != nil {
      gpsPoint = nil
      awaitingGpsForMove = true
      updateAwaitingGps()
    }
  }

  func initiateMoveToTouch() {
    save()
    if closeAllowed {
      closeAction = .move
    }
  }

  func save() {
    if let context = editContext {
      if context.hasChanges {
        do {
          try context.save()
          updateGraphicAttributes()
          closeAllowed = true
          if presentationMode == .new {
            closeAction = .save(observationClass, entity)
          } else {
            closeAction = .save(nil, nil)
          }
        } catch {
          setError(error.localizedDescription)
          closeAllowed = false
          closeAction = .default
        }
      } else {
        closeAllowed = true
        closeAction = .cancel
      }
    }
  }

  func cancel() {
    closeAction = .cancel
  }

  func delete() {
    if let entity = entity, let context = entity.managedObjectContext, let graphic = graphic,
      let overlay = graphic.graphicsOverlay
    {
      context.delete(entity)
      do {
        try context.save()
        overlay.graphics.remove(graphic)
        closeAllowed = true
        closeAction = .delete
      } catch {
        setError(error.localizedDescription)
        closeAllowed = false
        closeAction = .default
      }
    } else {
      setError("Programming Error: no entity or graphic")
      closeAllowed = false
      closeAction = .default
    }
  }

  func moveGraphic(to mapPoint: AGSPoint) throws {
    if let adhocLocation = adhocLocation {
      adhocLocation.location = mapPoint.toCLLocationCoordinate2D()
      try editContext?.save()
      if let graphic = graphic {
        graphic.move(to: mapPoint)
      }
    }
  }

}

//MARK: - Convenience Initializers

extension ObservationPresenter {

  private convenience init(survey: Survey?) {
    self.init()
    self.survey = survey
    if let survey = survey {
      let editContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
      editContext.parent = survey.viewContext
      self.editContext = editContext
      self.errorMessage = ""
      self.isEditable = true
    }
  }

  private convenience init(survey: Survey?, mission: Mission?) {
    self.init(survey: survey)
    if mission == nil {
      self.setError("No mission available")
    } else {
      if let context = editContext, let id = mission?.objectID {
        self.mission = context.object(with: id) as? Mission
      }
    }
  }

  /// Create a new observation at the map touch location
  /// Optional Gps Point (for timestamp), and observation class will come later
  static func create(
    survey: Survey?, mission: Mission?, mapTouch: AGSPoint, mapReference: MapReference?
  ) -> ObservationPresenter {
    let op = ObservationPresenter(survey: survey, mission: mission)
    op.presentationMode = .new
    if mapReference == nil {
      op.setError("No map reference available")
    } else {
      if let context = op.editContext, let id = mapReference?.objectID {
        op.mapReference = context.object(with: id) as? MapReference
      }
    }
    op.initWith(mapTouch)
    return op
  }

  /// Create a new observation at the GPS (or Angle/Distance)
  /// Required Gps Point will come later
  static func create(
    survey: Survey?, mission: Mission?, observationClass: ObservationClass,
    template: MissionProperty? = nil, observing: Bool? = nil
  )
    -> ObservationPresenter
  {
    let op = ObservationPresenter(survey: survey, mission: mission)
    op.presentationMode = .new
    op.template = template
    op.observing = observing
    op.initWith(observationClass)
    return op
  }

  /// Show an existing observation
  static func show(survey: Survey?, graphic: AGSGraphic) -> ObservationPresenter {
    let op = ObservationPresenter(survey: survey)
    op.presentationMode = .review
    op.initWith(graphic)
    return op
  }

  private func initWith(_ graphic: AGSGraphic) {
    self.graphic = graphic
    self.name = graphic.graphicsOverlay?.overlayID
    updateObservationClass(with: self.name)
    updateTimestamp(with: graphic)
    updateEntity(from: editContext, with: self.timestamp)
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

  private func setError(_ message: String) {
    if errorMessage.isEmpty {
      errorMessage = message
      isEditable = false
    }
  }

}

//MARK: - Entity Creation

extension ObservationPresenter {

  private func createAdHocLocation(in context: NSManagedObjectContext) {
    // depends on gpsPoint or timestamp, mapTouch, mapReference, all previously validated
    if let mapTouch = mapTouch, let map = mapReference {
      let adhocLocation = AdhocLocation.new(in: context)
      adhocLocation.location = mapTouch.toCLLocationCoordinate2D()
      adhocLocation.timestamp = gpsPoint?.timestamp ?? timestamp
      adhocLocation.map = map
      self.adhocLocation = adhocLocation
    }
  }

  private func createAngleDistanceLocation(in context: NSManagedObjectContext, feature: Feature) {
    // depends on gpsPoint, previously validated
    if let gpsPoint = gpsPoint {
      let angleDistanceLocation = AngleDistanceLocation.new(in: context)
      angleDistanceLocation.direction = gpsPoint.course
      self.angleDistanceLocation = angleDistanceLocation
    }
  }

  private func createEntity(
    in context: NSManagedObjectContext, for observationClass: ObservationClass
  ) {
    guard let survey = survey, let mission = mission else {
      print("Unable to create entity. No survey or mission")  //Error already set
      return
    }
    switch observationClass {
    case .mission:
      createMissionProperty(to: context, config: survey.config, mission: mission)
      break
    case .feature(let feature):
      createFeature(to: context, feature: feature, mission: mission)
      break
    }
  }

  private func createFeature(to context: NSManagedObjectContext, feature: Feature, mission: Mission)
  {
    // depends on gpsPoint, adhocLocation, angleDistanceLocation
    guard gpsPoint != nil || adhocLocation != nil || angleDistanceLocation != nil else {
      let msg = "Programmer Error: No location defined for Observation"
      print(msg)
      setError(msg)
      return
    }
    let defaults = feature.dialog?.defaultValues
    let uniqueIdAttribute = feature.attributes?.uniqueIdAttribute
    // A mapTouch uses the GpsPoint for the timestamp (to link to observer's GPS position),
    // The Observation should should only set the AdhocLocation and not GpsPoint.
    // See discussion in Observation:requestLocationOfObserver
    let gpsPoint = adhocLocation == nil ? self.gpsPoint : nil
    entity = Observation.new(
      feature, mission: mission, gpsPoint: gpsPoint, adhocLocation: adhocLocation,
      angleDistanceLocation: angleDistanceLocation, defaults: defaults,
      uniqueIdAttribute: uniqueIdAttribute, in: context)
  }

  private func createMissionProperty(
    to context: NSManagedObjectContext, config: SurveyProtocol, mission: Mission
  ) {
    // depends on template, fields, gpsPoint, adhocLocation, observing
    guard gpsPoint != nil || adhocLocation != nil else {
      let msg = "Programmer Error: No location defined for Mission Propery"
      print(msg)
      setError(msg)
      return
    }
    let defaults = template == nil ? config.mission?.dialog?.defaultValues : nil
    let mpTemplate: (MissionProperty, [Attribute])? = {
      if let template = template, let attrs = fields {
        return (template, attrs)
      } else {
        return nil
      }
    }()
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

  private func updateDeletable() {
    switch observationClass {
    case .feature(_):
      isDeletable = entity != nil && graphic != nil
      break
    default:
      isDeletable = false
      break
    }
  }

  private func updateEditing() {
    if isEditing {
      updateDeletable()
      updateMoveable()
      if presentationMode == .review {
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

  private func updateGraphicAttributes() {
    if let graphic = graphic, let entity = entity {
      for key in graphic.attributes.allKeys {
        if let key = key as? String {
          if key != .attributeKeyTimestamp && key != .attributeKeyObserving {
            graphic.attributes[key] = entity.value(forKey: key)
          }
        }
      }
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
    // See Observation:requestLocationOfObserver for a discussion of how an observation's
    //   gpsPoint, adhocLocation and AngleLocation work together
    // In short there are 4 supported configurations (where properties are not null)
    //  1) gpsPoint -> .gps
    //  2) angleDistanceLocation + gpsPoint -> .angleDistance (not supported on MissionProperty)
    //  3) adhocLocation -> .mapTouch
    //  4) adhocLocation + gpsPoint -> .gps (original touch location was moved to GPS)

    locationMethod = .gps  //default
    guard let entity = entity else {
      print("No entity provided to ObservationPresenter.updateLocationProperties(from:)")
      return
    }
    if let missionProperty = entity as? MissionProperty {
      gpsPoint = missionProperty.gpsPoint
      if let location = missionProperty.adhocLocation {
        adhocLocation = location
        if gpsPoint == nil {
          locationMethod = .mapTouch
        }
      }
    }
    if let observation = entity as? Observation {
      gpsPoint = observation.gpsPoint
      if let location = observation.angleDistanceLocation {
        angleDistanceLocation = location
        locationMethod = .angleDistance
      }
      if let location = observation.adhocLocation {
        adhocLocation = location
        if gpsPoint == nil {
          locationMethod = .mapTouch
        }
      }
    }
  }

  private func updateMoveable() {
    isMoveableToTouch = false
    isMoveableToGps = false
    if locationMethod == .some(.mapTouch) {
      isMoveableToGps = !gpsDisabled
      if presentationMode == .edit {
        isMoveableToTouch = true
      }
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

  private func updateTimestamp(with gpsPoint: GpsPoint?) {
    if let timestamp = gpsPoint?.timestamp {
      self.timestamp = timestamp
    }
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
      //If feature has a map label defined, use that (it may be the id)
      if let idFieldName = fields.first(where: { $0.type == .id })?.name,
        let id = entity?.value(forKey: .attributePrefix + idFieldName) as? Int
      {
        title = "\(name) #\(id)"
      }
      //If feature has no label or id, then use Timestamp
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
