//
//  StatsTableController.swift
//  SLINK
//
//  Created by XIN ZHOU on 14/02/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSAuthCore
import AWSCognitoIdentityProvider
import AWSMobileClient
import AWSUserPoolsSignIn
import Charts


class StatsTableController: UITableViewController {
    var truncedTimeStamp: String = String() // Data passed by the previous view
    var WODTitle = "WOD TITLE" // Title of WOD
    var rownumber = Int() // number of rows in the table, used for init/reload
    var exerciseList: [String] = [String]() // List of exercises in the WOD
    var forceList: [[String]] = [[String]]() //2D Array, dataset for the force
    var speedList: [[String]] = [[String]]() //2D Array, dataset for the speed
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //register the cell nibs(.xib)
        let nib = UINib(nibName: "OverviewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "OverviewCell")
        
        let nib2 = UINib(nibName: "StatsCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "statcell")
        
        //scan database table for data
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 100
        let userNAME = self.getUsername()
        
        dynamoDbObjectMapper.scan(DATA.self, expression: scanExpression, completionHandler: {(objectModel: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Read Error: \(error)")
                return
            }
            
            for exercise in objectModel!.items{
                if exercise.value(forKey: "_uName") as? String == userNAME{
                    let timeStamp = self.truncTimestamp(timeStamp_plus_num: exercise.value(forKey: "_timePlusNum") as! String)
                    if timeStamp == self.truncedTimeStamp{
                        self.WODTitle = exercise.value(forKey: "_wODName") as! String
                        self.exerciseList.append(exercise.value(forKey: "_exName") as! String)
                        self.speedList.append(exercise.value(forKey: "_speedList") as! [String])
                        self.forceList.append(exercise.value(forKey: "_forceList") as! [String])
                    }
                }
            }
            self.rownumber = 1 + self.exerciseList.count
            self.tableView.reloadData()
        })
    }

    // init/reload table data:

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rownumber
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{ //First cell: overview of historic WOD
            let cell = tableView.dequeueReusableCell(withIdentifier: "OverviewCell", for: indexPath) as! OverviewCell
            cell.WODTitle.text = WODTitle
            let date = NSDate(timeIntervalSince1970: Double(self.truncedTimeStamp)!)
            cell.timeStampLabel.text = date.aws_stringValue("dd.MM.yyyy | HH:mm")
            return cell
        }else{ // One cell for each exercise
            let cell = tableView.dequeueReusableCell(withIdentifier: "statcell", for: indexPath) as! StatsCell
            var repCount:Int = 0
            var entries1 = [ChartDataEntry]()
            var entries2 = [ChartDataEntry]()
            for force in forceList[indexPath.row-1]{
                repCount = repCount+1
                entries1.append(ChartDataEntry.init(x: Double(repCount), y:Double(Double(force)!/500)))
            }
            
            
            //Load Data & init graphs for each exercise cell:
            repCount = 0
            for speed in speedList[indexPath.row-1]{
                repCount = repCount+1
                entries2.append(ChartDataEntry.init(x: Double(repCount), y: Double(speed)!))
            }

            let line1 = LineChartDataSet(values: entries1, label: "")
            line1.colors = [NSUIColor.white]
            line1.drawCirclesEnabled = false
            line1.drawValuesEnabled = false
            line1.lineWidth = 1.5
            
            let data = LineChartData()
            data.addDataSet(line1)
            data.highlightEnabled = false
            
            cell.chart1View.dragEnabled = false
            cell.chart1View.pinchZoomEnabled = false
            cell.chart1View.setScaleEnabled(false)
            cell.chart1View.legend.enabled = false
            cell.chart1View.drawBordersEnabled = false
            cell.chart1View.borderColor = UIColor.white
            
            cell.chart1View.xAxis.drawGridLinesEnabled = true
            cell.chart1View.xAxis.gridLineDashLengths = [2,4]
            cell.chart1View.xAxis.labelPosition = .bottom
            cell.chart1View.xAxis.drawAxisLineEnabled = false
            cell.chart1View.leftAxis.drawGridLinesEnabled = true
            cell.chart1View.rightAxis.drawGridLinesEnabled = false
            cell.chart1View.leftAxis.enabled = true
            cell.chart1View.rightAxis.enabled = false
            cell.chart1View.leftAxis.drawAxisLineEnabled = false
            cell.chart1View.leftAxis.drawLabelsEnabled = true
            
            cell.chart1View.xAxis.labelCount = 5
            cell.chart1View.leftAxis.labelTextColor = UIColor.white

            cell.chart1View.data = data
            
            let line2 = LineChartDataSet(values: entries2, label: "")
            line2.colors = [NSUIColor.white]
            line2.drawCirclesEnabled = false
            line2.drawValuesEnabled = false
            line2.lineWidth = 1.5
            
            let data2 = LineChartData()
            data2.addDataSet(line2)
            data2.highlightEnabled = false
            
            cell.chart2View.dragEnabled = false
            cell.chart2View.pinchZoomEnabled = false
            cell.chart2View.setScaleEnabled(false)
            cell.chart2View.legend.enabled = false
            cell.chart2View.drawBordersEnabled = false
            cell.chart2View.borderColor = UIColor.white
            
            cell.chart2View.xAxis.drawGridLinesEnabled = true
            cell.chart2View.xAxis.gridLineDashLengths = [2,4]
            cell.chart2View.xAxis.labelPosition = .bottom
            cell.chart2View.xAxis.drawAxisLineEnabled = false
            cell.chart2View.leftAxis.drawGridLinesEnabled = true
            cell.chart2View.rightAxis.drawGridLinesEnabled = false
            cell.chart2View.leftAxis.enabled = true
            cell.chart2View.rightAxis.enabled = false
            cell.chart2View.leftAxis.drawAxisLineEnabled = false
            cell.chart2View.leftAxis.drawLabelsEnabled = true
            
            cell.chart2View.xAxis.labelCount = 5
            cell.chart2View.leftAxis.labelTextColor = UIColor.white
            
            cell.chart2View.data = data2
            cell.exerciseTitle.text = exerciseList[indexPath.row-1]
            return cell
        }
    }

    
    func convertTimeList(unixTime: [String]) -> [String]{ //format into wanted date-time format
        var dateList = [String]()
        var counter = 0
        for _ in unixTime{
            let date = NSDate(timeIntervalSince1970: Double(unixTime[counter])!)
            dateList.append(date.aws_stringValue("dd.MM.yyyy | HH:mm"))
            counter = counter + 1
        }
        return dateList
    }
    
    func truncTimestamp(timeStamp_plus_num: String) -> String{ //omit miliseconds
        var timestamp = ""
        var stop = false
        for char in timeStamp_plus_num{
            if char == "."{
                stop = true
            }
            if !stop{
                timestamp.append(char)
            }
            
        }
        return timestamp
    }
    

    
    func getUsername()->String?{
        let serviceConfiguration = AWSServiceConfiguration(region: .EUWest2, credentialsProvider: nil)
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "5cep6ndcsg9kajsql3ls5g4un", clientSecret: "8eg2j0clh2l0kv04qdkmjqv8adetvdnp2ajtdsvusrvaol2odp0", poolId: "eu-west-2_eEXOvkpzt")
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: "slink_userpoolapp_MOBILEHUB_286091421")
        let pool = AWSCognitoIdentityUserPool(forKey: "slink_userpoolapp_MOBILEHUB_286091421")
        return pool.currentUser()?.username
    }

}
