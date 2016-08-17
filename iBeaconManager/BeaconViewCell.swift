//
//  TableViewCell.swift
//  iBeaconManager
//
//  Created by Максим on 12.07.16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit

class BeaconViewCell: UITableViewCell, BeaconCellData {

    @IBOutlet weak var beaconImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var UUIDLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    
    weak var beaconItem: BeaconItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateDataInCell() {
        nameLabel.text = beaconItem?.name
        distanceLabel.text = beaconItem?.info.accuracy.description
        UUIDLabel.text = beaconItem?.info.proximityUUID.uuidString
        majorLabel.text = beaconItem?.info.major.description
        minorLabel.text = beaconItem?.info.minor.description
    }
}

protocol BeaconCellData: class{
    func updateDataInCell()
}
