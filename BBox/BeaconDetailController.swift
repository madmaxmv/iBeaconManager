//
//  BeaconDetailController.swift
//  iBeaconManager
//
//  Created by Максим on 10.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import CoreLocation

protocol BeaconDetailControllerDelegate: class {
    func beaconDetailControllerDidCancel()
    func beaconDetailControllerDidSaveNewBeacon(beacon: BeaconItem)
}

class BeaconDetailController: UITableViewController {
    
    @IBOutlet weak var beaconNameTextField: UITextField!
    @IBOutlet weak var UUIDLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    
    var beacon: BeaconItem!
    
    weak var delegate: BeaconDetailControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beaconNameTextField.placeholder = beacon.name
        UUIDLabel.text = beacon.UUID
        majorLabel.text = beacon.major.stringValue
        minorLabel.text = beacon.minor.stringValue
        
        let tapAnyWhere = UITapGestureRecognizer(target: self, action: #selector(BeaconDetailController.dismissKeyboard))
        tapAnyWhere.cancelsTouchesInView = false // позволит обрабатывать дальнейшие события
        view.addGestureRecognizer(tapAnyWhere)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        delegate.beaconDetailControllerDidCancel()
    }
    
    @IBAction func save(sender: AnyObject) {
        beacon.name = beaconNameTextField.text!
        delegate.beaconDetailControllerDidSaveNewBeacon(beacon: beacon)
    }
 
    func dismissKeyboard() {
        beaconNameTextField.resignFirstResponder()
    }
}
