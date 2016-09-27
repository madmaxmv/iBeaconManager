//
//  NSManagedObjectContext.swift
//  BBox
//
//  Created by Максим on 27.09.16.
//  Copyright © 2016 Personal. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    func saveContext() {
        if self.hasChanges {
            do {
                try self.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
