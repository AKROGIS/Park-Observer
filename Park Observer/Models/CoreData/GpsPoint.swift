//
//  GpsPoint.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

/// A swift interface to the objective-c NSManagedObject class in CoreData

import CoreData
import CoreLocation  // for CLLocationCoordinate2D
import Foundation

@objc(GpsPoint)
public class GpsPoint: NSManagedObject {

  @NSManaged public var altitude: Double // default = -1
  @NSManaged public var course: Double // default = -1
  @NSManaged public var horizontalAccuracy: Double // default = -1
  @NSManaged private var primitiveLatitude: NSNumber?
  @NSManaged private var primitiveLongitude: NSNumber?
  @NSManaged public var speed: Double // default = -1
  @NSManaged public var timestamp: Date?
  @NSManaged public var verticalAccuracy: Double // default = -1
  @NSManaged public var mission: Mission?
  @NSManaged public var missionProperty: MissionProperty?
  @NSManaged public var observation: Observation?

}

// MARK: - Property Accessors
// To allow the use of a more intuitive type Double? in lieu of NSNumber?
// See https://martiancraft.com/blog/2015/12/nsmanaged/ for details

extension GpsPoint {

  var latitude: Double? {
    get {
      willAccessValue(forKey: "latitude")
      defer { didAccessValue(forKey: "latitude") }
      return primitiveLatitude?.doubleValue
    }
    set {
      willChangeValue(forKey: "latitude")
      defer { didChangeValue(forKey: "latitude") }
      primitiveLatitude = newValue.map({NSNumber(value: $0)})
    }
  }

  var longitude: Double? {
    get {
      willAccessValue(forKey: "longitude")
      defer { didAccessValue(forKey: "longitude") }
      return primitiveLongitude?.doubleValue
    }
    set {
      willChangeValue(forKey: "longitude")
      defer { didChangeValue(forKey: "longitude") }
      primitiveLongitude = newValue.map({NSNumber(value: $0)})
    }
  }

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

typealias Location = CLLocationCoordinate2D

extension GpsPoint {

  var location: Location? {
    guard let lat = latitude, let lon = longitude else {
      return nil
    }
    return Location(latitude: lat, longitude: lon)
  }

}
