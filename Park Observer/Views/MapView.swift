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

  func makeUIView(context: Context) -> AGSMapView {
    // Set static properties on UIView
    let view = AGSMapView()
    return view
  }

  func updateUIView(_ view: AGSMapView, context: Context) {
    // Set dynamic properties on UIView
    let map = AGSMap(basemap: .imageryWithLabels())
    view.map = map
  }

}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView()
  }
}
