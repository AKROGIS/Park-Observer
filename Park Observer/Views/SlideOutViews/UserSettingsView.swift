//
//  UserSettingsView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 6/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct UserSettingsView: View {
  @EnvironmentObject var userSettings: UserSettings

  var body: some View {
    Form {
      //TODO: Use form groups/controls; implement save settings
      Toggle(isOn: $userSettings.darkMapControls) {
        Text("Dark Mode Map Controls")
      }
      Toggle(isOn: $userSettings.backgroundTracklogging) {
        Text("Tracklog When Not Active")
      }
      if userSettings.backgroundTracklogging {
        Text("Warning: App will consume extra battery power when not active").foregroundColor(.red)
          .font(.subheadline)
      }
      Toggle(isOn: $userSettings.showAlarmClock) {
        Text("Show Alarm Clock")
      }
      Toggle(isOn: $userSettings.showInfoBanner) {
        Text("Show Informational Banner")
      }
      Toggle(isOn: $userSettings.showTotalizer) {
        Text("Show Totalizer")
      }
      //Picker(title: "hi", selection: $userSettings.totalizerUnits) {}
      Text("Gps Settings")
      //Slider(value: $userSettings.gpsAccuracy, in: 5..<200, minimumValueLabel: Text("5m"), maximumValueLabel: Text("200m"))
      Text("  Gps Frequency - time")
      Text("  Gps Frequency - distance")
      Text("  Gps Frequency - smart mode?")
    }
  }

}

struct UserSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    UserSettingsView()
  }
}
