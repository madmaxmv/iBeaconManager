//
//  ViewController.swift
//  iBeaconManager
//
//  Created by Максим on 22.06.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import CoreLocation

class iBeaconListController: UITableViewController {

    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) {
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

extension iBeaconListController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
    }
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: NSError) {
        
    }
}

