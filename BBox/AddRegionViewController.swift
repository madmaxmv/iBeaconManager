//
//  AddRegionViewController.swift
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
    
    lazy var uuidRegex: NSRegularExpression? = {
        do {
            let regex = try NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: [.caseInsensitive])
            return regex
        } catch {
            return nil
        }
    }()
    private var nameFieldValid = false
    private var UUIDFieldValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBarButtonItem.isEnabled = false
        
        do {
            uuidRegex = try NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: [.caseInsensitive])
        } catch {
            print("No NSRegularExpression")
        }
        
        nameTextField.addTarget(self, action: #selector(AddRegionViewController.nameTextFieldChanged(_:)), for: .editingChanged)
        uuidTextField.addTarget(self, action: #selector(AddRegionViewController.uuidTextFieldChanged(_:)), for: .editingChanged)
    }
    
    @IBAction func saveRegion() {
        delegate!.addRegion(name: nameTextField.text!, withUUID: uuidTextField.text!)
    }
    
    func nameTextFieldChanged(_ textField: UITextField) {
        nameFieldValid = (textField.text!.characters.count > 0)
        saveBarButtonItem.isEnabled = (UUIDFieldValid && nameFieldValid)
    }
    
    func uuidTextFieldChanged(_ textField: UITextField) {
        if let uuidRegEx = uuidRegex {
            let numberOfMatches = uuidRegEx.numberOfMatches(in: textField.text!, options: [.reportProgress], range: NSMakeRange(0, textField.text!.characters.count))
            UUIDFieldValid = (numberOfMatches > 0)
            saveBarButtonItem.isEnabled = (UUIDFieldValid && nameFieldValid)
        }
    }
}
