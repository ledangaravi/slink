//
//  DEVICES.swift
//  MySampleApp
//
//
// Copyright 2019 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.21
//

import Foundation
import UIKit
import AWSDynamoDB

class DEVICES: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _deviceID: String?
    var _wODName: String?
    var _exList: [String]?
    var _repList: [String]?
    var _uName: String?
    var _wList: [String]?
    
    class func dynamoDBTableName() -> String {

        return "slink-mobilehub-286091421-DEVICES"
    }
    
    class func hashKeyAttribute() -> String {

        return "_deviceID"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_deviceID" : "device_ID",
               "_wODName" : "WOD_name",
               "_exList" : "exList",
               "_repList" : "repList",
               "_uName" : "u_name",
               "_wList" : "wList",
        ]
    }
}
