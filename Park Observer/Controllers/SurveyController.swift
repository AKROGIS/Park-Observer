//
//  SurveyController.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 6/9/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// This class is responsible for updating state in mapView/CoreData in response to CoreLocation and user input.
/// The single source of truth is the SurveyDB, but this data is effectively duplicated in the mapView.
/// Since I can't think of a simple/efficient way for the mapView and CoreData to work together off of a
/// single datasource, I will update both in tandem through this class. To avoid surprises, this is the only class
/// that should update the entities in CoreData or the mapView's layers/markers.
/// This class should be owned by the SceneDelegate (so it can respond to life cycle events) and will provide
/// various publish properties and callbacks to other views or view controllers. This class owns the mapView, and
/// which is shared with other view controllers like the LocationButtonController.
/// It is the delegate for CoreLocation and mapView touches among others.
/// Some of its many tasks
/// - Has observable state for swiftUI views (not mapView) - i.e. on transect, current survey, current map name, ...
/// - Start/Stop trackLogging; Start/Stop observing
/// - Controls background trackLogging (do not write to UI until in foreground); consider battery usage
/// - Controls GPS point frequency; explore battery savings

import ArcGIS  // For AGSMapView and AGSGeoViewTouchDelegate
import CoreLocation  // For CLLocationManagerDelegate
import Foundation  // For NSObject (for delegates)

