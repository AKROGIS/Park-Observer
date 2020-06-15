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

class SurveyController: NSObject, ObservableObject, CLLocationManagerDelegate, AGSGeoViewTouchDelegate {

  let mapView: AGSMapView
  var surveyName: String? = nil
  var mapName: String? = nil

  // I'm not sure this controller should own these other controllers, but it works
  // better than the other options (owned by various views or SceneDelegate).
  // It also simplifies the SceneDelegate, the View environment, and the Views.
  let locationButtonController: LocationButtonController
  let viewPointController: ViewPointController

  private var survey: Survey? = nil

  override init() {
    self.mapView = AGSMapView()
    locationButtonController = LocationButtonController(mapView: self.mapView)
    viewPointController = ViewPointController(mapView: self.mapView)
    super.init()
  }

  func loadMap(name: String? = nil) {
    let defaultMap = Defaults.mapName.readString()
    guard let name = name ?? mapName ?? defaultMap else {
      print("SurveyController.mapName(name:): No name given")
      // MapView will be empty; user can now choose a map to display
      return
    }
    NSLog("Start load map \(name)")
    if name.starts(with: "esri.") {
      loadEsriBasemap(name)
    } else {
      loadLocalTileCache(name)
    }
    mapView.map?.load(completion: { error in
      NSLog("Finish load map")
      if let error = error {
        print(error)
      } else {
        if name == defaultMap {
          self.viewPointController.restoreState()
        }
        // location tracking should take precedence over the previous extents.
        self.locationButtonController.restoreState()
        self.mapName = name
      }
    })
  }

  func loadSurvey(name: String? = nil) {
    guard let name = name ?? surveyName ?? Defaults.surveyName.readString() else {
      print("SurveyController.drawSurvey(name:): No name given")
      // No Survey; user can now choose a survey to display/edit
      return
    }
    NSLog("Start load survey \(name)")
    Survey.load(name) { (result) in
      NSLog("Finish load survey")
      switch result {
      case .success(let survey):
        print("survey loaded")
        self.surveyName = name
        self.survey = survey
        NSLog("Start draw survey")
        // TODO: This can take several seconds for a large survey; Do async
        self.mapView.draw(survey)
        NSLog("Finish draw survey")
        break
      case .failure(let error):
        print("Error in Survey.load(): \(error)")
        break
      }
    }
  }

  func startBackgroundLocations() {
    //TODO: Stop updating the UI with CoreLocation Updates,
    // If the survey collects background locations, save them for return to foreground
  }

  func drawBackgroundLocations() {
    //TODO: Update the UI with CoreLocation Updates received while in the background
  }

  func saveState() {
    // To be called when the app goes into the background
    // If the app is terminated this state can be restored when the app relaunches.
    print("Saving mapName: \(mapName ?? "<nil>")")
    Defaults.mapName.write(mapName)
    print("Saving surveyName: \(surveyName ?? "<nil>")")
    Defaults.surveyName.write(surveyName)
    locationButtonController.saveState()
    viewPointController.saveState()
  }

}

//MARK: - Survey Drawing

//TODO: Move to a separate file
extension String {
  static let layerNameGpsPoints = "GpsPoints"
  static let layerNameMissionProperties = "MissionProperties"
  static let layerNameTrackLogs = "TrackLogs"
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
    let overlay = AGSGraphicsOverlay()
    overlay.overlayID = .layerNameGpsPoints
    overlay.renderer = survey.config.mission?.gpsSymbology
    if let gpsPoints = try? survey.viewContext.fetch(GpsPoints.allOrderByTime) {
      overlay.graphics.addObjects(
        from: gpsPoints.compactMap { gpsPoint in
          guard let location = gpsPoint.location else { return nil }
          let agsPoint = AGSPoint(clLocationCoordinate2D: location)
          //TODO: add attributes?
          return AGSGraphic(geometry: agsPoint, symbol: nil, attributes: nil)
        })
    }
    self.graphicsOverlays.add(overlay)
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
      if let observations = try? survey.viewContext.fetch(Observations.fetchAll(for: feature.name))
      {
        overlay.graphics.addObjects(
          from: observations.compactMap { observation in
            guard let location = observation.locationOfFeature else { return nil }
            let agsPoint = AGSPoint(clLocationCoordinate2D: location)
            //TODO: add attributes?
            return AGSGraphic(geometry: agsPoint, symbol: nil, attributes: nil)
          })
      }
      self.graphicsOverlays.add(overlay)
    }
  }
}

//TODO: Move to a separate file

//MARK: - Map Loading

extension SurveyController {

  private func loadLocalTileCache(_ name: String) {
    // The tile package needs to exist in the document directory of the device or simulator
    // For a device use iTunes File Sharing (enable in the info.plist)
    // For the simulator - breakpoint on the next line, to see what the path is
    // This function does no I/O, so the name is not checked until mapView tries to load the map.
    let path = FileManager.default.mapURL(with: name)
    let cache = AGSTileCache(fileURL: path)
    let layer = AGSArcGISTiledLayer(tileCache: cache)
    let basemap = AGSBasemap(baseLayer: layer)
    mapView.map = AGSMap(basemap: basemap)
  }

  static let esriBasemaps: [String: () -> AGSBasemap] = [
    "esri.DarkGrayCanvasVector": AGSBasemap.darkGrayCanvasVector,
    "esri.Imagery": AGSBasemap.imagery,
    "esri.ImageryWithLabels": AGSBasemap.imageryWithLabels,
    "esri.ImageryWithLabelsVector": AGSBasemap.imageryWithLabelsVector,
    "esri.LightGrayCanvas": AGSBasemap.lightGrayCanvas,
    "esri.LightGrayCanvasVector": AGSBasemap.lightGrayCanvasVector,
    "esri.NationalGeographic": AGSBasemap.nationalGeographic,
    "esri.NavigationVector": AGSBasemap.navigationVector,
    "esri.Oceans": AGSBasemap.oceans,
    "esri.OpenStreetMap": AGSBasemap.openStreetMap,
    "esri.Streets": AGSBasemap.streets,
    "esri.StreetsNightVector": AGSBasemap.streetsNightVector,
    "esri.StreetsVector": AGSBasemap.streetsVector,
    "esri.StreetsWithReliefVector": AGSBasemap.streetsWithReliefVector,
    "esri.TerrainWithLabels": AGSBasemap.terrainWithLabels,
    "esri.TerrainWithLabelsVector": AGSBasemap.terrainWithLabelsVector,
    "esri.Topographic": AGSBasemap.topographic,
    "esri.TopographicVector": AGSBasemap.topographicVector,
  ]

  private func loadEsriBasemap(_ name: String) {
    if let basemap = SurveyController.esriBasemaps[name] {
      mapView.map = AGSMap(basemap: basemap())
    }
  }

}
