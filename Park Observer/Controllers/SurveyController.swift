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
import Combine  // For Cancellable
import CoreLocation  // For CLLocationManagerDelegate
import Foundation  // For NSObject (for delegates)
import SwiftUI  // For Alert

class SurveyController: NSObject, ObservableObject {

  let mapView = AGSMapView()

  @Published private(set) var surveyName: String? = nil
  @Published private(set) var mapName: String? = nil {
    didSet {
      updateMapReference()
    }
  }

  var isInBackground = false {
    didSet {
      if isInBackground {
        saveState()
        startBackgroundLocations()
      } else {
        //TODO: disable location updates until we are done adding all saved locations
        drawBackgroundLocations()
      }
    }
  }

  @Published var trackLogging = false {
    didSet {
      if trackLogging {
        startTrackLogging()
        startTotalizer()
      } else {
        stopTrackLogging()
        stopTotalizer()
      }
      updateInfoBanner()
      updateSurveyControls()
    }
  }

  @Published var observing = false {
    didSet {
      if trackLogging {
        let showEditor: Bool = {
          guard let mission = survey?.config.mission else {
            return false
          }
          if mission.attributes == nil { return false }
          if observing {
            if reObserving {
              return mission.editAtStartReobserving
            } else {
              reObserving = true
              return mission.editAtStartFirstObserving
            }
          } else {
            return mission.editAtStopObserving
          }
        }()
        totalizer?.observing = observing
        addMissionPropertyAtGps(showEditor: showEditor)
      }
      updateInfoBanner()
      updateSurveyControls()
    }
  }

  @Published var trackLogLabel = "Tracklog"
  @Published var transectLabel = SurveyProtocol.defaultTransectLabel

  @Published var showingTrackLogButton = false
  @Published var showingObserveButton = false
  @Published var showingMissionPropertiesButton = false

  private var reObserving = false  // Set to true after first observation is started

  @Published var enableBackgroundTrackLogging = false {
    didSet {
      if enableBackgroundTrackLogging {
        locationManager.requestAlwaysAuthorization()
      }
    }
  }

  @Published var slideOutMenuVisible = false {
    didSet {
      if !slideOutMenuVisible {
        slideOutClosedActions()
      }
    }
  }
  @Published var isGpsIntervalDefinedByProtocol = false
  @Published var slideOutMenuWidth: CGFloat = 300.0
  @Published var message: Message? = nil
  @Published var observationsLocatableWithTouch = [ObservationClass]()
  @Published var featuresLocatableWithoutTouch = [Feature]()
  @Published var gpsAuthorization = GpsAuthorization.unknown

  // TouchDelegate properties
  @Published var showingAlert = false

  @Published var alert: Alert? = nil

  private var movingObservation: ObservationPresenter? = nil
  @Published var selectedObservation: ObservationPresenter? = nil
  @Published var selectedObservations: [ObservationPresenter]? = nil

  @Published var showMapTouchSelectionSheet = false
  var showingObservationEditor = false
  var showingObservationSelector = false
  var movingGraphic = false

  // I'm not sure this controller should own these other controllers, but it works
  // better than the other options (owned by various views or SceneDelegate).
  // It also simplifies the SceneDelegate, the View environment, and the Views.
  let locationButtonController: LocationButtonController
  let viewPointController: ViewPointController
  let userSettings = UserSettings()
  let locationManager = CLLocationManager()
  var touchDelegate: MapViewTouchDelegate? = nil

  private var survey: Survey? = nil {
    didSet {
      updateMapReference()
      updateSurveyControls()
      isGpsIntervalDefinedByProtocol = survey?.config.gpsInterval != nil
      if let survey = survey {
        missionPropertyTemplate = MissionProperties.fetchLast(in: survey.viewContext)
        initializeUniqueIds()
        initializeTotalizer()
      }
    }
  }

  private var mission: Mission? = nil
  private var missionPropertyTemplate: MissionProperty? = nil
  private var mapReference: MapReference? = nil
  private(set) var defaultMapExtentsSet = false

