//
//  CompassView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/8/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

final class CompassView: UIViewRepresentable {

  @ObservedObject var mapViewController: MapViewController

  init(mapViewController: MapViewController) {
    self.mapViewController = mapViewController
  }

  func makeUIView(context: Context) -> Compass {
    // Set static properties on UIView
    //FIXME: Remove forced unwrap (!)
    let compass = Compass(mapView: mapViewController.mapView!)
    return compass
  }

  func updateUIView(_ compass: Compass, context: Context) {
  }
}

struct CompassView_Previews: PreviewProvider {
  static var previews: some View {
    CompassView(mapViewController: MapViewController())
  }
}
