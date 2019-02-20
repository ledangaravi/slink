//
//  ExerciseTableViewCell.swift
//  SLINK
//
//  Created by XIN ZHOU on 03/02/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {

    @IBOutlet weak var exercise: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
