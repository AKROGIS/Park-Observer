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

enum Defaults: String {
  case backgroundTracklogging  // Bool; default: false
  case darkMapControls  // Bool; default: false
  case gpsAccuracy  // Double; default: 0.0
  case mapAutoPanMode  // AGSLocationDisplayAutoPanMode (enum:Int); default: .off
  case mapCenterLat  // Double; default: 0.0
  case mapCenterLon  // Double; default: 0.0
  case mapLocationDisplay  // Bool; default : false
  case mapName  // String?; default: nil
  case mapRotation  // Double; default: 0.0
  case mapScale  // Double; default: 0.0
  case showAlarmClock  // Bool; default: false
  case showInfoBanner  // Bool; default: false
  case showTotalizer  // Bool; default: false
  case slideOutMenuWidth  // Double; default: 0.0
  case surveyName  // String?; default: nil
}

extension Defaults {

  func write(_ value: Any?) {
    let defaults = UserDefaults.standard
    switch self {
    case .mapAutoPanMode:
      if let value = value as? AGSLocationDisplayAutoPanMode {
        defaults.set(value.rawValue, forKey: self.rawValue)
      } else {
        print("Error: Value in .mapAutoPanMode is not a AGSLocationDisplayAutoPanMode")
      }
    default:
      defaults.set(value, forKey: self.rawValue)
    }
  }

  func readBool() -> Bool {
    switch self {
    case .backgroundTracklogging, .darkMapControls, .mapLocationDisplay, .showAlarmClock,
      .showInfoBanner, .showTotalizer:
      return UserDefaults.standard.bool(forKey: self.rawValue)
    default:
      print("Error: Bool not a valid type for \(self.rawValue) in defaults; returning false")
      return false
    }
  }

  func readInt() -> Int {
    switch self {
    // case .XXX:
    //  return  UserDefaults.standard.integer(forKey: self.rawValue)
    default:
      print("Error: Int not a valid type for \(self.rawValue) in defaults; returning 0")
      return 0
    }
  }

  func readDouble() -> Double {
    switch self {
    case .gpsAccuracy, .mapRotation, .mapScale, .mapCenterLat, .mapCenterLon, .slideOutMenuWidth:
      return UserDefaults.standard.double(forKey: self.rawValue)
    default:
      print("Error: Double not a valid type for \(self.rawValue) in defaults; returning 0")
      return 0
    }
  }

  func readString() -> String? {
    switch self {
    case .mapName, .surveyName:
      return UserDefaults.standard.object(forKey: self.rawValue) as? String? ?? nil
    default:
      print("Error: String not a valid type for \(self.rawValue) in defaults; returning nil")
      return nil
    }
  }

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

}
