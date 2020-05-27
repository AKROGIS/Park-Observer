//
//  AngleDistanceLocation.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import CoreData
import Foundation

@objc(AngleDistanceLocation)
public class AngleDistanceLocation: NSManagedObject {

  @NSManaged public var angle: NSNumber?  // The geographic angle (degrees) from the user to the feature
  @NSManaged public var direction: NSNumber?  // The GPS heading (direction of travel) as a geographic angle (degrees)
  @NSManaged public var distance: NSNumber?  // The distance in meters from the user to the feature
  @NSManaged public var observation: Observation?

}

/// Converts between a user centric Angle/Distance, and a database Angle/Distance
/// The database stores two angles in geographic degrees (North = 0, increasing clockwise), and distance in meters.
/// The user input/output is in degrees to the feature (in a protocol determined reference frame), and the distance in user units.
struct AngleDistanceHelper {

  /// Angle-Distance conventions are specified in the part of the Survey Protocol
  let config: Location?

  /// deadAhead is the current course or heading (typically provided by the course attribute from CoreLocation services)
  /// It is expressed as an angle in degrees in the  the geographics reference frame (i.e angles increases clockwise with 0º = North)
  /// deadAhead provides the frame of reference for the angle property.
  /// An angle that is deadAhead, from the user's perspective as defined in the the config property, matches this angle.
  let deadAhead: Double?

  /// The distance from the user to the observed feature in the units provided by the protocol (config.units)
  var distanceInUserUnits: Double? {
    didSet {
      distanceInMeters = metersDistanceFrom(distanceInUserUnits)
    }
  }

  /// The angle in degrees from the user's perspective to the observed feature.
  /// The frame of reference is given by the deadAhead and direction properties on the config.
  /// For example if config.deadAhead is 180º and config.direction is clockwise,
  /// then 150º is 30º degrees to port and 220º is 40º to starboard
  var userAngle: Double? {
    didSet {
      absoluteAngle = absoluteAngleFrom(userAngle)
    }
  }

  /// The distance from the user to the observed feature in the units provided by the protocol (config.units)
  var distanceInMeters: Double? {
    didSet {
      distanceInUserUnits = userDistanceFrom(distanceInMeters)
    }
  }

  /// The angle from the user to the observed feature in degrees the geographic
  /// reference frame  (i.e angles increases clockwise with 0º = North)
  var absoluteAngle: Double? {
    didSet {
      userAngle = userAngleFrom(absoluteAngle)
    }
  }

  func absoluteAngleFrom(_ angle: Double?) -> Double? {
    //FIXME: Implement absoluteAngleFrom
    return 0
  }

  func userAngleFrom(_ angle: Double?) -> Double? {
    //FIXME: Implement userAngleFrom
    return 0
  }

  func userDistanceFrom(_ distance: Double?) -> Double? {
    //FIXME: Implement userDistanceFrom
    return 0
  }

  func metersDistanceFrom(_ distance: Double?) -> Double? {
    //FIXME: Implement metersDistanceFrom
    return 0
  }

  func featureLocationFromUserLocation(_ location: (latitude: NSNumber?, longitude: NSNumber?)) -> (
    latitude: NSNumber?, longitude: NSNumber?
  ) {
    //FIXME: Implement featureLocationFromUserLocation
    return (latitude: 0.0, longitude: 0.0)
  }

  var perpendicularMeters: Double? {
    //FIXME: Implement perpendicularMeters
    return 0.0
  }

}
