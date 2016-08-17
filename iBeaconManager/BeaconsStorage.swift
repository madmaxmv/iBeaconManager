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
        let userDefaults = UserDefaults.standard()
        savedBeacons = [BeaconItem]()
        if let storedData = userDefaults.object(forKey: "SavedBeacons") as? Data{
            if let items = NSKeyedUnarchiver.unarchiveObject(with: storedData) as? [BeaconItem] {
              savedBeacons.append(contentsOf: items)
            }
        }
    }
    
    
    /// Метод возвращает информацю о сохраненном маяке по заданному индексу таблицы.
    func getSavedBeaconForIndexPath(_ indexPath: IndexPath) -> BeaconItem {
        return savedBeacons[(indexPath as NSIndexPath).row]
    }
    /// Метод возвращает информацю о доступном маяке по заданному индексу таблицы.
    func getAvailableBeaconForIndexPath(_ indexPath: IndexPath) -> BeaconItem {
        return availableBeacons[(indexPath as NSIndexPath).row]
    }
    
    /// Метод сохраняет маяк в массив сохраненных пользователем маяков (savedBeacons).
    func keepBeaconInStorage(_ beacon: BeaconItem) {
        let usrDef = UserDefaults.standard()
        savedBeacons.append(beacon)
        removeBeaconFromOthers(beacon)
        
        let storedData = NSKeyedArchiver.archivedData(withRootObject: savedBeacons)
      
        usrDef.set(storedData, forKey: "SavedBeacons")
        usrDef.synchronize()
    }
    
    /// Метод удаляет маяк из списка сохраненных.
    func removeBeaconWithIndexPathFormSaved(_ indexPath: IndexPath) {
        let usrDef = UserDefaults.standard()
        savedBeacons.remove(at: (indexPath as NSIndexPath).row)
        let storedData = NSKeyedArchiver.archivedData(withRootObject: savedBeacons)
        
        usrDef.set(storedData, forKey: "SavedBeacons")
        usrDef.synchronize()
    }

    private func removeBeaconFromOthers(_ beacon: BeaconItem) {
        var index = 0
        for item in availableBeacons {
            if beacon == item.info {
                break
            }
            index += 1
        }
        availableBeacons.remove(at: index)
    }
    
    /// Ищет beacon в массиве, если находит то возвращает его.
    private func getBeaconItem(_ beacon: CLBeacon, inStorage storage: [BeaconItem]) -> BeaconItem? {
        for item in storage {
            if item == beacon {
                return item
            }
        }
        return nil
    }
    
    private func saveBeaconIfNeed() {
        for beacon in availableBeacons {
            if !beacon.info.accuracy.sign && beacon.info.accuracy < 0.02 {
                delegate?.canSaveBeaconInStorage(beacon)
            }
        }
    }
}

extension BeaconStorage: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: NSError) {
        print("Failed monitoring region: \(error.description)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager did failed: \(error.description)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
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
