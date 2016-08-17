//
//  RegionsController.swift
//  iBeaconManager
//
//  Created by Максим on 26.06.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import hndlSegue

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
    
    @IBAction func addTeam(_ sender: AnyObject) {
        self.performSegueWithIdentifier("AddRegion", sender: nil) { segue, sender in
            let controller = segue.destinationViewController as! AddRegionViewController
            controller.delegate = self
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return regionsPool.sectionsCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionsPool.rowsInSection(section)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell", for: indexPath)
        
        let region = regionsPool.getObjectAtIndex(indexPath)
        cell.textLabel?.text = region.name
        cell.detailTextLabel?.text = region.uuid
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            regionsPool.removeObjectAtIndex(indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension RegionsController: AddRegionViewControllerDelegate {
    func addRegion(_ name: String, withUUID uuid: String) {
        regionsPool?.addObject(name, withUUID: uuid)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}
