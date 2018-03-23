//
//  EasyModel.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 10/17/16.
//  Copyright © 2016 MataDesigns. All rights reserved.
//

import Foundation

enum EasyModelError: Error, CustomStringConvertible {
    
    
    case invalidType(propertyName: String, extra: String)
    case nonOptional(propertyName: String, type: Any.Type)
    case missingRequired(propertyName: String, type: Any.Type)
    
    var description: String {
        return "‼️ EasyModel Error: \(caseDescription)"
    }
    
    var caseDescription: String {
        let considerOptional = "Consider changing to optional to void this error."
        switch self {
        case .nonOptional(let name, let type): return "Non-optional property \(name): \(String(reflecting: type)) cannot be nil. \(considerOptional)"
        case .invalidType(let name, let extra): return "Cannot set value for property \(name): \(extra)"
        case .missingRequired(let name, let type): return "No value found for required property \(name): \(String(reflecting: type)). \(considerOptional)"
        }
    }
}

/// A simple class implementing EasyJSON so that init isnt required.
open class EasyModel: EasyJSON {
    open private(set) var _options_: EasyModelOptions = EasyModelOptions()
    
    public required init() {}
}


/// A protocol designed to Object map JSON. Can be used on class or struct.
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
        try fill(withDict: parsedData)
    }
    
    /**
     Fills the object with the json provided.
     
     - Parameters:
     - jsonDict: JSON represented as a dictionary.
     */
    public mutating func fill(withDict jsonDict: [String: Any?]) throws {
        for (name, mirror, mirrorValue) in propertyMirrors() {
            // Get jsonKey aka property name unless snakeCased option is enabled
            var jsonKey = _options_.snakeCased ? name.camelCaseToSnakeCase : name
            // Check if property has a custom map
            if let map = _options_.map(for: name) {
                // Get new jsonKey from the map
                guard let mapKey = map.jsonKey else {
                    // Continue because map jsonKey was nil (aka dont fill property)
                    continue
                }
                jsonKey = mapKey
            }
            // Get value from json dict for key (aka property name or from a map)
            guard let value = jsonDict[jsonKey] else {
                // Json Dict doesnt contain key (Check if property is required aka non-optional)
                if getValue(for: name) == nil && !isOptional(type: mirror.subjectType) {
                    throw EasyModelError.missingRequired(propertyName: name, type: mirror.subjectType)
                }
                continue
            }
            
            // Check if jsonDict is nil that the property is Optional (aka can be nil).
            if value == nil && !isOptional(type: mirror.subjectType) {
                throw EasyModelError.nonOptional(propertyName: name, type: mirror.subjectType)
            }
            
            // Check if property has a converter
            if let converter = _options_.converter(for: name) {
                // Get value from converter
                let convertValue = converter.toModel(value)
                try setValue(convertValue, forKey: name)
                continue
            }
            
            switch value {
            // If value is array of json objects.
            case let jsonArray as [[String: Any]]:
                guard let objectType = getBaseType(mainType: mirror.subjectType) as? EasyJSON.Type else {
                    // TODO: This is a error
                    print("Base Type not Class/EasyModel")
                    continue
                }
                // If array is initialized in code use that value else create new array.
                var modelObjects = mirrorValue as? [EasyJSON] ?? [EasyJSON]()
                modelObjects.removeAll()
                for jsonObject in jsonArray {
                    var objc = objectType.init()
                    try objc.fill(withDict: jsonObject)
                    modelObjects.append(objc)
                }
                try setValue(modelObjects, forKey: name)
            // If value is json object.
            case let jsonObject as [String: Any]:
                guard let easyModelType = getBaseType(mainType: mirror.subjectType) as? EasyJSON.Type else {
                    // TODO: this is a error
                    print("Base Type not Class/EasyModel")
                    continue
                }
                var easyModel = mirrorValue as? EasyJSON ?? easyModelType.init()
                try easyModel.fill(withDict: jsonObject)
                try setValue(easyModel, forKey: name)
            default:
                try setValue(value, forKey: name)
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
    
    private func getBaseType(mainType: Any.Type) -> AnyClass? {
        let typeString = String(reflecting: mainType)
        let typeComponents = typeString.components(separatedBy: "<")
        let baseType = typeComponents[typeComponents.count-1].replacingOccurrences(of: ">", with: "")
        return NSClassFromString(baseType)
    }
    
    private func isOptional(type: Any.Type) -> Bool {
        let typeString = String(reflecting: type)
        if typeString.contains("ImplicitlyUnwrapped") {
            return false
        }
        return typeString.contains("Optional")
    }
    
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
    private mutating func setValue(_ value: Any?, forKey key: String) throws {
        guard let value = value else {
            return
        }
        do {
            return try Reflection.set(value, key: key, for: &self)
        } catch  {
            throw EasyModelError.invalidType(propertyName: key, extra: String(describing: error))
        }        
    }
    
    /**
     Parse mirror matching mirror to property name
     (Parsing superclass as well.)
     
     - Parameter
     - mirror: mirror which went want to get all the properties.
     - Returns: An array of tuples that is the property name and the property mirror.
     */
    private func mirrorTo(_ mirror: Mirror) -> [(String, Mirror, Any?)] {
        var results: [(String, Mirror, Any?)] = []
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
    private func propertyMirrors() -> [(String, Mirror, Any?)] {
        var results: [(String, Mirror, Any?)] = []
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
