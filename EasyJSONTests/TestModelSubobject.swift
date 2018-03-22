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
    public var id: Int!
    public var firstName: String?
    public var lastName: String?
    public var primaryAddress = AddressModel()
    public var addresses = [AddressModel]()
}

public class AddressModel: EasyModel {
    public var id: Int!
    public var street: String?
    public var city: String?
    public var state: String?
}
