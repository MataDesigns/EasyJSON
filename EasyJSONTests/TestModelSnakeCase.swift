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
    
    override var _options_: EasyModelOptions {
        return EasyModelOptions(snakeCased: true)
    }
    
    public var id: Int!
    public var firstName: String?
    public var lastName: String?
    public var addresses = [AddressModel]()
}
