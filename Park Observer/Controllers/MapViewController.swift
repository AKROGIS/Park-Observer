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

  weak var mapView: AGSMapView?
  var locationDisplayOn: Bool = false
  @Published var map = AGSMap()

  func displayLocation(for mapView: AGSMapView) {
    self.mapView = mapView
    mapView.locationDisplay.start { error in
      if let error = error {
        // No need to alert; failure is due to user choosing to disallow location services
        print("Error starting ArcGIS location services: \(error.localizedDescription)")
      }
      self.locationDisplayOn = mapView.locationDisplay.started
    }
  }

  // TODO: Set up a delegate to monitor changes in location authorization

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
