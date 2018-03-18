//
//  TestModelSubobject.swift
//  EasyJSONTests
//
//  Created by Nicholas Mata on 1/6/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit
import EasyJSON

public class TestModelSubobject: EasyModel {
    public var id: Int = -1
    public var firstName: String?
    public var lastName: String?
    public var addresses = [AddressModel]()
    
    public override var _subObjects_: [String : AnyClass] {
        return ["addresses": AddressModel.self]
    }
}

public class AddressModel: EasyModel {
    public var id: Int = -1
    public var street: String?
    public var city: String?
    public var state: String?
}
