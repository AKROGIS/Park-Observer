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
  }

  @Published var rotation = 0.0

  func hookupMapView() {
    guard let mapView = mapView else {
      print("Error: mapView was set to nil; Cant hook it up to the controller")
      return
    }
    loadDefaultMap()
    startLocationDisplay()
    startObserving(mapView)
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

  func loadDefaultMap() {
    // You need to copy the tile package in the document directory of the device or simulator
    // For a device use iTunes File Sharing (enable in the info.plist)
    // For the simulator - breakpoint on the next line, to see what the path is
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let url = paths[0]
    let path = url.appendingPathComponent("Anchorage18.tpk")
    let cache = AGSTileCache(fileURL: path)
    let layer = AGSArcGISTiledLayer(tileCache: cache)
    let basemap = AGSBasemap(baseLayer: layer)
    map = AGSMap(basemap: basemap)
  }

}