  //Totalizer support
  @Published var isShowingTotalizer = false
  var totalizer: Totalizer? = nil

  //Banner support
  @Published var isShowingInfoBanner = false
  @Published var infoBannerText: String = ""

  var cancellables = [AnyCancellable]()

  //MARK: - Initialize

  override init() {
    locationButtonController = LocationButtonController(mapView: self.mapView)
    viewPointController = ViewPointController(mapView: self.mapView)
    super.init()
    locationManager.delegate = self
    touchDelegate = MapViewTouchDelegate(surveyController: self)
    self.mapView.touchDelegate = touchDelegate
    let cancellable1 = userSettings.$showTotalizer.sink { [weak self] show in
      self?.isShowingTotalizer = show && (self?.trackLogging ?? false)
    }
    cancellables.append(cancellable1)
    let cancellable2 = userSettings.$showInfoBanner.sink { [weak self] show in
      self?.isShowingInfoBanner = show && !(self?.infoBannerText.isEmpty ?? true)
    }
    cancellables.append(cancellable2)
    let cancellable3 = userSettings.$gpsDistanceFilter.sink { [weak self] _ in
      self?.setGpsDistanceFilter()
    }
    cancellables.append(cancellable3)
  }

  //MARK: - Load Map/Survey

  func loadMap(name: String? = nil) {
    defaultMapExtentsSet = false
    let defaultMap = Defaults.mapName.readString()
    guard let name = name ?? mapName ?? defaultMap else {
      print("SurveyController.mapName(name:): No name given")
      // MapView will be empty; user can now choose a map to display
      return
    }
    //NSLog("Start load map \(name)")
    if name.starts(with: "Esri ") {
      mapView.map = getEsriBasemap(for: name)
    } else {
      mapView.map = getLocalTileCache(for: name)
    }
    mapView.map?.load(completion: { error in
      if let error = error {
        print("Error in mapView.map.load(): \(error)")
        self.mapName = nil
      } else {
        if name == defaultMap {
          self.viewPointController.restoreState()
          self.defaultMapExtentsSet = true
        } else {
          if self.survey != nil {
            self.mapView.zoomToOverlayExtents()
            self.defaultMapExtentsSet = false
          }
        }
        // location tracking should take precedence over the previous extents.
        self.locationButtonController.restoreState()
        self.mapName = name
        //NSLog("Finish load map")
      }
    })
  }

  func loadSurvey(name: String? = nil) {
    guard let name = name ?? surveyName ?? Defaults.surveyName.readString() else {
      message = Message.warning("No survey loaded. Use the menu to select a survey.")
      return
    }
    unloadCurrentSurvey()
    //NSLog("Start load survey \(name)")
    Survey.load(name) { (result) in
      //NSLog("Finish load survey")
      switch result {
      case .success(let survey):
        self.surveyName = name
        self.survey = survey
        //NSLog("Start draw survey")
        // Map draw can take several seconds for a large survey. Fortunately, the map layers can
        // be updated on a background thread, and mapView updates the UI appropriately.
        DispatchQueue.global(qos: .userInitiated).async {
          self.mapView.draw(survey, zoomToExtents: !self.defaultMapExtentsSet)
          self.defaultMapExtentsSet = false
          //NSLog("Finish draw survey")
        }
        break
      case .failure(let error):
        self.message = Message.error("Error loading survey: \(error)")
        break
      }
    }
  }

  func willDelete(_ file: AppFile) {
    if file.type == .survey && file.name == surveyName {
      unloadCurrentSurvey()
    }
    if file.type == .map && file.name == mapName {
      mapView.map = nil
      self.mapName = nil
    }
  }

  /// Save Survey, Stop TrackLogging, and clear all references to objects owned by the survey
  func unloadCurrentSurvey() {
    trackLogging = false
    saveSurvey()
    featuresLocatableWithoutTouch.removeAll()
    observationsLocatableWithTouch.removeAll()
    mission = nil
    missionPropertyTemplate = nil
    mapReference = nil
    selectedObservation = nil
    selectedObservations = nil
    showingObservationEditor = false
    showingObservationSelector = false
    showMapTouchSelectionSheet = false
    movingGraphic = false
    mapView.removeLayers()
    survey = nil
    surveyName = nil
    showingTrackLogButton = false
    showingObserveButton = false
    showingMissionPropertiesButton = false
  }

