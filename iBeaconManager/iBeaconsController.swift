//
//  ViewController.swift
//  iBeaconManager
//
//  Created by Максим on 24.06.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class iBeaconsController: UITableViewController {

    private var regionPool = RegionsPool.getInstance()
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension iBeaconsController: CLLocationManagerDelegate {
    
}