//
//  EditableObservation.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/2/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS  // For AGSGraphic
import CoreData  // For NSManagedObject
import Foundation  // For Date

/// The View Model for Observation editing and review
struct EditableObservation {
  let dialog: Dialog?
  let fields: [Attribute]
  let graphic: AGSGraphic
  let name: String
  var object: NSManagedObject?
  let timestamp: Date

  init(
    dialog: Dialog? = nil,
    fields: [Attribute]? = nil,
    graphic: AGSGraphic? = nil,
    name: String? = nil,
    object: NSManagedObject? = nil,
    timestamp: Date? = nil
  ) {
    self.dialog = dialog
    self.fields = fields ?? [Attribute]()
    self.graphic = graphic ?? AGSGraphic()
    self.name = name ?? "Unknown"
    self.object = object
    self.timestamp = timestamp ?? Date()
  }
}
