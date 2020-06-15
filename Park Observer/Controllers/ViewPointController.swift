//
//  ViewPointController.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/6/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// This class is responsible publishing the mapView's viewport state, and updating the
/// mapview when the state changes.
/// The AGSMapView is a UIView, not a swiftUI view, it does not subscribe to @Published,
/// nor does it provide Observable properties.  This class provides the glue between SwiftUI
/// views that want to bind to the AGSMapView viewport properties (rotation, scale, centerpoint)

import ArcGIS  // For AGSMapView, AGSPoint, AGSViewpoint
import CoreLocation  // For CLLocationCoordinate2D
import Foundation  // For ObservableObject, @Published, DispatchQueue, DispatchTimeInterval

class ViewPointController: ObservableObject {

  let mapView: AGSMapView

  @Published var rotation = 0.0 {
    didSet {
      // Do not update the mapView if it is providing the new rotation value
      if !updateFromMapView {
        mapView.setViewpointRotation(rotation, completion: nil)
      }
    }
  }

  @Published var scale = 0.0 {
    didSet {
      // Do not update the mapView if it is providing the new scale value
      if !updateFromMapView {
        mapView.setViewpointScale(scale, completion: nil)
      }
    }
  }

  @Published var center = CLLocationCoordinate2D() {
    didSet {
      // Do not update the mapView if it is providing the new center point value
      if !updateFromMapView {
        let centerPoint = AGSPoint(clLocationCoordinate2D: center)
        mapView.setViewpointCenter(centerPoint, completion: nil)
      }
    }
  }

  init(mapView: AGSMapView) {
    self.mapView = mapView
    hookupMapView()
  }

  private var updateFromMapView = false

  func restoreState() {
    // I pretend these updates are coming from the mapView, because I will update the mapView
    // in one call at the end, instead of updating with each property change
    updateFromMapView = true
    rotation = Defaults.mapRotation.readDouble()
    scale = Defaults.mapScale.readDouble()
    let latitude = Defaults.mapCenterLat.readDouble()
    let longitude = Defaults.mapCenterLon.readDouble()
    center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let centerPoint = AGSPoint(clLocationCoordinate2D: center)
    mapView.setViewpoint(AGSViewpoint(center: centerPoint, scale: scale, rotation: rotation))
    updateFromMapView = false
  }

  func saveState() {
    Defaults.mapRotation.write(rotation)
    Defaults.mapScale.write(scale)
    Defaults.mapCenterLat.write(center.latitude)
    Defaults.mapCenterLon.write(center.longitude)
  }

  func hookupMapView() {
    observeViewPoint(mapView)
  }

  //MARK: - Map Observing

  private func observeViewPoint(_ mapView: AGSMapView) {
    // We want the rotation as often as possible for a smooth compass display,
    // We do not need the scale and center as frequently
    let updateCoalescer = Coalescer(
      dispatchQueue: DispatchQueue.main,
      interval: DispatchTimeInterval.milliseconds(500)
    ) {
      self.updateFromMapView = true
      self.scale = mapView.mapScale
      let viewpoint = mapView.currentViewpoint(with: .centerAndScale)
      let point = viewpoint?.targetGeometry as? AGSPoint
      if let center = point?.toCLLocationCoordinate2D() {
        self.center = center
      }
      self.updateFromMapView = false
    }
    mapView.viewpointChangedHandler = {
      updateCoalescer.ping()
      DispatchQueue.main.async {
        self.updateFromMapView = true
        self.rotation = self.mapView.rotation
        self.updateFromMapView = false
      }
    }
  }

}
