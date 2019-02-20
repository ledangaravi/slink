//
//  OverviewCell.swift
//  SLINK
//
//  Created by XIN ZHOU on 11/02/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit

class OverviewCell: UITableViewCell { //Cell for the overview of a historic WOD
    
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var WODTitle: UILabel!
    @IBOutlet weak var BreakDurationLabel: UILabel!
    @IBOutlet weak var AdviceLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
