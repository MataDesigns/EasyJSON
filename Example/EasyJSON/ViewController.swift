//
//  ViewController.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 09/25/2016.
//  Copyright (c) 2016 Nicholas Mata. All rights reserved.
//

import UIKit
import EasyJSON

class BasicUser {
    var firstName: String!
    var lastName: String!
}

class UserModel: EasyModel {
    override var jsonTimeFormat: String {
        return "hh:ss"
    }
    
    var id: Int = -1
    var firstName: String!
    var middleName: String?
    var lastName: String!
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let user : [String: Any?] = ["id" : 0, "firstName" : "Nicholas", "lastName" : "Mata"]
        let model = UserModel()
        do {
        try model.fill(with: user)
        } catch let error {
            print(error)
        }
        let basicUser = BasicUser()
        basicUser.firstName = model.firstName
        basicUser.lastName = model.lastName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

