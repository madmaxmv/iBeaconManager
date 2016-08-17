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
        tableView.register(cellNib, forCellReuseIdentifier: "BeaconCell")
        
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.rowHeight = 110
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         regionPool.startMonitoringRegions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        regionPool.stopMonitoringRegions()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (beaconsStorage.countOfBeaconsInStorage != 0)
            ? 1
            : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconsStorage.countOfBeaconsInStorage
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell", for: indexPath) as? BeaconViewCell
        
        let beacon = beaconsStorage.getSavedBeaconForIndexPath(indexPath)
        
        cell!.beaconItem = beacon
        beacon.observer = cell
        cell?.updateDataInCell()
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            beaconsStorage.removeBeaconWithIndexPathFormSaved(indexPath)
            tableView.reloadData()
        }
    }
}

extension StoredBeaconsController: BeaconsStorageDelegate {

    func newBeaconDetected() {
        tableView.reloadData()
    }
    
    func canSaveBeaconInStorage(_ beacon: BeaconItem) -> Bool {
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
        dismiss(animated: true, completion: nil)
    }
    
    func beaconDetailControllerDidSaveNewBeacon(_ beacon: BeaconItem) {
        beaconsStorage.keepBeaconInStorage(beacon)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
