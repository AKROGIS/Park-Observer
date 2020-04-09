//
//  MapControlsView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/9/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct MapControlsView: View {
  @ObservedObject var mapViewController: MapViewController

  var body: some View {
    HStack {
      ScalebarView(mapViewController: mapViewController)
        .frame(width: 200.0, height: 36)
      // Important!  CompassView must be instantiated after MapView
      //   Compass initiation requires a non-nil AGSMapView, which is created in MapView
      Spacer()
      CompassView(mapViewController: mapViewController)
        .frame(width: 30.0, height: 30)
      if mapViewController.locationDisplayOn {
        AutoPanModeButtonView(autoPanMode: $mapViewController.autoPanMode)
          .padding().background(Color.white)
      }
    }
  }
  
}

struct MapDashboardView_Previews: PreviewProvider {
  static var previews: some View {
    MapControlsView(mapViewController: MapViewController())
  }
}
