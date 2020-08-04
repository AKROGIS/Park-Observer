//
//  SurveyController+MapViewDrawing.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/29/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS  // for AGSGraphic, AGSPoint, AGSMapView, AGSRenderer, AGSGraphicsOverlay, AGSPolyline

/// Well known layer names
extension String {
  static let layerNameGpsPoints = "GpsPoints"
  static let layerNameMissionProperties = "Mission Properties"
  //TODO: Use a single Tracklogs layer
  static let layerNameTrackLogsOn = "TrackLogsOn"
  static let layerNameTrackLogsOff = "TrackLogsOff"
}

/// Keys for values in the graphic attributes
extension String {
  // Strings must avoid conflicts with user attributes and
  static let attributeKeyTimestamp = "_timestamp_"  // Avoid conflicts with user attributes
  static let attributeKeyObserving = "observing"  // Needs to match renderer definition
}

extension GpsPoint {

  var asGraphic: AGSGraphic? {
    guard let location = self.location else {
      return nil
    }
    let agsPoint = AGSPoint(clLocationCoordinate2D: location)
    //TODO: if renderer is unique value or class break, then include rendering fields in attributes
    return AGSGraphic(geometry: agsPoint, symbol: nil, attributes: nil)
  }

}

extension MissionProperty {

  func asGraphic(for config: ProtocolMission?) -> AGSGraphic? {
    // Use the timestamp to lookup the MissionProperty on any thread
    guard let location = self.location else {
      print("Cannot draw graphic; MissionProperty has no location")
      return nil
    }
    let agsPoint = AGSPoint(clLocationCoordinate2D: location)
    var attributes = self.attributes(for: config)
    if let timestamp = self.timestamp {
      attributes[.attributeKeyTimestamp] = timestamp
    }
    return AGSGraphic(geometry: agsPoint, symbol: nil, attributes: attributes)
  }

}

extension Observation {

  func asGraphic(for feature: Feature) -> AGSGraphic? {
    // Use the timestamp to lookup the MissionProperty on any thread
    guard let location = self.locationOfFeature else {
      print("Cannot draw graphic; Observation has no location")
      return nil
    }
    let agsPoint = AGSPoint(clLocationCoordinate2D: location)
    var attributes = self.attributes(for: feature)
    if let timestamp = self.timestamp {
      attributes[.attributeKeyTimestamp] = timestamp
    }
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
    return missionProperties.compactMap { $0.asGraphic(for: self.config.mission) }
  }

  func featureGraphics(for feature: Feature) -> [AGSGraphic] {
    guard let features = try? self.viewContext.fetch(Observations.fetchAll(for: feature))
    else {
      return []
    }
    return features.compactMap { $0.asGraphic(for: feature) }
  }

}

extension AGSMapView {

  func draw(_ survey: Survey, zoomToExtents: Bool = true) {
    self.removeLayers()
    self.addLayers(for: survey)
    //self.addGpsPoints(from: survey)
    self.addTrackLogs(from: survey)
    self.addMissionProperties(from: survey)
    self.addFeatures(from: survey)
    if zoomToExtents {
      self.zoomToOverlayExtents()
    }
  }

  func removeLayers() {
    self.graphicsOverlays.removeAllObjects()
  }

  //IMPORTANT - Keep layer indices consistent with the order they are added to mapView!
  // The mapView owns the layers, but I need to access them by content/function
  // There is a overlayID I can set on each layer, but that would require searching
  // the layer list everytime I added a graphic.  Because I control the order that
  // layers are added to the map, so I can hard code the layer index for fast access.

  func addLayers(for survey: Survey) {
    let missionRenderers: [(String, AGSRenderer?)] = [
      (.layerNameGpsPoints, survey.config.mission?.gpsSymbology),
      // TODO: Use one layer with a Unique Value Renderer
      (.layerNameTrackLogsOn, survey.config.mission?.onSymbology),
      (.layerNameTrackLogsOff, survey.config.mission?.offSymbology),
      (.layerNameMissionProperties, survey.config.mission?.symbology),
    ]
    let featureRenderers: [(String, AGSRenderer?)] = survey.config.features.map {
      ($0.name, $0.symbology)
    }
    for (id, renderer) in missionRenderers + featureRenderers {
      let overlay = AGSGraphicsOverlay()
      overlay.overlayID = id
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

  func addMissionProperty(_ missionProperty: MissionProperty, config: ProtocolMission?)
    -> AGSGraphic?
  {
    guard let graphic = missionProperty.asGraphic(for: config) else {
      return nil
    }
    let overlay = self.missionPropertyOverlay
    overlay.graphics.add(graphic)
    return graphic
  }

  func addMissionProperties(from survey: Survey) {
    let overlay = self.missionPropertyOverlay
    overlay.graphics.addObjects(from: survey.missionPropertyGraphics)
  }

  func addTrackLogSegment(from point1: GpsPoint, to point2: GpsPoint, observing: Bool) {
    guard let location1 = point1.location, let location2 = point2.location else {
      return
    }
    let agsPoint1 = AGSPoint(clLocationCoordinate2D: location1)
    let agsPoint2 = AGSPoint(clLocationCoordinate2D: location2)
    let polyline = AGSPolyline(points: [agsPoint1, agsPoint2])
    var attributes = [String: Any]()
    attributes[.attributeKeyObserving] = observing
    //TODO: if renderer is unique value or class break, then include rendering fields in attributes
    let graphic = AGSGraphic(geometry: polyline, symbol: nil, attributes: attributes)
    let overlay = observing ? self.observingOverlay : self.notObservingOverlay
    overlay.graphics.add(graphic)
  }

  func addTrackLogs(from survey: Survey) {
    let overlayOn = self.observingOverlay
    let overlayOff = self.notObservingOverlay
    if let trackLogs = try? TrackLogs.fetchAll(context: survey.viewContext) {
      for trackLog in trackLogs {
        if let polyline = trackLog.polyline {
          var attributes = [String: Any]()
          if let observing = trackLog.properties.observing {
            attributes[.attributeKeyObserving] = observing
          }
          //TODO: if renderer is unique value or class break, then include rendering fields in attributes
          let graphic = AGSGraphic(geometry: polyline, symbol: nil, attributes: attributes)
          if let observing = trackLog.properties.observing, observing {
            overlayOn.graphics.add(graphic)
          } else {
            overlayOff.graphics.add(graphic)
          }
        }
      }
    }
  }

  func addFeature(_ observation: Observation, feature: Feature, index: Int) -> AGSGraphic? {
    guard let graphic = observation.asGraphic(for: feature) else {
      return nil
    }
    let overlay = self.featureOverlay(at: index)
    overlay.graphics.add(graphic)
    return graphic
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

  func zoomToOverlayExtents() {
    let envelopes = self.graphicsOverlays.compactMap {
      return ($0 as? AGSGraphicsOverlay)?.extent
    }
    guard envelopes.count > 0 else { return }
    guard let union = AGSGeometryEngine.unionGeometries(envelopes) else { return }
    self.setViewpointGeometry(union, padding: 44.0, completion: nil)
  }

}
