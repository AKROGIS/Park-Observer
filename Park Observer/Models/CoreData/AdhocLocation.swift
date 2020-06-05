//
//  AdhocLocation.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import CoreData
import Foundation

@objc(AdhocLocation)
public class AdhocLocation: NSManagedObject {

  @NSManaged private var primitiveLatitude: NSNumber?
  @NSManaged private var primitiveLongitude: NSNumber?
  @NSManaged public var timestamp: Date?
  @NSManaged public var map: MapReference?
  @NSManaged public var missionProperty: MissionProperty?
  @NSManaged public var observation: Observation?

}
// MARK: - Property Accessors
// To allow the use of a more intuitive type Double? in lieu of NSNumber?
// See https://martiancraft.com/blog/2015/12/nsmanaged/ for details

extension AdhocLocation {

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

// MARK: - Creation

extension AdhocLocation {

  static func new(in context: NSManagedObjectContext) -> AdhocLocation {
    return NSEntityDescription.insertNewObject(
      forEntityName: .entityNameAdhocLocation, into: context) as! AdhocLocation
  }

}

// MARK: - Computed Properties

extension AdhocLocation {

  var location: Location? {
    guard let lat = latitude, let lon = longitude else {
      return nil
    }
    return Location(latitude: lat, longitude: lon)
  }

}
