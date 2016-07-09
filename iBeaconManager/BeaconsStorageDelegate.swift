//
//  BeaconsStorageDelegate.swift
//  iBeaconManager
//
//  Created by Максим on 09.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import Foundation

protocol  BeaconsStorageDelegate: class {
    /// Метод делегата, которому необходимо обновить данные.
    func updateBeaconsData()
}