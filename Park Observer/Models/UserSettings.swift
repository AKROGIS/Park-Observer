//
//  UserSettings.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 6/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

class UserSettings: ObservableObject {

  /// MapControls can be light (for dark colored maps), or dark (for light maps)
  @Published var darkMapControls = false

  /// Minimum required accuracy (in meters) of the GPS points
  @Published var gpsAccuracy = 0.0

  /// An Alarm clock control for countdown alerts
  @Published var showAlarmClock = false

  /// A text strip along the top of the map with the state of the map
  @Published var showInfoBanner = false

  /// Display of how long the user has been surveying (on transect/observing)
  @Published var showTotalizer = false

  /// Units to display for the length of the survey
  @Published var totalizerUnits = MissionTotalizer.TotalizerUnits.kilometers

  /// When streaming points for the tracklog, wait x seconds between successive points
  @Published var tracklogIntervalTime = 0.0

  /// When streaming points for the tracklog, wait x meters between successive points
  @Published var tracklogIntervalDistance = 0.0

  /// When streaming points for the tracklog, use time or distance
  @Published var tracklogIntervalUnits = TracklogIntervalUnits.off

  func restoreState() {
    darkMapControls = Defaults.darkMapControls.readBool()
    gpsAccuracy = Defaults.gpsAccuracy.readDouble()
    showAlarmClock = Defaults.showAlarmClock.readBool()
    showInfoBanner = Defaults.showInfoBanner.readBool()
    showTotalizer = Defaults.showTotalizer.readBool()
  }

  func saveState() {
    Defaults.darkMapControls.write(darkMapControls)
    Defaults.gpsAccuracy.write(gpsAccuracy)
    Defaults.showAlarmClock.write(showAlarmClock)
    Defaults.showInfoBanner.write(showInfoBanner)
    Defaults.showTotalizer.write(showTotalizer)
  }

}

enum TracklogIntervalUnits: Int {
  case off = 0
  case distance
  case time
}
