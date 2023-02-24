//
//  AngleDistanceFormDefinition.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/28/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//  ALS 05/26/2022- Increase distance limitation from 1000 to 10000; immediate need from GLBA

import SwiftUI  // For Binding

struct AngleDistanceFormDefinition {
  let definition: LocationMethod
  let location: AngleDistanceLocation
  let helper: AngleDistanceHelper

  init(definition: LocationMethod, location: AngleDistanceLocation) {
    self.definition = definition
    self.location = location
    self.helper = AngleDistanceHelper(config: definition, heading: location.direction)
  }

}

//MARK: - Computed Properties

extension AngleDistanceFormDefinition {

  var angle: Binding<Double?> {
    return Binding<Double?>(
      get: {
        guard self.location.angle > -360 else { return nil }
        let angle = self.location.angle
        if self.definition.type == .azimuthDistance {
          return angle
        }
        let heading = self.location.direction
        let deadAhead = self.definition.deadAhead
        let cw = self.definition.direction == .cw
        return self.helper.userAngle(from: angle, with: heading, as: deadAhead, increasing: cw)
      },
      set: { value in
        if let userAngle = value {
          if self.definition.type == .azimuthDistance {
            self.location.angle = userAngle
            return
          }
          let heading = self.location.direction
          let deadAhead = self.definition.deadAhead
          let cw = self.definition.direction == .cw
          let angle = self.helper.databaseAngle(
            from: userAngle, with: heading, as: deadAhead, increasing: cw)
          self.location.angle = angle
        }
      })
  }

  var angleCaption: String? {
    if self.definition.type == .azimuthDistance {
      return "Range: 0°(N)..90°(E)..360°"
    }
    let min = String(format: "%.0f", self.definition.deadAhead - 180.0)
    let max = String(format: "%.0f", self.definition.deadAhead + 180.0)
    let deadAhead = String(format: "%.0f", definition.deadAhead)
    let dir = definition.direction.rawValue.uppercased()
    return "Range: \(min)°..\(deadAhead)°(ahead)..\(max)°; Increases \(dir)"
    // For debugging
    //let angle = String(format: "%.0f", location.angle)
    //let direction = String(format: "%.0f", location.direction)
    //return "Range: \(min)°..\(deadAhead)° aka \(direction)°(in front)..\(max)°; Increases \(inc) (DB: \(angle)°)"
  }

  var angleError: String? {
    if self.angle.wrappedValue == nil {
      return self.definition.type == .azimuthDistance ? "Azimuth required!" : "Angle required!"
    }
    return nil
  }

  var angleFormat: String {
    "%.0f"
  }

  var angleFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    if self.definition.type == .azimuthDistance {
      formatter.minimum = 0.0
      formatter.maximum = 360.0
    } else {
      formatter.minimum = NSNumber(value: self.definition.deadAhead - 180.0)
      formatter.maximum = NSNumber(value: self.definition.deadAhead + 180.0)
    }
    formatter.maximumFractionDigits = 0
    return formatter
  }

  var anglePrefix: String {
    return self.definition.type == .azimuthDistance ? "Azimuth:" : "Angle:"
  }

  var angleSuffix: String? {
    "degrees"
  }

  var angleWarning: String? {
    if self.definition.type == .angleDistance, let angle = self.angle.wrappedValue {
      if angle < self.definition.deadAhead - 90.0 || angle > self.definition.deadAhead + 90.0 {
        return "Warning: feature is behind you!"
      }
    }
    return nil
  }

  var distance: Binding<Double?> {
    return Binding<Double?>(
      get: {
        guard self.location.distance > 0 else { return nil }
        return self.helper.convert(meters: self.location.distance, to: self.definition.units)
      },
      set: { value in
        if let value = value {
          let newValue = self.helper.meters(from: value, in: self.definition.units)
          self.location.distance = newValue
        }
      })
  }

  var distanceCaption: String? {
    // ALS 05/26/2022- Updated from 1000 to 10000
    "Range: 1..10000"
    // For debugging
    //"Range: 0..10000 (DB:\(self.location.distance) meters)"
  }

  var distanceError: String? {
    return self.distance.wrappedValue == nil ? "Distance required!" : nil
  }

  var distanceFormat: String {
    "%.0f"
  }

  var distanceFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.minimum = 0
    // ALS 05/26/2022- Updated from 1000 to 10000
    formatter.maximum = 10000
    formatter.maximumFractionDigits = 0
    return formatter
  }

  var distancePlaceholder: String {
    ""
  }

  var distancePrefix: String {
    "Distance:"
  }

  var distanceSuffix: String? {
    definition.units.rawValue
  }

  var footer: String? {
    nil
  }

  var header: String? {
    "Location of feature from observer"
  }

  var isValid: Bool {
    self.angle.wrappedValue != nil && self.distance.wrappedValue != nil
  }

}
