//
//  BeaconsStorage.swift
//  iBeaconManager
//
//  Created by matyushenko on 01.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconStorage: NSObject {
    /// Сохраненные пользователем маячки.
    var storedBeacons: [BeaconItem]
    
    /// Маяки, которые находятся в зоне видимости пользователя, но он их не сохранил.
    var otherBeacons = [CLBeacon]()
    
    /// Количество сохраненных маяков в зане видимости.
    var storedBeaconsInSight: Int {
        var count = 0
        for beacon in storedBeacons where beacon.isInSight {
            count += 1
        }
        return count
    }
    
    weak var delegate: BeaconsStorageDelegate?
    
    static private let singleStorage = BeaconStorage()
    
    class func getInstance() -> BeaconStorage {
        return singleStorage
    }
    
    private override init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        storedBeacons = [BeaconItem]()
        if let items = userDefaults.arrayForKey("SavedBeacons") as? [BeaconItem] {
            storedBeacons.appendContentsOf(items)
        }
        
    }
    
    /// Метод сохраняет маяк в storedBeacons
    func keepBeaconInStorage() {
        
    }
    
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
    }
}