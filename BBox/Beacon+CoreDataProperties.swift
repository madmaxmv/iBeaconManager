//
//  Beacon+CoreDataProperties.swift
//  BBox
//
//  Created by Максим on 15.09.16.
//  Copyright © 2016 Personal. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Beacon {

    @NSManaged var name:    String!
    @NSManaged var major:   NSNumber!
    @NSManaged var minor:   NSNumber!
    @NSManaged var uuid:    String!

}
