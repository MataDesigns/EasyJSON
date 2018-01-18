//
//  TestModelSnakeCase.swift
//  EasyJSONTests
//
//  Created by Nicholas Mata on 1/18/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit
import EasyJSON

class TestModelSnakeCase: EasyModel {
    override var snakeCase: Bool {
        return true
    }
    
    public var id: Int = -1
    public var firstName: String?
    public var lastName: String?
    public var addresses = [AddressModel]()
    
    
    public override var subObjects: [String : AnyClass] {
        return ["addresses": AddressModel.self]
    }
}
