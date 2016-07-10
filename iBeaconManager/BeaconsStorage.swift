//
//  BeaconsStorage.swift
//  iBeaconManager
//
//  Created by matyushenko on 01.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

//import Foundation
import CoreLocation

class BeaconStorage: NSObject {
    /// Сохраненные пользователем маячки.
    var storedBeacons: [BeaconItem]
    
    /// Маяки, которые находятся в зоне видимости пользователя, но он их не сохранил.
    var otherBeacons = [CLBeacon]()
    
    weak var delegate: BeaconsStorageDelegate?
    
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
    
    /// Метод сохраняет маяк в storedBeacons
    func keepBeaconInStorage(beacon: BeaconItem) {
        let usrDef = NSUserDefaults.standardUserDefaults()
        storedBeacons.append(beacon)
        let storedData = NSKeyedArchiver.archivedDataWithRootObject(storedBeacons)
      
        usrDef.setObject(storedData, forKey: "SavedBeacons")
        usrDef.synchronize()
    }
    
    /// Метод возвращает информацю о маяке по заданному индексу таблицы.
    func getBeaconForIndexPath(indexPath: NSIndexPath) -> CLBeacon {
        if indexPath.section == 0 {
            return storedBeacons[indexPath.row].info
        }
        return otherBeacons[indexPath.row]
    }
    
    func getStoredBeaconItem(forBeacon beacon: CLBeacon) -> BeaconItem? {
        for item in storedBeacons {
            if item == beacon {
                return item
            }
        }
        return nil
    }
    
    func saveBeaconIfNeed() {
        for beacon in otherBeacons {
            if beacon.accuracy < 0.05 {
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
        self.otherBeacons.removeAll()
        
        for beacon in beacons {
            if let savedBeacon = getStoredBeaconItem(forBeacon: beacon) {
                savedBeacon.info = beacon
            } else {
                self.otherBeacons.append(beacon)
            }
        }
        delegate?.updateBeaconsData()
        saveBeaconIfNeed()
    }
}