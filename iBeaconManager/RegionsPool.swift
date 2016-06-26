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

class RegionsPool: NSObject {
    
//    private var locationManager = CLLocationManager()
//    private var beaconsUDIDs = [NSUUID]()
    
    static private let singlePool = RegionsPool()
    var managedObjectContext: NSManagedObjectContext!
    
    
    class func getInstance() -> RegionsPool {
        return singlePool
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
        saveContext()
    }
    
    func removeObjectAtIndex(indexPath: NSIndexPath) {
        let object = fetchedResultsController.objectAtIndexPath(indexPath) as! RegionInfo
        self.managedObjectContext.deleteObject(object)
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
//    func hasUUID(uuid: NSUUID) -> Bool {
//        print(uuid.description)
//        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid.description)
//        if fetchedResultsController.s
//        return beaconsUDIDs.contains(uuid)
//    }
//

//
//    func removeBeaconUUID(uuid: NSUUID) {
//        if let index = beaconsUDIDs.indexOf(uuid){
//            beaconsUDIDs.removeAtIndex(index)
//            stopMonitoringBeacon(uuid)
//        }
//    }
//    
//    func startMonitorinBeacon(uuid: NSUUID){
//        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "iBeaconsManager")
//        locationManager.startMonitoringForRegion(beaconRegion)
//        locationManager.startRangingBeaconsInRegion(beaconRegion)
//    }
//    
//    func stopMonitoringBeacon(uuid: NSUUID) {
//        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "iBeaconsManager")
//        locationManager.stopMonitoringForRegion(beaconRegion)
//        locationManager.stopRangingBeaconsInRegion(beaconRegion)
//    }
}
//
//extension BeaconsPool: CLLocationManagerDelegate{
//    
//    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
//        if beacons.count > 0 {
//            print(beacons.first)
//        }
//    }
//    
//    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        if let beaconRegion = region as? CLBeaconRegion {
////            print(beaconRegion.)
//        }
//    }
//}

extension RegionsPool: NSFetchedResultsControllerDelegate {
    
}