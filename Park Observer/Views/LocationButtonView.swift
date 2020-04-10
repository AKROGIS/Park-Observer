//
//  LocationButtonView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/10/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import SwiftUI

struct LocationButtonView: View {
  @Binding var buttonState: LocationButtonState
  @Binding var locationAuthorized: Bool?

  @State private var showingAlert = false

  var body: some View {
    Button(action: toggle) {
      Image(systemName: imageName)
    }
      .padding()
      .background(Color(.systemBackground))
      .clipShape(Circle())
      //TODO: change foreground color to disabled if locationAuthorized is nil or false
      //TODO: get background from environment (whiteish for dark maps, blackish for light maps)
      //TODO: make background slightly transparent, make border less transparent
      //TODO: system images are like fonts, experiment with size and weight
      //TODO: coordinate look with CompassView
      .alert(isPresented: $showingAlert) {
        Alert(
          title: Text("Location Services Disabled"),
          message: Text(
            "Your location cannot be shown. Use Settings to enable location services."),
          dismissButton: .default(Text("Got it!")))
        //TODO: provide a primary (cancel) and secondary (settings) buttons
      }
  }

  func toggle() {
    if let authorized = locationAuthorized, authorized {
      switch buttonState {
      case .off:
        buttonState = .on(.off)
        break
      case .on(let autoPanMode):
        switch autoPanMode {
        case .off:
          //TODO: set button to previous autoPanMode if turned off by map touch
          buttonState = .on(.recenter)
          break
        case .recenter:
          buttonState = .on(.navigation)
          break
        case .navigation:
          buttonState = .on(.compassNavigation)
          break
        case .compassNavigation:
          buttonState = .off
          break
        @unknown default:
          print("Error: Unexpected enum value in AGSLocationDisplayAutoPanMode")
          buttonState = .off
          break
        }
      }
    } else {
      showingAlert = true
    }
  }

  var imageName: String {
    if let authorized = locationAuthorized, authorized {
      switch buttonState {
      case .off: return "location.slash"
      case .on(let autoPanMode):
        switch autoPanMode {
        case .compassNavigation: return "location.circle"
        case .navigation: return "location.north.line.fill"
        case .recenter: return "location.fill"
        case .off: return "location"
        @unknown default:
          print("Error: Unexpected enum value in AGSLocationDisplayAutoPanMode")
          return "location.slash"
        }
      }
    }
    return "location.slash"
  }

}

struct LocationButtonView_Previews: PreviewProvider {
  static var previews: some View {
    LocationButtonView(buttonState: .constant(.off), locationAuthorized: .constant(false))
  }
}

enum LocationButtonState {
  case off
  case on(AGSLocationDisplayAutoPanMode)
}

extension LocationButtonState: Equatable {
  public static func == (lhs: LocationButtonState, rhs: LocationButtonState) -> Bool {
    switch (lhs, rhs) {
    case (.off, .off):
      return true
    case (.on, .on):
      return true
    default:
      return false
    }
  }
}
