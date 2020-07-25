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
  private var totalObserving = 0.0
  private var totalNotObserving = 0.0

  func setup(with definition: MissionTotalizer) {
    clear()
    self.definition = definition
    updateText()
  }

  func updateProperties(_ newMissionProperty: MissionProperty) {
    if let fields = definition?.fields, let oldMissionProperty = oldMissionProperty {
      for field in fields {
        let key = .attributePrefix + field
        let oldValue = oldMissionProperty.value(forKey: key)
        let newValue = newMissionProperty.value(forKey: key)
        if !valuesEqual(oldValue, newValue) {
          reset()
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
          return meters / 1609.344
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

  func clear() {
    definition = nil
    oldMissionProperty = nil
    reset()
  }

  private func reset() {
    totalObserving = 0.0
    totalNotObserving = 0.0
    oldLocation = nil
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
    var tempText = textParts.joined(separator: "; ")
    if let fieldNames = definition.fields {
      let names = fieldNames.joined(separator: ";")
      let values = fieldNames.map { name in
        guard let properties = oldMissionProperty else { return "??" }
        guard let value = properties.value(forKey: .attributePrefix + name) else { return "??" }
        return "\(value)"
      }.joined(separator: ";")
      tempText += " for \(names) = \(values)"
    }
    text = tempText
  }

  private func format(_ value: Double, _ units: MissionTotalizer.TotalizerUnits) -> String {
    switch units {
    case .minutes:
      let minutes = Int(value)
      let seconds = Int((value - Double(minutes)) * 60)
      return String(format: "%dm:%.2ds", minutes, seconds)
    case .kilometers:
      let format = value < 10.0 ? "%0.2f km" : "%0.1f km"
      return String(format: format, value)
    case .miles:
      let format = value < 10.0 ? "%0.2f mi" : "%0.1f mi"
      return String(format: format, value)
    }
  }

}
