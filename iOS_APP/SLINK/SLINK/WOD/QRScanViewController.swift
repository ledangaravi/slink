//
//  QRScanViewController.swift
//  SLINK
//
//  Created by XIN ZHOU on 08/02/2019.
//  Copyright © 2019 SLINK. All rights reserved.
//

import UIKit
import AVFoundation
import AWSDynamoDB
import AWSAuthCore
import AWSAuthUI
import AWSCognitoIdentityProvider
import AWSMobileClient
import AWSUserPoolsSignIn



class QRScanViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var viewPreview: UIView!
    
    var wodname:String = String()
    var exList: [String] = [String]()
    var repList: [String] = [String]()
    var wList: [String] = [String]()
    
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewPreview.layer.cornerRadius = 5;
        captureSession = nil;
        startReading()
    }
    
    func startReading() -> Bool {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
        } catch let error as NSError {
            print(error)
            return false
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer.frame = viewPreview.layer.bounds
        viewPreview.layer.addSublayer(videoPreviewLayer)
        view.bringSubview(toFront: self.bottomView)
        view.bringSubview(toFront: self.instructions)
        
        // Check for metadata:
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
        print(captureMetadataOutput.availableMetadataObjectTypes)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession?.startRunning()
        
        return true
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        for data in metadataObjects {
            let metaData = data as! AVMetadataObject
            print(metaData.description)
            let transformed = videoPreviewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed {
                //QRCode found, upload to database
                //Should trigger the AWS lambda function
                
                print(unwraped.stringValue)
                uploadDevice(scannedDevice: unwraped.stringValue)
                captureSession?.stopRunning()
                self.performSegue(withIdentifier: "segueStart", sender: nil)
            }
        }
    }
    
    
    func uploadDevice(scannedDevice: String) { // upload to database table to pass data to SLINK device through AWS Lambda
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let device: DEVICES = DEVICES()
        
        device._uName = self.getUsername()
        device._deviceID = scannedDevice
        device._wODName = self.wodname
        device._exList = self.exList
        device._repList = self.repList
        device._wList = self.wList
        
        
        //Save a new item
        dynamoDbObjectMapper.save(device, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
    }
    
    func getUsername()->String?{
        let serviceConfiguration = AWSServiceConfiguration(region: .EUWest2, credentialsProvider: nil)
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "5cep6ndcsg9kajsql3ls5g4un", clientSecret: "8eg2j0clh2l0kv04qdkmjqv8adetvdnp2ajtdsvusrvaol2odp0", poolId: "eu-west-2_eEXOvkpzt")
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: "slink_userpoolapp_MOBILEHUB_286091421")
        let pool = AWSCognitoIdentityUserPool(forKey: "slink_userpoolapp_MOBILEHUB_286091421")
        return pool.currentUser()?.username
    }
    
    
}
