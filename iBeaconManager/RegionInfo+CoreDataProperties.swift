//
//  RegionInfo+CoreDataProperties.swift
//  iBeaconManager
//
//  Created by Максим on 26.06.16.
//  Copyright © 2016 Maxim. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RegionInfo {

    @NSManaged var uuid: String
    @NSManaged var name: String
    @NSManaged var major: NSNumber?
    @NSManaged var minor: NSNumber?
    @NSManaged var power: NSNumber?

}