class SurveyController: NSObject, ObservableObject, CLLocationManagerDelegate,
  AGSGeoViewTouchDelegate
{

  let mapView = AGSMapView()
  var surveyName: String? = nil
  var mapName: String? = nil

  var isInBackground = false {
    didSet {
      if isInBackground {
        saveState()
        startBackgroundLocations()
      } else {
        drawBackgroundLocations()
      }
    }
  }

  @Published var trackLogging = false {
    didSet {
      if trackLogging {
        startTrackLogging()
      } else {
        stopTrackLogging()
      }
    }
  }

  @Published var observing = false {
    didSet {
      if trackLogging {
        addMissionPropertyAtGps()
      }
    }
  }

  @Published var slideOutMenuVisible = false
  @Published var slideOutMenuWidth: CGFloat = 300.0
  @Published var message: Message? = nil
  @Published var featureNames = [String]()
  @Published var gpsAuthorization = GpsAuthorization.unknown
  @Published var enableSurveyControls = false

  // I'm not sure this controller should own these other controllers, but it works
  // better than the other options (owned by various views or SceneDelegate).
  // It also simplifies the SceneDelegate, the View environment, and the Views.
  let locationButtonController: LocationButtonController
  let viewPointController: ViewPointController
  let userSettings = UserSettings()
  let locationManager = CLLocationManager()

  private var survey: Survey? = nil {
    didSet {
      if let survey = oldValue {
        save(survey)
      }
      if let survey = survey {
        enableSurveyControls = true
        self.featureNames = survey.config.features.map { $0.name }
      } else {
        enableSurveyControls = false
        self.featureNames.removeAll()
      }
    }
  }
  private var mission: Mission? = nil
  private var missionProperty: MissionProperty? = nil

  override init() {
    locationButtonController = LocationButtonController(mapView: self.mapView)
    viewPointController = ViewPointController(mapView: self.mapView)
    super.init()
    locationManager.delegate = self
  }

  //MARK: - Load Map/Survey

  func loadMap(name: String? = nil) {
    let defaultMap = Defaults.mapName.readString()
    guard let name = name ?? mapName ?? defaultMap else {
      print("SurveyController.mapName(name:): No name given")
      // MapView will be empty; user can now choose a map to display
      return
    }
    NSLog("Start load map \(name)")
    if name.starts(with: "Esri ") {
      mapView.map = getEsriBasemap(for: name)
    } else {
      mapView.map = getLocalTileCache(for: name)
    }
    mapView.map?.load(completion: { error in
      if let error = error {
        print("Error in mapView.map.load(): \(error)")
      } else {
        if name == defaultMap {
          self.viewPointController.restoreState()
        }
        // location tracking should take precedence over the previous extents.
        self.locationButtonController.restoreState()
        self.mapName = name
        NSLog("Finish load map")
      }
    })
  }

  func loadSurvey(name: String? = nil) {
    guard let name = name ?? surveyName ?? Defaults.surveyName.readString() else {
      message = Message.warning("No survey loaded. Use the menu to select a survey.")
      return
    }
    NSLog("Start load survey \(name)")
    Survey.load(name) { (result) in
      NSLog("Finish load survey")
      switch result {
      case .success(let survey):
        self.surveyName = name
        self.survey = survey
        self.featureNames = survey.config.features.map { $0.name }
        NSLog("Start draw survey")
        // Map draw can take several seconds for a large survey. Fortunately, the map layers can
        // be updated on a background thread, and mapView updates the UI appropriately.
        DispatchQueue.global(qos: .userInitiated).async {
          self.mapView.draw(survey)
          NSLog("Finish draw survey")
        }
        break
      case .failure(let error):
        self.message = Message.error("Error loading survey: \(error)")
        break
      }
    }
  }

  func save(_ survey: Survey?) {
    do {
      try survey?.save()
    } catch {
      message = Message.error("Unable to save survey: \(error.localizedDescription)")
    }
  }

  //MARK: - Save/Restore State

  func saveState() {
    // To be called when the app goes into the background
    // If the app is terminated this state can be restored when the app relaunches.
    print("SurveyController.saveState() called on main thread: \(Thread.isMainThread)")
    do {
      try survey?.save()
    } catch {
      print("Error saving survey: \(error)")
    }
    Defaults.mapName.write(mapName)
    Defaults.surveyName.write(surveyName)
    locationButtonController.saveState()
    viewPointController.saveState()
    Defaults.slideOutMenuWidth.write(slideOutMenuWidth)
    userSettings.saveState()
  }

  func restoreState() {
    userSettings.restoreState()
    slideOutMenuWidth = CGFloat(Defaults.slideOutMenuWidth.readDouble())
    slideOutMenuWidth = slideOutMenuWidth < 10.0 ? 300.0 : slideOutMenuWidth
  }

  //MARK: - Background Locations

  var savedLocations = [CLLocation]()

  func startBackgroundLocations() {
    locationManager.allowsBackgroundLocationUpdates =
      self.userSettings.backgroundTracklogging && gpsAuthorization == .background
  }

  func drawBackgroundLocations() {
    for location in savedLocations {
      addGpsLocation(location)
    }
  }

  //MARK: - Adding GPS Locations

  private var awaitingAuthorizationForTrackLogging = false
  private var awaitingAuthorizationForMissionProperty = false
  private var awaitingAuthorizationForFeatureAtIndex = -1
  private var awaitingLocationForMissionProperty = false
  private var awaitingLocationForFeatureAtIndex = -1

  func stopTrackLogging() {
    observing = false
    locationManager.stopUpdatingLocation()
    mission = nil
    save(survey)
  }

  func startTrackLogging() {
    if gpsAuthorization == .unknown {
      locationManager.requestWhenInUseAuthorization()
      trackLogging = false
      awaitingAuthorizationForTrackLogging = true
      return
    }
    if gpsAuthorization == .denied {
      //TODO: raise alert with option to go to settings.  See Location Button
      message = Message.info("App is not authorized to obtain your location. Enable in setttings.")
      trackLogging = false
      return
    }
    if let context = self.survey?.viewContext {
      mission = Mission.new(in: context)
      locationManager.startUpdatingLocation()
      addMissionPropertyAtGps()
    } else {
      message = Message.error("No survey selected, or survey is corrupt.")
    }
  }

  func addMissionPropertyAtGps() {
    if gpsAuthorization == .denied {
      message = Message.error("App is not authorized to obtain your location. Enable in setttings.")
      return
    }
    if gpsAuthorization == .unknown {
      locationManager.requestWhenInUseAuthorization()
      awaitingAuthorizationForMissionProperty = true
      return
    }
    awaitingLocationForMissionProperty = true
    // Cycle the Location Manager to get the current location
    locationManager.stopUpdatingLocation()
    locationManager.startUpdatingLocation()
    // mission property will be added when we the next GPS location
  }

  func addObservationAtGps(featureIndex: Int) {
    if gpsAuthorization == .denied {
      message = Message.error("App is not authorized to obtain your location. Enable in setttings.")
      return
    }
    if gpsAuthorization == .unknown {
      locationManager.requestWhenInUseAuthorization()
      awaitingAuthorizationForFeatureAtIndex = featureIndex
      return
    }
    awaitingLocationForFeatureAtIndex = featureIndex
    // Cycle the Location Manager to get the current location
    locationManager.stopUpdatingLocation()
    locationManager.startUpdatingLocation()
    // feature will be added when we the next GPS location
  }

  /// Called by the Core Location Delegate whenever a new (or updated) location is available
  func addGpsLocation(_ location: CLLocation) {
    //TODO: validate: timestamp is recent but not too recent, meets accuracy criteria
    if isInBackground {
      savedLocations.append(location)
      return
    }
    guard let survey = self.survey, let mission = self.mission else {
      var item = "GPS point"
      if awaitingLocationForFeatureAtIndex >= 0 { item = "Observation" }
      if awaitingLocationForMissionProperty { item = "Mission Property" }
      self.message = Message.error("No active survey. Can't add \(item).")
      return
    }
    let gpsPoint = GpsPoint.new(in: survey.viewContext)
    gpsPoint.initializeWith(mission: mission, location: location)
    self.mapView.addGpsPoint(gpsPoint)
    if awaitingLocationForMissionProperty {
      defer {
        awaitingLocationForMissionProperty = false
      }
      let missionProperty = MissionProperty.new(in: survey.viewContext)
      missionProperty.mission = mission
      missionProperty.gpsPoint = gpsPoint
      missionProperty.observing = observing
      //TODO: Add default mission attributes (and edit them in slideout panel)
      self.mapView.addMissionProperty(missionProperty)
      self.missionProperty = missionProperty
    }
    if awaitingLocationForFeatureAtIndex >= 0 {
      defer {
        awaitingLocationForFeatureAtIndex = -1
      }
      let index = awaitingLocationForFeatureAtIndex
      if index < survey.config.features.count {
        let feature = survey.config.features[index]
        let observation = Observation.new(feature, in: survey.viewContext)
        observation.mission = mission
        //TODO: support adhoc and angleDistance locations
        observation.gpsPoint = gpsPoint
        //TODO: Add and edit feature attributes in slideout panel)
        self.mapView.addFeature(observation, feature: feature, index: index)
      }
    }
  }

}

