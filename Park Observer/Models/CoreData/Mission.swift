//
//  Mission.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

/// A swift interface to the objective-c NSManagedObject class in CoreData

import CoreData
import Foundation

@objc(Mission)
public class Mission: NSManagedObject {

  @NSManaged public var gpsPoints: NSSet?
  @NSManaged public var missionProperties: NSSet?
  @NSManaged public var observations: NSSet?

}

// MARK: - Creation

extension Mission {

  static func new(in context: NSManagedObjectContext) -> Mission {
    return NSEntityDescription.insertNewObject(forEntityName: .entityNameMission, into: context)
      as! Mission
  }

}

// MARK: - Fetching

extension Mission {

  static var fetchAll: NSFetchRequest<Mission> {
    return NSFetchRequest<Mission>(entityName: .entityNameMission)
  }

}
