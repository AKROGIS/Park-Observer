//
//  Survey+SummaryStats.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import Foundation  // For Date

extension Survey {

  var observationCount: Int? {
    try? viewContext.count(for: Observations.fetchAll)
  }

  var trackCount: Int? {
    try? viewContext.count(for: Mission.fetchAll)
  }

  var gpsCount: Int? {
    try? viewContext.count(for: GpsPoints.fetchRequest)
  }

  var gpsCountSinceArchive: Int? {
    if info.exportDate == nil && info.syncDate == nil {
      return gpsCount
    }
    if let date = info.exportDate, info.syncDate == nil {
      return try? viewContext.count(for: GpsPoints.pointsSince(date))
    }
    if let date = info.syncDate, info.exportDate == nil {
      return try? viewContext.count(for: GpsPoints.pointsSince(date))
    }
    if let date1 = info.syncDate, let date2 = info.exportDate {
      let date = date1 < date2 ? date2 : date1
      return try? viewContext.count(for: GpsPoints.pointsSince(date))
    }
    return nil
  }

  var dateOfFirstGpsPoint: Date? {
    if let gpsPoints = try? viewContext.fetch(GpsPoints.firstPoint) {
      if let gpsPoint = gpsPoints.first {
        return gpsPoint.timestamp
      }
    }
    return nil
  }

  var dateOfLastGpsPoint: Date? {
    if let gpsPoints = try? viewContext.fetch(GpsPoints.lastPoint) {
      if let gpsPoint = gpsPoints.first {
        return gpsPoint.timestamp
      }
    }
    return nil
  }

}
