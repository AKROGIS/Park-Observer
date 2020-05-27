//
//  GpsPoint.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import CoreData
import Foundation

@objc(GpsPoint)
public class GpsPoint: NSManagedObject {

  @NSManaged public var altitude: NSNumber?
  @NSManaged public var course: NSNumber?
  @NSManaged public var horizontalAccuracy: NSNumber?
  @NSManaged public var latitude: NSNumber?
  @NSManaged public var longitude: NSNumber?
  @NSManaged public var speed: NSNumber?
  @NSManaged public var timestamp: Date?
  @NSManaged public var verticalAccuracy: NSNumber?
  @NSManaged public var mission: Mission?
  @NSManaged public var missionProperty: MissionProperty?
  @NSManaged public var observation: Observation?

}

typealias GpsPoints = [GpsPoint]

// MARK: - Creation

extension GpsPoint {

  static func new(in context: NSManagedObjectContext) -> GpsPoint {
    return NSEntityDescription.insertNewObject(forEntityName: .entityNameGpsPoint, into: context)
      as! GpsPoint
  }

}

// MARK: - Fetching

extension GpsPoints {

  static var fetchRequest: NSFetchRequest<GpsPoint> {
    return NSFetchRequest<GpsPoint>(entityName: .entityNameGpsPoint)
  }

  static var allOrderByTime: NSFetchRequest<GpsPoint> {
    let request: NSFetchRequest<GpsPoint> = fetchRequest
    let sortOrder = NSSortDescriptor(key: "timestamp", ascending: true)
    request.sortDescriptors = [sortOrder]
    return request
  }

}

// MARK: - Computed Properties

extension GpsPoint {

  var location: (latitude: NSNumber?, longitude: NSNumber?) {
    return (latitude: latitude, longitude: longitude)
  }

}