  private func updateMapReference() {
    if let context = survey?.viewContext, let name = mapName {
      let mapInfo = MapInfo(from: name)
      mapReference = MapReference.findOrNew(matching: mapInfo, in: context)
    } else {
      mapReference = nil
    }
  }

  //MARK: - Save/Restore State

  func saveState() {
    // To be called when the app goes into the background
    // If the app is terminated this state can be restored when the app relaunches.
    //print("SurveyController.saveState() called on main thread: \(Thread.isMainThread)")
    saveSurvey()
    Defaults.mapName.write(mapName)
    Defaults.surveyName.write(surveyName)
    locationButtonController.saveState()
    viewPointController.saveState()
    Defaults.slideOutMenuWidth.write(slideOutMenuWidth)
    Defaults.backgroundTrackLogging.write(enableBackgroundTrackLogging)
    userSettings.saveState()
  }

  func restoreState() {
    userSettings.restoreState()
    enableBackgroundTrackLogging = Defaults.backgroundTrackLogging.readBool()
    slideOutMenuWidth = CGFloat(Defaults.slideOutMenuWidth.readDouble())
    slideOutMenuWidth = slideOutMenuWidth < 10.0 ? 300.0 : slideOutMenuWidth
  }

  func initializeUniqueIds() {
    guard let survey = survey else { return }
    if let attribute = survey.config.mission?.attributes?.uniqueIdAttribute {
      MissionProperty.initializeUniqueId(attribute: attribute, in: survey.viewContext)
    }
    for feature in survey.config.features {
      if let attribute = feature.attributes?.uniqueIdAttribute {
        Observation.initializeUniqueId(
          feature: feature, attribute: attribute, in: survey.viewContext)
      }
    }
  }

  func setTitle(_ title: String) -> SurveyInfo? {
    if let survey = survey {
      survey.setTitle(title)
      return survey.info
    }
    return nil
  }

  func saveSurvey() {
    guard let survey = survey else { return }
    do {
      try survey.save()
    } catch {
      message = Message.error("Unable to save survey: \(error.localizedDescription)")
    }
  }

  //MARK: - Feature lists

  private func updateSurveyControls() {
    updateFeatureLocatableWithoutTouch()
    showingMissionPropertiesButton = isEditingEnabled(for: .mission)
    if let config = survey?.config {
      showingTrackLogButton = config.tracklogs != .none
      showingObserveButton = {
        if config.transects == .none {
          return false
        }
        if config.tracklogs == .required && !trackLogging {
          return false
        }
        return true
      }()
      transectLabel = config.transectLabel
    }
  }

  func isEditingEnabled(for observationClass: ObservationClass?) -> Bool {
    switch observationClass {
    case .feature(let feature):
      return allowAddFeature(feature)
    case .mission:
      if let config = survey?.config {
        if config.mission?.attributes == nil { return false }
        return trackLogging || config.tracklogs != .required
      }
      return false
    case .none:
      return false
    }
  }

  /// Updates the state of the published property featuresLocatableWithoutTouch
  /// Should be called whenever the survey, tracklogging or observing change
  private func updateFeatureLocatableWithoutTouch() {
    guard let survey = survey else {
      featuresLocatableWithoutTouch = []
      return
    }
    featuresLocatableWithoutTouch = survey.config.features.locatableWithoutMapTouch
      .filter { allowAddFeature($0) }
  }

  /// Updates the state of the published property observationsLocatableWithTouch
  /// Should be called after an AddObservationAtMapTouch event happens and
  /// before the feature selector action sheet is presented
  private func updateObservationsLocatableWithTouch() {
    guard let survey = survey else {
      observationsLocatableWithTouch = []
      return
    }
    observationsLocatableWithTouch = survey.config.features.locatableWithMapTouch
      .filter { allowAddFeature($0) }
      .map { .feature($0) }
    if allowAddMissionPropertyAtMapTouch {
      observationsLocatableWithTouch.append(.mission)
    }
  }

