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
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchReqest = NSFetchRequest()
        let entity = NSEntityDescription.entity(forEntityName: "RegionInfo", in: self.managedObjectContext)
        fetchReqest.entity = entity
        
        let sortDescriptorByName = SortDescriptor(key: "name", ascending: true)
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
    
    func rowsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func getObjectAtIndex(_ indexPath: IndexPath) -> RegionInfo {
        return fetchedResultsController.object(at: indexPath) as! RegionInfo
    }
    
    func addObject(_ name: String, withUUID uuid: String) {
        
        let region = NSEntityDescription.insertNewObject(forEntityName: "RegionInfo",
            into: self.managedObjectContext)
            as! RegionInfo
        
        region.name = name
        region.uuid = uuid
        startMonitoringRegion(region)
        saveContext()
        updateFetchResult()
    }
    
    func removeObjectAtIndex(_ indexPath: IndexPath) {
        let region = fetchedResultsController.object(at: indexPath) as! RegionInfo
        stopMonitoringRegion(region)
        self.managedObjectContext.delete(region)
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
    
    func startMonitoringRegions() {
        updateFetchResult()
        for region in fetchedResultsController.fetchedObjects as! [RegionInfo]{
            startMonitoringRegion(region)
        }
        locationManager.delegate = BeaconStorage.getInstance()
    }
    
    private func startMonitoringRegion(_ regionInfo: RegionInfo) {
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: regionInfo.uuid)!, identifier: regionInfo.name)
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    private func stopMonitoringRegion(_ regionInfo: RegionInfo) {
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: regionInfo.uuid)!, identifier: regionInfo.name)
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    func stopMonitoringRegions() {
        for region in fetchedResultsController.fetchedObjects as! [RegionInfo]{
            stopMonitoringRegion(region)
        }
        locationManager.delegate = nil
    }
}

extension RegionsPool: NSFetchedResultsControllerDelegate {
    
}
