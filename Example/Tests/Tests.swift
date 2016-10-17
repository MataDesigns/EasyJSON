import UIKit
import XCTest
import EasyJSON

class Tests: XCTestCase {
    
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
    
    var model : UserModel!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        model = UserModel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIntParse() {
        let json : [String : Any?] = ["id" : 0]
        
        model.fill(withDict: json)
        
        XCTAssert(model.id != -1, "Parse ID")
        
        let jsonDict = model.toJson()
        XCTAssert(jsonDict["id"] as! Int == 0, "id To Json")
    }
    
    func testStringParse() {
        let json : [String : Any?] = [
            "firstName" : "Nicholas",
            "middleName": nil,
            "lastName" : "Mata"
        ]
        
        model.fill(withDict: json)
        XCTAssert(model.firstName == "Nicholas", "Parse First Name")
        XCTAssert(model.middleName == nil      , "Parse Middle Name")
        XCTAssert(model.lastName == "Mata"     , "Parse LastName")
        
        let jsonDict = model.toJson()
        XCTAssert(jsonDict["firstName"] as! String == "Nicholas", "firstName To Json")
        XCTAssert(jsonDict["middleName"] == nil                 , "middleName To Json")
        XCTAssert(jsonDict["lastName"] as! String == "Mata"     , "lastName To Json")
    }
    
    func testDateParse() {
        let today = Date()
        let json : [String : Any?] = ["createdOn": today]
        model.fill(withDict: json)
        XCTAssert(model.createdOn == today, "Pass")
    }
    
    func testBoolParse() {
        let json : [String : Any?] = ["isNew": true]
        model.fill(withDict: json)
        XCTAssert(model.isNew, "Pass")
    }
    
    func testSubObjectParse() {
        let json : [String : Any?] = [
            "addressInfo": [
                "street": "355 Western Drive Apt C",
                "city": "Santa Cruz"
            ]
        ]
        model.fill(withDict: json)
        XCTAssert(model.addressInfo != nil, "Pass")
    }
    
}
