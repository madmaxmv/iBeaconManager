//
//  beaconInfo.swift
//  iBeaconManager
//
//  Created by Максим on 09.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconItem {
    /// Имя конкретного маячка.
    var name: String
    
    /// Если маячек сохранен но не в зоне видимости информация о его неизменяемых параметрах:
    var major: NSNumber
    var minor: NSNumber
    var UUID: String

    /// Информация о маячке.
    var info: CLBeacon! {
        willSet {
            observer?.updateDataInCell()
        }
    }
    
    var humanDistance: String {
        return ""
    }
    
    weak var observer: BeaconCellData?
    
    required init(name: String, major: NSNumber, minor: NSNumber, UUID: String) {
        self.name = name
        self.major = major
        self.minor = minor
        self.UUID = UUID
    }
    
    convenience init(name: String, beacon: CLBeacon) {
        self.init(name: name, major: beacon.major, minor: beacon.minor, UUID: beacon.proximityUUID.UUIDString)
        self.info = beacon
    }
    
    deinit {
        print("deinit beacon")
    }
}

func ==(left: BeaconItem, right: CLBeacon) -> Bool {
    let result = left.info.proximityUUID == right.proximityUUID &&
                 left.info.major == right.major &&
                 left.info.minor == right.minor
    return result
}
