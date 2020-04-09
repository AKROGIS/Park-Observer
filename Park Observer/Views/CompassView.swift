//
//  CompassView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/8/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct CompassView: View {
  // I am not using bindings because I need to avoid a race condition with the
  // rotation being set in the MapView and the CompassView.

  var rotation: Double
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Image("CompassIcon").rotationEffect(.degrees(-rotation))
    }
    .buttonStyle(PlainButtonStyle())
  }

}

struct CompassView_Previews: PreviewProvider {
  static var previews: some View {
    CompassView(rotation: 15.0, action: {})
  }
}
