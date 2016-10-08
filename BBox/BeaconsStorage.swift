//
//  BeaconsStorage.swift
//  iBeaconManager
//
//  Created by matyushenko on 01.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import CoreLocation
import CoreData

class BeaconStorage: NSObject {
    
    let defaultBeaconName = "Unknown"
    
    /// Сохраненные пользователем маячки.
    private var savedBeacons: [BeaconItem]  = [BeaconItem]()
    /// Маяки, которые находятся в зоне видимости пользователя, но он их не сохранил.
    private var availableBeacons = [BeaconItem]()
    
    /// Делегат для отображения новых ключей.
    weak var delegate: BeaconsStorageDelegate?

    var managedObjectContext: NSManagedObjectContext?
    
    var countOfBeaconsInStorage: Int {
        return savedBeacons.count
    }
    var countOfAvailableBeacons: Int {
        return availableBeacons.count
    }
    
    static private let singleStorage = BeaconStorage()
    
    class func getInstance() -> BeaconStorage {
        return singleStorage
    }
    
    private override init() {
        super.init()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchReqest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Beacon", inManagedObjectContext: self.managedObjectContext!)
        fetchReqest.entity = entity
        
        let sortDescriptorByName = NSSortDescriptor(key: "name", ascending: true)
        fetchReqest.sortDescriptors = [sortDescriptorByName]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchReqest,
            managedObjectContext: self.managedObjectContext!,
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

    
    /// Метод возвращает информацю о сохраненном маяке по заданному индексу таблицы.
    func getSavedBeaconForIndexPath(indexPath: NSIndexPath) -> BeaconItem {
        return savedBeacons[indexPath.row]
    }
    /// Метод возвращает информацю о доступном маяке по заданному индексу таблицы.
    func getAvailableBeaconForIndexPath(indexPath: NSIndexPath) -> BeaconItem {
        return availableBeacons[indexPath.row]
    }
    
    func loadBeaconFromStorage() {
        let beacons = fetchedResultsController.fetchedObjects as? [Beacon]
        for beacon in beacons ?? [] {
            savedBeacons.append(beacon.asBeaconItem)
        }
    }
    
    /// Метод сохраняет маяк в массив сохраненных пользователем маяков (savedBeacons).
    func keepBeaconInStorage(beacon: BeaconItem) {
        savedBeacons.append(beacon)
        removeBeaconFromOthers(beacon)
        
        if let managedContext = managedObjectContext {
            let beaconEntity = NSEntityDescription.insertNewObjectForEntityForName("Beacon", inManagedObjectContext: managedContext) as! Beacon
            beaconEntity.fillingFrom(beaconItem: beacon)
        
            managedContext.saveContext()
            fetchedResultsController.update()
        }
    }
    
    /// Метод удаляет маяк из списка сохраненных.
    func removeBeaconWithIndexPathFormSaved(indexPath: NSIndexPath) {
        savedBeacons.removeAtIndex(indexPath.row)
        
        if let managedContext = managedObjectContext {
            let beaconEntity = fetchedResultsController.objectAtIndexPath(indexPath) as! Beacon
            managedContext.deleteObject(beaconEntity)
            managedContext.saveContext()
            fetchedResultsController.update()
        }
    }

    private func removeBeaconFromOthers(beacon: BeaconItem) {
        var index = 0
        for item in availableBeacons {
            if beacon == item {
                break
            }
            index += 1
        }
        availableBeacons.removeAtIndex(index)
    }
    
    /// Ищет beacon в массиве, если находит то возвращает его.
    private func getBeaconItem(beacon: CLBeacon, inStorage storage: [BeaconItem]) -> BeaconItem? {
        for item in storage {
            if item == beacon {
                return item
            }
        }
        return nil
    }
    
    private func saveBeaconIfNeed() {
        for beacon in availableBeacons {
            if !beacon.info!.accuracy.isSignMinus && beacon.info!.accuracy < 0.05 {
                delegate?.canSaveBeaconInStorage(beacon)
            }
        }
    }
}

extension BeaconStorage: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: NSError) {
        print("Failed monitoring region: \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager did failed: \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        for beacon in beacons {
            if let savedBeacon = getBeaconItem(beacon, inStorage: savedBeacons) {
                savedBeacon.info = beacon
            } else if let otherBeacon = getBeaconItem(beacon, inStorage: availableBeacons){
                otherBeacon.info = beacon
            } else {
                let newBeacon = BeaconItem(name: defaultBeaconName, beacon: beacon)
                availableBeacons.append(newBeacon)
                delegate?.newBeaconDetected()
            }
        }
        saveBeaconIfNeed()
    }
}

extension BeaconStorage: NSFetchedResultsControllerDelegate {}
