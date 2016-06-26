//
//  RegionsController.swift
//  iBeaconManager
//
//  Created by Максим on 26.06.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import CoreData

class RegionsController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    var regionPool: RegionsPool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        regionPool = RegionsPool.getInstance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTeam(sender: AnyObject) {
        let alert = UIAlertController(title: "Region Info",
            message: "Add a new region Info",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) in
            textField.placeholder = "Region Name"
        }
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) in
            textField.placeholder = "Region UUID"
        }

        alert.addAction(UIAlertAction(title: "Save",
            style: .Default, handler: { (action: UIAlertAction!) in
                
                let nameTextField = alert.textFields![0]
                let zoneTextField = alert.textFields![1]
                
                self.regionPool.addObject((nameTextField.text)!, withUUID: (zoneTextField.text)!)
                
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
            style: .Default, handler: { (action: UIAlertAction!) in
                print("Cancel")
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return regionPool.sectionsCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionPool.rowsInSection(section)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RegionCell", forIndexPath: indexPath)
        
        let region = regionPool.getObjectAtIndex(indexPath)
        cell.textLabel?.text = region.name
        cell.detailTextLabel?.text = region.uuid
        return cell
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            addButton.enabled = true
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            regionPool.removeObjectAtIndex(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}
