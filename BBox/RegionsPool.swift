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
    private var locationManager: CLLocationManager
    
    class func getInstance() -> RegionsPool {
        return singlePool
    }
    
    private override init() {
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Region> = { [unowned self] in
        let fetchReqest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Region", in: self.managedObjectContext)
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
        
        return fetchedResultsController as! NSFetchedResultsController<Region>
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
        return fetchedResultsController.object(at: indexPath as IndexPath)
    }
    
    func addObject(name: String, withUUID uuid: String) {
        
        let region = NSEntityDescription.insertNewObject(forEntityName: "Region", into: managedObjectContext) as! Region
        
        region.name = name
        region.uuid = uuid
        startMonitoringRegion(region: region)
        managedObjectContext.saveContext()
        fetchedResultsController.update()
    }
    
    func removeObjectAtIndex(indexPath: NSIndexPath) {
        let region = fetchedResultsController.object(at: indexPath as IndexPath) 
        stopMonitoringRegion(region: region)
        self.managedObjectContext.delete(region)
        managedObjectContext.saveContext()
        fetchedResultsController.update()
    }
    
    func startMonitoringRegions(delegate: CLLocationManagerDelegate) {
        fetchedResultsController.update()
        for region in (fetchedResultsController.fetchedObjects as [Region]?) ?? [] {
            startMonitoringRegion(region: region)
        }
        locationManager.delegate = delegate
        locationManager.activityType = .otherNavigation
    }
    
    private func startMonitoringRegion(region: Region) {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(uuidString: region.uuid)! as UUID, identifier: region.name)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    private func stopMonitoringRegion(region: Region) {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(uuidString: region.uuid)! as UUID, identifier: region.name)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    func stopMonitoringRegions() {
        for region in (fetchedResultsController.fetchedObjects as [Region]?) ?? [] {
            stopMonitoringRegion(region: region)
        }
        locationManager.delegate = nil
    }
}
