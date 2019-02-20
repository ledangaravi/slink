//
//  createExerciseTableViewCell.swift
//  SLINK
//
//  Created by XIN ZHOU on 02/02/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit

class createExerciseTableViewCell: UITableViewCell {

    @IBAction func addset2(_ sender: UIButton) {
        delegate?.AddSetButtonPressed()
    }
    
    @IBAction func addset1(_ sender: Any) {
        delegate?.AddSetButtonPressed()
    }
    @IBOutlet weak var addSetButton: UIButton!
    @IBOutlet weak var addSet: UIButton!
    
    var delegate: AddSetCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.init(red:0.11, green:0.11, blue:0.11, alpha:1.0) //#1C1C1D
        addSet.tintColor = UIColor.init(red: 254/255, green: 252/255, blue: 118/255, alpha: 1)
        addSetButton.tintColor = UIColor.init(red: 254/255, green: 252/255, blue: 118/255, alpha: 1)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
