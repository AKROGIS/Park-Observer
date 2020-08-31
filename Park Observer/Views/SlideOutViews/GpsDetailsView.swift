//
//  GpsDetailsView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/12/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct GpsDetailsView: View {
  let gpsPoint: GpsPoint
  var body: some View {
    Form {
      Section {
        VStack(alignment: .leading) {
          Text("Observed").font(.caption).foregroundColor(.secondary)
          Text(gpsPoint.timestamp?.shortDateMediumTime ?? "")
        }
        VStack(alignment: .leading) {
          Text("Latitude").font(.caption).foregroundColor(.secondary)
          if gpsPoint.horizontalAccuracy < 0 {
            Text("Unknown")
          } else {
            Text(String.formatOptional(format: "%0.6f°", value: gpsPoint.latitude))
          }
        }
        VStack(alignment: .leading) {
          Text("Longitude").font(.caption).foregroundColor(.secondary)
          if gpsPoint.horizontalAccuracy < 0 {
            Text("Unknown")
          } else {
            Text(String.formatOptional(format: "%0.6f°", value: gpsPoint.longitude))
          }
        }
        VStack(alignment: .leading) {
          Text("Horizontal Accuracy").font(.caption).foregroundColor(.secondary)
          if gpsPoint.horizontalAccuracy < 0 {
            Text("Unknown")
          } else {
            Text(
              String.formatOptional(format: "± %0.1f meters", value: gpsPoint.horizontalAccuracy))
          }
        }
        VStack(alignment: .leading) {
          Text("Altitude (from sea level)").font(.caption).foregroundColor(.secondary)
          if gpsPoint.verticalAccuracy < 0 {
            Text("Unknown")
          } else {
            Text(
              "\(String.formatOptional(format: "%0.1f", value: gpsPoint.altitude)) ± \(String.formatOptional(format: "%0.1f", value: gpsPoint.verticalAccuracy)) meters"
            )
          }
        }
        VStack(alignment: .leading) {
          Text("Course").font(.caption).foregroundColor(.secondary)
          if gpsPoint.course < 0 {
            Text("Unknown")
          } else {
            Text(String.formatOptional(format: "%0.0f°", value: gpsPoint.course))
          }
        }
        VStack(alignment: .leading) {
          Text("Speed").font(.caption).foregroundColor(.secondary)
          if gpsPoint.speed < 0 {
            Text("Unknown")
          } else {
            Text(String.formatOptional(format: "%0.1f meters/second", value: gpsPoint.speed))
          }
        }
      }
    }
  }
}

struct GpsDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    GpsDetailsView(gpsPoint: GpsPoint())
  }
}
