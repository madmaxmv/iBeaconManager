//
//  BesideBeaconsController.swift
//  iBeaconManager
//
//  Created by Максим on 31.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit

class BesideBeaconsController: UITableViewController {

    var beaconsStorage = BeaconStorage.getInstance()
    var regionPool = RegionsPool.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beaconsStorage.delegate = self
        
        self.title = NSLocalizedString("BesideBeaconsController.title", comment: "Beside beacons")
        let cellNib = UINib(nibName: "BeaconCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "BeaconCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 110
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        regionPool.startMonitoringRegions(delegate: beaconsStorage)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        regionPool.stopMonitoringRegions()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (beaconsStorage.countOfAvailableBeacons != 0)
            ? 1
            : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconsStorage.countOfAvailableBeacons
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell", for: indexPath as IndexPath) as? BeaconViewCell
        
        let beacon = beaconsStorage.getAvailableBeaconForIndexPath(indexPath: indexPath as NSIndexPath)
        
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
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! BeaconDetailController
            
            controller.delegate = self
            controller.beacon = sender as! BeaconItem
        }
        return false
    }
}

extension BesideBeaconsController: BeaconDetailControllerDelegate {
    func beaconDetailControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func beaconDetailControllerDidSaveNewBeacon(beacon: BeaconItem) {
        beaconsStorage.keepBeaconInStorage(beacon: beacon)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
