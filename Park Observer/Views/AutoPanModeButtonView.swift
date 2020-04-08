//
//  AutoPanModeButtonView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/8/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import SwiftUI

struct AutoPanModeButtonView: View {
  @Binding var autoPanMode: AGSLocationDisplayAutoPanMode

  var body: some View {
    Button(action: toggle) {
      Image(systemName: imageName)
    }.buttonStyle(PlainButtonStyle())
      .foregroundColor(.primary)
  }

  func toggle() {
    switch autoPanMode {
    case .recenter:
      autoPanMode = .compassNavigation
      break
    case .compassNavigation:
      autoPanMode = .navigation
      break
    case .navigation:
      autoPanMode = .off
      break
    case .off:
      autoPanMode = .recenter
      break
    @unknown default:
      autoPanMode = .recenter
      break
    }
  }

  var imageName: String {
    switch autoPanMode {
    case .compassNavigation: return "location.circle"
    case .navigation: return "location.north.line.fill"
    case .recenter: return "location.fill"
    case .off: return "location.slash"
    @unknown default: return "location.slash"
    }
  }
}

struct AutoPanModeButtonView_Previews: PreviewProvider {
  static var previews: some View {
    AutoPanModeButtonView(autoPanMode: .constant(.off))
  }
}
