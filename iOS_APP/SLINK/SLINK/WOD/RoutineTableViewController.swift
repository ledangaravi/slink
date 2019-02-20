//
//  RoutineTableViewController.swift
//  
//
//  Created by XIN ZHOU on 01/02/2019.
//

import UIKit
import AWSDynamoDB

//Protocols for passing data & triggering functions across view controllers:
protocol NewSetDelegate{
    func NewSet(exercisename: String)
}

protocol RoutineNameChangedDelegate{
    func routineNameChanged(newName: String)
    func routineNameStartedEditing()
}

protocol AddSetCellDelegate{
    func AddSetButtonPressed()
}

protocol  StartWODDelegate {
    func scanQR()
}



class RoutineTableViewController: UITableViewController, NewSetDelegate, RoutineNameChangedDelegate, AddSetCellDelegate,StartWODDelegate {
    
    @IBOutlet var tableview: UITableView!
    
    var isAddingNew: Bool = false //Whether a new exercise is being added
    var chosenExerciseIndex: Int = Int() //index of chosen exercise
    
    var routineTitle: String = String() // Title of WOD
    var exerciseList: [String] = [String]() //exercise names
    var databaseExerciseList: [String] = [String]() //exercise names frtched from database
    var databaseRepList: [String] = [String]() // list of reps fetched from database
    var databaseWeightList: [String] = [String]() //list of weights fetched from database
    
    func scanQR(){// triggered when "START WOD" button is pressed
        self.performSegue(withIdentifier: "segue3", sender: nil)
    }
    
    func routineNameChanged(newName: String){ // need to update database when routine name is changed
        deleteSet(routinename: routineTitle)
        routineTitle = newName
        uploadSet(routinename: routineTitle, exerciselist: databaseExerciseList, weightlist: databaseWeightList, replist: databaseRepList)
        tableview.allowsSelection = true
        tableview.reloadData()
    }
    
    func routineNameStartedEditing(){
        tableview.allowsSelection = false
    }
    
    func AddSetButtonPressed(){
        isAddingNew = true
         self.performSegue(withIdentifier: "segue2", sender: nil)
    }

    
    func NewSet(exercisename: String){
        let updatedElements = DecodeExerciseDescription(exercisedescription: exercisename)
        if isAddingNew{
            // append new exercise (name, reps and weight) to lists:
            exerciseList.append(exercisename)
            databaseExerciseList.append(updatedElements[0])
            databaseRepList.append(updatedElements[1])
            databaseWeightList.append(updatedElements[2])
        }else{
            //update existing entry in the lists:
            exerciseList[chosenExerciseIndex] = exercisename
            databaseExerciseList[chosenExerciseIndex] = updatedElements[0]
            databaseRepList[chosenExerciseIndex] = updatedElements[1]
            databaseWeightList[chosenExerciseIndex] = updatedElements[2]
        }
        tableview.reloadData()
        uploadSet(routinename: routineTitle, exerciselist: databaseExerciseList, weightlist: databaseWeightList, replist: databaseRepList)
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load nibs of cells
        let nib = UINib(nibName: "routineNameTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "routineTitleCell")
        
        let nib2 = UINib(nibName: "createExerciseTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "AddSetCell")
        
        let nib3 = UINib(nibName: "StartWODCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "StartWOD")
        
        let nib4 = UINib(nibName: "EmptyCell", bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: "empty")
        
    }

    // able view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return exerciseList.count+4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{ // Cell for title
            let cell = tableView.dequeueReusableCell(withIdentifier: "routineTitleCell", for: indexPath) as? routineNameTableViewCell
                if !(routineTitle == "new_supersecure"){
                    cell?.routineTitleTextField.text = routineTitle
                }else{
                    tableview.allowsSelection = false
                    cell?.routineTitleTextField.becomeFirstResponder()
                }
            cell?.delegate = self
            return cell!
        }else if indexPath.row == exerciseList.count+1{ // Cell for "add set" button
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSetCell", for: indexPath) as! createExerciseTableViewCell
            cell.delegate = self
            return cell
        }else if indexPath.row == exerciseList.count+2{ //basically a spacer for aesthetic reasons
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) as! EmptyCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == exerciseList.count+3{ // button to start the workout
            let cell = tableView.dequeueReusableCell(withIdentifier: "StartWOD", for: indexPath) as! StartWODCell
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }else{ //The cells to show what exercises are in the WOD
            let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath) as? ExerciseTableViewCell
            cell!.exercise.text = exerciseList[indexPath.row-1]
            cell!.backgroundColor = UIColor.init(red:0.11, green:0.11, blue:0.11, alpha:1.0)
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row <= exerciseList.count+1{
            if indexPath.row == exerciseList.count+1{
                isAddingNew = true
            }else{
                isAddingNew = false
                chosenExerciseIndex = indexPath.row-1
            }
            self.performSegue(withIdentifier: "segue2", sender: nil)
        }
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // pass essential data
        if let vc : ExerciseEditViewController = segue.destination as? ExerciseEditViewController{ // if an existing exercise within a WOD is being edited or a new exericse is being created
            vc.delegate = self
        }else if let vc: QRScanViewController = segue.destination as? QRScanViewController{ // if the WOD is being started
            vc.wodname = self.routineTitle
            vc.exList = self.databaseExerciseList
            vc.repList = self.databaseRepList
            vc.wList = self.databaseWeightList
        }
        
        
        
    }
    
    func uploadSet(routinename: String, exerciselist: [String], weightlist: [String], replist: [String]) { //update database
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        let routine: Routines = Routines()
        
        
        routine._routineName = routinename
        routine._exerciseList = exerciselist
        routine._weightList = weightlist
        routine._repList = replist
        
        
        //Save a new item
        dynamoDbObjectMapper.save(routine, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
    }
    
    func DecodeExerciseDescription(exercisedescription: String) -> [String]{ // read exercise name, reps and weight from description(title)
        //INDEX:
        // 0: exercise name, 1: rep count, 2: weight count
        var output = [String]()
        var exerciseName = String()
        var repCount = String()
        var weightCount = String()

        var indexSwitcher = 0
        for letter in exercisedescription{
            if indexSwitcher == 0{
                if letter != "|"{
                    exerciseName.append(letter)
                }else{
                    indexSwitcher = 1
                    exerciseName.removeLast()
                }
            }else if indexSwitcher == 1{
                if letter != " "{
                    repCount.append(letter)
                }else{
                    if repCount.count != 0{
                        indexSwitcher = 2
                    }
                }
            }else if indexSwitcher == 2{
                if letter != " " && letter != "R" && letter != "E" && letter != "P" && letter != "S" && letter != "|"{
                    weightCount.append(letter)
                }else{
                    if weightCount.count != 0{
                        indexSwitcher = 3
                    }
                }
            }
        }
        output.append(exerciseName)
        output.append(repCount)
        output.append(weightCount)
        return output
    }
    
    func deleteSet(routinename: String) { // delete item from database
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
