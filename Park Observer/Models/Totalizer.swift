//
//  Totalizer.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 7/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreLocation  // For CLLocation
import Foundation  // For ObservableObject and @Published

/// Publishes statistics regarding the current tracklog
final class Totalizer: ObservableObject {

  /// The text to be displayed to the user
  @Published private(set) var text = "Totalizer not configured"

  private var definition: MissionTotalizer
  private var monitoredPropertyValues = [String: Any?]()
  private var oldLocation: CLLocation? = nil
  private var totalObserving = 0.0
  private var totalNotObserving = 0.0
  private var totalPending = 0.0

  /// Should the next location be added to the observing or not observing total
  var observing = false

  /// Subsequent locations may be the start of a new total
  ///
  /// However we won't know until the user finishes editing the properties
  /// This should be set to true when the mission properties editor is presented to the user
  /// It should be set to false if the user cancels a mission properties editor
  /// It has no effect if there are no monitored fields in the totalizer definition
  var propertyUpdatePending = false {
    didSet {
      guard definition.fields?.count ?? 0 > 0 else {
        propertyUpdatePending = false
        return
      }
      totalPending = 0.0
    }
  }

  init(definition: MissionTotalizer) {
    self.definition = definition
  }

  /// Start the totalizer with the definition
  func start(with missionProperty: MissionProperty?) {
    stop()
    initializeProperties(missionProperty)
    updateText()
  }

  /// Stop (and reset) the totalizer
  func stop() {
    monitoredPropertyValues.removeAll()
    clear()
    text = "Totalizer stopped"
  }

  /// The user has updated the mission properties
  func updateProperties(_ newMissionProperty: MissionProperty) {
    var propertiesChanged = false
    guard propertyUpdatePending == true else {
      print("Unexpected update of totalizer properties is being ignored.")
      return
    }
    guard let fields = definition.fields else {
      print("Totalizer not monitoring property changes; update is being ignored.")
      return
    }
    if monitoredPropertyValues.count == 0 {
      propertiesChanged = true
    }
    for field in fields {
      let key = .attributePrefix + field
      let newValue = newMissionProperty.value(forKey: key)
      if let oldValue = monitoredPropertyValues[key] {
        if !valuesEqual(oldValue, newValue) {
          propertiesChanged = true
        }
      }
      monitoredPropertyValues[key] = newValue
    }
    if propertiesChanged {
      if observing {
        totalObserving = totalPending
        totalNotObserving = 0.0
      } else {
        totalObserving = 0.0
        totalNotObserving = totalPending
      }
    }
    propertyUpdatePending = false
    totalPending = 0.0
    updateText()
  }

  /// Update the totalizer with a new location
  func updateLocation(_ newLocation: CLLocation) {
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
      if observing {
        totalObserving += value
      } else {
        totalNotObserving += value
      }
      if propertyUpdatePending {
        totalPending += value
      }
      updateText()
    }
    oldLocation = newLocation
  }

  private func clear() {
    observing = false
    propertyUpdatePending = false
    totalObserving = 0.0
    totalNotObserving = 0.0
    totalPending = 0.0
    oldLocation = nil
  }

  private func initializeProperties(_ missionProperty: MissionProperty?) {
    monitoredPropertyValues.removeAll()
    guard let fields = definition.fields else { return }
    guard let missionProperty = missionProperty else { return }
    for field in fields {
      let key = .attributePrefix + field
      let newValue = missionProperty.value(forKey: key)
      monitoredPropertyValues[key] = newValue
    }
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
        let key = .attributePrefix + name
        guard let optValue = monitoredPropertyValues[key], let value = optValue else { return "??" }
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
