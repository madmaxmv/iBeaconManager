//
//  BeaconsStorageDelegate.swift
//  iBeaconManager
//
//  Created by Максим on 09.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

protocol  BeaconsStorageDelegate: class {
    func newBeaconDetected()
    func canSaveBeaconInStorage(beacon: BeaconItem) -> Bool
}