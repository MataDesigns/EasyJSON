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
    
    /** Dictionary Tests **/
    
    func testDictToModelFull() {
        let jsonDict: [String : Any] = ["id" : 1, "firstName": "Nicholas", "lastName": "Mata"]
        let model = TestModel()
        self.measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == jsonDict["id"] as! Int)
        assert(model.firstName == (jsonDict["firstName"] as! String))
        assert(model.lastName == (jsonDict["lastName"] as! String))
    }
    
    func testDictToModelPartial() {
        let jsonDict: [String : Any] = ["id" : 1, "firstName": "Nicholas"]
        let model = TestModel()
        self.measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == jsonDict["id"] as! Int)
        assert(model.firstName == (jsonDict["firstName"] as! String))
        assert(model.lastName == nil)
    }
    
    func testDictToModelEmpty() {
        let jsonDict: [String: Any] = [:]
        let model = TestModel()
        self.measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == -1)
        assert(model.firstName == nil)
        assert(model.lastName == nil)
    }
    
    
    /** String Tests **/
    
    func testStringToModelFull() {
        let id = 1
        let firstName = "Nicholas"
        let lastName = "Mata"
        
        let json = "{ \"id\": \(id), \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\"}"
        let model = TestModel()
        self.measure {
            try? model.fill(withJson: json)
        }
        assert(model.id == id)
        assert(model.firstName == firstName)
        assert(model.lastName == lastName)
    }
    
    func testStringToModelPartial() {
        let id = 1
        let firstName = "Nicholas"
        
        let json = "{ \"id\": \(id), \"firstName\": \"\(firstName)\"}"
        let model = TestModel()
        self.measure {
            try? model.fill(withJson: json)
        }
        assert(model.id == id)
        assert(model.firstName == firstName)
        assert(model.lastName == nil)
    }
    
    func testStringToModelEmpty() {
        let json = ""
        let model = TestModel()
        self.measure {
            try? model.fill(withJson: json)
        }
        assert(model.id == -1)
        assert(model.firstName == nil)
        assert(model.lastName == nil)
    }
    
    
}
