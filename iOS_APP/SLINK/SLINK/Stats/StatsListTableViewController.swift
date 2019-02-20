//
//  StatsListTableViewController.swift
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

class StatsListTableViewController: UITableViewController {
    var statsList: [String] = [String]() //List of titles of historic WODs
    var timeStampList: [String] = [String]() //List of UNIQUE Timestamps
    var chosenCellIndex = Int() // index of the selected cell

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Scan Database Table to fetch relevant data (historic WODs)
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        let userNAME = self.getUsername()
        var timestampExists = false
        scanExpression.limit = 100
        statsList.removeAll()

        dynamoDbObjectMapper.scan(DATA.self, expression: scanExpression, completionHandler: {(objectModel: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Read Error: \(error)")
                return
            }
            
            for exercise in objectModel!.items{
                if exercise.value(forKey: "_uName") as? String == userNAME{
                    timestampExists = false
                    let timeStamp = self.truncTimestamp(timeStamp_plus_num: exercise.value(forKey: "_timePlusNum") as! String)
                    for stats in self.statsList{
                        if stats == timeStamp {
                            //Timestamp exists -> Table Item is an exercise of a WOD that is already scanned
                            timestampExists = true
                        }
                    }
                    if !timestampExists{
                        // Timestamp does not exist -> table item is the first exercise of a new WOD
                        self.statsList.append(timeStamp)
                    }
                }
            }
            
            self.timeStampList = self.convertTimeList(unixTime: self.statsList)
            self.tableView.reloadData() //update view after fetching database data
        })
    }

    // Init/Reload Tableview data:

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeStampList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath)
        cell.textLabel?.text = timeStampList[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    // When a cell (a WOD) is chosen:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenCellIndex = indexPath.row
        self.performSegue(withIdentifier: "segueStats", sender: nil)
    }
    

    
    func getUsername()->String?{ //Fetch Username from AWS
        let serviceConfiguration = AWSServiceConfiguration(region: .EUWest2, credentialsProvider: nil)
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "5cep6ndcsg9kajsql3ls5g4un", clientSecret: "8eg2j0clh2l0kv04qdkmjqv8adetvdnp2ajtdsvusrvaol2odp0", poolId: "eu-west-2_eEXOvkpzt")
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: "slink_userpoolapp_MOBILEHUB_286091421")
        let pool = AWSCognitoIdentityUserPool(forKey: "slink_userpoolapp_MOBILEHUB_286091421")
        return pool.currentUser()?.username
    }
    
    
    func convertTimeList(unixTime: [String]) -> [String]{ //Format the date and time
        var dateList = [String]()
        var counter = 0
        for _ in unixTime{
            let date = NSDate(timeIntervalSince1970: Double(unixTime[counter])!)
            dateList.append(date.aws_stringValue("dd.MM.yyyy | HH:mm"))
            counter = counter + 1
        }
        return dateList
    }
    
    func truncTimestamp(timeStamp_plus_num: String) -> String{ //round the timestamp (floor) to omit miliseconds
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //Pass timestamp to next view
        if let vc : StatsTableController = segue.destination as? StatsTableController{
            vc.truncedTimeStamp = statsList[chosenCellIndex]
        }
    }
    

}
