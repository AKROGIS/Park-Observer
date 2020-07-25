//
//  Totalizer.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 7/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreLocation  // For CLLocation
import Foundation  // For ObservableObject and @Published

class Totalizer: ObservableObject {

  @Published var text = "Totalizer not configured"

  private var definition: MissionTotalizer? = nil
  private var oldMissionProperty: MissionProperty? = nil
  private var oldLocation: CLLocation? = nil
  private var secondsObserving: TimeInterval = 0.0
  private var secondsNotObserving: TimeInterval = 0.0
  private var metersObserving = 0.0
  private var metersNotObserving = 0.0
  private var totalObserving = 0.0
  private var totalNotObserving = 0.0

  func reset(with definition: MissionTotalizer) {
    self.definition = definition
    resetCounts()
    updateText()
  }

  func updateProperties(_ newMissionProperty: MissionProperty) {
    if let fields = definition?.fields, let oldMissionProperty = oldMissionProperty {
      for field in fields {
        let key = .attributePrefix + field
        let oldValue = oldMissionProperty.value(forKey: key)
        let newValue = newMissionProperty.value(forKey: key)
        if !valuesEqual(oldValue, newValue) {
          resetCounts()
          break
        }
      }
    }
    updateText()
    self.oldMissionProperty = newMissionProperty
  }

  func updateLocation(_ newLocation: CLLocation) {
    guard let definition = definition else { return }
    if let oldLocation = oldLocation {
      let value: Double = {
        switch definition.units {
        case .minutes:
          let seconds = newLocation.timestamp.timeIntervalSince(oldLocation.timestamp)
          return seconds / 60.0
        case .kilometers:
          let meters = newLocation.distance(from: oldLocation)
          return meters / 1000.0
        case .miles:
          let meters = newLocation.distance(from: oldLocation)
          return meters / 1000.0
        }
      }()
      let observing = oldMissionProperty?.observing ?? false
      if observing {
        totalObserving += value
      } else {
        totalNotObserving += value
      }
      updateText()
    }
    oldLocation = newLocation
  }

  private func resetCounts() {
    secondsObserving = 0.0
    secondsNotObserving = 0.0
    metersObserving = 0.0
    metersNotObserving = 0.0
  }

  /// Assumes values come from coredata and are either String or NSNumber
  private func valuesEqual(_ v1: Any?, _ v2: Any?) -> Bool {
    if v1 == nil && v2 == nil {
      return true
    }
    if let s1 = v1 as? String, let s2 = v2 as? String {
      return s1 == s2
    }
    if let n1 = v1 as? NSNumber, let n2 = v2 as? NSNumber {
      return n1 == n2
    }
    return false
  }

  private func updateText() {
    guard let definition = definition else { return }

    var textParts = [String]()
    if definition.includeOn {
      textParts.append("\(format(totalObserving, definition.units)) observing")
    }
    if definition.includeOff {
      textParts.append("\(format(totalNotObserving, definition.units)) not observing")
    }
    if definition.includeTotal {
      let total = totalObserving + totalNotObserving
      textParts.append("\(format(total, definition.units)) tracklogging")
    }
    text = textParts.joined(separator: "; ")
  }

  private func format(_ value: Double, _ units: MissionTotalizer.TotalizerUnits) -> String {
    switch units {
    case .minutes:
      let minutes = Int(value)
      let seconds = Int((value - Double(minutes)) * 60)
      return "\(minutes)m:\(seconds)s"
    case .kilometers:
      return String(format: "%0.1f km", value)
    case .miles:
      return String(format: "%0.1f mi", value)
    }
  }

}
