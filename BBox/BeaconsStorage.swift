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
    var savedBeacons: [BeaconItem]  = [BeaconItem]()
    /// Маяки, которые находятся в зоне видимости пользователя, но он их не сохранил.
    var availableBeacons = [BeaconItem]()
    
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
    
    lazy var fetchedResultsController: NSFetchedResultsController<Beacon> = {
        let fetchReqest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Beacon", in: self.managedObjectContext!)
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
        
        return fetchedResultsController as! NSFetchedResultsController<Beacon>
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
        for beacon in (fetchedResultsController.fetchedObjects as [Beacon]?) ?? [] {
            savedBeacons.append(beacon.asBeaconItem)
        }
    }
    
    /// Метод сохраняет маяк в массив сохраненных пользователем маяков (savedBeacons).
    func keepBeaconInStorage(beacon: BeaconItem) {
        savedBeacons.append(beacon)
        removeBeaconFromOthers(beacon: beacon)
        
        if let managedContext = managedObjectContext {
            let beaconEntity = NSEntityDescription.insertNewObject(forEntityName: "Beacon", into: managedContext) as! Beacon
            beaconEntity.fillingFrom(beaconItem: beacon)
        
            managedContext.saveContext()
            fetchedResultsController.update()
        }
    }
    
    /// Метод удаляет маяк из списка сохраненных.
    func removeBeaconWithIndexPathFormSaved(indexPath: NSIndexPath) {
        savedBeacons.remove(at: indexPath.row)
        
        if let managedContext = managedObjectContext {
            let beaconEntity = fetchedResultsController.object(at: indexPath as IndexPath) 
            managedContext.delete(beaconEntity)
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
        availableBeacons.remove(at: index)
    }
    
    /// Ищет beacon в массиве, если находит то возвращает его.
    func getBeaconItem(beacon: CLBeacon, inStorage storage: [BeaconItem]) -> BeaconItem? {
        for item in storage {
            if item == beacon {
                return item
            }
        }
        return nil
    }
    
    func saveBeaconIfNeed() {
        for beacon in availableBeacons {
            if !beacon.info!.accuracy.isLess(than: 0.0) && beacon.info!.accuracy < 0.05 {
                let _ = delegate?.canSaveBeaconInStorage(beacon: beacon)
            }
        }
    }
}

extension BeaconStorage: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager did failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            if let savedBeacon = getBeaconItem(beacon: beacon, inStorage: savedBeacons) {
                savedBeacon.info = beacon
            } else if let otherBeacon = getBeaconItem(beacon: beacon, inStorage: availableBeacons){
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
