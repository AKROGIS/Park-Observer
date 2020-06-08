//
//  EntityNames.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// String constants of the CoreData entities for compile time safety

extension String {
  // Constants used in the code which MUST match the object model (*.xcdatamodeld)
  static let entityNameAdhocLocation = "AdhocLocation"
  static let entityNameAngleDistanceLocation = "AngleDistanceLocation"
  static let entityNameGpsPoint = "GpsPoint"
  static let entityNameMap = "Map"
  static let entityNameMission = "Mission"
  static let entityNameMissionProperty = "MissionProperty"
  static let entityNameObservation = "Observation"

  // Class names do not need to match the entity names
  static let classNameObservtion = "Observation"
}
