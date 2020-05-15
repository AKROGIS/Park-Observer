//
//  Mission.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Mission)
public class Mission: NSManagedObject {}

extension Mission {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<Mission> {
    return NSFetchRequest<Mission>(entityName: .entityNameMission)
  }

  @NSManaged public var gpsPoints: NSSet?
  @NSManaged public var missionProperties: NSSet?
  @NSManaged public var observations: NSSet?

}

// MARK: Generated accessors for gpsPoints

extension Mission {

  @objc(addGpsPointsObject:)
  @NSManaged public func addToGpsPoints(_ value: GpsPoint)

  @objc(removeGpsPointsObject:)
  @NSManaged public func removeFromGpsPoints(_ value: GpsPoint)

  @objc(addGpsPoints:)
  @NSManaged public func addToGpsPoints(_ values: NSSet)

  @objc(removeGpsPoints:)
  @NSManaged public func removeFromGpsPoints(_ values: NSSet)

}

// MARK: Generated accessors for missionProperties

extension Mission {

  @objc(addMissionPropertiesObject:)
  @NSManaged public func addToMissionProperties(_ value: MissionProperty)

  @objc(removeMissionPropertiesObject:)
  @NSManaged public func removeFromMissionProperties(_ value: MissionProperty)

  @objc(addMissionProperties:)
  @NSManaged public func addToMissionProperties(_ values: NSSet)

  @objc(removeMissionProperties:)
  @NSManaged public func removeFromMissionProperties(_ values: NSSet)

}

// MARK: Generated accessors for observations

extension Mission {

  @objc(addObservationsObject:)
  @NSManaged public func addToObservations(_ value: Observation)

  @objc(removeObservationsObject:)
  @NSManaged public func removeFromObservations(_ value: Observation)

  @objc(addObservations:)
  @NSManaged public func addToObservations(_ values: NSSet)

  @objc(removeObservations:)
  @NSManaged public func removeFromObservations(_ values: NSSet)

}
