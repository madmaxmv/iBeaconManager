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
    /// Информация о маячке
    var info: CLBeacon
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("beaconName") as! String
        info = aDecoder.decodeObjectForKey("beaconInfo") as! CLBeacon
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "beaconName")
        aCoder.encodeObject(info, forKey: "beaconInfo")
    }
}