//
//  AngleDistanceLocation.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import CoreData
import Foundation

@objc(AngleDistanceLocation)
public class AngleDistanceLocation: NSManagedObject {}

extension AngleDistanceLocation {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<AngleDistanceLocation> {
    return NSFetchRequest<AngleDistanceLocation>(entityName: "AngleDistanceLocation")
  }

  @NSManaged public var angle: NSNumber?
  @NSManaged public var direction: NSNumber?
  @NSManaged public var distance: NSNumber?
  @NSManaged public var observation: Observation?

}
