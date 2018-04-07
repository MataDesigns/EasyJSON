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
    func testSnakeCase() {
        var classroom = ClassroomModel()
        do {
            try classroom.fill(withDict: myClassroom)
        } catch  {
            print(error)
            assert(false)
        }
        
        var classroomDict = myClassroom
        var teacherDict = classroomTeacher
        // Classroom
        assert(classroom.id == (classroomDict["id"] as! Int),                         "Invalid classroom Id")
        assert(classroom.name == classroomDict["name"] as? String,                  "Invalid classroom name")
        assert(classroom.gradeAverage == classroomDict["grade_average"] as? Double, "Invalid classroom grade average")
        // Classroom Teacher
        assert(classroom.teacher.id == (teacherDict["id"] as! Int),                   "Invalid teacher Id")
        assert(classroom.teacher.firstName == teacherDict["first_name"] as? String, "Invalid teacher first_name")
        assert(classroom.teacher.lastName == teacherDict["last_name"] as? String,   "Invalid teacher last_name")
        
        assert(classroom.students.count == (classroomDict["students"] as! [[String:Any]]).count,     "Students for classroom not filled")
        assert(classroom.daysOfTheWeek.count == (classroomDict["days_of_the_week"] as! [Int]).count, "Days of Week for classroom not filled")
    }
    
    func testfromJsonDict()
    {
        var model = PersonModel()
        do {
            try model.fill(withDict: me)
        } catch {
            print(error)
            assert(false)
        }
        
        var person = model
        var personDict = me
        var personAddressDict = myAddress
        // Me
        assert(person.id == personDict["id"] as! Int,                                        "Invalid Id")
        assert(person.firstName == personDict["firstName"] as? String,                       "Invalid firstName")
        assert(person.middleName == personDict["middleName"] as? String,                     "Invalid middleName")
        assert(person.lastName == personDict["lastName"] as? String,                         "Invalid lastName")
        assert(person.facebookId == personDict["facebookId"] as? Int,                        "Invalid facebookId")
        assert(person.birthday?.dateString("MM/dd/yy") == personDict["birthday"] as? String, "Invalid birthday")
        // My Address
        assert(person.address.id == personAddressDict["id"] as! Int,                              "Address has invalid Id")
        assert(person.address.streetAddress == personAddressDict["streetAddress"] as? String,     "Address has invalid street address")
        assert(person.address.extendedAddress == personAddressDict["extendedAddress"] as? String, "Address has invalid extended address")
        assert(person.address.city == personAddressDict["city"] as? String,                       "Address has invalid city")
        assert(person.address.state == personAddressDict["state"] as? String,                     "Address has invalid state")
        assert(person.address.zipcode == personAddressDict["zipcode"] as? String,                 "Address has invalid zipcode")
        
        assert(person.friends.count == (personDict["friends"] as! [[String:Any]]).count,     "Friends not filled")
        
        
        person = model.friends[0]
        personDict = friendOne
        personAddressDict = friendOneAddress
        // Friend One Tests
        assert(person.id == personDict["id"] as! Int,                                        "Invalid Id")
        assert(person.firstName == personDict["firstName"] as? String,                       "Invalid firstName")
        assert(person.middleName == personDict["middleName"] as? String,                     "Invalid middleName")
        assert(person.lastName == personDict["lastName"] as? String,                         "Invalid lastName")
        assert(person.facebookId == personDict["facebookId"] as? Int,                        "Invalid facebookId")
        assert(person.birthday?.dateString("MM/dd/yy") == personDict["birthday"] as? String, "Invalid birthday")
        // Friend One Address Tests
        assert(person.address.id == personAddressDict["id"] as! Int,                              "Address has invalid Id")
        assert(person.address.streetAddress == personAddressDict["streetAddress"] as? String,     "Address has invalid street address")
        assert(person.address.extendedAddress == personAddressDict["extendedAddress"] as? String, "Address has invalid extended address")
        assert(person.address.city == personAddressDict["city"] as? String,                       "Address has invalid city")
        assert(person.address.state == personAddressDict["state"] as? String,                     "Address has invalid state")
        assert(person.address.zipcode == personAddressDict["zipcode"] as? String,                 "Address has invalid zipcode")
        
        assert(person.friends.count == (personDict["friends"] as! [[String:Any]]).count,     "Friends not filled")
        
        
        person = model.friends[1]
        personDict = friendTwo
        personAddressDict = friendTwoAddress
        // Friend Two Tests
        assert(person.id == personDict["id"] as! Int,                                        "Invalid Id")
        assert(person.firstName == personDict["firstName"] as? String,                       "Invalid firstName")
        assert(person.middleName == personDict["middleName"] as? String,                     "Invalid middleName")
        assert(person.lastName == personDict["lastName"] as? String,                         "Invalid lastName")
        assert(person.facebookId == personDict["facebookId"] as? Int,                        "Invalid facebookId")
        assert(person.birthday?.dateString("MM/dd/yy") == personDict["birthday"] as? String, "Invalid birthday")
        // Friend Two Address Tests
        assert(person.address.id == personAddressDict["id"] as! Int,                              "Address has invalid Id")
        assert(person.address.streetAddress == personAddressDict["streetAddress"] as? String,     "Address has invalid street address")
        assert(person.address.extendedAddress == personAddressDict["extendedAddress"] as? String, "Address has invalid extended address")
        assert(person.address.city == personAddressDict["city"] as? String,                       "Address has invalid city")
        assert(person.address.state == personAddressDict["state"] as? String,                     "Address has invalid state")
        assert(person.address.zipcode == personAddressDict["zipcode"] as? String,                 "Address has invalid zipcode")
        
        assert(person.friends.count == (personDict["friends"] as! [[String:Any]]).count,     "Friends not filled")
    }
}
