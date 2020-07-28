//
//  AngleDistanceFormDefinition.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/28/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI  // For Binding

//TODO: adapt to definition
struct AngleDistanceFormDefinition {
  let definition: LocationMethod
  let angleDistanceLocation: AngleDistanceLocation

  var header: String? {
    "Location of ???"
  }

  var footer: String? {
    "Do I even need a footer"
  }

  var angleCaption: String? {
    "-180 to +180"
  }

  var distanceCaption: String? {
    "\(definition.units) to feature"
  }

  var angle: Binding<Double?> {
    return Binding<Double?>(
      get: {
        return self.angleDistanceLocation.angle
      },
      set: { value in
        if let value = value {
          self.angleDistanceLocation.angle = value
        }
      })
  }

  var distance: Binding<Double?> {
    return Binding<Double?>(
      get: {
        return self.angleDistanceLocation.distance
      },
      set: { value in
        if let value = value {
          self.angleDistanceLocation.distance = value
        }
      })
  }

  let angleFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimum = -180
    formatter.maximum = 180
    formatter.maximumFractionDigits = 0
    return formatter
  }()

  let distanceFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimum = 0
    formatter.maximum = 1000
    formatter.maximumFractionDigits = 0
    return formatter
  }()

}
