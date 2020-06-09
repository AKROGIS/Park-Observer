//
//  TrackLogs.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/26/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// This class is responsible for representing a tracklog (defined below).  A tracklog is typically built to
/// provide a polyline for the mapView or summary information for CSV export from the data in coredata.
/// A tracklog should be created then exported to CSV or the mapview and then discarded.  While the class
/// cannot be mutated, except while building, it is built from objects owned by the CoreData context, and
/// they can be changed at anytime after the tracklog is created, thereby making the tracklog incorrect.
/// The tracklog does not monitor or adjust for changes in the underlying coredata objects, so it is only
/// guaranteed correct when it is built.

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
// For the user's perspective, a mission is a tracklog (begins and ends with start/stop
// tracklogging in the user interface). The tracklog is segmented whenever the mission
// properties change (on/off transect, weather changes, etc).  In that sense what we are
// calling tracklogs could also be considered tracklog or mission segments.

class TrackLog {

  let mission: Mission
  let properties: MissionProperty
  private(set) var points: GpsPoints = []
  private var lastDate: Date

  init(point: GpsPoint) throws {
    guard let mission = point.mission else {
      throw TrackLogBuildError.noMission
    }
    guard let props = point.missionProperty else {
      throw TrackLogBuildError.noProperty
    }
    guard let date = point.timestamp else {
      throw TrackLogBuildError.noTimestamp
    }
    self.lastDate = date
    self.mission = mission
    self.properties = props
    self.points.append(point)
  }

  func append(_ point: GpsPoint, lastPoint: Bool = false) throws {
    guard let mission = point.mission else {
      throw TrackLogBuildError.noMission
    }
    guard mission == self.mission else {
      throw TrackLogBuildError.wrongMission
    }
    // Do not add any points that have a missionProperty.
    // Any point with a missionProperty is the start of a new tracklog.
    // An exception is made for the last point in a tracklog since it may also
    // be the first point in the next tracklog.
    guard lastPoint || point.missionProperty == nil else {
      throw TrackLogBuildError.extraProperty
    }
    guard let date = point.timestamp else {
      throw TrackLogBuildError.noTimestamp
    }
    guard lastDate < date else {
      throw TrackLogBuildError.pointOutOfOrder
    }
    self.lastDate = date
    self.points.append(point)
  }

  func appendLast(_ point: GpsPoint) throws {
    try self.append(point, lastPoint: true)
  }

  // MARK: - Computed Properties

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

enum TrackLogBuildError: Error {
  case noMission
  case noProperty
  case noTimestamp
  case extraProperty
  case pointOutOfOrder
  case wrongMission
}

typealias TrackLogs = [TrackLog]

extension TrackLogs {

  /// Build a new set of tracklogs by fetching all necessary data from the CoreData Context of the current thread
  /// This may be called on different threads in different situations.
  /// It must not rely on any managed objects in a different context.  These object cannot be shared with another thread.
  static func fetchAll() throws -> TrackLogs {
    // The following fetch assumes we are in a private/background context block
    let gpsPoints = try GpsPoints.allOrderByTime.execute()
    var trackLogs: TrackLogs = []
    if gpsPoints.count == 0 {
      return trackLogs
    }
    var currentTrackLog = try TrackLog(point: gpsPoints[0])
    trackLogs.append(currentTrackLog)
    var currentMission = currentTrackLog.mission
    for point in gpsPoints.dropFirst() {
      if point.missionProperty == nil {
        // middle or last point, but not a first point
        try currentTrackLog.append(point)
      } else {
        // A first point
        guard let mission = point.mission else {
          throw TrackLogBuildError.noMission
        }
        if currentMission == mission {
          // This is not the start of mission #2+.
          // The start of mission #2+ does not need to add the current point to
          // the end of the current tracklog before starting a new one.
          // "Close" the current tracklog
          try currentTrackLog.appendLast(point)
        } else {
          currentMission = mission
        }
        // start a new tracklog and put it in the list
        currentTrackLog = try TrackLog(point:point)
        trackLogs.append(currentTrackLog)
      }
    }
    return trackLogs
  }

}
