//
//  StatsCell.swift
//  SLINK
//
//  Created by XIN ZHOU on 10/02/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit
import Charts

class StatsCell: UITableViewCell { //Cell to present statistics for each historic exercise within a historic WOD
    @IBOutlet weak var exerciseTitle: UILabel!
    @IBOutlet weak var chart1View: LineChartView!
    @IBOutlet weak var chart2View: LineChartView!
    
    var entries1 = [ChartDataEntry]()
    var entries2 = [ChartDataEntry]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
}
