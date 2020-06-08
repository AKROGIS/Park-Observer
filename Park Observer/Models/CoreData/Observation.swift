//
//  Observation.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

/// A swift interface to the objective-c NSManagedObject class in CoreData

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
      var adHelper = AngleDistanceHelper(
        config: nil, heading: angleDistance.direction)
      adHelper.absoluteAngle = angleDistance.angle
      adHelper.distanceInMeters = angleDistance.distance
      return adHelper.featureLocationFromUserLocation(location)
    } else {
      if gpsPoint == nil, let location = adhocLocation?.location
      {
        return location
      } else {
        return gpsPoint?.location
      }
    }
  }

  func requestLocationOfObserver(in context: NSManagedObjectContext? = nil) -> Location? {
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
    //
    // If an observation has both an adhocLocation and an angleDistanceLocation (should never happen)
    // This function will ignore the angleDistanceLocation
    //
    guard let timestamp = adhocLocation?.timestamp else {
      if let gps = gpsPoint {
        return gps.location
      } else {
        return nil
      }
    }
    let start = timestamp.addingTimeInterval(-0.001)
    let end = timestamp.addingTimeInterval(+0.001)
    //print(timestamp)

    let request: NSFetchRequest<GpsPoint> = GpsPoints.fetchRequest
    request.predicate = NSPredicate(format: "%@ <= timestamp AND timestamp <= %@", start as CVarArg, end as CVarArg)
    //request.predicate = NSPredicate(format: "timestamp == %@", timestamp as CVarArg)
    var results: GpsPoints?
    if let context = context {
      results = try? context.fetch(request)
    } else {
      // only works when executing in a private context block
      results = try? request.execute()
    }
    guard let gpsPoint = results?.first else {
      return nil
    }
    return gpsPoint.location
  }
}
