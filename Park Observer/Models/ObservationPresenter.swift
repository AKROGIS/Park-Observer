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

final class ObservationPresenter: ObservableObject {

  @Published var isEditing = false {
    didSet {
      isDeletable = true
      //TODO: is dependent on locationMethod and entity location properties
      isMoveableToGps = true
      presentationMode = .edit
    }
  }

  @Published private(set) var hasAngleDistanceForm = false
  @Published private(set) var hasAttributeForm = false
  @Published private(set) var isDeletable = false
  @Published private(set) var isEditable = true
  @Published private(set) var isMoveableToGps = false
  @Published private(set) var isMoveableToTouch = false
  @Published private(set) var presentationMode: PresentationMode = .review
  @Published private(set) var timestamp = Date()
  @Published private(set) var title = "Observation"
  @Published private(set) var angleDistanceForm: AngleDistanceFormDefinition? = nil
  @Published private(set) var attributeForm: AttributeFormDefinition? = nil

  var gpsPoint: GpsPoint? = nil {
    didSet {
      updateState()
    }
  }
  var observationClass: ObservationClass? = nil {
    didSet {
      updateState()
    }
  }
  var graphic: AGSGraphic? = nil {
    didSet {
      updateState()
    }
  }

  //TODO: update published state if these variables change
  private var survey: Survey? = nil
  private var mission: Mission? = nil
  private var locationMethod: LocationMethod.TypeEnum? = .gps
  private var entity: NSManagedObject? = nil
  private var adhocLocation: AdhocLocation? = nil
  private var angleDistanceLocation: AngleDistanceLocation? = nil

  private func updateState() {
    updateTitle()
  }

  private var fields: [Attribute] {
    guard let observationClass = observationClass else {
      return [Attribute]()
    }
    switch observationClass {
    case .mission:
      return survey?.config.mission?.attributes ?? [Attribute]()
    case .feature(let feature):
      return feature.attributes ?? [Attribute]()
    }
  }

  private var dialog: Dialog {
    guard let observationClass = observationClass else {
      return Dialog.defaultDialog
    }
    switch observationClass {
    case .mission:
      return survey?.config.mission?.dialog ?? Dialog.defaultDialog
    case .feature(let feature):
      return feature.dialog ?? Dialog.defaultDialog
    }
  }

  private var name: String? {
    guard let observationClass = observationClass else {
      return nil
    }
    switch observationClass {
    case .mission:
      return .entityNameMissionProperty
    case .feature(let feature):
      return feature.name
    }
  }

  private func updateTitle() {
    if let name = name {
      title = name
      //TODO: If feature has a map label defined, use that (it may be the id)
      if let idFieldName = fields.first(where: { $0.type == .id })?.name,
        let id = entity?.value(forKey: .attributePrefix + idFieldName) as? Int
      {
        title = "\(name) #\(id)"
      }
      //TODO: If feature has no label or id, then use Timestamp
    }
  }

  private func updateTimestamp() {
    //TODO: Get timestamp from gps if PresentationMode == .new else
    //  otherwise get timestamp from entity
    if let graphic = graphic {
      if let timestamp = graphic.attributes[String.attributeKeyTimestamp] as? Date {
        self.timestamp = timestamp
      }
    }
  }

  func initiateMoveToGps() {}
  func initiateMoveToTouch() {}
  func save() {}
  func cancel() {}
  func delete() {}

}

//MARK: - Initializers

extension ObservationPresenter {

  /*
   mission is optional with graphic,
   configure all properties (same as editable observation when given graphic
   set presentation mode
   */
  convenience init(survey: Survey?, mission: Mission?) {
    self.init()
    self.survey = survey
    self.mission = mission
    updateState()
  }

