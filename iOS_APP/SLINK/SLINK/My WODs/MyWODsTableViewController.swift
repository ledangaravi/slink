//
//  MyWODsTableTableViewController.swift
//  SLINK
//
//  Created by XIN ZHOU on 31/01/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit
import AWSDynamoDB

class MyWODsTableViewController: UITableViewController {
    var routineList: [String] = [String]() // List of WOD titles
    var chosenRoutine: String = String() //the WOD that was chosen
    var exerciseArray: [[String]] = [[String]]() //Array of exercises each WOD holds
    var exerciseDescriptionList: [String] = [String]() //Description = Exercisename + Reps + Weight
    var fetchedExerciseList: [[String]] = [[String]]() //Fetched from databse
    var fetchedRepList: [[String]] = [[String]]() //Fetched from databse
    var fetchedWeightList: [[String]] = [[String]]() //Fetched from databse
    var isNew: Bool = Bool() //Whether the WOD is newly created
    var chosenCellIndex: Int = Int() // index of the chosen cell (chosen WOD)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = .zero //programmicaly change the inset of seperators to 0. Could not successfully change in Storyboard, weirdly
        print(routineList)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        readRoutines() //fetch WODs from database
    }
    

    @IBAction func addRoutine(_ sender: UIBarButtonItem) {
        chosenRoutine = "new_supersecure"
        isNew = true
        self.performSegue(withIdentifier: "segue1", sender: nil)
    }
    
    // init/reload tableview data:
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routineList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "routineCell", for: indexPath)
        
        cell.textLabel?.text = routineList[indexPath.row]

        return cell
    }
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteSet(routinename: routineList[indexPath.row])
            routineList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Override to indicate which cell is chosen
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenRoutine = routineList[indexPath.row]
        exerciseDescriptionList = exerciseArray[indexPath.row]
        isNew = false
        chosenCellIndex = indexPath.row
        self.performSegue(withIdentifier: "segue1", sender: nil)
    }
    

    // Pass data before new view is loaded
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("chosenRoutine is: \(chosenRoutine)")
        let nextVC = segue.destination as? RoutineTableViewController
        nextVC?.routineTitle = chosenRoutine
        if !isNew{
            nextVC?.exerciseList = exerciseDescriptionList
            nextVC?.databaseExerciseList = fetchedExerciseList[chosenCellIndex]
            nextVC?.databaseRepList = fetchedRepList[chosenCellIndex]
            nextVC?.databaseWeightList = fetchedWeightList[chosenCellIndex]
        }
    }
    
    func readRoutines() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 20

        
        dynamoDbObjectMapper.scan(Routines.self, expression: scanExpression, completionHandler: {(objectModel: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Read Error: \(error)")
                return
            }
            self.routineList.removeAll()
            var counter = 0
            self.exerciseArray.removeAll()
            for routine in objectModel!.items{
                let routineName: String = routine.value(forKey: "routineName") as! String
                self.fetchedExerciseList.append(routine.value(forKey: "exerciseList") as! [String])
                self.fetchedRepList.append(routine.value(forKey: "repList") as! [String])
                self.fetchedWeightList.append(routine.value(forKey: "weightList") as! [String])

                self.exerciseArray.append(self.getExerciseDescription(ExerciseName: self.fetchedExerciseList[self.fetchedExerciseList.count-1], RepCount: self.fetchedRepList[self.fetchedRepList.count-1], WeightCount: self.fetchedWeightList[self.fetchedWeightList.count-1]))
                
                self.routineList.append(routineName)
                
                counter = counter + 1
            }
            self.tableView.reloadData()
        })
    }
    
    func getExerciseDescription(ExerciseName: [String], RepCount: [String], WeightCount: [String]) -> [String]{ //Format titles of cells
        var exerciseDes = [String]()
        var i = 0
        for exercisename in ExerciseName{
            let exercise = exercisename + " | " + RepCount[i] + " REPS | " + WeightCount[i] + " KG"
            exerciseDes.append(exercise)
            i = i + 1
        }
        return exerciseDes
    }
    
    
    func deleteSet(routinename: String) { // delete item from database table
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        let itemToDelete = Routines()
        itemToDelete?._routineName = routinename
        
        dynamoDbObjectMapper.remove(itemToDelete!, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print(" Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was deleted.")
        })
    }
    


}
