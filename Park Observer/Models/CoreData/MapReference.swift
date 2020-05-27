//
//  MapReference.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

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

// MARK: - Generated accessors

extension MapReference {

  @objc(addAdhocLocationsObject:)
  @NSManaged public func addToAdhocLocations(_ value: AdhocLocation)

  @objc(removeAdhocLocationsObject:)
  @NSManaged public func removeFromAdhocLocations(_ value: AdhocLocation)

  @objc(addAdhocLocations:)
  @NSManaged public func addToAdhocLocations(_ values: NSSet)

  @objc(removeAdhocLocations:)
  @NSManaged public func removeFromAdhocLocations(_ values: NSSet)

}