  /// Does the current state of trackLogging/observing and the survey configuration allow adding this feature
  private func allowAddFeature(_ feature: Feature) -> Bool {
    guard let survey = survey else { return false }
    if !trackLogging && survey.config.tracklogs == .required {
      return false
    } else {
      if observing {
        return true
      } else {
        // not observing (on transect)
        switch survey.config.transects {
        case .required:
          return false  // do not add this feature to the list
        case .none, .optional:
          return true
        case .perFeature:
          return feature.allowOffTransectObservations
        }
      }
    }
  }

  /// Does the current state of trackLogging and the survey configuration allow adding a MissionProperty with a map touch
  private var allowAddMissionPropertyAtMapTouch: Bool {
    // Typically MissionProperties are associated with a tracklog and _cannot_ be added with
    // a map touch, however if tracklogging is off and the user permits it, we can add one with
    // a map touch
    guard !trackLogging else { return false }
    guard let survey = survey else { return false }
    return survey.config.tracklogs != .required
  }

  //MARK: - Track Logging

  private var awaitingGpsAuthorizationCallback: (() -> Void)? = nil
  private var previousGpsPoint: GpsPoint? = nil
  private var savedLocations = [CLLocation]()

  func startNewMission() {
    if let context = self.survey?.viewContext {
      mission = Mission.new(in: context)
    }
    if mission == nil {
      message = Message.error("Unable to initialize survey: survey or mission undefined")
    }
  }

  func stopTrackLogging() {
    observing = false
    stopGpsStreaming()
    updateFeatureLocatableWithoutTouch()
    previousGpsPoint = nil
    mission = nil
    saveSurvey()
  }

  func startTrackLogging() {
    guard let survey = survey else {
      message = Message.error("No survey selected, or survey is corrupt.")
      return
    }
    updateFeatureLocatableWithoutTouch()
    if waitingToAuthorizeGps(callback: { self.startTrackLogging() }) { return }
    if gpsAuthorization == .denied {
      //TODO: raise alert with option to go to settings.  See Location Button
      message = Message.info("App is not authorized to obtain your location. Enable in setttings.")
      trackLogging = false
      return
    }
    startNewMission()
    startGpsStreaming()
    reObserving = false  // The next "start transect/observing" will be the first for this trackLog
    let showEditor: Bool = {
      guard let mission = survey.config.mission else {
        return false
      }
      if mission.attributes == nil { return false }
      return mission.editAtStartRecording
    }()
    addMissionPropertyAtGps(showEditor: showEditor)
  }

  //MARK: - Start/stop GPS

  private func waitingToAuthorizeGps(callback: @escaping () -> Void) -> Bool {
    if gpsAuthorization == .unknown {
      awaitingGpsAuthorizationCallback = callback
      locationManager.requestWhenInUseAuthorization()
      return true
    } else {
      awaitingGpsAuthorizationCallback = nil
      return false
    }
  }

  private func startGpsStreaming() {
    // After the location delegate gets the first acceptable point it will setupLocationManagerForStreaming()
    setupLocationManagerForImmediatePoint()
    locationManager.startUpdatingLocation()
  }

  private func stopGpsStreaming() {
    locationManager.stopUpdatingLocation()
  }

  private func requestGpsPointAsync(for observationPresenter: ObservationPresenter) {
    selectedObservation = observationPresenter
    requestGpsPointAsync()
  }

  private var indexOfGpsError: Int? = nil {
    didSet {
      if indexOfGpsError == nil {
        //TODO: message[indexOfGpsError] = nil
        message = nil
      }
    }
  }

  private var requestingImmediatePoint = false

  private var gpsTimeGap: Double {
    if requestingImmediatePoint { return 0 }
    return survey?.config.gpsInterval ?? userSettings.gpsDurationFilter
  }

