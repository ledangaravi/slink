//
//  ViewController.swift
//  SLINK
//
//  Created by XIN ZHOU on 31/01/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit
import AWSAuthCore
import AWSAuthUI
import AWSCognitoIdentityProvider
import AWSMobileClient
import AWSUserPoolsSignIn
import AWSDynamoDB
import CocoaMQTT
import CocoaAsyncSocket



extension UIViewController {
    func hideNavigationBar(){
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}


class HomeViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !AWSSignInManager.sharedInstance().isLoggedIn {
            presentAuthUIViewController()//user sign in
        }else{
            userName.text = getUsername()
        }
        
        checkExList() // Load preset exercises into the database if new user
        }
    
    
    
    func presentAuthUIViewController() { //Login page
        let config = AWSAuthUIConfiguration()
        config.enableUserPoolsUI = true
        config.backgroundColor = UIColor.black
        config.isBackgroundColorFullScreen = true
        config.logoImage = UIImage.init(named: "SLINK")
        config.font = UIFont.init(name: "OCR A Std", size: 11)
        config.canCancel = false
        
        AWSAuthUIViewController.presentViewController(
            with: self.navigationController!,
            configuration: config, completionHandler: { (provider: AWSSignInProvider, error: Error?) in
            if error == nil {
                // SignIn succeeded.
                self.userName.text = self.getUsername()
                self.checkExList()
            } else {
            print("sign in error")
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hideNavigationBar()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        showNavigationBar()
    }

    @IBAction func signOut(_ sender: Any) { //sign out button
        AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, error: Error?) in
            self.presentAuthUIViewController()
        })
    }
    
    func getUsername()->String?{ // fetch username from AWS
        let serviceConfiguration = AWSServiceConfiguration(region: .EUWest2, credentialsProvider: nil)
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "5cep6ndcsg9kajsql3ls5g4un", clientSecret: "8eg2j0clh2l0kv04qdkmjqv8adetvdnp2ajtdsvusrvaol2odp0", poolId: "eu-west-2_eEXOvkpzt")
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: "slink_userpoolapp_MOBILEHUB_286091421")
        let pool = AWSCognitoIdentityUserPool(forKey: "slink_userpoolapp_MOBILEHUB_286091421")
        return pool.currentUser()?.username
    }

    func checkExList(){ // Load preset exercises if new user
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 50
        dynamoDbObjectMapper.scan(EXNAMES.self, expression: scanExpression, completionHandler: {(objectModel: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Read Error: \(error)")
                return
            }
            var exists = false
            let userNAME = self.getUsername()
            for exercises in objectModel!.items{
                if exercises.value(forKey: "_uName") as! String == userNAME{
                    exists = true
                }
            }
            if !exists{
                for exercises in objectModel!.items{
                    if exercises.value(forKey: "_uName") as! String == "slink"{
                        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
                        let exercise: EXNAMES = EXNAMES()
                        exercise._uName = userNAME
                        exercise._exList = exercises.value(forKey: "_exList") as! [String]
                        dynamoDbObjectMapper.save(exercise, completionHandler: {
                            (error: Error?) -> Void in
                            if let error = error {
                                print("Amazon DynamoDB Save Error: \(error)")
                                return
                            }
                            print("An item was saved.")
                        })
                    }
                }
            }
        })
    }
}

