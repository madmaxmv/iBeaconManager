//
//  Beacon+CLBeacon.swift
//  BBox
//
//  Created by Максим on 27.09.16.
//  Copyright © 2016 Personal. All rights reserved.
//

import CoreLocation

extension Beacon {
    
    func fillingFrom(beaconItem beacon: BeaconItem){
        self.major = beacon.info!.major
        self.minor = beacon.info!.minor
        self.uuid = beacon.info!.proximityUUID.UUIDString
        self.name = beacon.name
    }
    
    var asBeaconItem: BeaconItem {
        return BeaconItem(name: name, major: major, minor: minor, UUID: uuid)
    }
}
