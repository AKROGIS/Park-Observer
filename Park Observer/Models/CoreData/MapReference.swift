//
//  MapReference.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

/// A swift interface to the objective-c NSManagedObject class in CoreData

import CoreData
import Foundation

@objc(MapReference)
public class MapReference: NSManagedObject {

  @NSManaged public var author: String?
  @NSManaged public var date: Date?
  @NSManaged public var name: String?
  @NSManaged public var adhocLocations: NSSet?

}

// MARK: - Creation

extension MapReference {

  static func new(in context: NSManagedObjectContext) -> MapReference {
    return NSEntityDescription.insertNewObject(forEntityName: .entityNameMap, into: context)
      as! MapReference
  }

}
