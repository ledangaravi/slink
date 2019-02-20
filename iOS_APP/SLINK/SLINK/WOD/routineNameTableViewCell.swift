//
//  routineNameTableViewCell.swift
//  SLINK
//
//  Created by XIN ZHOU on 01/02/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit

class routineNameTableViewCell: UITableViewCell {

    
    var delegate: RoutineNameChangedDelegate?
    
    @IBOutlet weak var routineTitleTextField: UITextField!
    
    @IBAction func enterPressed(_ sender: UITextField) {
        if routineTitleTextField.text?.count != 0{
            routineTitleTextField.endEditing(true)
            delegate?.routineNameChanged(newName: routineTitleTextField.text!)
        }


    }

    @IBAction func editingDidBegin(_ sender: UITextField) {
        delegate?.routineNameStartedEditing()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
