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
      Spacer()
      if mapViewController.rotation != 0.0 {
        CompassView(
          rotation: mapViewController.rotation,
          action: {
            self.mapViewController.mapView?.setViewpointRotation(0, completion: nil)
          }).transition(.opacity)
      }
      LocationButtonView(controller: mapViewController.locationButtonController)
    }
  }

}

struct MapDashboardView_Previews: PreviewProvider {
  static var previews: some View {
    MapControlsView(mapViewController: MapViewController())
  }
}
