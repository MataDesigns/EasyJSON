//
//  EasyModel.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 10/17/16.
//  Copyright © 2016 MataDesigns. All rights reserved.
//

import Foundation

open class EasyModel: EasyJSON {
    open private(set) var _options_: EasyModelOptions = EasyModelOptions()
    
    public required init() {}
}

public protocol EasyJSON {
    init()
    var _options_: EasyModelOptions {get}
}

extension EasyJSON {
    // MARK: - Public Functions
    
    /**
     Fills the object with the json provided.
     
     - Parameters:
     - jsonString: JSON represented as a string.
     
     */
    public mutating func fill(withJson jsonString: String) throws {
        let jsonData = jsonString.data(using: .utf8)
        let parsedData = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as! [String : Any]
        fill(withDict: parsedData)
    }
    
    /**
     Fills the object with the json provided.
     
     - Parameters:
     - jsonDict: JSON represented as a dictionary.
     */
    public mutating func fill(withDict jsonDict: [String: Any?]) {
        for (name, mirror, mirrorValue) in propertyMirrors() {
            
            var jsonKey = _options_.snakeCased ? name.camelCaseToSnakeCase : name
            
            if let map = _options_.map(for: name) {
                if let mapKey = map.jsonKey {
                    jsonKey = mapKey
                } else {
                    continue
                }
            }
            
            if let value = jsonDict[jsonKey] {
                
                if let converter = _options_.converter(for: name) {
                    let convertValue = converter.toModel(value)
                    setValue(convertValue, forKey: name)
                    continue
                }
                
                switch value {
                case let jsonArray as [[String: Any]]:
                    let type = String(reflecting: mirror.subjectType.self)
                    
                    var subtype = ""
                    if type.components(separatedBy: "<").count > 1 {
                        // Remove the Array prefix
                        subtype = String(type[(type.components(separatedBy: "<") [0] + "<").endIndex...])
                        subtype = String(subtype[..<subtype.index(before: subtype.endIndex)])
                        
                        // Remove the optional prefix from the subtype
                        if subtype.hasPrefix("Optional<") {
                            subtype = String(subtype[(subtype.components(separatedBy: "<") [0] + "<").endIndex...])
                            subtype = String(subtype[..<subtype.index(before: subtype.endIndex)])
                        }
                    }
                    if let objectType = NSClassFromString(subtype) {
                        if var modelObjects = mirrorValue as? [EasyJSON] {
                            modelObjects.removeAll()
                            for jsonObject in jsonArray {
                                var objc = (objectType as! EasyJSON.Type).init()
                                objc.fill(withDict: jsonObject)
                                modelObjects.append(objc)
                            }
                            setValue(modelObjects, forKey: name)
                        }
                    }
                case let jsonObject as [String: Any]:
                    var easyModel = mirrorValue as! EasyJSON
                    easyModel.fill(withDict: jsonObject)
                    setValue(easyModel, forKey: name)
                default:
                    setValue(value, forKey: name)
                }
                
            }
        }
    }
    
    /**
     Turns in object into JSON dictionary. [String: Any]
     
     - Returns: Dictionary representing the model in JSON.
     */
    public func toJson() -> [String: Any] {
        var json = [String: Any]()
        for (key, _, _) in propertyMirrors() {
            
            if key == "_options_" {
                continue
            }
            
            var jsonKey = _options_.snakeCased ? key.camelCaseToSnakeCase : key
            
            if let map = _options_.map(for: key) {
                if let mapKey = map.jsonKey {
                    jsonKey = mapKey
                } else {
                    continue
                }
            }
            
            let propertyValue = getValue(for: key)
            
            if let converter = _options_.converter(for: key) {
                let convertValue = converter.toJson(propertyValue)
                json[jsonKey] = convertValue
                continue
            }
            
            
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
     Get the value of the property using Reflection
     
     - Parameter
     - key: The property key/name
     - Returns: The value of the property
     */
    private func getValue(for key:String) ->Any? {
        do {
            return try Reflection.get(key, from: self)
        } catch  {
            return nil
        }
    }
    
    /**
     Set the value of the property using Reflection
     
     - Parameters:
     - value: The value to set the property too
     - key: The property key/name
     */
    private mutating func setValue(_ value: Any?, forKey key:String) {
        guard let value = value else {
            return
        }
        do {
            return try Reflection.set(value, key: key, for: &self)
        } catch  {
            print(error)
        }
        
        return
    }
    
    /**
     Parse mirror matching mirror to property name
     (Parsing superclass as well.)
     
     - Parameter
     - mirror: mirror which went want to get all the properties.
     - Returns: An array of tuples that is the property name and the property mirror.
     */
    private func mirrorTo(_ mirror: Mirror) -> [(String, Mirror, Any)] {
        var results: [(String, Mirror, Any)] = []
        for child in mirror.children
        {
            if let name = child.label{
                results.append((name, Mirror(reflecting: child.value), child.value))
            }
        }
        if let parent = mirror.superclassMirror {
            results.append(contentsOf: mirrorTo(parent))
        }
        return results
    }
    
    /**
     Gets the property name and mirror found in this object.
     This is a helper method used to get information about the properties
     of the object.
     
     - Returns: A dictionary where key is the property name and value is
     the mirror for the property.
     */
    private func propertyMirrors() -> [(String, Mirror, Any)] {
        var results: [(String, Mirror, Any)] = []
        let mirror = Mirror(reflecting: self)
        results.append(contentsOf: mirrorTo(mirror))
        
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
    public static func from(_ string: String, format: String = "yyyy-MM-dd'T'HH:mm:ss", timeZone: TimeZone = .autoupdatingCurrent) -> Date?  {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.date(from: string)
    }
    
    public func dateString(_ format: String = "MM/dd/yyyy HH:mm a", timeZone: TimeZone = .autoupdatingCurrent) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }
}
