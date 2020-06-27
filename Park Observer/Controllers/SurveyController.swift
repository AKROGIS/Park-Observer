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

  @Published var tracklogging = false {
    didSet {
      if !tracklogging {
        observing = false
        locationManager.stopUpdatingLocation()
        mission = nil
        save(survey)
      } else {
        if gpsAuthorization == .unknown {
          locationManager.requestWhenInUseAuthorization()
          tracklogging = false
          //User will have to tap start tracklog button again if they allow locations.
        }
        if gpsAuthorization == .foreground || gpsAuthorization == .background {
          if let context = self.survey?.viewContext {
            mission = Mission.new(in: context)
            //TODO: Create a new missionProperty; edit attributes (oh no, I need a gpsPoint)
            locationManager.startUpdatingLocation()
          } else {
            message = Message.error("No survey selected, or survey is corrupt")
          }
        }
      }
    }
  }

  @Published var observing = false {
    didSet {
      //TODO: toggle MissionProperty.observing; edit attributes
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
    locationManager.allowsBackgroundLocationUpdates = self.userSettings.backgroundTracklogging && gpsAuthorization == .background
  }

  func drawBackgroundLocations() {
    for location in savedLocations {
      addGpsLocation(location)
    }
  }

  //MARK: - Add Graphics

  func addGpsLocation(_ location: CLLocation) {
    //TODO: validate: timestamp is recent but not too recent, meets accuracy criteria
    if isInBackground {
      savedLocations.append(location)
      return
    }
    guard let survey = self.survey, let mission = self.mission else {
      self.message = Message.error("No active survey. Can't add GPS point.")
      return
    }
    let gpsPoint = GpsPoint.new(in: survey.viewContext)
    gpsPoint.initializeWith(mission: mission, location: location)
    self.mapView.addGpsPoint(gpsPoint, to: survey.gpsOverlay)
  }

  func addMissionPropertyAtGps() {
    // TODO: Implement
    print("addMissionPropertyAtGps")
  }

  func addObservationAtGps(featureIndex: Int) {
    // TODO: Implement
    print("addObservationAtGps for featureIndex \(featureIndex)")
    if let features = survey?.config.features, featureIndex < features.count {
      let feature = features[featureIndex]
      print("addObservationAtGps for \(feature.name)")
    }
  }

}

//MARK: - Survey Drawing

extension AGSMapView {

  func addGpsPoint(_ gpsPoint: GpsPoint, to overlay: AGSGraphicsOverlay) {
    if let graphic = gpsPoint.asGraphic {
      overlay.graphics.add(graphic)
    }
    //TODO: Draw tracklog
  }

}

//TODO: Move to a separate file
extension String {
  static let layerNameGpsPoints = "GpsPoints"
  static let layerNameMissionProperties = "MissionProperties"
  static let layerNameTrackLogs = "TrackLogs"
}

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

extension Survey {

  var gpsOverlay: AGSGraphicsOverlay {
    if let overlay = graphicsLayers[.layerNameGpsPoints] {
      return overlay
    }
    let overlay = AGSGraphicsOverlay()
    overlay.overlayID = .layerNameGpsPoints
    overlay.renderer = self.config.mission?.gpsSymbology
    graphicsLayers[.layerNameGpsPoints] = overlay
    return overlay
  }

  var gpsGraphics: [AGSGraphic] {
    guard let gpsPoints = try? self.viewContext.fetch(GpsPoints.allOrderByTime) else {
      return []
    }
    return gpsPoints.compactMap { $0.asGraphic }
  }

}

extension AGSMapView {

  func draw(_ survey: Survey) {
    self.clearLayers()
    self.drawGpsPoints(survey)
    self.drawTrackLogs(survey)
    self.drawMissionProperties(survey)
    self.drawFeatures(survey)
  }

  func clearLayers() {
    self.graphicsOverlays.removeAllObjects()
  }

  func drawGpsPoints(_ survey: Survey) {
    let gpsOverlay = survey.gpsOverlay
    gpsOverlay.graphics.addObjects(from: survey.gpsGraphics)
    self.graphicsOverlays.add(gpsOverlay)
  }

  func drawTrackLogs(_ survey: Survey) {
    // TODO: Use one layer with a Unique Value Renderer
    let overlayOn = AGSGraphicsOverlay()
    overlayOn.overlayID = .layerNameTrackLogs + "On"
    overlayOn.renderer = survey.config.mission?.onSymbology
    let overlayOff = AGSGraphicsOverlay()
    overlayOff.overlayID = .layerNameTrackLogs + "Off"
    overlayOff.renderer = survey.config.mission?.offSymbology
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
    self.graphicsOverlays.add(overlayOn)
    self.graphicsOverlays.add(overlayOff)
  }

  func drawMissionProperties(_ survey: Survey) {
    let overlay = AGSGraphicsOverlay()
    overlay.overlayID = .layerNameMissionProperties
    overlay.renderer = survey.config.mission?.symbology
    if let missionProperties = try? survey.viewContext.fetch(MissionProperties.fetchRequest) {
      overlay.graphics.addObjects(
        from: missionProperties.compactMap { prop in
          guard let location = prop.gpsPoint?.location else { return nil }
          let agsPoint = AGSPoint(clLocationCoordinate2D: location)
          //TODO: add attributes?
          return AGSGraphic(geometry: agsPoint, symbol: nil, attributes: nil)
        })
    }
    self.graphicsOverlays.add(overlay)
  }

  func drawFeatures(_ survey: Survey) {
    for feature in survey.config.features {
      let overlay = AGSGraphicsOverlay()
      overlay.overlayID = feature.name
      overlay.renderer = feature.symbology
      if let labelDef = feature.label?.labelDefinition() {
        overlay.labelDefinitions.add(labelDef)
        overlay.labelsEnabled = true
      }
      if let observations = try? survey.viewContext.fetch(Observations.fetchAll(for: feature.name))
      {
        overlay.graphics.addObjects(
          from: observations.compactMap { observation in
            guard let location = observation.locationOfFeature else { return nil }
            let agsPoint = AGSPoint(clLocationCoordinate2D: location)
            let attributes = observation.attributes(for: feature)
            return AGSGraphic(geometry: agsPoint, symbol: nil, attributes: attributes)
          })
      }
      self.graphicsOverlays.add(overlay)
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
      tracklogging = false
      break
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

