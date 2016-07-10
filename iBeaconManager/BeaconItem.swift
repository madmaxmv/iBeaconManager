//
//  beaconInfo.swift
//  iBeaconManager
//
//  Created by Максим on 09.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconItem: NSObject, NSCoding {
    /// Имя конкретного маячка.
    var name: String!
    /// Информация о маячке.
    var info: CLBeacon!
    
    var isInSight: Bool = false
    
    required override init() {
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("beaconName") as! String
        info = aDecoder.decodeObjectForKey("beaconInfo") as! CLBeacon
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "beaconName")
        aCoder.encodeObject(info, forKey: "beaconInfo")
    }
    
    func beaconIsInSight() {
        isInSight = true
    }
    
    func beaconIsntInSight() {
        isInSight = false
    }
}

func ==(left: BeaconItem, right: CLBeacon) -> Bool {
    let result = left.info.proximityUUID == right.proximityUUID &&
                 left.info.major == right.major &&
                 left.info.minor == right.minor
    return result
}