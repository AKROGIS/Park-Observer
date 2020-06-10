//
//  MissionProperty.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

/// A swift interface to the objective-c NSManagedObject class in CoreData

import CoreData
import Foundation

@objc(MissionProperty)
public class MissionProperty: NSManagedObject {

  @NSManaged private var primitiveObserving: NSNumber?
  @NSManaged public var adhocLocation: AdhocLocation?
  @NSManaged public var gpsPoint: GpsPoint?
  @NSManaged public var mission: Mission?

}

// MARK: - Property Accessors
// To allow the use of a more intuitive type Bool? in lieu of NSNumber?
// See https://martiancraft.com/blog/2015/12/nsmanaged/ for details

extension MissionProperty {

  var observing: Bool? {
    get {
      willAccessValue(forKey: "observing")
      defer { didAccessValue(forKey: "observing") }
      return primitiveObserving?.boolValue
    }
    set {
      willChangeValue(forKey: "observing")
      defer { didChangeValue(forKey: "observing") }
      primitiveObserving = newValue.map({ NSNumber(value: $0) })
    }
  }
}

// MARK: - Creation

extension MissionProperty {

  static func new(in context: NSManagedObjectContext) -> MissionProperty {
    return NSEntityDescription.insertNewObject(
      forEntityName: .entityNameMissionProperty, into: context) as! MissionProperty
  }

}
