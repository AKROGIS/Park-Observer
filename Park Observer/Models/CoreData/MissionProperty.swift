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

typealias MissionProperties = [MissionProperty]

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

  static func new(
    mission: Mission, gpsPoint: GpsPoint? = nil, adhocLocation: AdhocLocation? = nil,
    observing: Bool?, defaults: [String: Any]?, template: (MissionProperty, [Attribute])? = nil,
    uniqueIdAttribute: Attribute? = nil, in context: NSManagedObjectContext
  ) -> MissionProperty {
    let missionProperty = MissionProperty.new(in: context)
    missionProperty.mission = mission
    missionProperty.gpsPoint = gpsPoint
    missionProperty.adhocLocation = adhocLocation
    missionProperty.observing = observing
    if let defaults = defaults {
      for key in defaults.keys {
        let dbKey = .attributePrefix + key
        missionProperty.setValue(defaults[key], forKey: dbKey)
      }
    }
    if let (template, attributes) = template {
      for attribute in attributes {
        let key = .attributePrefix + attribute.name
        let value = template.value(forKey: key)
        missionProperty.setValue(value, forKey: key)
      }
    }
    if let attribute = uniqueIdAttribute {
      let key = .attributePrefix + attribute.name
      missionProperty.setValue(MissionProperty.nextId, forKey: key)
    }
    return missionProperty
  }

}

// MARK: - Fetching

extension MissionProperties {

  static var fetchRequest: NSFetchRequest<MissionProperty> {
    return NSFetchRequest<MissionProperty>(entityName: .entityNameMissionProperty)
  }

  static func fetchFirst(at timestamp: Date, in context: NSManagedObjectContext) -> MissionProperty?
  {
    let request = MissionProperties.fetchRequest
    request.predicate = NSPredicate.observationFilter(timestamp: timestamp)
    return (try? context.fetch(request))?.first
  }

  static func fetchLast(in context: NSManagedObjectContext) -> MissionProperty? {
    let request = MissionProperties.fetchRequest
    let sortOrder = NSSortDescriptor(key: "gpsPoint.timestamp", ascending: false)
    request.sortDescriptors = [sortOrder]
    return (try? context.fetch(request))?.first
    //TODO: also sort on adhocLocation.timestamp
  }

}

// MARK: - Computed Properties

extension MissionProperty {

  var timestamp: Date? {
    return gpsPoint?.timestamp ?? adhocLocation?.timestamp
  }

  var location: Location? {
    return gpsPoint?.location ?? adhocLocation?.location
  }

}

//MARK: - Unique ID

// This supports a single mission property attribute that has a unique ID (int32)
// When a survey is loaded, it must call resetId() to query and cache the maxID from the database.
// Testing revealed that fetching the maxId from coredata only considered entities that had been
// saved. It is safer to cache the maxId and increment it whenever a new entity is created
// (entites are only created by this class).  This means that there may be some holes
// in the id field.  However if I did not use caching and queried the database everytime a new
// entity was created, then it is possible that I would assign duplicate IDs if a save
// was not done before the query.  Since this class does not have control of the saving, and
// duplicates are much worse than holes, the solution is based on caching.

extension MissionProperty {

  static private var currentId: Int32 = 0

  static var nextId: Int32 {
    currentId += 1
    return currentId
  }

  static func initializeUniqueId(attribute: Attribute, in context: NSManagedObjectContext) {
    currentId = fetchMaxId(attribute: attribute, in: context) ?? 0
  }

  static func fetchMaxId(attribute: Attribute, in context: NSManagedObjectContext) -> Int32? {
    let entityName = String.entityNameMissionProperty
    return fetchMaxId(for: entityName, attribute: attribute, in: context)
  }

  static func fetchMaxId(
    for entityName: String, attribute: Attribute, in context: NSManagedObjectContext
  ) -> Int32? {
    guard attribute.type == .id else {
      return nil
    }
    let keyPath = .attributePrefix + attribute.name
    let query = NSExpressionDescription()
    query.name = "maxID"
    query.expression = NSExpression(
      forFunction: "max:", arguments: [NSExpression(forKeyPath: keyPath)])
    query.expressionResultType = .integer32AttributeType
    let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
    request.entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    request.resultType = .dictionaryResultType
    request.propertiesToFetch = [query]
    guard let results = try? context.fetch(request) as? [[String: Int32]],
      let result = results.first
    else {
      return nil
    }
    return result[query.name]
  }

}
