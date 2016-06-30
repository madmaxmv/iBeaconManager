//
//  AddUUIDViewController.swift
//  iBeaconManager
//
//  Created by Максим on 01.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit

protocol AddRegionViewControllerDelegate: class {
    func addRegion(name: String, withUUID uuid: String)
}

class AddRegionViewController: UITableViewController {
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var uuidTextField: UITextField!
    
    weak var delegate: AddRegionViewControllerDelegate?
    
    var uuidRegex: NSRegularExpression?
    var nameFieldValid = false
    var UUIDFieldValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBarButtonItem.enabled = false
        
        do {
            uuidRegex = try NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: [.CaseInsensitive])
        } catch {
            print("No NSRegularExpression")
        }
        
        nameTextField.addTarget(self, action: #selector(AddRegionViewController.nameTextFieldChanged(_:)), forControlEvents: .EditingChanged)
        uuidTextField.addTarget(self, action: #selector(AddRegionViewController.uuidTextFieldChanged(_:)), forControlEvents: .EditingChanged)
    }
    
    @IBAction func saveRegion() {
        delegate!.addRegion(nameTextField.text!, withUUID: uuidTextField.text!)
    }
    
    func nameTextFieldChanged(textField: UITextField) {
        nameFieldValid = (textField.text!.characters.count > 0)
        saveBarButtonItem.enabled = (UUIDFieldValid && nameFieldValid)
    }
    
    func uuidTextFieldChanged(textField: UITextField) {
        let numberOfMatches = uuidRegex!.numberOfMatchesInString(textField.text!, options: [.ReportProgress], range: NSMakeRange(0, textField.text!.characters.count))
        UUIDFieldValid = (numberOfMatches > 0)
        saveBarButtonItem.enabled = (UUIDFieldValid && nameFieldValid)
    }
}
