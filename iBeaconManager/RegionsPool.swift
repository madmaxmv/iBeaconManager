//
//  BeaconsPool.swift
//  iBeaconManager
//
//  Created by Максим on 25.06.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

/// Хранит данные обо всех регионах пользователя.
class RegionsPool: NSObject {
    
    static private let singlePool = RegionsPool()
    var managedObjectContext: NSManagedObjectContext!
    private var locationManager = CLLocationManager()
    
    class func getInstance() -> RegionsPool {
        return singlePool
    }
    
    private override init() {
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = BeaconStorage.getInstance()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchReqest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("RegionInfo", inManagedObjectContext: self.managedObjectContext)
        fetchReqest.entity = entity
        
        let sortDescriptorByName = NSSortDescriptor(key: "name", ascending: true)
        fetchReqest.sortDescriptors = [sortDescriptorByName]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchReqest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        return fetchedResultsController
    }()

    var sectionsCount: Int {
        get {
            if let sections = fetchedResultsController.sections {
                return sections.count
            }
            return 0
        }
    }
    
    func rowsInSection(section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func getObjectAtIndex(indexPath: NSIndexPath) -> RegionInfo {
        return fetchedResultsController.objectAtIndexPath(indexPath) as! RegionInfo
    }
    
    func addObject(name: String, withUUID uuid: String) {
        
        let region = NSEntityDescription.insertNewObjectForEntityForName("RegionInfo",
            inManagedObjectContext: self.managedObjectContext)
            as! RegionInfo
        
        region.name = name
        region.uuid = uuid
        startMonitoringRegion(region)
        saveContext()
        updateFetchResult()
    }
    
    func removeObjectAtIndex(indexPath: NSIndexPath) {
        let region = fetchedResultsController.objectAtIndexPath(indexPath) as! RegionInfo
        stopMonitoringRegion(region)
        self.managedObjectContext.deleteObject(region)
        saveContext()
        updateFetchResult()
    }
    
    func updateFetchResult() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func startMonitoringSavedRegions() {
        updateFetchResult()
        for region in fetchedResultsController.fetchedObjects as! [RegionInfo]{
            startMonitoringRegion(region)
        }
    }
    
    private func startMonitoringRegion(regionInfo: RegionInfo) {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: regionInfo.uuid)!, identifier: regionInfo.name)
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    private func stopMonitoringRegion(regionInfo: RegionInfo) {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: regionInfo.uuid)!, identifier: regionInfo.name)
        locationManager.stopMonitoringForRegion(beaconRegion)
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }
    
    func stopMonitoringCurrentRegions() {
//        updateFetchResult()
        for region in fetchedResultsController.fetchedObjects as! [RegionInfo]{
            startMonitoringRegion(region)
        }
    }
}

extension RegionsPool: NSFetchedResultsControllerDelegate {
    
}