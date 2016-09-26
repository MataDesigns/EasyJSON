//
//  JSONModel.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 9/20/16.
//  Copyright © 2016 MataDesigns. All rights reserved.
//

import Foundation
import UIKit

/// Allows for json to be transformed into a object, and vice-versa.
/// It is as simple as creating a object that has JSONModel as a subclass.
public class JSONModel: NSObject {
    
    public var jsonTimeFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    /**
     A dictionary which provides a way to create json
     keys which differs from propery names.
     
     Example:
     ```
     class Person: JSONModel {
     var firstName: String?
     var lastName: String?
     }
     ```
     Normally would create
     
     ```
     ["firstName": "Jane", "lastName": "Doe"]
     ```
     However by providing a custom map dictionary like
     ```
     ["firstName": "first", "lastName": "last"]
     
     ```
     Then the result would instead be.
     ```
     ["first": "Jane", "last": "Doe"]
     ```
     */
    public var mapToJson: [String: String]?
    
    
    /**
     It has a similiar functionality as mapToJson however.
     It provides a way to map json keys that are different from the property name.
     
     Example:
     ```
     class Person: JSONModel {
     var first: String?
     var last: String?
     }
     ```
     Normally would require the following json.
     
     ```
     ["first": value, "last": value]
     ```
     However by providing a custom map dictionary like
     ```
     ["firstName": "first", "lastName": "last"]
     
     ```
     Then the object could be filled with the following json.
     ```
     ["firstName": "Jane", "lastName": "Doe"]
     ```
     */
    public var mapFromJson: [String: Any]?
    
    /**
     Allows you to specify sub-objects, see example for better understanding.
     
     Example:
     ```
     class Person: JSONModel {
     var firstName: String?
     var lastName: String?
     }
     
     class Appointment: JSONModel {
     var time: Date!
     var person: Person
     }
     ```
     By setting subObjects to
     
     ```
     ["person" : Person.self]
     ```
     You can have the following json fill Appointment class including the person property.
     ```
     ["time": "2016-09-20T08:00:00", "person": ["firstName": "Jane", "lastName": "Doe"]]
     */
    public var subObjects: [String: AnyClass]?
    
    required override public init() {
        
    }
    
    /**
     Will decode a bas64 string into an image.
     If string is invalid or nil was given then function will return nil UIImage.
     
     - parameter base64String: A base64 encoded string.
     
     - returns: A UIImage that the string represented.
     */
    public func imageFor(_ base64String: String?) -> UIImage? {
        if let imageString = base64String {
            guard !imageString.isEmpty else {
                return nil
            }
            return UIImage(data: NSData(base64Encoded: imageString, options: .init(rawValue: UInt(0))) as! Data)
        }
        return nil
    }
    /**
     Turns in object into json [String: Any].
     
     - returns: json representation of the object.
     */
    public func toJson() -> [String: Any] {
        var json = [String: Any]()
        for key in propertyNames() {
            var jsonKey = key
            // Handle custom mappings
            if let newKey = mapToJson?[key] {
                jsonKey = newKey
            }
            json[jsonKey] = self.value(forKey: key) as AnyObject?
        }
        return json
    }
    
    
    /// Fills the properties of an object with json.
    ///
    /// - parameter json: [String: Any] representing json.
    public func fill(withJson json: [String: Any]) {
        for propertyName in propertyNames() {
            // Set the json key to be the name of the property.
            var jsonKey = propertyName
            print(Mirror(reflecting: self.value(forKey: propertyName)).subjectType)
            var customValue: Any? = nil
            if let newProperty = mapFromJson?[propertyName] {
                if newProperty is String{
                    jsonKey = newProperty as! String
                } else {
                    customValue = mapArray(json, map: newProperty as! [String])
                }
            }
            
            if customValue != nil {
                fill(withKey: jsonKey, value: customValue, property: propertyName)
            }
            
            if let value = json[jsonKey] {
                fill(withKey: jsonKey, value: value, property: propertyName)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func fill(withKey key:String, value: Any, property: String) {
        switch value {
        case is NSNull:
            self.setValue("", forKey: property)
        case is String:
            handleString(value as! String, property)
        default:
            if let type = subObjects?[key] {
                handleCustomObjects(value, property, type: type)
            } else {
                self.setValue(value, forKey: property)
            }
        }
    }
    
    private func handleString(_ string: String,_ property: String) {
        if let date = Date.from(string) {
            self.setValue(date, forKey: property)
        }else if let date = Date.from(string, format: "hh:mm:ss") {
            self.setValue(date, forKey: property)
        } else {
            self.setValue(string, forKey: property)
        }
    }
    
    private func handleCustomObjects(_ attribute: Any, _ property: String, type: AnyClass) {
        if type is JSONModel.Type {
            if let array = attribute as? [[String: Any]] {
                var modelObjects = [JSONModel]()
                for jsonObject in array {
                    let objc = (type as! JSONModel.Type).init()
                    objc.fill(withJson: jsonObject )
                    modelObjects.append(objc)
                }
                if modelObjects.count > 0 {
                    self.setValue(modelObjects, forKey: property)
                }
            } else {
                let objc = (type as! JSONModel.Type).init()
                objc.fill(withJson: attribute as! [String: Any])
                self.setValue(objc, forKey: property)
            }
        }
        
    }
    
    private func mapArray(_ json: [String: Any], map :[String]) -> Any? {
        var value: [String: Any] = json
        for key in map {
            if value[key] is [String: Any] {
                value = value[key] as! [String: Any]
            } else {
                return value[key]
            }
        }
        return nil
    }
    
    private func propertyNames() -> Array<String> {
        var results: Array<String> = [];
        
        var count: UInt32 = 0;
        let myClass: AnyClass = self.classForCoder;
        // Get the properties for the class via the class_copyPropertyList function
        let properties = class_copyPropertyList(myClass, &count);
        // Iterate each objc_property_t struct
        for i: UInt32 in 0 ..< count {
            // Get the property's objc_property_t
            let property = properties?[Int(i)]
            // Get the property name by calling property_getName function
            let cname = property_getName(property)
            // Covert the CString into a Swift string
            let name = String.init(cString: cname!)
            
            results.append(name);
        }
        
        // Release objc_property_t
        free(properties);
        
        return results;
    }
}

extension Date {
    static func from(_ string: String, format: String = "yyyy-MM-dd'T'HH:mm:ss") -> Date?  {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.autoupdatingCurrent
        return formatter.date(from: string)
    }
    
    func dateString(_ format: String = "MM/dd/yyyy HH:mm a") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.autoupdatingCurrent
        return formatter.string(from: self)
    }
}