  static func review(survey: Survey?, graphic: AGSGraphic) -> ObservationPresenter {
    let op = ObservationPresenter(survey: survey, mission: nil)
    op.graphic = graphic
    op.presentationMode = .review
    op.initWithGraphic()
    op.attributeForm = op.observationForm
    op.hasAttributeForm = op.attributeForm != nil
    return op
  }
  //static func edit(survey: Survey, graphic: AGSGraphic) -> ObservationPresenter {}
  //static func new(survey: Survey, feature: Feature, locationMethod: LocationMethod.TypeEnum) -> ObservationPresenter {}
  //static func new(survey: Survey, properties: MissionProperty, locationMethod: LocationMethod.TypeEnum) -> ObservationPresenter {}
  //static func newTouch(survey: Survey) -> ObservationPresenter {}

  func initAsMapTouch() {}
  func gpsDisabled() {}

  func initWithGraphic() {
    guard let graphic = graphic else {
      print("No graphic provided to ObservationPresenter.initWithGraphic()")
      return
    }
    if let name = graphic.graphicsOverlay?.overlayID {
      if name == .layerNameMissionProperties {
        observationClass = .mission
      } else {
        for feature in survey?.config.features ?? [Feature]() {
          if feature.name == name {
            observationClass = .feature(feature)
          }
        }
      }
    } else {
      print("No name found for graphic's layer in ObservationPresenter.initWithGraphic()")
      observationClass = nil
    }
    if let timestamp = graphic.attributes[String.attributeKeyTimestamp] as? Date {
      self.timestamp = timestamp
    } else {
      print("No timestamp found for graphic in ObservationPresenter.initWithGraphic()")
    }
    guard let context = survey?.viewContext else {
      print("No coredata context found in ObservationPresenter.initWithGraphic()")
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

//MARK: - Computed Properties
extension ObservationPresenter {

  var awaitingGps: Bool {
    return gpsPoint == nil && presentationMode == .new
  }

  var awaitingFeature: Bool {
    return observationClass == nil && presentationMode == .new
  }

  //TODO: Simplify this with other computed properties
  //TODO: alternatively start with entity, not graphic
  var observationForm: AttributeFormDefinition {
    let defaultObservationForm = AttributeFormDefinition()

    guard let graphic = graphic else {
      print("No graphic provided to ObservationPresenter.observationForm")
      return defaultObservationForm
    }
    guard let name = graphic.graphicsOverlay?.overlayID else {
      print("No name found for graphic's layer in ObservationPresenter.observationForm")
      return defaultObservationForm
    }
    var maybeFeature: Feature? = nil
    var maybeFields: [Attribute]? = nil
    var maybeDialog: Dialog? = nil
    if name == .layerNameMissionProperties {
      maybeFields = survey?.config.mission?.attributes
      maybeDialog = survey?.config.mission?.dialog
    } else {
      for feature in survey?.config.features ?? [Feature]() {
        if feature.name == name {
          maybeFeature = feature
          maybeFields = feature.attributes
          maybeDialog = feature.dialog
        }
      }
    }
    guard let dialog = maybeDialog else {
      print("No dialog definition found in ObservationPresenter.observationForm")
      return defaultObservationForm
    }
    guard let fields = maybeFields else {
      print("No attribute definition found in ObservationPresenter.observationForm")
      return defaultObservationForm
    }
    guard let timestamp = graphic.attributes[String.attributeKeyTimestamp] as? Date else {
      print("No timestamp found for graphic in ObservationPresenter.observationForm")
      return defaultObservationForm
    }
    guard let context = survey?.viewContext else {
      print("No coredata context found in ObservationPresenter.observationForm")
      return defaultObservationForm
    }
    var object: NSObject?
    if name == .layerNameMissionProperties {
      object = MissionProperties.fetchFirst(at: timestamp, in: context)
    } else {
      if let feature = maybeFeature {
        object = Observations.fetchFirst(feature, at: timestamp, in: context)
      }
    }
    guard let data = object else {
      print("No object found CoreData Context in ObservationPresenter.observationForm")
      return defaultObservationForm
    }
    return dialog.form(with: data, fields: fields)
  }
}
