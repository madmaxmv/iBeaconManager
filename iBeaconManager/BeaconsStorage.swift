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
    var storedBeacons: [BeaconItem]
    
    /// Маяки, которые находятся в зоне видимости пользователя, но он их не сохранил.
    var otherBeacons = [BeaconItem]()
    
    /// Делегат.
    weak var delegate: BeaconsStorageDelegate?
    
    /// Возвращает количество не пустых массивов с маяками
    /// Если есть сохраненные и в зоне видимости, то 2
    /// Если оба массива пусты, то 0. Иначе 1.
    var noEmptyStorageCount: Int {
        if (!storedBeacons.isEmpty && !otherBeacons.isEmpty) {
            return 2
        } else if (storedBeacons.isEmpty && otherBeacons.isEmpty) {
            return 0
        }
        return 1
    }

    static private let singleStorage = BeaconStorage()
    
    class func getInstance() -> BeaconStorage {
        return singleStorage
    }
    
    private override init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        storedBeacons = [BeaconItem]()
        if let storedData = userDefaults.objectForKey("SavedBeacons") as? NSData{
            if let items = NSKeyedUnarchiver.unarchiveObjectWithData(storedData) as? [BeaconItem] {
              storedBeacons.appendContentsOf(items)
            }
        }
    }
    
    /// Возвращает количества маяков в соотвествующем массиве для секции таблицы.
    func beaconsCountInStorageForSection(section: Int) -> Int {
        if section == 0 && !storedBeacons.isEmpty {
            return storedBeacons.count
        }
        return otherBeacons.count
    }
    
    /// Возвращает название хранилища маяков по секции таблицы.
    func storageDescriptionForSection(section: Int) -> String {
        if section == 0 && !storedBeacons.isEmpty {
            return "Сохраненные"
        }
        return "Доступные"
    }
    
    /// Метод сохраняет маяк в массив сохраненных пользователем маяков (storedBeacons).
    func keepBeaconInStorage(beacon: BeaconItem) {
        let usrDef = NSUserDefaults.standardUserDefaults()
        storedBeacons.append(beacon)
        removeBeaconFromOthers(beacon)
        
        let storedData = NSKeyedArchiver.archivedDataWithRootObject(storedBeacons)
      
        usrDef.setObject(storedData, forKey: "SavedBeacons")
        usrDef.synchronize()
    }
    
    /// Метод удаляет маяк из списка сохраненных.
    func removeBeaconFormStoredWithIndexPath(indexPath: NSIndexPath) {
        let usrDef = NSUserDefaults.standardUserDefaults()
        storedBeacons.removeAtIndex(indexPath.row)
        let storedData = NSKeyedArchiver.archivedDataWithRootObject(storedBeacons)
        
        usrDef.setObject(storedData, forKey: "SavedBeacons")
        usrDef.synchronize()
    }
    
    /// Метод возвращает информацю о маяке по заданному индексу таблицы.
    func getBeaconForIndexPath(indexPath: NSIndexPath) -> BeaconItem {
        if indexPath.section == 0 && !storedBeacons.isEmpty{
            return storedBeacons[indexPath.row]
        }
        return otherBeacons[indexPath.row]
    }
    
    private func removeBeaconFromOthers(beacon: BeaconItem) {
        var index = 0
        for item in otherBeacons {
            if beacon == item.info {
                break
            }
            index += 1
        }
        otherBeacons.removeAtIndex(index)
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
        for beacon in otherBeacons {
            if !beacon.info.accuracy.isSignMinus && beacon.info.accuracy < 0.05 {
                delegate?.canSaveBeaconInStorage(beacon)
            }
        }
    }
}

extension BeaconStorage: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Failed monitoring region: \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager did failed: \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        for beacon in beacons {
            if let savedBeacon = getBeaconItem(beacon, inStorage: storedBeacons) {
                savedBeacon.info = beacon
            } else if let otherBeacon = getBeaconItem(beacon, inStorage: otherBeacons){
                otherBeacon.info = beacon
            } else {
                let newBeacon = BeaconItem()
                newBeacon.info = beacon
                otherBeacons.append(newBeacon)
                delegate?.newBeaconDetected()
            }
        }
        saveBeaconIfNeed()
    }
}