  private func requestGpsPointAsync() {
    // Cycle the Location Manager to get the current location
    // Should Ignore time/distance gaps, but not accuracy requirements

    locationManager.stopUpdatingLocation()
    // After the location delegate gets the next acceptable point it will setupLocationManagerForStreaming()
    setupLocationManagerForImmediatePoint()
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.startUpdatingLocation()
  }

  private func setupLocationManagerForImmediatePoint() {
    requestingImmediatePoint = true
    locationManager.distanceFilter = kCLDistanceFilterNone
    setupLocationManager()
  }

  private func setupLocationManagerForStreaming() {
    requestingImmediatePoint = false
    setupLocationManager()
    setGpsDistanceFilter()
  }

  private func setGpsDistanceFilter() {
    if userSettings.gpsDistanceFilter > 0.0 {
      locationManager.distanceFilter = userSettings.gpsDistanceFilter
    } else {
      locationManager.distanceFilter = kCLDistanceFilterNone
    }
  }

  private func setupLocationManager() {
    locationManager.activityType = .otherNavigation
    locationManager.pausesLocationUpdatesAutomatically = false
    if userSettings.gpsAccuracyFilter > 0.0 {
      locationManager.desiredAccuracy = userSettings.gpsAccuracyFilter
    } else {
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
  }

  //MARK: - Background Locations

  func startBackgroundLocations() {
    let allowBackgroundLocations =
      trackLogging && self.enableBackgroundTrackLogging && gpsAuthorization == .background
    //NOTE: setting locationManager.allowsBackgroundLocationUpdates to true from false
    // will work without cycling the locationManager.  However the reverse is not true.
    // i.e. changing to false take effect until the the next startUpdatingLocation()
    let cycleManager =
      locationManager.allowsBackgroundLocationUpdates && !allowBackgroundLocations && trackLogging
      && gpsAuthorization == .background
    locationManager.allowsBackgroundLocationUpdates = allowBackgroundLocations
    if cycleManager {
      locationManager.stopUpdatingLocation()
      locationManager.startUpdatingLocation()
    }
  }

  func drawBackgroundLocations() {
    //print("Drawing \(savedLocations.count) locations collected in the background")
    for location in savedLocations {
      addGpsLocation(location)
    }
    savedLocations.removeAll()
  }

  //MARK:- Add GPS Point

  /// Called by the Core Location Delegate whenever a new (or updated) location is available
  /// Also called internally with cached locations collected while in the background
  /// Behavior is different in the background/foreground
  /// Background:
  ///   Simply cache the locations and return
  /// Foreground:
  ///   Location will  be saved to the database and
  ///   used to update the tracklog and totalizer (if tracklogging)
  ///   used to create an observation (oneshot - not tracklogging or as part of the tracklogging stream)
  func addGpsLocation(_ location: CLLocation) {

    //TODO: when returning to the foreground, we may get points from background cache, and new locations
    // important to process _all_ the background cache before any new location (to maintain order)

    if !trackLogging {
      // This is the result of a request for an observation, turn off updates
      stopGpsStreaming()
    }
    if isInBackground {
      //print("Obtained location \(location) in the background")
      savedLocations.append(location)
      return
    }
    guard let survey = self.survey else {
      message = Message.error("No active survey.")
      return
    }
    if mission == nil { startNewMission() }
    guard let mission = self.mission else {
      message = Message.error("No active mission.")
      return
    }
    let redundant: Bool = {
      if let oldTimestamp = previousGpsPoint?.timestamp {
        return location.timestamp == oldTimestamp
      }
      return false
    }()
    let awaitingGps = selectedObservation?.awaitingGps ?? false
    let editingContext = awaitingGps ? selectedObservation?.editContext : nil
    var gpsPoint: GpsPoint
    if redundant {
      gpsPoint = previousGpsPoint!
      // previous gps is in the wrong context if awaitingGps
      if let context = editingContext {
        gpsPoint = context.object(with: gpsPoint.objectID) as! GpsPoint
      }
    } else {
      let context = editingContext ?? survey.viewContext
      gpsPoint = GpsPoint.new(in: context)
      let missionInContext: Mission = {
        if let context = editingContext {
          return context.object(with: mission.objectID) as! Mission
        } else {
          return mission
        }
      }()
      gpsPoint.initializeWith(mission: missionInContext, location: location)
      mapView.addGpsPoint(gpsPoint)
      if let oldPoint = previousGpsPoint {
        mapView.addTrackLogSegment(from: oldPoint, to: gpsPoint, observing: observing)
      }
      totalizer?.updateLocation(location)
      self.previousGpsPoint = gpsPoint
    }
    if let context = editingContext, trackLogging {
      // This GpsPoint is part of a new (cancelable) observation _AND_ a tracklog
      // Save it to the viewContext (for the tracklog), in case the observation is canceled
      try? context.save()
    }
    if let observation = selectedObservation, observation.awaitingGps {
      observation.setGpsPoint(gpsPoint: gpsPoint)
    }
  }

  //MARK:- Add Observations

  /// Tap the Add Mission Property button or start tracklog/observing or stop observing
  /// Not all situations should show the editor (check with survey config)
  func addMissionPropertyAtGps(showEditor: Bool) {
    if waitingToAuthorizeGps(callback: { self.addMissionPropertyAtGps(showEditor: showEditor) }) {
      return
    }
    if gpsAuthorization == .denied {
      message = Message.error("App is not authorized to obtain your location. Enable in setttings.")
      return
    }
    print("Adding Mission Property at GPS")
    if mission == nil { startNewMission() }
    let observationPresenter = ObservationPresenter.create(
      survey: survey, mission: mission, observationClass: .mission,
      template: missionPropertyTemplate, observing: observing)
    //observationPresenter will create the mission property when it gets the next GPS location
    requestGpsPointAsync(for: observationPresenter)
    if showEditor {
      present(observationPresenter)
    } else {
      observationPresenter.autoAction = {
        self.closeObservationView(observationPresenter)
      }
    }
  }

  /// Tap the Add Feature Button - for locate at GPS _or_ AngleDIstance
  func addObservationAtGps(feature: Feature) {
    if waitingToAuthorizeGps(callback: { self.addObservationAtGps(feature: feature) }) { return }
    if gpsAuthorization == .denied {
      message = Message.error("App is not authorized to obtain your location. Enable in setttings.")
      return
    }
    print("Adding \(feature.name) at \(feature.allowAngleDistance ? "AngleDistance" : "GPS")")
    if mission == nil { startNewMission() }
    let observationPresenter = ObservationPresenter.create(
      survey: survey, mission: mission, observationClass: .feature(feature))
    //selectedObservation will create the observation when it gets the next GPS location
    requestGpsPointAsync(for: observationPresenter)
    present(observationPresenter)
  }

  /// Tap the map to add a feature (or mission property if not) at the map location
  func addObservation(at mapPoint: AGSPoint) {

    updateObservationsLocatableWithTouch()
    guard observationsLocatableWithTouch.count > 0 else { return }

    if waitingToAuthorizeGps(callback: { self.addObservation(at: mapPoint) }) { return }

    print("Adding observation at \(mapPoint.toCLLocationCoordinate2D())")
    if mission == nil { startNewMission() }
    let observationPresenter = ObservationPresenter.create(
      survey: survey, mission: mission, mapTouch: mapPoint, mapReference: mapReference,
      template: missionPropertyTemplate, observing: observing, gpsRequestor: requestGpsPointAsync)
    // observationPresenter will create observation after we get the next suitable GPS location
    // and the observationClass to create (may need to present selector to user)

    //Note: GPS Authorization is not required for map touch, so .denied is ok
    if gpsAuthorization == .denied {
      observationPresenter.setGpsDisabled()
    } else {
      requestGpsPointAsync(for: observationPresenter)
    }

    if observationsLocatableWithTouch.count == 1 {
      observationPresenter.setObservationClass(observationClass: observationsLocatableWithTouch[0])
      present(observationPresenter)
    } else {
      selectedObservation = observationPresenter
      showMapTouchSelectionSheet = true  //ActionSheet is in SurveyControlsView
    }
  }

  func viewDidSelectObservationClass(_ observation: ObservationClass?) {
    guard let observation = observation else {
      print("Map Touch Observation Selector Canceled")
      // selectedObservation never got an ObservationClass so it never
      // created any entities, so there is nothing to undo
      selectedObservation = nil
      return
    }
    print("Map Touch Observation Selector selected \(observation.name)")
    if let selected = selectedObservation, selected.awaitingFeature {
      selected.setObservationClass(observationClass: observation)
      present(selected)
    }
  }

  private func present(_ observationPresenter: ObservationPresenter) {
    selectedObservation = observationPresenter
    observationPresenter.autoAction = nil
    showingObservationEditor = true
    slideOutMenuVisible = true
  }

  func slideOutClosedActions() {
    showingObservationSelector = false
    showingObservationEditor = false
    if let selectedObservation = selectedObservation {
      closeObservationView(selectedObservation)
      // Do not set selectedObservation to nil (we may have represented due to a failed save)
    }
    if selectedObservation != nil {
      return  //Wait for user to resolve the errors in saving selectedObservation
    }
    if let observations = selectedObservations {
      selectedObservation = nil
      for observation in observations {
        // TODO: There is a conflict if one of the observations is waiting for a map touch
        //   and another fails to save. option 1) present save fail, when that resolves, get map
        //   touch (current resolution), problem: user may forget about the map touch.
        //   2) resolve move first, then try to save remaining observations.
        closeObservationView(observation)
        // selectedObservation will be set if the observation fails to save an is represented
        if selectedObservation != nil {
          return  //Wait for user to resolve the save error
        }
      }
      // None of observations in selectedObservations failed to save, so we are done
      selectedObservations = nil
    }
  }

  private func closeObservationView(_ selectedObservation: ObservationPresenter) {
    switch selectedObservation.closeAction {
    case .default:
      // Save not Cancel is the default action
      selectedObservation.save()
      if selectedObservation.closeAllowed {
        if case .save(let observationClass, let entity) = selectedObservation.closeAction {
          addNew(observationClass: observationClass, entity: entity)
        }
        self.selectedObservation = nil
      } else {
        present(selectedObservation)
      }
      break
    case .move:
      self.movingObservation = selectedObservation
      message = .info("Tap on the map at the new location for the observation")
      // TODO: Can I set up a modal to prevent any other events?
      movingGraphic = true
      self.selectedObservation = nil
    case .save(let observationClass, let entity):
      addNew(observationClass: observationClass, entity: entity)
      self.selectedObservation = nil
      break
    default:  //.cancel, .delete
      self.selectedObservation = nil
      break
    }
  }

  func moveGraphic(to mapPoint: AGSPoint) {
    do {
      try movingObservation?.moveGraphic(to: mapPoint)
      message = nil
    } catch {
      message = .error(error.localizedDescription)
    }
    movingObservation = nil
    movingGraphic = false
  }

  private func addNew(observationClass: ObservationClass?, entity: NSObject?) {
    switch observationClass {
    case .mission:
      if let missionProperty = entity as? MissionProperty {
        addNew(missionProperty: missionProperty)
      }
      break
    case .feature(let feature):
      if let observation = entity as? Observation {
        addNew(observation: observation, feature: feature)
      }
      break
    case .none:
      break
    }
  }

  private func addNew(missionProperty: MissionProperty) {
    let _ = mapView.addMissionProperty(missionProperty, config: survey?.config.mission)
    // missionProperty is in the edit context which will disappear soon
    // get the same object in the permanent viewContext
    if let context = survey?.viewContext {
      let id = missionProperty.objectID
      self.missionPropertyTemplate = context.object(with: id) as? MissionProperty
    }
    // Update the totalizer, but save first so that the background tracklogs are complete
    try? survey?.save()
    totalizer?.updateProperties(missionProperty)
  }

  private func addNew(observation: Observation, feature: Feature) {
    //TODO: Simplify mapview feature graphic creation (remove index)
    if let index = survey?.config.features.firstIndex(where: { $0.name == feature.name }) {
      let _ = mapView.addFeature(observation, feature: feature, index: index)
    }
  }

  //MARK: - Attribute Form Support

  func observationPresenter(for graphic: AGSGraphic) -> ObservationPresenter {
    let op = ObservationPresenter.show(
      survey: survey, graphic: graphic, gpsRequestor: requestGpsPointAsync)
    op.isEditing = isEditingEnabled(for: graphic.asObservationClass(in: survey))
    return op
  }

}

//TODO: Move to a separate file

//MARK: - Totalizer Support

extension SurveyController {

