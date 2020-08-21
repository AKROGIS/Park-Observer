//
//  Defaults.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// This file declares an enum that provides a set of well known keys to the NSDefaults system.
/// It is responsible for reading/writing values (of defined types) in NSDefaults
/// This file maintains no state.

import ArcGIS  // for AGSLocationDisplayAutoPanMode
import Foundation  // for UserDefaults

/// An enumeration of the values persisted in the defaults database
enum Defaults: String {

  /// The time interval (seconds) until the alarm clock should alert
  ///
  /// A Double value; default is 0.0
  /// Zero indicates no value is set and a more reasonable default will be assigned
  case alarmInterval

  /// Display buttons (i.e. Cancel/Delete/Move/...) on the top (instead of bottom) of the attribute editing form
  ///
  /// A Boolean value; default is false
  case attributeButtonsOnTop

  /// Track logging may or may not be allowed when app is in the background
  ///
  /// A Boolean value; default is false
  case backgroundTrackLogging

  /// Map Controls can be light (for dark colored maps), or dark (for light maps)
  ///
  /// A Boolean value; default is false
  case darkMapControls

  /// The minimum required horizontal accuracy (in meters) of the GPS points
  ///
  /// A Double value; default is 0.0
  /// Zero indicates no value is set and GPS points will not be rejected based on accuracy
  case gpsAccuracyFilter

  /// Preferred distance gap (in meters) between GPS points in the track log
  ///
  /// A Double value; default is 0.0
  /// A value of 0.0 will put all GPS points in the tracklog
  case gpsDistanceFilter

  /// Preferred time gap (in seconds) between GPS points in the track log
  ///
  /// A Double value; default is 0.0
  /// A value of 0.0 will put all GPS points in the tracklog
  case gpsDurationFilter

  /// The user's current auto pan mode (i.e. follow gps)
  ///
  /// An AGSLocationDisplayAutoPanMode value (enum:Int); default: .off(0)
  case mapAutoPanMode

  /// The latitude of the center of the map
  ///
  /// A Double value; default is 0.0
  case mapCenterLat

  /// The longitude of the center of the map
  ///
  /// A Double value; default is 0.0
  case mapCenterLon

  /// Map controls can be made larger for bumpy scenarios
  ///
  /// A MapControlSize value (enum:CGFloat); default: .small (44.0)
  case mapControlsSize

  /// Is  the user's location shown on the map
  ///
  /// A Boolean value; default is false
  case mapLocationDisplay

  /// The name of the current map
  ///
  /// An optional String; default: nil
  case mapName

  /// The rotation of the map
  ///
  /// A Double value; default is 0.0
  /// Zero is north, and the value is in degrees, increasing clockwise
  case mapRotation

  /// The scale of the map
  ///
  /// A Double value; default is 0.0
  /// Zero indicates no value is set and a more reasonable default will be assigned
  case mapScale

  /// Should the alarm clock control be shown on screen
  ///
  /// The alarm clock reminds users it is time to do some scheduled event (like call in for a wellness check)
  /// A Boolean value; default is false
  case showAlarmClock

  /// Should the information banner be shown on the screen?
  ///
  /// The information banner displays text for the state of track logging and/or observing
  /// A Boolean value; default is false
  case showInfoBanner

  /// Show the time and location of the observation in the attribute editor
  ///
  /// A Boolean value; default is false
  case showLocationInAttributeForm

  /// Should the totalizer be shown on the screen?
  ///
  /// The totalizer displays the amount of time/distance the user has been track logging and/or observing
  /// A Boolean value; default is false
  case showTotalizer

  /// The width (in pixels) of the slide out menu
  ///
  /// A Double value; default is 0.0
  /// Zero indicates no value is set and a more reasonable default will be assigned
  case slideOutMenuWidth

  /// The survey control buttons can be on the top or bottom of the screen
  ///
  /// A Boolean value; default is false
  case surveyControlsOnBottom

  /// The name of the current survey
  ///
  /// An optional String; default: nil
  case surveyName
}

extension Defaults {

  /// Read a boolean value from the defaults database
  func readBool() -> Bool {
    switch self {
    case .attributeButtonsOnTop, .backgroundTrackLogging, .darkMapControls, .mapLocationDisplay,
      .showAlarmClock, .showInfoBanner, .showLocationInAttributeForm, .showTotalizer,
      .surveyControlsOnBottom:
      return UserDefaults.standard.bool(forKey: self.rawValue)
    default:
      print("Error: Bool not a valid type for \(self.rawValue) in defaults; returning false")
      return false
    }
  }

  /// Read an integer value from the defaults database
  func readInt() -> Int {
    switch self {
    // case .XXX:
    //  return  UserDefaults.standard.integer(forKey: self.rawValue)
    default:
      print("Error: Int not a valid type for \(self.rawValue) in defaults; returning 0")
      return 0
    }
  }

  /// Read a double value from the defaults database
  func readDouble() -> Double {
    switch self {
    case .alarmInterval, .gpsAccuracyFilter, .gpsDistanceFilter, .gpsDurationFilter,
      .mapCenterLat, .mapCenterLon, .mapRotation, .mapScale, .slideOutMenuWidth:
      return UserDefaults.standard.double(forKey: self.rawValue)
    default:
      print("Error: Double not a valid type for \(self.rawValue) in defaults; returning 0")
      return 0
    }
  }

  /// Read an AGSLocationDisplayAutoPanMode enum from the defaults database
  func readMapAutoPanMode() -> AGSLocationDisplayAutoPanMode {
    switch self {
    case .mapAutoPanMode:
      let rawValue = UserDefaults.standard.integer(forKey: self.rawValue)
      return AGSLocationDisplayAutoPanMode(rawValue: rawValue) ?? .off
    default:
      print(
        "Error: AGSLocationDisplayAutoPanMode not a valid type "
          + "for \(self.rawValue) in defaults; returning '.off''")
      return .off
    }
  }

  /// Read a MapControlSize enum from the defaults database
  func readMapControlSize() -> MapControlSize {
    switch self {
    case .mapControlsSize:
      let rawValue = UserDefaults.standard.double(forKey: self.rawValue)
      return MapControlSize(rawValue: CGFloat(rawValue)) ?? .small
    default:
      print(
        "Error: MapControlSize not a valid type "
          + "for \(self.rawValue) in defaults; returning '.small''")
      return .small
    }
  }

  /// Read a string value from the defaults database
  func readString() -> String? {
    switch self {
    case .mapName, .surveyName:
      return UserDefaults.standard.object(forKey: self.rawValue) as? String? ?? nil
    default:
      print("Error: String not a valid type for \(self.rawValue) in defaults; returning nil")
      return nil
    }
  }

  /// Write this value to the defaults system
  func write(_ value: Any?) {
    let defaults = UserDefaults.standard
    switch self {
    case .mapAutoPanMode:
      if let value = value as? AGSLocationDisplayAutoPanMode {
        defaults.set(value.rawValue, forKey: self.rawValue)
      } else {
        print("Error: Value in .mapAutoPanMode is not a AGSLocationDisplayAutoPanMode")
      }
    case .mapControlsSize:
      if let value = value as? MapControlSize {
        defaults.set(value.rawValue, forKey: self.rawValue)
      } else {
        print("Error: Value in .mapControlsSize is not a MapControlSize")
      }
    default:
      defaults.set(value, forKey: self.rawValue)
    }
  }

}
