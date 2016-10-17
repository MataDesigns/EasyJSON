//
//  EasyModel.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 10/17/16.
//  Copyright © 2016 MataDesigns. All rights reserved.
//

import Foundation
import UIKit

open class EasyModel: NSObject {
    
    //MARK: - Variables
    
    /**
     The format to parse date from string.
     */
    open var jsonTimeFormat :String  {
        return "yyyy-MM-dd'T'HH:mm:ss"
    }
    
    /**
     Provides a way to map json keys that are different from the property name.
     
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
    open var mapFromJson: [String: String] {
        get {
            return [:]
        }
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
    
    /**
     An array of property names which you would like to exclude when turning Model into JSON.
     */
    open var exclude: [String] {
        return []
    }
    
    private var defaultExcludes: [String] = ["jsonTimeFormat", "exclude", "mapToJson", "mapFromJson", "subObjects"]
    
    private var allExcludes: [String] {
        return defaultExcludes + exclude
    }
    
    required override public init() {
        
    }
    
    // MARK: - Public Functions
    
    /**
     Fills the object with the json provided.
     
     - parameters:
        - jsonString: JSON represented as a string.
     
     */
    public func fill(withJson jsonString: String) throws {
        do {
            let jsonData = jsonString.data(using: .utf8)
            let parsedData = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as! [String : Any]
            fill(withDict: parsedData)
        } catch let error as NSError {
            print(error)
        }
    }
    
    /**
     Fills the object with the json provided.
     
     - parameters:
        - jsonDict: JSON represented as a dictionary.
     */
    public func fill(withDict jsonDict: [String: Any?]) {
        for (name, mirror) in propertyMirrors() {
            var jsonKey = mapFromJson[name] != nil ? mapFromJson[name]! : name
            
            if let value = jsonDict[jsonKey] {
                if let subObjectType = subObjects[name] {
                    handleSubObject(value, name, type: subObjectType)
                    continue
                }
                
                switch value {
                case is NSNull:
                    if mirror.displayStyle == .optional {
                        setValue(nil, forKey: name)
                    } else {
                        setValue("", forKey: name)
                    }
                case is Bool:
                    setValue(value as! Bool, forKey: name)
                case is String:
                    handleString(value as! String, name)
                case is Int:
                    setValue(value as! Int, forKey: name)
                case is Date:
                    setValue(value as! Date, forKey: name)
                case let jsonModel as [String: Any]:
                    print("WARNING EasyModel !!!: Could not fill sub object named \(name)")
                case nil:
                    if mirror.displayStyle == .optional {
                        setValue(nil, forKey: name)
                    }
                default:
                    setValue(value, forKey: name)
                }
                
            }
        }
    }
    
    
    /**
     Turns in object into JSON dictionary. [String: Any]
     
     - returns: Dictionary representing the model in JSON.
     */
    public func toJson() -> [String: Any] {
        var json = [String: Any]()
        for (key, mirror) in propertyMirrors() {
            
            if allExcludes.contains(key) {
                continue
            }
            
            var jsonKey = mapToJson[key] != nil ? mapToJson[key]! : key

            let propertyValue = self.value(forKey: key) as Any?
            
            switch propertyValue {
            case let jsonModel as EasyModel:
                json[jsonKey] = jsonModel.toJson()
            case let jsonModels as [EasyModel]:
                var models = [[String: Any]]()
                for jsonModel in jsonModels {
                    models.append(jsonModel.toJson())
                }
                json[jsonKey] = models
            case let realValue as Any:
                json[jsonKey] = realValue
            default:
                json[jsonKey] = propertyValue
            }
        }
        return json
    }
    
    // MARK: - Private Functions
    
    /**
     Handles a property that is in subObjects dictionary.
     */
    private func handleSubObject(_ attribute: Any, _ property: String, type: AnyClass)  {
        
        guard type is EasyModel.Type else {
            print("WARNING EasyModel !!!: Sub-Object must be of type EasyModel.")
            return
        }
        
        switch attribute {
        case let jsonDict as [String : Any]:
            let objc = (type as! EasyModel.Type).init()
            objc.fill(withDict: jsonDict)
            setValue(objc, forKey: property)
        case let jsonDicts as [[String : Any]]:
            var modelObjects = [EasyModel]()
            for jsonObject in jsonDicts {
                let objc = (type as! EasyModel.Type).init()
                objc.fill(withDict: jsonObject)
                modelObjects.append(objc)
            }
            if modelObjects.count > 0 {
                self.setValue(modelObjects, forKey: property)
            }
            
        default:
            break
        }
    }
    
    /**
     Handles a string value but checking for dates in the specified format.
     */
    private func handleString(_ string: String,_ property: String) {
        if let date = Date.from(string, format: jsonTimeFormat) {
            self.setValue(date, forKey: property)
        }else if let date = Date.from(string, format: "hh:mm:ss") {
            self.setValue(date, forKey: property)
        } else {
            self.setValue(string, forKey: property)
        }
    }
    
    /**
     Gets the property name and mirror found in this object.
     This is a helper method used to get information about the properties
     of the object.
     
     - returns:
        A dictionary where key is the property name and value is the mirror for the property.
     
     */
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
