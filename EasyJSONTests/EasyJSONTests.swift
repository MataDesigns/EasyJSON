//
//  EasyJSONTests.swift
//  EasyJSONTests
//
//  Created by Nicholas Mata on 6/26/17.
//  Copyright © 2017 MataDesigns. All rights reserved.
//

import XCTest
@testable import EasyJSON

class EasyJSONTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
}

extension EasyJSONTests {
    func testfromJsonDict()
    {
        var model = PersonModel()
        do {
            try model.fill(withDict: myDict)
        } catch {
            print(error)
            assert(false)
        }
        
        assert(model.id == myDict["id"] as! Int, "Invalid Id")
        assert(model.firstName == myDict["firstName"] as? String, "Invalid firstName")
    }
}
