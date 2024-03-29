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

  /// Display buttons (i.e. Cancel/Delete/Move/...) on the top (instead of bottom) of the attribute editing form
  @Published var attributeButtonsOnTop = false

  /// Map Controls can be light (for dark colored maps), or dark (for light maps)
  @Published var darkMapControls = false

  /// Minimum required accuracy (in meters) of the GPS points
  ///
  /// A value of 0.0 mean no accuracy requirements, otherwise the locations's horizontal error
  /// must be less than gpsAccuracy
  @Published var gpsAccuracyFilter = 0.0

  /// Preferred distance gap (in meters) between GPS points in the track log
  ///
  /// A value of 0.0 will put all GPS points in the tracklog
  @Published var gpsDistanceFilter = 0.0

  /// Preferred time gap (in seconds) between GPS points in the track log
  ///
  /// A value of 0.0 will put all GPS points in the tracklog
  @Published var gpsDurationFilter = 0.0

  /// Map Controls can be made larger for bumpy scenarios
  @Published var mapControlsSize: MapControlSize = .small

  /// An Alarm clock control for countdown alerts
  @Published var showAlarmClock = false {
    didSet { toggleAlarm() }
  }

  /// A text strip along the top of the map with the state of the map
  @Published var showInfoBanner = false

  /// Show the time and location of the observation in the attribute editor
  @Published var showLocationInAttributeForm = false

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
    attributeButtonsOnTop = Defaults.attributeButtonsOnTop.readBool()
    darkMapControls = Defaults.darkMapControls.readBool()
    gpsAccuracyFilter = Defaults.gpsAccuracyFilter.readDouble()
    gpsDistanceFilter = Defaults.gpsDistanceFilter.readDouble()
    gpsDurationFilter = Defaults.gpsDurationFilter.readDouble()
    mapControlsSize = Defaults.mapControlsSize.readMapControlSize()
    showAlarmClock = Defaults.showAlarmClock.readBool()
    showInfoBanner = Defaults.showInfoBanner.readBool()
    showLocationInAttributeForm = Defaults.showLocationInAttributeForm.readBool()
    showTotalizer = Defaults.showTotalizer.readBool()
    surveyControlsOnBottom = Defaults.surveyControlsOnBottom.readBool()
    if alarmInterval < 60.0 {
      alarmInterval = 2.0 * 60.0 * 60.0  // 2 hours in seconds
    }
  }

  /// Save the user defaults to the persisted defaults database
  func saveState() {
    Defaults.alarmInterval.write(alarmInterval)
    Defaults.attributeButtonsOnTop.write(attributeButtonsOnTop)
    Defaults.darkMapControls.write(darkMapControls)
    Defaults.gpsAccuracyFilter.write(gpsAccuracyFilter)
    Defaults.gpsDistanceFilter.write(gpsDistanceFilter)
    Defaults.gpsDurationFilter.write(gpsDurationFilter)
    Defaults.mapControlsSize.write(mapControlsSize)
    Defaults.showAlarmClock.write(showAlarmClock)
    Defaults.showInfoBanner.write(showInfoBanner)
    Defaults.showLocationInAttributeForm.write(showInfoBanner)
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
