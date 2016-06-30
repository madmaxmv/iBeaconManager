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
    var regionsPool: RegionsPool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        regionsPool = RegionsPool.getInstance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTeam(sender: AnyObject) {
        self.performSegueWithIdentifier("AddRegion", sender: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return regionsPool.sectionsCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionsPool.rowsInSection(section)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RegionCell", forIndexPath: indexPath)
        
        let region = regionsPool.getObjectAtIndex(indexPath)
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
            regionsPool.removeObjectAtIndex(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddRegion" {
            let controller = segue.destinationViewController as! AddRegionViewController
            controller.delegate = self
        }
    }
}

extension RegionsController: AddRegionViewControllerDelegate {
    func addRegion(name: String, withUUID uuid: String) {
        regionsPool?.addObject(name, withUUID: uuid)
        tableView.reloadData()
        navigationController?.popViewControllerAnimated(true)
    }
}
