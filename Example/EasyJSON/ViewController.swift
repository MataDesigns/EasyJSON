//
//  ViewController.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 09/25/2016.
//  Copyright (c) 2016 Nicholas Mata. All rights reserved.
//

import UIKit
import EasyJSON

class AddressInfo: EasyModel {
    var street: String?
    var city: String?
}

class UserModel: EasyModel {
    
    var id: Int = -1
    
    var firstName: String?
    var middleName: String?
    var lastName: String?
    
    var addressInfo: AddressInfo?
    
    var createdOn: Date?
    
    var isNew: Bool = false
    
    override var subObjects: [String : AnyClass] {
        return ["addressInfo": AddressInfo.self]
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let user : [String: Any?] = [
            "id" : 0,
            "firstName" : "Nicholas",
            "middleName": nil,
            "lastName" : "Mata",
            "isNew" : true,
            "addressInfo": [
                "street": "355 Western Drive Apt C",
                "city": "Santa Cruz"],
            "createdOn": Date()
        ]
        
        let model = UserModel()
        model.fill(withDict: user)
        
        
        let jsonUserString = "{ \"firstName\" : \"Nicholas\"}"
        let modelFromString = UserModel()
        do {
            try modelFromString.fill(withJson: jsonUserString)
        } catch {
            
        }
        
        print(model.toJson())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

