//
//  ScalebarView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/8/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

final class ScalebarView: UIViewRepresentable {

  @ObservedObject var mapViewController: MapViewController

  init(mapViewController: MapViewController) {
    self.mapViewController = mapViewController
  }

  func makeUIView(context: Context) -> Scalebar {
    // Set static properties on UIView
    let scalebar = Scalebar()
    scalebar.mapView = mapViewController.mapView
    scalebar.style = .dualUnitLine
    scalebar.alignment = .left
    scalebar.textColor = UIColor.white
    scalebar.textShadowColor = UIColor.black.withAlphaComponent(0.80)
    scalebar.lineColor = UIColor.white
    scalebar.shadowColor = UIColor.black.withAlphaComponent(0.80)
    scalebar.font = UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.semibold)
    return scalebar
  }

  func updateUIView(_ view: Scalebar, context: Context) {
    if view.mapView != mapViewController.mapView {
      view.mapView = mapViewController.mapView
    }
  }
}

struct ScalebarView_Previews: PreviewProvider {
  static var previews: some View {
    ScalebarView(mapViewController: MapViewController())
  }
}
