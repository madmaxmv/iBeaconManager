//
//  TableViewCell.swift
//  iBeaconManager
//
//  Created by Максим on 12.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit

class BeaconViewCell: UITableViewCell, BeaconCellData {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var beaconImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    weak var beaconItem: BeaconItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = 10.0
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateDataInCell() {
        nameLabel.text = beaconItem?.name
        distanceLabel.text = beaconItem?.info?.accuracy.description
    }
}

protocol BeaconCellData: class{
    func updateDataInCell()
}
