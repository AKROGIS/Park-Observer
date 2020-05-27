//
//  TrackLogs.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/26/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

struct TrackLog {
  let properties: MissionProperty
  let points: GpsPoints

  var length: Double? {
    //FIXME: Implement
    return nil
  }
}

typealias TrackLogs = [TrackLog]

extension TrackLogs {

  /// Build a new set of tracklogs by fetching all necessary data from the CoreData Context of the current thread
  /// This may be called on different threads in different situations.
  /// It must not rely on any previously retrieved managed objects
  static func fetchAll() -> TrackLogs {
    //FIXME: Implement
    return []
  }
}