//MARK: - Survey Drawing

//TODO: Move to a separate file

extension GpsPoint {

  var asGraphic: AGSGraphic? {
    guard let location = self.location else {
      return nil
    }
    let agsPoint = AGSPoint(clLocationCoordinate2D: location)
    //TODO: add attributes?
    return AGSGraphic(geometry: agsPoint, symbol: nil, attributes: nil)
  }
}

extension MissionProperty {

  var asGraphic: AGSGraphic? {
    guard let location = self.gpsPoint?.location ?? self.adhocLocation?.location else {
      return nil
    }
    let agsPoint = AGSPoint(clLocationCoordinate2D: location)
    //TODO: add attributes?
    return AGSGraphic(geometry: agsPoint, symbol: nil, attributes: nil)
  }
}

extension Observation {

  func asGraphic(for feature: Feature) -> AGSGraphic? {
    guard let location = self.locationOfFeature else {
      return nil
    }
    let agsPoint = AGSPoint(clLocationCoordinate2D: location)
    let attributes = self.attributes(for: feature)
    return AGSGraphic(geometry: agsPoint, symbol: nil, attributes: attributes)
  }
}

extension Survey {

  var gpsGraphics: [AGSGraphic] {
    guard let gpsPoints = try? self.viewContext.fetch(GpsPoints.allOrderByTime) else {
      return []
    }
    return gpsPoints.compactMap { $0.asGraphic }
  }

