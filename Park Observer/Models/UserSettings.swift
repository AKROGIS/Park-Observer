//
//  UserSettings.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 6/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

class UserSettings: ObservableObject {

  /// The time interval (seconds) until the alarm clock should alert
  @Published var alarmInterval = 0.0

  /// Map Controls can be light (for dark colored maps), or dark (for light maps)
  @Published var darkMapControls = false

  /// Minimum required accuracy (in meters) of the GPS points
  @Published var gpsAccuracy = 0.0

  /// Map Controls can be made larger for bumpy scenarios
  @Published var mapControlsSize: MapControlSize = .small

  /// An Alarm clock control for countdown alerts
  @Published var showAlarmClock = false {
    didSet { toggleAlarm() }
  }

  /// A text strip along the top of the map with the state of the map
  @Published var showInfoBanner = false

  /// Display of how long the user has been surveying (on transect/observing)
  @Published var showTotalizer = false

  /// The survey control buttons can be on the top or bottom of the screen
  @Published var surveyControlsOnBottom = false

  /// Units to display for the length of the survey
  @Published var totalizerUnits = MissionTotalizer.TotalizerUnits.kilometers

  /// When streaming points for the tracklog, wait x meters between successive points
  @Published var tracklogIntervalDistance = 0.0

  /// When streaming points for the tracklog, wait x seconds between successive points
  @Published var tracklogIntervalTime = 0.0

  /// When streaming points for the tracklog, use time or distance
  @Published var tracklogIntervalUnits = TracklogIntervalUnits.off

  /// Read the user defaults from the persisted defaults database
  func restoreState() {
    alarmInterval = Defaults.alarmInterval.readDouble()
    darkMapControls = Defaults.darkMapControls.readBool()
    gpsAccuracy = Defaults.gpsAccuracy.readDouble()
    mapControlsSize = Defaults.mapControlsSize.readMapControlSize()
    showAlarmClock = Defaults.showAlarmClock.readBool()
    showInfoBanner = Defaults.showInfoBanner.readBool()
    showTotalizer = Defaults.showTotalizer.readBool()
    surveyControlsOnBottom = Defaults.surveyControlsOnBottom.readBool()
    if alarmInterval < 60.0 {
      alarmInterval = 2.0 * 60.0 * 60.0  // 2 hours in seconds
    }
  }

  /// Save the user defaults to the persisted defaults database
  func saveState() {
    Defaults.alarmInterval.write(alarmInterval)
    Defaults.darkMapControls.write(darkMapControls)
    Defaults.gpsAccuracy.write(gpsAccuracy)
    Defaults.mapControlsSize.write(mapControlsSize)
    Defaults.showAlarmClock.write(showAlarmClock)
    Defaults.showInfoBanner.write(showInfoBanner)
    Defaults.showTotalizer.write(showTotalizer)
    Defaults.surveyControlsOnBottom.write(surveyControlsOnBottom)
  }

  private func toggleAlarm() {
    if showAlarmClock {
      requestNotificationAutorization()
    } else {
      let center = UNUserNotificationCenter.current()
      center.removeAllPendingNotificationRequests()
    }
  }

  func requestNotificationAutorization() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
      if !granted {
        self.showAlarmClock = false
        //TODO: Show alert to turn on Notifications in Settings
        // add @Published private(set) var showNotificationAlert
        // add .alert(isPresented: userSettings.$showNotificationAlert)
      }
    }
  }

}

enum TracklogIntervalUnits: Int {
  case off = 0
  case distance
  case time
}