  func initializeTotalizer() {
    totalizer = nil
    if let config = survey?.config, let definition = config.mission?.totalizer,
      config.tracklogs != .none
    {
      totalizer = Totalizer(definition: definition)
    }
  }

  func startTotalizer() {
    if let totalizer = totalizer {
      totalizer.start(with: missionPropertyTemplate)
      isShowingTotalizer = userSettings.showTotalizer
    }
  }

  func stopTotalizer() {
    totalizer?.stop()
    isShowingTotalizer = false
  }
}

//MARK: - Banner support

extension SurveyController {
  var hasInfoBannerDefinition: Bool {
    survey?.config.observingMessage != nil || survey?.config.notObservingMessage != nil
  }

  func updateInfoBanner() {
    infoBannerText = {
      if observing {
        return survey?.config.observingMessage ?? ""
      } else {
        if trackLogging {
          return survey?.config.notObservingMessage ?? ""
        } else {
          return ""
        }
      }
    }()
    isShowingInfoBanner = userSettings.showInfoBanner && !infoBannerText.isEmpty
  }
}

//MARK: - Map Loading

extension SurveyController {

  private func getLocalTileCache(for name: String) -> AGSMap? {
    // The tile package needs to exist in the document directory of the device or simulator
    // For a device use iTunes File Sharing (enable in the info.plist)
    // For the simulator - breakpoint on the next line, to see what the path is
    // This function does no I/O, so the name is not checked until mapView tries to load the map.
    let url = AppFile(type: .map, name: name).url
    let cache = AGSTileCache(fileURL: url)
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

extension SurveyController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    indexOfGpsError = 0
    message = Message.warning(error.localizedDescription)
    //TODO: indexOfGpsError = Message.count
    //message[indexOfGpsError] = Message.warning(error.localizedDescription)
  }

  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    //print("Location Manager Did Change Authorization to: \(status.description)")
    switch status {
    case .notDetermined:
      gpsAuthorization = .unknown
      break
    case .authorizedAlways:
      gpsAuthorization = .background
      break
    case .authorizedWhenInUse:
      gpsAuthorization = .foreground
      self.enableBackgroundTrackLogging = false
      break
    default:
      gpsAuthorization = .denied
      self.enableBackgroundTrackLogging = false
      trackLogging = false
      break
    }
    if let callback = awaitingGpsAuthorizationCallback {
      awaitingGpsAuthorizationCallback = nil
      // Call the method waiting for authorization
      callback()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for location in locations {
      guard location.horizontalAccuracy > 0.0 else {
        indexOfGpsError = 0
        message = Message.warning("GPS error: location unavailable")
        break
      }
      if userSettings.gpsAccuracyFilter > 0.0 {
        if userSettings.gpsAccuracyFilter < location.horizontalAccuracy {
          indexOfGpsError = 0
          let error = String(format: "±%0.2f", location.horizontalAccuracy)
          message = Message.warning("GPS error (\(error) m) too large")
          break
        }
      }
      let age = location.timestamp.distance(to: Date())
      guard age < 1.0 else {
        //print("  Skipping stale location. Age: \(age)")
        break
      }
      if let lastTimestamp = previousGpsPoint?.timestamp {
        let interval = lastTimestamp.distance(to: location.timestamp)
        if interval < gpsTimeGap {
          //print("  Skipping location (too new): \(interval) < \(gpsTimeGap)")
          break
        }
      }
      // Clear any GPS errors
      indexOfGpsError = nil
      addGpsLocation(location)
      if requestingImmediatePoint {
        setupLocationManagerForStreaming()
      }
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
