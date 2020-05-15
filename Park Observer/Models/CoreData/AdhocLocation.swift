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
public class AdhocLocation: NSManagedObject {}

extension AdhocLocation {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<AdhocLocation> {
    return NSFetchRequest<AdhocLocation>(entityName: "AdhocLocation")
  }

  @NSManaged public var latitude: NSNumber?
  @NSManaged public var longitude: NSNumber?
  @NSManaged public var timestamp: Date?
  @NSManaged public var map: MapReference?
  @NSManaged public var missionProperty: MissionProperty?
  @NSManaged public var observation: Observation?

}
