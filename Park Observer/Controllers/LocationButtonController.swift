//
//  LocationButtonController.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/14/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// This class is responsible for controlling a LocationButtonView.
/// It provides observable state and callbacks to a LocationButtonView.  This view provides a control
/// button (and feedback) on the state of the "show my GPS location" feature of the mapView.
/// This controller maintains a weak reference to an AGSMapView instance which it monitors and modifies.
/// This class should be created and owned by the owner of the LocationButtonView and passed as
/// as a parameter to the LocationButtonView.

import ArcGIS
import CoreLocation
import Foundation

class LocationButtonController: ObservableObject {

  // We need this UIView to observe for changes, and set it's state
  //   Observing: .locationDisplay.started/autoPanMode
  //   Setting: .locationDisplay.start/stop/autoPanMode
  let mapView: AGSMapView

  init(mapView: AGSMapView) {
    self.mapView = mapView
    hookupMapView()
  }

  // "Readonly" in LocationButtonView
  @Published var authorized: Authorized = .unknown {
    didSet {
      if oldValue != authorized {
        print("Changed authorized to \(authorized)")
        if authorized == .no {
          showLocation = false
        }
      }
    }
  }

  // "Readonly" in LocationButtonView
  @Published var autoPanMode: AGSLocationDisplayAutoPanMode = .off {
    didSet {
      if oldValue != autoPanMode {
        print("Changed autoPanMode to \(autoPanMode.rawValue)")
        mapView.locationDisplay.autoPanMode = autoPanMode
      }
    }
  }

  // "Readonly" in LocationButtonView
  @Published var showLocation: Bool = false {
    didSet {
      if oldValue != showLocation {
        print("Changed showLocation to \(showLocation)")
        if showLocation {
          mapView.locationDisplay.start()
        } else {
          mapView.locationDisplay.stop()
        }
      }
    }
  }

  func restoreState() {
    print("Restoring showLocation")
    showLocation = Defaults.mapLocationDisplay.readBool()
    print("Restoring autoPanMode")
    autoPanMode = Defaults.mapAutoPanMode.readMapAutoPanMode()
    print("Restoring authorized")
    authorized = Authorized(from: CLLocationManager.authorizationStatus())
  }

  func saveState() {
    // We don't save authorized; the Settings App is the source of truth for that value
    print("Saving showLocation: \(showLocation)")
    Defaults.mapLocationDisplay.write(showLocation)
    print("Saving autoPanMode: \(autoPanMode.rawValue)")
    Defaults.mapAutoPanMode.write(autoPanMode)
  }

  private var locationDelegate = LocationManagerDelegate()
  private var locationManager = CLLocationManager()
  private var previousPanMode: AGSLocationDisplayAutoPanMode? = nil

  private func hookupMapView() {
    locationDelegate.controller = self
    locationManager.delegate = locationDelegate
    observeAutoPanMode()
  }

  private func observeAutoPanMode() {
    mapView.locationDisplay.autoPanModeChangedHandler = { autoPanMode in
      print("mapView changed autoPanMode to \(autoPanMode.rawValue)")
      if autoPanMode != self.autoPanMode {
        if self.autoPanMode == .navigation || self.autoPanMode == .compassNavigation {
          self.previousPanMode = self.autoPanMode
        }
        DispatchQueue.main.async {
          self.autoPanMode = autoPanMode
        }
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
      print(
        "LocationButtonController: CLLocationManager didFailWithError: \(error.localizedDescription)"
      )
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
      print(
        "LocationButtonController: CLLocationManager didChangeAuthorization Status \(status.rawValue)"
      )
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
