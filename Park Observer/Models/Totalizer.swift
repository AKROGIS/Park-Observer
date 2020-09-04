//
//  Totalizer.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 7/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreData  // For NSManagedObjectContext
import CoreLocation  // For CLLocation
import Foundation  // For ObservableObject and @Published

/// Publishes statistics regarding the current tracklog or mission properties
///
/// See the _Protocol Specification.md_ for details on the behavior of the
/// totalizer.
final class Totalizer: ObservableObject {

  /// The text to be displayed to the user
  @Published private(set) var text = "Totalizer not configured"

  private var definition: MissionTotalizer
  private var currentFieldValues = [String: Any?]()
  private var oldLocation: CLLocation? = nil
  private var totalObserving = 0.0
  private var totalNotObserving = 0.0

  /// Should the next location be added to the observing or not observing total
  var observing = false

  var hasFields: Bool {
    return definition.fields?.count ?? 0 > 0
  }

  init(definition: MissionTotalizer) {
    self.definition = definition
  }

  /// Start the totalizer and reset or reload totals
  func start(with missionProperty: MissionProperty?) {
    clear()
    if hasFields {
      reloadTotals(missionProperty)
    }
    updateText()
  }

  /// Stop  the totalizer
  func stop() {
    text = "Totalizer stopped"
  }

  /// The user has updated the mission properties
  func updateProperties(_ missionProperty: MissionProperty) {
    guard hasFields else { return }
    if changesCurrentValues(missionProperty) {
      reloadTotals(missionProperty)
    }
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
      updateText()
    }
    oldLocation = newLocation
  }

  private func clear() {
    observing = false
    totalObserving = 0.0
    totalNotObserving = 0.0
    oldLocation = nil
  }

  private func reloadTotals(_ missionProperty: MissionProperty?) {
    // The very first missionProperty object of a survey will be nil
    // If we return here, then the we will not initialize the properties (set currentFieldValues)
    // and all checks for updates will fail until we start the next tracklog
    // instead, if missionProperties is nil then set all field values to nil
    guard let missionProperty = missionProperty else {
      for field in definition.fields ?? [] {
        let key = .attributePrefix + field
        currentFieldValues[key] = nil as Any?  // Just nil will remove the key from the dictionary
      }
      return
    }
    initializeProperties(missionProperty)
    guard let context = missionProperty.managedObjectContext else { return }
    // Read the tracklogs in the background and then find matching segments and update the totals
    let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    privateContext.persistentStoreCoordinator = context.persistentStoreCoordinator
    privateContext.perform {
      if let tracklogs = try? TrackLogs.fetchAll() {
        var totalObserving = 0.0
        var totalNotObserving = 0.0
        for tracklog in tracklogs {
          if !self.changesCurrentValues(tracklog.properties) {
            let value: Double = {
              switch self.definition.units {
              case .minutes:
                let seconds = tracklog.duration ?? 0
                return seconds / 60.0
              case .kilometers:
                let meters = tracklog.length ?? 0
                return meters / 1000.0
              case .miles:
                let meters = tracklog.length ?? 0
                return meters / 1609.344
              }
            }()
            if tracklog.properties.observing ?? false {
              totalObserving += value
            } else {
              totalNotObserving += value
            }
          }
        }
        DispatchQueue.main.async {
          self.totalObserving = totalObserving
          self.totalNotObserving = totalNotObserving
        }
      }
    }
  }

  private func initializeProperties(_ missionProperty: MissionProperty?) {
    currentFieldValues.removeAll()
    guard let fields = definition.fields else { return }
    guard let missionProperty = missionProperty else { return }
    for field in fields {
      let key = .attributePrefix + field
      let newValue = missionProperty.value(forKey: key)
      // currentFieldValues will store nil values (and not ignore the key)
      // so it's key list count will always equal the fields count
      currentFieldValues[key] = newValue
    }
  }

  private func changesCurrentValues(_ missionProperty: MissionProperty?) -> Bool {
    if let missionProperty = missionProperty {
      for (key, value) in currentFieldValues {
        let newValue = missionProperty.value(forKey: key)
        if !valuesEqual(value, newValue) {
          return true
        }
      }
    }
    return false
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
        guard let optValue = currentFieldValues[key], let value = optValue else { return "??" }
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
