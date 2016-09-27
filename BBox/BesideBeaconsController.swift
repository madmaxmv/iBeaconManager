//
//  BesideBeaconsController.swift
//  iBeaconManager
//
//  Created by Максим on 31.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit

class BesideBeaconsController: UITableViewController {

    private var beaconsStorage = BeaconStorage.getInstance()
    private var regionPool = RegionsPool.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beaconsStorage.delegate = self
        
        self.title = NSLocalizedString("BesideBeaconsController.title", comment: "Beside beacons")
        let cellNib = UINib(nibName: "BeaconCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "BeaconCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 110
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
        return (beaconsStorage.countOfAvailableBeacons != 0)
            ? 1
            : 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconsStorage.countOfAvailableBeacons
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCell", forIndexPath: indexPath) as? BeaconViewCell
        
        let beacon = beaconsStorage.getAvailableBeaconForIndexPath(indexPath)
        
        cell!.beaconItem = beacon
        beacon.observer = cell
        cell?.updateDataInCell()
        
        return cell!
    }
}

extension BesideBeaconsController: BeaconsStorageDelegate {
    
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

extension BesideBeaconsController: BeaconDetailControllerDelegate {
    func beaconDetailControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func beaconDetailControllerDidSaveNewBeacon(beacon: BeaconItem) {
        beaconsStorage.keepBeaconInStorage(beacon)
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
