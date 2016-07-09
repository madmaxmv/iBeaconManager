//
//  ViewController.swift
//  iBeaconManager
//
//  Created by Максим on 24.06.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import CoreLocation

class iBeaconsController: UITableViewController {

    private var beaconsStorage = BeaconStorage.getInstance()
    private var regionPool = RegionsPool.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        regionPool.startMonitoringSavedRegions()
        beaconsStorage.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Секций может быть две. Первая с маяками которые были сохранены пользователем.
        // Вторая со всеми маяками, находящимися в зоне видимости.
        if section == 0 {
            return beaconsStorage.storedBeacons.count
        }
        return beaconsStorage.otherBeacons.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if beaconsStorage.storedBeacons.isEmpty {
                return nil
            }
            return "Сохраненные"
        }
        return "Доступные"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCell", forIndexPath: indexPath)
        
        let beacon = beaconsStorage.getBeaconForIndexPath(indexPath) 
        
        cell.textLabel?.text = "iBeacon"
        cell.detailTextLabel?.text = beacon.accuracy.description
        return cell
    }
}

extension iBeaconsController: BeaconsStorageDelegate {
    func updateBeaconsData() {
        tableView.reloadData()
    }
}