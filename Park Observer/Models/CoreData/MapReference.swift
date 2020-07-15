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

  // returns a matching Map Reference, or creates a new one to match
  static func findOrNew(matching info: MapInfo, in context: NSManagedObjectContext) -> MapReference
  {
    if let ref = fetchFirst(matching: info, in: context) {
      return ref
    }
    let ref = new(in: context)
    ref.author = info.author
    ref.date = info.date
    ref.name = info.title
    return ref
  }

}

// MARK: - Fetching

extension MapReference {

  static var fetchRequest: NSFetchRequest<MapReference> {
    return NSFetchRequest<MapReference>(entityName: .entityNameMap)
  }

  static func mapInfoFilter(info: MapInfo) -> NSPredicate {
    if let date = info.date {
      let filter = "author == %@ AND date == %@ AND name == %@"
      return NSPredicate(
        format: filter, info.author as CVarArg, date as CVarArg, info.title as CVarArg)
    } else {
      let filter = "author == %@ AND date = nil AND name == %@"
      return NSPredicate(
        format: filter, info.author as CVarArg, info.title as CVarArg)
    }
  }

  static func fetchFirst(matching info: MapInfo, in context: NSManagedObjectContext)
    -> MapReference?
  {
    let request: NSFetchRequest<MapReference> = fetchRequest
    request.predicate = mapInfoFilter(info: info)
    return (try? context.fetch(request))?.first
  }

}
