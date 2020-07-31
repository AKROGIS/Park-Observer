//
//  ObservationClass.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/30/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// a "Super Type" that includes the features and a Mission Property
enum ObservationClass {
  case mission
  case feature(Feature)

  var name: String {
    switch self {
    case .mission:
      return .entityNameMissionProperty
    case .feature(let feature):
      return feature.name
    }
  }

}
