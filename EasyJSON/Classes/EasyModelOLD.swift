//
//  EasyModel.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 9/20/16.
//  Copyright © 2016 MataDesigns. All rights reserved.
//

import Foundation
import UIKit

enum EasyModelError: Error {
    case invalidModel(String)
}

/// Allows for json to be transformed into a object, and vice-versa.
/// It is as simple as creating a object that has EasyModel as a subclass.
open class EasyModelOLD: NSObject {
    
    open var jsonTimeFormat :String  {
        return "yyyy-MM-dd'T'HH:mm:ss"
    }
    
    /**
     A dictionary which provides a way to create json
     keys which differs from propery names.
     
     Example:
     ```
     class Person: EasyModel {
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
    open var mapToJson: [String: String] {
        return [:]
    }
    
    /**
     An array of property names which you would like to exclude when turning
     Model into JSON.
     */
    open var excludes: [String] {
        return []
    }
    
    var allExcludes: [String] = ["jsonTimeFormat", "excludes", "mapToJson", "mapFromJson", "subObjects"]
    
    
    /**
     It has a similiar functionality as mapToJson however.
     It provides a way to map json keys that are different from the property name.
     
     Example:
     ```
     class Person: EasyModel {
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
    open var mapFromJson: [String: String]  {
        return [:]
    }
    
    /**
     Allows you to specify sub-objects, see example for better understanding.
     
     Example:
     ```
     class Person: EasyModel {
     var firstName: String?
     var lastName: String?
     }
     
     class Appointment: EasyModel {
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
    open var subObjects: [String: AnyClass] {
        return [:]
    }
    
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
        allExcludes.append(contentsOf: excludes)
        var json = [String: Any]()
        for (key, mirror) in propertyMirrors() {
            if allExcludes.contains(key) {
                continue
            }
            var jsonKey = key
            // Handle custom mappings
            if let newKey = mapToJson[key] {
                jsonKey = newKey
            }
            let propertyValue = self.value(forKey: key) as Any
            if let jsonModel = propertyValue as? EasyModel {
                json[jsonKey] = jsonModel.toJson()
            } else if let jsonModels = propertyValue as? [EasyModel] {
                var models = [[String: Any]]()
                for jsonModel in jsonModels {
                    models.append(jsonModel.toJson())
                }
                json[jsonKey] = models
            } else
            {
                json[jsonKey] = propertyValue
            }
        }
        return json
    }
    
    
    /// Fills the properties of an object with json.
    ///
    /// - parameter json: [String: Any] representing json.
    public func fill(with json: [String: Any]) throws {
        for (propertyName, mirror) in propertyMirrors() {
            //print("\(propertyName) \(mirror.subjectType)")
            // Set the json key to be the name of the property.
            var jsonKey = propertyName
            var customValue: Any? = nil
            if let newProperty = mapFromJson[propertyName] {
                if newProperty is String{
                    jsonKey = newProperty as! String
                } else {
                    customValue = mapArray(json, map: newProperty as! [String])
                }
            }
            
            if customValue != nil {
                try fill(withKey: jsonKey, value: customValue, property: propertyName)
                continue
            }
            
            if let value = json[jsonKey] {
                try fill(withKey: jsonKey, value: value, property: propertyName)
                continue
            }
            
            if  mirror.displayStyle != .optional {
                throw EasyModelError.invalidModel("\(propertyName) set to none optional but isn't inside JSON.")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func fill(withKey key:String, value: Any?, property: String) throws {
        switch value {
        case is NSNull:
            setValue("", forKey: property)
        case is String:
            handleString(value as! String, property)
        case is Int:
            if let final = value as? Int {
                setValue(final, forKey: property)
            }
        default:
            if let type = subObjects[key] {
                try handleCustomObjects(value, property, type: type)
            } else {
                setValue(value, forKey: property)
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
    
    private func handleCustomObjects(_ attribute: Any, _ property: String, type: AnyClass) throws {
        if type is EasyModel.Type {
            if let array = attribute as? [[String: Any]] {
                var modelObjects = [EasyModel]()
                for jsonObject in array {
                    let objc = (type as! EasyModel.Type).init()
                    try objc.fill(with: jsonObject)
                    modelObjects.append(objc)
                }
                if modelObjects.count > 0 {
                    self.setValue(modelObjects, forKey: property)
                }
            } else {
                let objc = (type as! EasyModel.Type).init()
                try objc.fill(with: attribute as! [String: Any])
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
    
    private func propertyMirrors() -> [(String, Mirror)] {
        var results: [(String, Mirror)] = []
        
        for child in Mirror(reflecting: self).children
        {
            if let name = child.label{
                results.append((name, Mirror(reflecting: child.value)))
            }
        }
        
        return results
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
