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

// The swiftUI MapView (UIViewRepresentable) does not own the mapView (AGSMapView: UIView).
// It is owned by the environmental object: SurveyController.
// The AGSMapView maintains a ton of state and it seems overly complicated to try and make it
// play be the SwiftUI rules.  Instead I will cheat, and let various view controllers have a
// reference to the mapView via the SurveyController, so that they can coordinate their state
// with the part of the mapView that they have responsibility for.

struct MapView: UIViewRepresentable {

  @EnvironmentObject var surveyController: SurveyController

  func makeUIView(context: Context) -> AGSMapView {
    surveyController.mapView.isAttributionTextVisible = false
    surveyController.mapView.releaseHardwareResourcesWhenBackgrounded = true
    return surveyController.mapView
  }

  func updateUIView(_ view: AGSMapView, context: Context) {
  }

}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView()
  }
}
