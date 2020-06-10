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

//class SurveyController: NSObject, ObservableObject, CLLocationManagerDelegate, AGSGeoViewTouchDelegate {
class SurveyController: ObservableObject {

  let mapView = AGSMapView()
  var surveyName: String? = nil
  var mapName: String? = nil

  private var survey: Survey? = nil

  func drawSurvey(name: String?) {
    guard let name = name ?? surveyName ?? Defaults.surveyName.readString() else {
      print("Error in SurveyController.drawSurvey(): No survey given")
      return
    }
    Survey.load(name) { (result) in
      switch result {
      case .success(let survey):
        print("survey loaded")
        self.surveyName = name
        self.survey = survey
        self.mapView.draw(survey)
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

  func startForegroundLocations() {
    //TODO: Update the UI with CoreLocation Updates received while in the background
  }

}


//TODO: Move to a separate file
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
    let name = "GpsPoints"
    let overlay = AGSGraphicsOverlay()
    overlay.overlayID = name
    overlay.renderer = survey.config.mission?.gpsSymbology
    if let gpsPoints = try? survey.viewContext.fetch(GpsPoints.allOrderByTime) {
      overlay.graphics.addObjects(from: gpsPoints.compactMap { gpsPoint in
        guard let location = gpsPoint.location else { return nil }
        let agsPoint = AGSPoint(clLocationCoordinate2D: location)
        //TODO: add attributes?
        return AGSGraphic(geometry: agsPoint, symbol: nil, attributes: nil)
      })
    }
    self.graphicsOverlays.add(overlay)
  }

  func drawTrackLogs(_ survey: Survey) {

  }

  func drawMissionProperties(_ survey: Survey) {

  }

  func drawFeatures(_ survey: Survey) {

  }

}
