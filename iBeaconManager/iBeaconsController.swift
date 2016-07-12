//
//  ViewController.swift
//  iBeaconManager
//
//  Created by Максим on 24.06.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import CoreLocation
import hndlSegue

class iBeaconsController: UITableViewController {

    private var beaconsStorage = BeaconStorage.getInstance()
    private var regionPool = RegionsPool.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        beaconsStorage.delegate = self
        
        let cellNib = UINib(nibName: "BeaconCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "BeaconCell")
        tableView.rowHeight = 110
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
         regionPool.startMonitoringRegions()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        regionPool.stopMonitoringRegions()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       return beaconsStorage.noEmptyStorageCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Секций может быть две. Первая с маяками которые были сохранены пользователем.
        // Вторая со всеми маяками, находящимися в зоне видимости.
        return beaconsStorage.beaconsCountInStorageForSection(section)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return beaconsStorage.storageDescriptionForSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCell", forIndexPath: indexPath) as? BeaconViewCell
        
        let beacon = beaconsStorage.getBeaconForIndexPath(indexPath)
        
        cell!.beaconItem = beacon
        beacon.observer = cell
        cell?.updateDataInCell()
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if !beaconsStorage.storedBeacons.isEmpty && indexPath.section == 0 {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            beaconsStorage.removeBeaconFormStoredWithIndexPath(indexPath)
            tableView.reloadData()
        }
    }
}

extension iBeaconsController: BeaconsStorageDelegate {

    func newBeaconDetected() {
        tableView.reloadData()
    }
    
    func canSaveBeaconInStorage(beacon: BeaconItem) -> Bool {
        regionPool.stopMonitoringRegions()
        performSegueWithIdentifier("SaveBeacon", sender: beacon as AnyObject) { segue, sender in
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! BeaconDetailController
            
            controller.delegate = self
            controller.beacon = sender as! BeaconItem
        }
        return false
    }
}

extension iBeaconsController: BeaconDetailControllerDelegate {
    func beaconDetailControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func beaconDetailControllerDidSaveNewBeacon(beacon: BeaconItem) {
        beaconsStorage.keepBeaconInStorage(beacon)
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
}