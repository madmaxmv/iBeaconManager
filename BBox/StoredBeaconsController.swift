//
//  StoredBeaconsController.swift
//  iBeaconManager
//
//  Created by Максим on 24.06.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import CoreLocation
import hndlSegue

class StoredBeaconsController: UITableViewController {

    private var beaconsStorage = BeaconStorage.getInstance()
    private var regionPool = RegionsPool.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        beaconsStorage.delegate = self
        
        self.title = NSLocalizedString("StoredBeaconsController.title", comment: "Saved beacons")
        let cellNib = UINib(nibName: "BeaconCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "BeaconCell")
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableViewAutomaticDimension
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
        return (beaconsStorage.countOfBeaconsInStorage != 0)
            ? 1
            : 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconsStorage.countOfBeaconsInStorage
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCell", forIndexPath: indexPath) as? BeaconViewCell
        
        let beacon = beaconsStorage.getSavedBeaconForIndexPath(indexPath)
        
        cell!.beaconItem = beacon
        beacon.observer = cell
        cell?.updateDataInCell()
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            beaconsStorage.removeBeaconWithIndexPathFormSaved(indexPath)
            tableView.reloadData()
        }
    }
}

extension StoredBeaconsController: BeaconsStorageDelegate {

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

extension StoredBeaconsController: BeaconDetailControllerDelegate {
    func beaconDetailControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func beaconDetailControllerDidSaveNewBeacon(beacon: BeaconItem) {
        beaconsStorage.keepBeaconInStorage(beacon)
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
