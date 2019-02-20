//
//  StartWODCell.swift
//  SLINK
//
//  Created by XIN ZHOU on 08/02/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit

class StartWODCell: UITableViewCell {

    @IBOutlet weak var startButton: UIButton!
    
    var delegate: StartWODDelegate?
    
    @IBAction func startwod(_ sender: UIButton) {
        delegate?.scanQR()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startButton.backgroundColor = UIColor.white
        startButton.isEnabled = true
        startButton.layer.cornerRadius = 5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
