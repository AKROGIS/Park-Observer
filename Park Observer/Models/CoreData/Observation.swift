//
//  Observation.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Observation)
public class Observation: NSManagedObject {

  @NSManaged public var adhocLocation: AdhocLocation?
  @NSManaged public var angleDistanceLocation: AngleDistanceLocation?
  @NSManaged public var gpsPoint: GpsPoint?
  @NSManaged public var mission: Mission?

}

typealias Observations = [Observation]

// MARK: - Creation

extension Observation {

  static func new(_ feature: Feature, in context: NSManagedObjectContext) -> Observation {
    let entityName = .observationPrefix + feature.name
    return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
      as! Observation
  }

}

// MARK: - Fetching

extension Observations {

  static func fetchAll(for featureName: String) -> NSFetchRequest<Observation> {
    let entityName = .observationPrefix + featureName
    let request: NSFetchRequest<Observation> = NSFetchRequest<Observation>(entityName: entityName)
    return request
  }

}

// MARK: - Computed Properties

extension Observation {

  var timestamp: Date? {
    return gpsPoint?.timestamp ?? adhocLocation?.timestamp
  }

  var locationOfFeature: Location? {
    if let angleDistance = angleDistanceLocation, let location = gpsPoint?.location {
      let adHelper = AngleDistanceHelper(
        config: nil,
        deadAhead: angleDistance.direction?.doubleValue,
        distanceInMeters: angleDistance.distance?.doubleValue,
        absoluteAngle: angleDistance.angle?.doubleValue)
      return adHelper.featureLocationFromUserLocation(location)
    } else {
      if gpsPoint == nil, let lat = adhocLocation?.latitude?.doubleValue, let lon = adhocLocation?.longitude?.doubleValue  {
        return Location(latitude: lat, longitude: lon)
      } else {
        return gpsPoint?.location
      }
    }
  }

  func requestLocationOfObserver() -> (latitude: NSNumber?, longitude: NSNumber?) {
    // an observation should always have a gpsPoint or an adhocLocation (mapLocation)
    // If this observation has an adhocLocation, then the observer is
    //   at the gpsPoint with the same time stamp as the adhocLocation
    // If there is no GPS point with a timestamp matching the timestamp of the mapLocation,
    //   Then the observers location is considered unknown.  We might be able to interpolate
    //   between the nearest GPS points, but those might be far off or non-existant, so it is
    //   better to report unknown (via nil) than to guess.
    // If this observation has no adhocLocation, then observer is at the GPS point.
    //   An Observation could have both an adhocLocation and a GPS point.  In this case,
    //   the original observation occurred at the adhocLocation timestamp, and then the location
    //   was corrected at the GPS point timestamp.  There are now two observation locations,
    //   but we will always report the first one.
    // If there is no gpsPoint and no adhocLocation, the the observers location is unknown.
    //   this should be precluded during data input.
    guard let timestamp = adhocLocation?.timestamp else {
      if let gps = gpsPoint {
        return (latitude: gps.latitude, longitude: gps.longitude)
      } else {
        return (latitude: nil, longitude: nil)
      }
    }
    let request: NSFetchRequest<GpsPoint> = GpsPoints.fetchRequest
    request.predicate = NSPredicate(format: "timestamp == %@", timestamp as CVarArg)
    guard let gpsPoint = try? request.execute().first else {
      return (latitude: nil, longitude: nil)
    }
    return (latitude: gpsPoint.latitude, longitude: gpsPoint.longitude)
  }
}
