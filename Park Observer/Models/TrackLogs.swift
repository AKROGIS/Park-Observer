//
//  TrackLogs.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/26/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS  // for AGSPolyline and AGSPoint
import Foundation  // for TimeInterval

// A tracklog is an ordered sequence of gpsPoints and a mission property.
// All gpsPoints have a mission; gpsPoints with different missions are on different tracklogs.
// Only points at the start/stop of a tracklog will have a mission property.
// If there is a mission property at the end of a mission, this closes the current tracklog,
// and starts a new (single point) tracklog.

// . = gps points; | = mission properties; points on the same line are the same tracklog
// the gpsPoint (.) above and below the mission properties (|) is the same gpsPoint in 2 tracklogs
// time ->
// |
// ......                   |
//      |                   ..........
//      ........                     |
//             |                     ..........
//             ........                       |
//                                            .
// <-    mission 1   ->     <-   mission 2   ->
//
// Note that there are three tracklogs in both missions.  The 3rd tracklog in mission 2
// has only one point.  This is a valid trackog. It will have 0 length and 0 duration.
// It is not possible to create a tracklog with no points.
//
// IMPORTANT: This object assumes that clients will never remove, edit or replace points, only
// append new ones in ORDER (chronologically).

class TrackLog {
  let properties: MissionProperty
  var points: GpsPoints = []

  init(properties: MissionProperty) {
    self.properties = properties
  }

  var duration: TimeInterval? {
    guard let endTime = points.last?.timestamp, let startTime = points.first?.timestamp else {
      return nil
    }
    return endTime.timeIntervalSince(startTime)
  }

  var length: Double? {
    let agsPoints: [AGSPoint] = points.compactMap { point in
      guard let location = point.location else { return nil }
      return AGSPoint(clLocationCoordinate2D: location)
    }
    guard agsPoints.count > 0 else {
      return nil
    }
    let polyline = AGSPolyline(points: agsPoints)
    guard let geometry = AGSGeometryEngine.simplifyGeometry(polyline) else {
      return nil
    }
    return AGSGeometryEngine.geodeticLength(
      of: geometry, lengthUnit: AGSLinearUnit.meters(), curveType: .shapePreserving)
  }

}

typealias TrackLogs = [TrackLog]

extension TrackLogs {

  enum BuildError: Error {
    case noFirstProperty
    case noMission
  }

  /// Build a new set of tracklogs by fetching all necessary data from the CoreData Context of the current thread
  /// This may be called on different threads in different situations.
  /// It must not rely on any previously retrieved managed objects
  static func fetchAll() throws -> TrackLogs {
    // The following fetch assumes we are in a private/background context block
    let gpsPoints = try GpsPoints.allOrderByTime.execute()
    var trackLogs: TrackLogs = []
    if gpsPoints.count == 0 {
      return trackLogs
    }
    guard let point = gpsPoints.first, let properties = point.missionProperty else {
      throw BuildError.noFirstProperty
    }
    guard var currentMission = point.mission else {
      throw BuildError.noMission
    }
    // The initial currentTrackLog is a throw away tracklog (not added to the array).
    // Otherwise, currentTrackLog would be an optional with a lot of nil checks.
    // It will have gpsPoints[0] added to points list only once (closing the tracklog)
    var currentTrackLog = TrackLog(properties: properties)
    for point in gpsPoints {
      if let properties = point.missionProperty {
        // This is all first/last points, except the start of mission #2+.
        // The start of mission #2+ does not need to add the current point to the
        // current tracklog before starting a new one.
        if currentMission == point.mission {
          // "Close" the current tracklog
          currentTrackLog.points.append(point)
        }
        // start a new tracklog and put it in the list
        guard let mission = point.mission else {
          throw BuildError.noMission
        }
        currentMission = mission
        currentTrackLog = TrackLog(properties: properties)
        currentTrackLog.points.append(point)
        trackLogs.append(currentTrackLog)
      } else {
        // middle or last point, but not a first point
        currentTrackLog.points.append(point)
      }
    }
    return trackLogs
  }

}
