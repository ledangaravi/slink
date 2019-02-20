//
//  TableViewCell.swift
//  SLINK
//
//  Created by XIN ZHOU on 31/01/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit

class routineCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.init(red:0.11, green:0.11, blue:0.11, alpha:1.0) //#1C1C1D
        self.textLabel?.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