  var missionPropertyGraphics: [AGSGraphic] {
    guard let missionProperties = try? self.viewContext.fetch(MissionProperties.fetchRequest) else {
      return []
    }
    return missionProperties.compactMap { $0.asGraphic }
  }

  func featureGraphics(for feature: Feature) -> [AGSGraphic] {
    guard let features = try? self.viewContext.fetch(Observations.fetchAll(for: feature.name))
    else {
      return []
    }
    return features.compactMap { $0.asGraphic(for: feature) }
  }
}

extension AGSMapView {

  func draw(_ survey: Survey) {
    self.removeLayers()
    self.addLayers(for: survey)
    self.addGpsPoints(from: survey)
    self.addTrackLogs(from: survey)
    self.addMissionProperties(from: survey)
    self.addFeatures(from: survey)
  }

  func removeLayers() {
    self.graphicsOverlays.removeAllObjects()
  }

  //IMPORTANT - Keep layer indices consistent with the I create them
  // the mapView owns the layers, but I need to access them by content/function
  // There is a overlayID is can set on each layer, but that would require searching
  // the layer list everytime I added a graphic.  Because I control the order that
  // layers are added to the map, I can hard code the layer index for fast access.

  func addLayers(for survey: Survey) {
    let missionRenderers: [AGSRenderer?] = [
      survey.config.mission?.gpsSymbology,
      // TODO: Use one layer with a Unique Value Renderer
      survey.config.mission?.onSymbology,
      survey.config.mission?.offSymbology,
      survey.config.mission?.symbology,
    ]
    let featureRenderers: [AGSRenderer?] = survey.config.features.map { $0.symbology }
    for renderer in missionRenderers + featureRenderers {
      let overlay = AGSGraphicsOverlay()
      overlay.renderer = renderer
      self.graphicsOverlays.add(overlay)
    }
  }

  var gpsOverlay: AGSGraphicsOverlay {
    self.graphicsOverlays[0] as! AGSGraphicsOverlay
  }

  var observingOverlay: AGSGraphicsOverlay {
    self.graphicsOverlays[1] as! AGSGraphicsOverlay
  }

  var notObservingOverlay: AGSGraphicsOverlay {
    self.graphicsOverlays[2] as! AGSGraphicsOverlay
  }

  var missionPropertyOverlay: AGSGraphicsOverlay {
    self.graphicsOverlays[3] as! AGSGraphicsOverlay
  }

  func featureOverlay(at index: Int) -> AGSGraphicsOverlay {
    self.graphicsOverlays[4 + index] as! AGSGraphicsOverlay
  }

  func addGpsPoint(_ gpsPoint: GpsPoint) {
    if let graphic = gpsPoint.asGraphic {
      let overlay = self.gpsOverlay
      overlay.graphics.add(graphic)
    }
  }

  func addGpsPoints(from survey: Survey) {
    let overlay = self.gpsOverlay
    overlay.graphics.addObjects(from: survey.gpsGraphics)
  }

  func addMissionProperty(_ missionProperty: MissionProperty) {
    if let graphic = missionProperty.asGraphic {
      let overlay = self.missionPropertyOverlay
      overlay.graphics.add(graphic)
    }
  }

  func addMissionProperties(from survey: Survey) {
    let overlay = self.missionPropertyOverlay
    overlay.graphics.addObjects(from: survey.missionPropertyGraphics)
  }

  func addTrackLogs(from survey: Survey) {
    let overlayOn = self.observingOverlay
    let overlayOff = self.notObservingOverlay
    if let trackLogs = try? TrackLogs.fetchAll(context: survey.viewContext) {
      for trackLog in trackLogs {
        if let polyline = trackLog.polyline {
          let graphic = AGSGraphic(geometry: polyline, symbol: nil, attributes: nil)
          //TODO: add attributes?
          if let observing = trackLog.properties.observing, observing {
            overlayOn.graphics.add(graphic)
          } else {
            overlayOff.graphics.add(graphic)
          }
        }
      }
    }
  }

