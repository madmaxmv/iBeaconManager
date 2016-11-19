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
    var info: CLBeacon? {
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
        self.init(name: name, major: beacon.major, minor: beacon.minor, UUID: beacon.proximityUUID.uuidString)
        self.info = beacon
    }
    
    deinit {
        print("deinit beacon")
    }
}

func ==(left: BeaconItem, right: BeaconItem) -> Bool {
    return (left.UUID == right.UUID)
        && (left.major.description == right.major.description)
        && (left.minor.description == right.minor.description)
}

func ==(left: BeaconItem, right: CLBeacon) -> Bool {
    return (left.UUID == right.proximityUUID.uuidString)
        && (left.major.description == right.major.description)
        && (left.minor.description == right.minor.description)
}
