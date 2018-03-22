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
/** Dictionary Tests **/
extension EasyJSONTests {
    func testDictToModelFull() {
        let jsonDict: [String : Any?] = ["id" : 1, "firstName": "Nicholas", "lastName": "Mata"]
        var model = TestModel()
        measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == jsonDict["id"] as? Int)
        assert(model.firstName == (jsonDict["firstName"] as! String))
        assert(model.lastName == (jsonDict["lastName"] as! String))
    }
    
    func testDictToModelPartial() {
        let jsonDict: [String : Any?] = ["id" : 1, "firstName": "Nicholas"]
        var model = TestModel()
        measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == jsonDict["id"] as? Int)
        assert(model.firstName == (jsonDict["firstName"] as! String))
        assert(model.lastName == nil)
    }
    
    func testDictToModelEmpty() {
        let jsonDict: [String: Any] = [:]
        var model = TestModel()
        measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == nil)
        assert(model.firstName == nil)
        assert(model.lastName == nil)
    }
    
}

/** String Tests **/
extension EasyJSONTests {
    
    
    func testStringToModelFull() {
        let id = 1
        let firstName = "Nicholas"
        let lastName = "Mata"
        
        let json = "{ \"id\": \(id), \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\"}"
        var model = TestModel()
        measure {
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
        var model = TestModel()
        measure {
            try? model.fill(withJson: json)
        }
        assert(model.id == id)
        assert(model.firstName == firstName)
        assert(model.lastName == nil)
    }
    
    func testStringToModelEmpty() {
        let json = ""
        var model = TestModel()
        measure {
            try? model.fill(withJson: json)
        }
        assert(model.id == nil)
        assert(model.firstName == nil)
        assert(model.lastName == nil)
    }
}

/** Subobjects Tests **/
extension EasyJSONTests {
    func testSubobjectArray() {
        let jsonDict: [String : Any] = ["id" : 1,
                                        "firstName": "Nicholas",
                                        "lastName": "Mata",
                                        "primaryAddress": ["id": 1, "street": "123 Melrose Drive", "city": "Vista", "state" : "CA"],
                                        "addresses": [
                                            ["id": 1, "street": "123 Melrose Drive", "city": "Vista", "state" : "CA"],
                                            ["id": 2, "street": "123 Western Drive", "city": "Santa Cruz", "state" : "CA"]
            ]
        ]
        var model = TestModelSubobject()
        measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == jsonDict["id"] as! Int)
        assert(model.firstName == (jsonDict["firstName"] as! String))
        assert(model.lastName == (jsonDict["lastName"] as! String))
        assert(model.addresses.first?.id == ((jsonDict["addresses"] as! [[String: Any]])[0]["id"] as! Int), "Subobject Addresses was not filled.")
    }
}

/** SnakeCase Tests **/
extension EasyJSONTests {
    func testFromSnake() {
        let jsonDict: [String : Any] = ["id" : 1,
                                        "first_name": "Nicholas",
                                        "last_name": "Mata",
                                        "addresses": [
                                            ["id": 1, "street": "123 Melrose Drive", "city": "Vista", "state" : "CA"],
                                            ["id": 2, "street": "123 Western Drive", "city": "Santa Cruz", "state" : "CA"]
            ]
        ]
        var model = TestModelSnakeCase()
        measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == jsonDict["id"] as! Int)
        assert(model.firstName == (jsonDict["first_name"] as! String))
        assert(model.lastName == (jsonDict["last_name"] as! String))
        assert(model.addresses.first?.id == ((jsonDict["addresses"] as! [[String: Any]])[0]["id"] as! Int), "Subobject Addresses was not filled.")
    }
    
    func testToSnake() {
        let jsonDict: [String : Any] = ["id" : 1,
                                        "first_name": "Nicholas",
                                        "last_name": "Mata",
                                        "addresses": [
                                            ["id": 1, "street": "123 Melrose Drive", "city": "Vista", "state" : "CA"],
                                            ["id": 2, "street": "123 Western Drive", "city": "Santa Cruz", "state" : "CA"]
            ]
        ]
        var model = TestModelSnakeCase()
        measure {
            model.fill(withDict: jsonDict)
        }
        let modelJson = model.toJson()
        assert(modelJson["id"] as! Int == jsonDict["id"] as! Int)
        assert(modelJson["first_name"] as! String == (jsonDict["first_name"] as! String))
        assert(modelJson["last_name"] as! String == (jsonDict["last_name"] as! String))
        assert(((modelJson["addresses"] as! [[String: Any]])[0]["id"] as! Int) == ((jsonDict["addresses"] as! [[String: Any]])[0]["id"] as! Int), "Subobject Addresses was not filled.")
    }
}

/** Subclass Tests **/
extension EasyJSONTests {
    func testFromSubclass() {
        let jsonDict: [String : Any?] = ["id" : 1,
                                         "firstName": "Nicholas",
                                         "lastName": "Mata"]
        var model = TestSubclass()
        measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == jsonDict["id"] as? Int)
        assert(model.firstName == (jsonDict["firstName"] as! String))
        assert(model.lastName == (jsonDict["lastName"] as! String))
    }
    
    func testToSubclass() {
        let jsonDict: [String : Any] = ["id" : 1,
                                        "firstName": "Nicholas",
                                        "lastName": "Mata"]
        var model = TestSubclass()
        measure {
            model.fill(withDict: jsonDict)
        }
        let modelJson = model.toJson()
        assert(modelJson["id"] as! Int == jsonDict["id"] as! Int)
        assert(modelJson["firstName"] as! String == (jsonDict["firstName"] as! String))
        assert(modelJson["lastName"] as! String == (jsonDict["lastName"] as! String))
    }
}


/** Converter Tests **/

extension EasyJSONTests {
    func testModelOptions() {
        
        var jsonDict: [String : Any?] = ["id" : 1,
                                         "isValid" : "Yes",
                                         "time": "01:00"]
        var model = TestModelWithOptions()
        measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == jsonDict["id"] as? Int)
        var modelJson = model.toJson()
        assert(modelJson["time"] as! String == (jsonDict["time"] as! String))
        assert(modelJson["isValid"] as! String == (jsonDict["isValid"] as! String))
    }
    
    func testModelOptionsSnakeCased() {
        var jsonDict: [String : Any?] = ["id" : 1,
                                         "is_valid" : "Yes",
                                         "time": "01:00"]
        var model = TestModelWithOptions(snakeCased: true)
        measure {
            model.fill(withDict: jsonDict)
        }
        assert(model.id == jsonDict["id"] as? Int)
        let modelJson = model.toJson()
        assert(modelJson["time"] as! String == (jsonDict["time"] as! String))
        assert(modelJson["is_valid"] as! String == (jsonDict["is_valid"] as! String))
    }
}