  func addFeature(_ observation: Observation, feature: Feature, index: Int) {
    if let graphic = observation.asGraphic(for: feature) {
      let overlay = self.featureOverlay(at: index)
      overlay.graphics.add(graphic)
    }
  }

  func addFeatures(from survey: Survey) {
    for (index, feature) in survey.config.features.enumerated() {
      let overlay = self.featureOverlay(at: index)
      if let labelDef = feature.label?.labelDefinition() {
        overlay.labelDefinitions.add(labelDef)
        overlay.labelsEnabled = true
      }
      overlay.graphics.addObjects(from: survey.featureGraphics(for: feature))
    }
  }
}

//TODO: Move to a separate file

//MARK: - Map Loading

extension SurveyController {

  private func getLocalTileCache(for name: String) -> AGSMap? {
    // The tile package needs to exist in the document directory of the device or simulator
    // For a device use iTunes File Sharing (enable in the info.plist)
    // For the simulator - breakpoint on the next line, to see what the path is
    // This function does no I/O, so the name is not checked until mapView tries to load the map.
    let path = FileManager.default.mapURL(with: name)
    let cache = AGSTileCache(fileURL: path)
    let layer = AGSArcGISTiledLayer(tileCache: cache)
    let basemap = AGSBasemap(baseLayer: layer)
    return AGSMap(basemap: basemap)
  }

  private func getEsriBasemap(for name: String) -> AGSMap? {
    guard let basemap = OnlineBaseMaps.esri[name] else {
      return nil
    }
    return AGSMap(basemap: basemap())
  }

}

//MARK: - CoreLocation Manager Delegate

extension SurveyController {

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    message = Message.warning(error.localizedDescription)
    //TODO: - Clear when GPS is back
  }

  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    print("Location Manager Did Change Authorization to: \(status.description)")
    switch status {
    case .notDetermined:
      gpsAuthorization = .unknown
      break
    case .authorizedAlways:
      gpsAuthorization = .background
      break
    case .authorizedWhenInUse:
      gpsAuthorization = .foreground
      self.userSettings.backgroundTracklogging = false
      break
    default:
      gpsAuthorization = .denied
      self.userSettings.backgroundTracklogging = false
      trackLogging = false
      break
    }
    if awaitingAuthorizationForTrackLogging {
      trackLogging = true
      awaitingAuthorizationForTrackLogging = false
    }
    if awaitingAuthorizationForMissionProperty {
      addMissionPropertyAtGps()
      awaitingAuthorizationForMissionProperty = false
    }
    if awaitingAuthorizationForFeatureAtIndex >= 0 {
      addObservationAtGps(featureIndex: awaitingAuthorizationForFeatureAtIndex)
      awaitingAuthorizationForFeatureAtIndex = -1
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for location in locations {
      //TODO: validate: timestamp is recent but not too recent, meets accuracy criteria
      addGpsLocation(location)
    }
  }

}

// MARK: - CLAuthorizationStatus extension

extension CLAuthorizationStatus: CustomStringConvertible {
  public var description: String {
    switch self {
    case .authorizedAlways: return "Authorized Always"
    case .authorizedWhenInUse: return "Authorized When In Use"
    case .denied: return "Denied"
    case .notDetermined: return "Not Determined"
    case .restricted: return "Restricted"
    @unknown default: return "**Unexpected Enum Value**"
    }
  }
}

enum GpsAuthorization {
  /// Don't bother asking, I know the user doesn't allow GPS Locations.  I will get notified if they change thier mind.
  case denied
  /// Authorized to get location in the foreground and background
  case background
  /// User has not set a location preference,  I should ask.
  case unknown
  /// Only authorized to get location in the foreground
  case foreground
}
