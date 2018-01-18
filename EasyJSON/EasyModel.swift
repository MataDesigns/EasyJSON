//
//  EasyModel.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 10/17/16.
//  Copyright © 2016 MataDesigns. All rights reserved.
//

import Foundation

@objcMembers open class EasyModel: NSObject {
    
    //MARK: - Variables
    
    /**
     The format to parse date from string.
     */
    open var timeFormat :String  {
        return "yyyy-MM-dd'T'HH:mm:ss"
    }
    
    /**
     Whether dates are UTC
     */
    open var isUTC: Bool {
        return false
    }
    
    
    /**
     If json is snake_cased and property names are camelCased then enable this so
     you DONT have to write a mapFromJson and mapToJson.
    */
    open var snakeCase: Bool {
        return false
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
        return [:]
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
        let jsonData = jsonString.data(using: .utf8)
        let parsedData = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as! [String : Any]
        fill(withDict: parsedData)
    }
    
    /**
     Fills the object with the json provided.
     
     - parameters:
        - jsonDict: JSON represented as a dictionary.
     */
    public func fill(withDict jsonDict: [String: Any]) {
        for (name, mirror) in propertyMirrors() {
            
            let jsonKey = mapFromJson[name] != nil ? mapFromJson[name]! : (snakeCase ? name.camelCaseToSnakeCase : name)
            
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
                    handleString(value as! String, name, mirror)
                case is Int:
                    setValue(value as! Int, forKey: name)
                case is Date:
                    setValue(value as! Date, forKey: name)
                case is [[String: Any]]:
                    if mirror.displayStyle != .optional {
                        print("⚠️ EasyJSON WARNING: Property named \"\(name)\" was not set because not declared as subObject.\n    This can result in unwanted behavior! \n    TO REMOVE THIS WARNING: make property named \"\(name)\" optional in class \"\(Mirror(reflecting: self).subjectType)\".")
                    }
                case is [String: Any]:
                    if mirror.displayStyle != .optional {
                        print("⚠️ EasyJSON WARNING: Property named \"\(name)\" was not set because not declared as subObject.\n    This can result in unwanted behavior! \n    TO REMOVE THIS WARNING: make property named \"\(name)\" optional in class \"\(Mirror(reflecting: self).subjectType)\".")
                    }
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
        for (key, _) in propertyMirrors() {
            
            if allExcludes.contains(key) {
                continue
            }
            
            let jsonKey = mapToJson[key] != nil ? mapToJson[key]! : (snakeCase ? key.camelCaseToSnakeCase : key)
            
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
    private func handleString(_ string: String,_ property: String, _ mirror: Mirror) {
        if mirror.subjectType == Date!.self || mirror.subjectType == Date?.self {
            if let date = Date.from(string, format: timeFormat, timeZone: isUTC ? TimeZone(identifier: "UTC")! : .autoupdatingCurrent) {
                self.setValue(date, forKey: property)
            }else if let date = Date.from(string, format: "HH:mm:ss", timeZone: isUTC ? TimeZone(identifier: "UTC")! : .autoupdatingCurrent) {
                self.setValue(date, forKey: property)
            }
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

extension String {
    internal var snakeCaseToCamelCase: String {
        let items = self.components(separatedBy: "_")
        var camelCase = ""
        
        items.enumerated().forEach { (arg) in
            let (index, value) = arg
            camelCase += 0 == index ? value : value.capitalized
        }
        return camelCase
    }
    
    internal var camelCaseToSnakeCase: String {
        let stringCharacters = String(self).map{ String($0) }
        let snakeCaseString = stringCharacters.map{ $0.lowercased() != $0 ? "_" + $0.lowercased() : $0 }.joined()
        
        return snakeCaseString
    }
}

extension Date {
    static func from(_ string: String, format: String = "yyyy-MM-dd'T'HH:mm:ss", timeZone: TimeZone = .autoupdatingCurrent) -> Date?  {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.date(from: string)
    }
    
    func dateString(_ format: String = "MM/dd/yyyy HH:mm a", timeZone: TimeZone = .autoupdatingCurrent) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }
}
