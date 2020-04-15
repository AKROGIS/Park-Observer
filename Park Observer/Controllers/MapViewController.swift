//
//  MapViewController.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/6/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import Foundation

class MapViewController: ObservableObject {

  weak var mapView: AGSMapView? {
    didSet { hookupMapView() }
  }

  @Published var map = AGSMap()
  @Published var locationAuthorized: Bool? = nil

  @Published var locationButtonState: LocationButtonState = .off {
    willSet(newState) {
      // Note: for LocationButtonState .on(x) == .on(y) is true
      if locationButtonState == .off && newState == .on(.off) {
        startLocationDisplay()
      }
    }
    didSet {
      Defaults.mapLocationDisplay.write(locationButtonState != .off)
      switch locationButtonState {
      case .on(let autoPanMode):
        Defaults.mapAutoPanMode.write(autoPanMode)
        break
      default:
        break
      }
    }
  }

  @Published var rotation = 0.0 {
    didSet {
      if oldValue != rotation {
        print("Saving new rotation: \(rotation)")
        Defaults.mapRotation.write(rotation)
      }
    }
  }

  func hookupMapView() {
    guard let mapView = mapView else {
      print("Error: mapView was set to nil; Cant hook it up to the controller")
      return
    }
    setDefaultMap()
    setDefaultViewport(in: mapView) {
      // Call this after the viewport animations are done. Otherwise the animations
      // may nullify the user's autoPanning preference from the default settings.
      self.startLocationDisplay()
    }
    startObserving(mapView)
  }

  func setDefaultViewport(in mapView: AGSMapView, completion: @escaping () -> Void) {
    let latitude = Defaults.mapCenterLat.readDouble()
    let longitude = Defaults.mapCenterLon.readDouble()
    let scale = Defaults.mapScale.readDouble()
    let rotation = Defaults.mapRotation.readDouble()
    print("Restoring rotation to \(rotation)")
    print("Restoring scale to \(scale)")
    var rotationIsAnimating = false
    var recenterIsAnimating = false
    if scale == 0 && rotation == 0 {
      completion()
      return
    }
    if scale != 0 {
      let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      let center = AGSPoint(clLocationCoordinate2D: location)
      recenterIsAnimating = true
      mapView.setViewpointCenter(center, scale: scale) { _ in
        recenterIsAnimating = false
        if !rotationIsAnimating {
          completion()
        }
      }
    }
    if rotation != 0 {
      rotationIsAnimating = true
      mapView.setViewpointRotation(rotation) { _ in
        rotationIsAnimating = false
        if !recenterIsAnimating {
          completion()
        }
      }
    }
  }

  func startLocationDisplay() {
    guard let mapView = self.mapView else {
      locationAuthorized = nil
      locationButtonState = .off
      return
    }
    if mapView.locationDisplay.started {
      return
    }
    mapView.locationDisplay.start { error in
      if let error = error {
        // No need to alert; failure is due to user choosing to disallow location services
        print("Error starting ArcGIS location services: \(error.localizedDescription)")
        self.locationAuthorized = nil
      }
      if mapView.locationDisplay.started {
        self.locationAuthorized = true
        self.locationButtonState = .on(mapView.locationDisplay.autoPanMode)
      } else {
        self.locationAuthorized = false
        self.locationButtonState = .off
      }
    }
  }

  // TODO: Set up a delegate to monitor changes in location authorization

  func startObserving(_ mapView: AGSMapView) {
    observeAutoPanMode(from: mapView)
    observeRotation(from: mapView)
    //TODO: Observe viewport changes
  }

  private func observeAutoPanMode(from mapView: AGSMapView) {
    // The autoPanModeChangedHandler is not called when the mapView owner sets the property.
    // The mapView will call this when the map is panned, rotated or zoomed.
    mapView.locationDisplay.autoPanModeChangedHandler = { autoPanMode in
      // Important: We do not know when it will be called.
      // Needed to postpone modifying view state until view is done updating.
      DispatchQueue.main.async {
        if mapView.locationDisplay.started {
          self.locationButtonState = .on(autoPanMode)
        } else {
          self.locationButtonState = .off
        }
      }
    }
  }

  // Important!  If we do not retain the KeyValueObserver, it will be immediately disposed.
  // This also means we do not need to dispose of it, as it will automatically happen.
  private var rotationObservation: NSKeyValueObservation?

  private func observeRotation(from mapView: AGSMapView) {
    rotationObservation = mapView.observe(\.rotation, options: .new) { [weak self] (_, change) in
      guard let rotation = change.newValue else {
        return
      }
      DispatchQueue.main.async {
        self?.rotation = rotation
      }
    }
  }

  //MARK: - Map Loading

  func setDefaultMap() {
    if let name = Defaults.mapName.readString() {
      loadMap(name: "Anchorage18.tpk")
      //loadMap(name: name)
    } else {
      loadMap(name: "esri.Imagery")
    }
  }

  func loadMap(name: String) {
    Defaults.mapName.write(name)
    if name.starts(with: "esri.") {
      loadEsriBasemap(name)
    } else {
      loadLocalTileCache(name)
    }
  }

  private func loadLocalTileCache(_ name: String) {
    // The tile package needs to exist in the document directory of the device or simulator
    // For a device use iTunes File Sharing (enable in the info.plist)
    // For the simulator - breakpoint on the next line, to see what the path is
    // This function does no I/O, so the name is not checked until mapView tries to load the map.
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let url = paths[0]
    let path = url.appendingPathComponent(name)
    let cache = AGSTileCache(fileURL: path)
    let layer = AGSArcGISTiledLayer(tileCache: cache)
    let basemap = AGSBasemap(baseLayer: layer)
    map = AGSMap(basemap: basemap)
  }

  let esriBasemaps: [String: () -> AGSBasemap] = [
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
    if let basemap = esriBasemaps[name] {
      map = AGSMap(basemap: basemap())
    }
  }

}
