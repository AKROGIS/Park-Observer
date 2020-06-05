//
//  AdhocLocation.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import CoreData
import Foundation

@objc(AdhocLocation)
public class AdhocLocation: NSManagedObject {

  @NSManaged public var latitude: NSNumber?
  @NSManaged public var longitude: NSNumber?
  @NSManaged public var timestamp: Date?
  @NSManaged public var map: MapReference?
  @NSManaged public var missionProperty: MissionProperty?
  @NSManaged public var observation: Observation?

}

// MARK: - Creation

extension AdhocLocation {

  static func new(in context: NSManagedObjectContext) -> AdhocLocation {
    return NSEntityDescription.insertNewObject(
      forEntityName: .entityNameAdhocLocation, into: context) as! AdhocLocation
  }

}

// MARK: - Computed Properties

extension AdhocLocation {

  var location: Location? {
    guard let lat = latitude?.doubleValue, let lon = longitude?.doubleValue else {
      return nil
    }
    return Location(latitude: lat, longitude: lon)
  }

}
