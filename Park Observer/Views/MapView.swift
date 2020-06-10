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

struct MapView: UIViewRepresentable {

  @EnvironmentObject var surveyController: SurveyController

  func makeUIView(context: Context) -> AGSMapView {
    surveyController.mapView.isAttributionTextVisible = false
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
