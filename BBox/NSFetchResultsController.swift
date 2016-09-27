//
//  NSFetchResultsController.swift
//  BBox
//
//  Created by Максим on 27.09.16.
//  Copyright © 2016 Personal. All rights reserved.
//

import CoreData

extension NSFetchedResultsController {
    func update() {
        do {
            try self.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
}
