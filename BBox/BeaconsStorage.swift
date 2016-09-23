//
//  BeaconsStorage.swift
//  iBeaconManager
//
//  Created by matyushenko on 01.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import CoreLocation

class BeaconStorage: NSObject {
    /// Сохраненные пользователем маячки.
    private var savedBeacons: [BeaconItem]
    /// Маяки, которые находятся в зоне видимости пользователя, но он их не сохранил.
    private var availableBeacons = [BeaconItem]()
    
    /// Делегат.
    weak var delegate: BeaconsStorageDelegate?

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
        let userDefaults = NSUserDefaults.standardUserDefaults()
        savedBeacons = [BeaconItem]()
        if let storedData = userDefaults.objectForKey("SavedBeacons") as? NSData{
            if let items = NSKeyedUnarchiver.unarchiveObjectWithData(storedData) as? [BeaconItem] {
                savedBeacons.appendContentsOf(items)
            }
        }
    }
    
    
    /// Метод возвращает информацю о сохраненном маяке по заданному индексу таблицы.
    func getSavedBeaconForIndexPath(indexPath: NSIndexPath) -> BeaconItem {
        return savedBeacons[(indexPath as NSIndexPath).row]
    }
    /// Метод возвращает информацю о доступном маяке по заданному индексу таблицы.
    func getAvailableBeaconForIndexPath(indexPath: NSIndexPath) -> BeaconItem {
        return availableBeacons[(indexPath as NSIndexPath).row]
    }
    
    /// Метод сохраняет маяк в массив сохраненных пользователем маяков (savedBeacons).
    func keepBeaconInStorage(beacon: BeaconItem) {
        let usrDef = NSUserDefaults.standardUserDefaults()
        savedBeacons.append(beacon)
        removeBeaconFromOthers(beacon)
        
        let storedData = NSKeyedArchiver.archivedDataWithRootObject(savedBeacons)
      
        usrDef.setObject(storedData, forKey: "SavedBeacons")
        usrDef.synchronize()
    }
    
    /// Метод удаляет маяк из списка сохраненных.
    func removeBeaconWithIndexPathFormSaved(indexPath: NSIndexPath) {
        let usrDef = NSUserDefaults.standardUserDefaults()
        savedBeacons.removeAtIndex((indexPath as NSIndexPath).row)
        let storedData = NSKeyedArchiver.archivedDataWithRootObject(savedBeacons)
        
        usrDef.setObject(storedData, forKey: "SavedBeacons")
        usrDef.synchronize()
    }

    private func removeBeaconFromOthers(beacon: BeaconItem) {
        var index = 0
        for item in availableBeacons {
            if beacon == item.info {
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
            if !beacon.info.accuracy.isSignMinus && beacon.info.accuracy < 0.02 {
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
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for beacon in beacons {
            if let savedBeacon = getBeaconItem(beacon, inStorage: savedBeacons) {
                savedBeacon.info = beacon
            } else if let otherBeacon = getBeaconItem(beacon, inStorage: availableBeacons){
                otherBeacon.info = beacon
            } else {
                let newBeacon = BeaconItem()
                newBeacon.info = beacon
                availableBeacons.append(newBeacon)
                delegate?.newBeaconDetected()
            }
        }
        saveBeaconIfNeed()
    }
}
