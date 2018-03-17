//
//  TestSubClass.swift
//  EasyJSONTests
//
//  Created by Nicholas Mata on 3/17/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit
import EasyJSON

class TestSuperclass: EasyModel {
    var id: Int = -1
}

class TestSubclass: TestSuperclass {
    var firstName: String?
    var lastName: String?
}
