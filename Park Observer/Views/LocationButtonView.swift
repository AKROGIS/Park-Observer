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
  @ObservedObject var controller: LocationButtonController
  @Environment(\.darkMap) var darkMap

  @State private var showingAlert = false

  var body: some View {
    Button(action: {
      self.showingAlert = self.controller.authorized == .no
      self.controller.toggle()
    }) {
      Image(systemName: getImageName())
    }
      .padding()
      .background(Color(darkMap ? .white : .black).opacity(0.65))
      .clipShape(Circle())
      .overlay(Circle().stroke(Color(darkMap ? .white : .black), lineWidth: 3))
      .alert(isPresented: $showingAlert) {
        Alert(
          title: Text("Location Services Disabled"),
          message: Text(
            "Your location cannot be shown. Use Settings to enable location services."),
          primaryButton: .cancel(Text("OK")),
          secondaryButton: .default(Text("Settings")) {
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
              // URL from string is an optional, but in this case we know it will always be valid
              UIApplication.shared.open(settingsUrl)
            }
          })
      }
  }

  private func getImageName() -> String {
    if controller.showLocation {
      switch controller.autoPanMode {
      case .off:
        return "location"
      case .compassNavigation:
        return "location.circle"
      case .navigation:
        return "location.north.line.fill"
      case .recenter:
        return "location.fill"
      @unknown default:
        print("Error: Unexpected enum value in AGSLocationDisplayAutoPanMode")
        return "exclamationmark.octagon.fill"
      }
    } else {
      return "location.slash"
    }
  }

}

struct LocationButtonView_Previews: PreviewProvider {
  static var previews: some View {
    LocationButtonView(controller: LocationButtonController())
  }
}
