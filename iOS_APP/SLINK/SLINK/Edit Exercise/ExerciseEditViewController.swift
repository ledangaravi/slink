//
//  ExerciseEditViewController.swift
//  SLINK
//
//  Created by XIN ZHOU on 02/02/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSAuthCore
import AWSAuthUI
import AWSCognitoIdentityProvider
import AWSMobileClient
import AWSUserPoolsSignIn

class ExerciseEditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var delegate:NewSetDelegate?
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var exercisePicker: UIPickerView!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    var isCreatingNewExercise: Bool = Bool() // Whether a new exercise is being created
    var exerciseList = [String]()
    var repList = [String]()
    var weightList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.exercisePicker.delegate = self
        self.exercisePicker.dataSource = self
        exercisePicker.backgroundColor = UIColor.black
        exercisePicker.tintColor = UIColor.white
        nameField.isEnabled = false

        LoadExercises() //fetch exercises
        
        exerciseList.append("Fetching Exercises...")
        
        repList = ["5 REPS","10 REPS","15 REPS","20 REPS","25 REPS","30 REPS","35 REPS","40 REPS","45 REPS","50 REPS","55 REPS","60 REPS","65 REPS","70 REPS","75 REPS","80 REPS","85 REPS","90 REPS","95 REPS","100 REPS","105 REPS","110 REPS","115 REPS","120 REPS","125 REPS","130 REPS","135 REPS","140 REPS","145 REPS","150 REPS"]
        weightList = ["1 KG","2 KG","3 KG","4 KG","5 KG","6 KG","7 KG","8 KG","9 KG"]
        
        nameField.text = exerciseList[0]
        repLabel.text = repList[0]
        weightLabel.text = weightList[0]
    }
    
    
    @IBAction func enterPressed(_ sender: UITextField) { // press enter on keyboarf to stop editing the textfield
        enableSave()
    }
    
    
    @IBAction func screenTouched(_ sender: UITapGestureRecognizer) { //Press anywhere to stop editing the textfield
        enableSave()
    }
    
    @IBAction func saved(_ sender: UIBarButtonItem) { // save button pressed
        delegate?.NewSet(exercisename: nameField.text! + " | " + repLabel.text! + " | " + weightLabel.text!)
        
        if isCreatingNewExercise{
            uploadSet(exercisename: nameField.text ?? "")
        }
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    
    //Pickerview data source:
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return 200
        case 1:
            return 90
        default:
            return 50
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return exerciseList.count
        case 1:
            return repList.count
        default:
            return weightList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        switch component {
        case 0:
            //Pick the exercise:
            let exerciseTitle:UILabel = UILabel()
            exerciseTitle.textColor = UIColor.white
            if row == exerciseList.count-1{
                // Create your own exercise, highlighted thtough the yellow text colour
                exerciseTitle.textColor = UIColor.init(red: 254/255, green: 252/255, blue: 118/255, alpha: 1)
            }
            exerciseTitle.font = exerciseTitle.font.withSize(20)
            exerciseTitle.text = exerciseList[row]
            return exerciseTitle

        case 1:
            //Pick the Reps:
            let repCount = UILabel()
            repCount.textColor = UIColor.white
            repCount.textAlignment = NSTextAlignment.center
            repCount.font = repCount.font.withSize(20)
            repCount.text = repList[row]
            return repCount
            
        default:
            //Pick the weight:
            //The picked weight wil update the threshold on the SLINK device
            let weightCount = UILabel()
            weightCount.textColor = UIColor.white
            weightCount.textAlignment = NSTextAlignment.center
            weightCount.font = weightCount.font.withSize(20)
            weightCount.text = weightList[row]
            return weightCount
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            //exercise is selected:
            if row == exerciseList.count-1{
                //Create own exercise
                nameField.isEnabled = true
                nameField.text = ""
                nameField.placeholder = "Enter new exercise"
                isCreatingNewExercise = true
                nameField.becomeFirstResponder()
                saveButton.tintColor = UIColor.gray
                saveButton.isEnabled = false
            }else{
                //chose preset exercise
                nameField.isEnabled = false
                nameField.text = exerciseList[row]
                nameField.endEditing(true)
                isCreatingNewExercise = false
            }
            
        case 1:
            //reps is selected
            repLabel.text = repList[row]
        default:
            //weight is selected
            weightLabel.text = weightList[row]
        }
        
       
    }

    
    func LoadExercises() { //fetch exercises
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 50
        
        dynamoDbObjectMapper.scan(EXNAMES.self, expression: scanExpression, completionHandler: {(objectModel: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Read Error: \(error)")
                return
            }
            self.exerciseList.removeAll()
            let userNAME = self.getUsername()
            
            for exercise in objectModel!.items{
                if exercise.value(forKey: "_uName") as? String == userNAME{
                    self.exerciseList = exercise.value(forKey: "_exList") as! [String]
                }
            }

            self.exerciseList.append("Enter new exercise")
            self.exercisePicker.reloadComponent(0)
            self.nameField.text = self.exerciseList[0]
            
            
        })
    }
    
    func uploadSet(exercisename: String) { //upload data to database
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let exercise: EXNAMES = EXNAMES()
        
        var newExlist = self.exerciseList
        newExlist.removeLast()
        newExlist.append(nameField.text!)
        exercise._uName = getUsername()
        exercise._exList = newExlist
        
        
        //Save a new item
        dynamoDbObjectMapper.save(exercise, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
    }
    
    func enableSave(){ //allowed to save the exercise
        if nameField.text != ""{
            nameField.endEditing(true)
            saveButton.tintColor = UIColor.init(red: 254/255, green: 252/255, blue: 118/255, alpha: 1)
            saveButton.isEnabled = true
        }
    }
    
    func getUsername()->String?{ // fetch username that is logged in 
        let serviceConfiguration = AWSServiceConfiguration(region: .EUWest2, credentialsProvider: nil)
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "5cep6ndcsg9kajsql3ls5g4un", clientSecret: "8eg2j0clh2l0kv04qdkmjqv8adetvdnp2ajtdsvusrvaol2odp0", poolId: "eu-west-2_eEXOvkpzt")
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: "slink_userpoolapp_MOBILEHUB_286091421")
        let pool = AWSCognitoIdentityUserPool(forKey: "slink_userpoolapp_MOBILEHUB_286091421")
        return pool.currentUser()?.username
    }

}
