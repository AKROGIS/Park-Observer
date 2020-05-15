//
//  GpsPoint+CoreDataProperties.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import Foundation
import CoreData


extension GpsPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GpsPoint> {
        return NSFetchRequest<GpsPoint>(entityName: "GpsPoint")
    }

    @NSManaged public var altitude: NSNumber?
    @NSManaged public var course: NSNumber?
    @NSManaged public var horizontalAccuracy: NSNumber?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var speed: NSNumber?
    @NSManaged public var timestamp: Date?
    @NSManaged public var verticalAccuracy: NSNumber?
    @NSManaged public var mission: Mission?
    @NSManaged public var missionProperty: MissionProperty?
    @NSManaged public var observation: Observation?

}
