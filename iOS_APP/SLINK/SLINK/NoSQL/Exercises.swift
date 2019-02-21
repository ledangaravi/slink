//
//  Exercises.swift
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

class Exercises: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _exerciseName: String?
    
    class func dynamoDBTableName() -> String {

        return "slink-mobilehub-286091421-Exercises"
    }
    
    class func hashKeyAttribute() -> String {

        return "_exerciseName"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_exerciseName" : "ExerciseName",
        ]
    }
}