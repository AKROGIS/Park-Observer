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
    List {
      //TODO: Use form groups/controls; implement save settings
      Toggle(isOn: $userSettings.darkMapControls) {
        Text("Dark Mode Map Controls")
      }
      Text("Gps Settings")
      Text("  Background Tracklogs?")
      Text("  Warning about batery usage").foregroundColor(.red)
      Text("  Gps Frequency - time")
      Text("  Gps Frequency - distance")
      Text("  Gps Frequency - smart mode?")
      Text("  Gps Error Threshold?")
      Text("Info Banner")
      Text("Totalizer")
    }
  }

}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView()
    }
}
