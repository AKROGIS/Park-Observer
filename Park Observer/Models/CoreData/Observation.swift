//
//  Observation.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Observation)
public class Observation: NSManagedObject {}

extension Observation {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<Observation> {
    return NSFetchRequest<Observation>(entityName: .entityNameObservation)
  }

  @NSManaged public var adhocLocation: AdhocLocation?
  @NSManaged public var angleDistanceLocation: AngleDistanceLocation?
  @NSManaged public var gpsPoint: GpsPoint?
  @NSManaged public var mission: Mission?

}
