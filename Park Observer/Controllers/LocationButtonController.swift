//
//  LocationButtonController.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/14/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import CoreLocation
import Foundation

class LocationButtonController: ObservableObject {

  // We need this UIView to observe for changes, and set it's state
  //   Observing: .locationDisplay.started/autoPanMode
  //   Setting: .locationDisplay.start/stop/autoPanMode
  // Without it we can't do much, and remain in a default state
  weak var mapView: AGSMapView? {
    didSet { hookupMapView() }
  }

  // "Readonly" in LocationButtonView
  @Published var authorized: Authorized = .unknown {
    didSet {
      if oldValue != authorized {
        if authorized == .no {
          showLocation = false
        }
      }
    }
  }

  // "Readonly" in LocationButtonView
  @Published var autoPanMode: AGSLocationDisplayAutoPanMode = .off {
    didSet {
      print("Set autoPanMode")
      if oldValue != autoPanMode {
        Defaults.mapAutoPanMode.write(autoPanMode)
        mapView?.locationDisplay.autoPanMode = autoPanMode
      }
    }
  }

  // "Readonly" in LocationButtonView
  @Published var showLocation: Bool = false {
    didSet {
      print("Set showLocation")
      if oldValue != showLocation {
        print("Changed showLocation")
        Defaults.mapLocationDisplay.write(showLocation)
        if showLocation {
          mapView?.locationDisplay.start()
        } else {
          mapView?.locationDisplay.stop()
        }
      }
    }
  }

  private var locationDelegate = LocationManagerDelegate()
  private var locationManager = CLLocationManager()
  private var previousPanMode: AGSLocationDisplayAutoPanMode? = nil

  private func hookupMapView() {
    guard let mapView = mapView else {
      print("Error: mapView was set to nil; Can't hook it up to the controller")
      return
    }
    locationDelegate.controller = self
    locationManager.delegate = locationDelegate
    showLocation = Defaults.mapLocationDisplay.readBool()
    autoPanMode = Defaults.mapAutoPanMode.readMapAutoPanMode()
    // checkLocationStatus after getting defaults; to avoid inapropriate defaults for auth level
    authorized = Authorized(from: CLLocationManager.authorizationStatus())
    observeAutoPanMode(from: mapView)
  }

  private func observeAutoPanMode(from mapView: AGSMapView) {
    mapView.locationDisplay.autoPanModeChangedHandler = { autoPanMode in
      if autoPanMode != self.autoPanMode {
        if self.autoPanMode == .navigation || self.autoPanMode == .compassNavigation {
          self.previousPanMode = self.autoPanMode
        }
        self.autoPanMode = autoPanMode
      }
    }
  }

  func toggle() {
    print("Toggled button")
    if authorized == .no {
      // Button should do nothing (but show alert) if not authorized
      print("Specifically not authorized")
      return
    }
    if authorized == .unknown {
      print("Authorized status is unknown")
      locationManager.requestWhenInUseAuthorization()
    }
    if !showLocation {
      showLocation = true
    } else {
      switch autoPanMode {
      case .off:
        if let previousPanMode = previousPanMode {
          autoPanMode = previousPanMode
          self.previousPanMode = nil
        } else {
          autoPanMode = .recenter
        }
        break
      case .recenter:
        autoPanMode = .navigation
        break
      case .navigation:
        autoPanMode = .compassNavigation
        break
      case .compassNavigation:
        autoPanMode = .off
        showLocation = false
        break
      @unknown default:
        print("Error: Unexpected enum value in AGSLocationDisplayAutoPanMode")
      }
    }
  }

  private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    weak var controller: LocationButtonController? = nil

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Location Button Location Manager didFailWithError: \(error.localizedDescription)")
      if let error = error as? CLError {
        if error.code == .denied {
          controller?.authorized = .no
        }
      }
    }

    func locationManager(
      _ manager: CLLocationManager,
      didChangeAuthorization status: CLAuthorizationStatus
    ) {
      print("Location Button Location Manager didChangeAuthorization Status \(status.rawValue)")
      controller?.authorized = Authorized(from: status)
    }
  }

}

enum Authorized {
  case yes
  case no
  case unknown
}

extension Authorized {
  init(from status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      self = .yes
    case .denied, .restricted:
      self = .no
    default:
      self = .unknown
    }
  }
}
