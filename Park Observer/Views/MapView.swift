//
//  MapView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/6/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import SwiftUI
import UIKit

final class MapView: UIViewRepresentable {

  @ObservedObject var mapViewController: MapViewController

  // BUG: in UIViewRepresentable? (swift 5.1; iOS 13.3; Xcode 11.3)
  // updateUIView is not called if either
  //   1) it is in a struct; only works for final class
  //   2) if @ObservedObject is only declared in UIViewRepresentable; must be declared in superview
  // note: @ObservedObject decorator can be used, but is not required

  init(mapViewController: MapViewController) {
    self.mapViewController = mapViewController
  }

  func makeUIView(context: Context) -> AGSMapView {
    // Set static properties on UIView
    let view = AGSMapView()
    view.isAttributionTextVisible = false
    mapViewController.mapView = view
    return view
  }

  func updateUIView(_ view: AGSMapView, context: Context) {
    // Set dynamic properties on UIView
    // Avoid setting properties that didn't change, AGSMapView() does not check for deltas
    if view.map != mapViewController.map {
      view.map = mapViewController.map
    }
    if view.locationDisplay.autoPanMode != mapViewController.autoPanMode {
      view.locationDisplay.autoPanMode = mapViewController.autoPanMode
    }
  }

}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(mapViewController: MapViewController())
  }
}
