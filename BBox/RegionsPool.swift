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
class RegionsPool: NSObject, NSFetchedResultsControllerDelegate {
    
    static private let singlePool = RegionsPool()
    var managedObjectContext: NSManagedObjectContext!
    private var locationManager = CLLocationManager()
    
    class func getInstance() -> RegionsPool {
        return singlePool
    }
    
    private override init() {
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchReqest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Region", inManagedObjectContext: self.managedObjectContext)
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
    
    func getObjectAtIndex(indexPath: NSIndexPath) -> Region {
        return fetchedResultsController.objectAtIndexPath(indexPath) as! Region
    }
    
    func addObject(name: String, withUUID uuid: String) {
        
        let region = NSEntityDescription.insertNewObjectForEntityForName("Region", inManagedObjectContext: managedObjectContext) as! Region
        
        region.name = name
        region.uuid = uuid
        startMonitoringRegion(region)
        managedObjectContext.saveContext()
        fetchedResultsController.update()
    }
    
    func removeObjectAtIndex(indexPath: NSIndexPath) {
        let region = fetchedResultsController.objectAtIndexPath(indexPath) as! Region
        stopMonitoringRegion(region)
        self.managedObjectContext.deleteObject(region)
        managedObjectContext.saveContext()
        fetchedResultsController.update()
    }
    
    func startMonitoringRegions() {
        fetchedResultsController.update()
        for region in fetchedResultsController.fetchedObjects as! [Region]{
            startMonitoringRegion(region)
        }
        locationManager.delegate = BeaconStorage.getInstance()
    }
    
    private func startMonitoringRegion(region: Region) {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: region.uuid)!, identifier: region.name)
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    private func stopMonitoringRegion(region: Region) {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: region.uuid)!, identifier: region.name)
        locationManager.stopMonitoringForRegion(beaconRegion)
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }
    
    func stopMonitoringRegions() {
        for region in fetchedResultsController.fetchedObjects as! [Region]{
            stopMonitoringRegion(region)
        }
        locationManager.delegate = nil
    }
}
