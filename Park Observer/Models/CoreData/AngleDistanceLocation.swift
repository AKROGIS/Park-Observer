//
//  AngleDistanceLocation.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import ArcGIS  // for AGSSpatialReference, AGSGeometryEngine, AGSPoint
import CoreData  // for NSManagedObject, NSManagedObjectContext, NSEntityDescription
import Foundation  // for NSNumber, fabs, sin, cos

@objc(AngleDistanceLocation)
public class AngleDistanceLocation: NSManagedObject {

  @NSManaged public var angle: NSNumber?  // The geographic angle (degrees) from the user to the feature
  @NSManaged public var direction: NSNumber?  // The GPS heading (direction of travel) as a geographic angle (degrees)
  @NSManaged public var distance: NSNumber?  // The distance in meters from the user to the feature
  @NSManaged public var observation: Observation?

}

// MARK: - Creation

extension AngleDistanceLocation {

  static func new(in context: NSManagedObjectContext) -> AngleDistanceLocation {
    return NSEntityDescription.insertNewObject(
      forEntityName: .entityNameAngleDistanceLocation, into: context) as! AngleDistanceLocation
  }

}

// MARK: - AngleDistanceHelper

/// Converts between a user centric Angle/Distance, and a database Angle/Distance
/// The database stores two angles in geographic degrees (North = 0, increasing clockwise), and distance in meters.
/// The user input/output is in degrees to the feature (in a protocol determined reference frame), and the distance in user units.
struct AngleDistanceHelper {

  /// Angle-Distance conventions are specified in the part of the Survey Protocol
  let config: LocationMethod?

  /// heading is the current course (typically provided by the course attribute from CoreLocation services)
  /// It is expressed as an angle in degrees in the geographics reference frame (i.e angles increases clockwise with 0º = North)
  /// heading provides the frame of reference for the angle property.
  /// An angle that is deadAhead, from the user's perspective as defined in the the config property, matches this angle.
  let heading: Double?

  /// The distance from the user to the observed feature in the units provided by the protocol (config.units)
  var distanceInUserUnits: Double? {
    didSet {
      if !inDidSet {
        inDidSet = true
        distanceInMeters = metersDistanceFrom(distanceInUserUnits)
        inDidSet = false
      }
    }
  }

  /// The angle in degrees from the user's perspective to the observed feature.
  /// The frame of reference is given by the deadAhead and direction properties on the config.
  /// For example if config.deadAhead is 180º and config.direction is clockwise,
  /// then 150º is 30º degrees to port and 220º is 40º to starboard
  var userAngle: Double? {
    didSet {
      if !inDidSet {
        inDidSet = true
        absoluteAngle = absoluteAngleFrom(userAngle)
        inDidSet = false
      }
    }
  }

  /// The distance from the user to the observed feature in the units provided by the protocol (config.units)
  var distanceInMeters: Double? {
    didSet {
      if !inDidSet {
        inDidSet = true
        distanceInUserUnits = userDistanceFrom(distanceInMeters)
        inDidSet = false
      }
    }
  }

  /// The angle from the user to the observed feature in degrees the geographic
  /// reference frame  (i.e angles increases clockwise with 0º = North)
  var absoluteAngle: Double? {
    didSet {
      if !inDidSet {
        inDidSet = true
        userAngle = userAngleFrom(absoluteAngle)
        inDidSet = false
      }
    }
  }

  // To prevent infiinte loops in my dependent property setters
  // i.e set userAngle => set absoluteAngle => set userAngle ....
  private var inDidSet: Bool = false

  // Need an explicit init because the private property make the implicit init private
  init(config: LocationMethod?, heading: Double?) {
    self.heading = heading
    self.config = config
  }

  private func absoluteAngleFrom(_ angle: Double?) -> Double? {
    guard let heading = heading, let angle = angle else {
      return nil
    }
    let referenceAngle = config?.deadAhead ?? LocationMethod.defaultDeadAhead
    let direction = config?.direction ?? LocationMethod.defaultDirection
    let multiplier = direction == .cw ? 1.0 : -1.0
    var absoluteAngle = heading + multiplier * (angle - referenceAngle)
    if absoluteAngle < 0 {
      absoluteAngle = fmod(absoluteAngle, 360.0) + 360.0
    }
    if 360.0 < absoluteAngle {
      absoluteAngle = fmod(absoluteAngle, 360.0)
    }
    return absoluteAngle
  }

  private func userAngleFrom(_ angle: Double?) -> Double? {
    guard let heading = heading, let angle = angle else {
      return nil
    }
    let referenceAngle = config?.deadAhead ?? LocationMethod.defaultDeadAhead
    let direction = config?.direction ?? LocationMethod.defaultDirection
    let multiplier = direction == .cw ? 1.0 : -1.0
    let userAngle = referenceAngle + multiplier * (angle - heading)
    if userAngle < referenceAngle - 180.0 {
      return userAngle + 360.0
    }
    if referenceAngle + 180.0 < userAngle {
      return userAngle - 360.0
    }
    return userAngle
  }

  static let feetPerMeter = 3.28084
  static let yardsPerMeter = 1.0936133333333

  private func userDistanceFrom(_ distance: Double?) -> Double? {
    guard let distance = distance else {
      return nil
    }
    let units = config?.units ?? LocationMethod.defaultUnits
    switch units {
    case .feet:
      return distance * AngleDistanceHelper.feetPerMeter
    case .meters:
      return distance
    case .yards:
      return distance * AngleDistanceHelper.yardsPerMeter
    }
  }

  private func metersDistanceFrom(_ distance: Double?) -> Double? {
    guard let distance = distance else {
      return nil
    }
    let units = config?.units ?? LocationMethod.defaultUnits
    switch units {
    case .feet:
      return distance / AngleDistanceHelper.feetPerMeter
    case .meters:
      return distance
    case .yards:
      return distance / AngleDistanceHelper.yardsPerMeter
    }
  }

  func featureLocationFromUserLocation(_ location: Location) -> Location? {
    guard let geoAngle = absoluteAngle, let distance = distanceInMeters else {
      return nil
    }
    //Find the UTM zone based on our lat/long, then use AGS to create a LL point
    // project to UTM, do angle/distance offset, then project new UTM point to LL
    let zone = 1 + Int((180 + location.longitude) / 6.0)
    let wkid = location.latitude < 0 ? 32700 + zone : 32600 + zone
    guard let utm = AGSSpatialReference(wkid: wkid) else {
      return nil
    }
    let wgs84 = AGSSpatialReference.wgs84()
    let startLL = AGSPoint(clLocationCoordinate2D: location)
    guard let startUTM = AGSGeometryEngine.projectGeometry(startLL, to: utm) as? AGSPoint else {
      return nil
    }
    //geoAngle is clockwise from North, convert to math angle: counterclockwise from East = 0
    let radians = (90.0 - geoAngle) * Double.pi / 180.0
    let deltaX = distance * cos(radians)
    let deltaY = distance * sin(radians)
    let endUTM = AGSPoint(x: startUTM.x + deltaX, y: startUTM.y + deltaY, spatialReference: utm)
    if let endLL = AGSGeometryEngine.projectGeometry(endUTM, to: wgs84) as? AGSPoint {
      return Location(latitude: endLL.y, longitude: endLL.x)
    }
    return nil
  }

  var perpendicularMeters: Double? {
    guard let geoAngle = absoluteAngle, let heading = heading, let distance = distanceInMeters
    else {
      return nil
    }
    let radians = (geoAngle - heading) * Double.pi / 180.0
    return fabs(distance * sin(radians))
  }

}
