//
//  MissionProperty+CoreDataProperties.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//
//

import Foundation
import CoreData


extension MissionProperty {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MissionProperty> {
        return NSFetchRequest<MissionProperty>(entityName: "MissionProperty")
    }

    @NSManaged public var observing: NSNumber?
    @NSManaged public var adhocLocation: AdhocLocation?
    @NSManaged public var gpsPoint: GpsPoint?
    @NSManaged public var mission: Mission?

}
