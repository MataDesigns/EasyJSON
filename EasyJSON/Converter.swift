//
//  PropertyConverter.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/22/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit

public typealias ToModelConverter = (Any?) -> Any?
public typealias ToJsonConverter = (Any?) -> Any?

public enum ConverterKey {
    case key(String)
    case type(Any.Type)
}

extension ConverterKey: Hashable {
    public var hashValue: Int {
        switch self {
        case .key(let string):
            return string.hashValue
        case .type(let typeOf):
            let typeString = String(describing: typeOf)
            let components = typeString.components(separatedBy: "Optional<")
            guard components.count == 2 else {
                return typeString.hashValue
            }
            let removedOptional = components[1]
            return removedOptional.dropLast().hashValue
        }
    }
    
    public static func ==(lhs: ConverterKey, rhs: ConverterKey) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

/// A protocol for encoding and decoding a value
public protocol Converter {
    var toModel: ToModelConverter {get}
    var toJson: ToJsonConverter {get}
}

/// A converter for relationship between a string and date
public class DateConverter: Converter {
    public var toModel: ToModelConverter
    public var toJson: ToJsonConverter
    
    public init(format:String, timeZone: TimeZone = .autoupdatingCurrent) {
        self.toModel = { return Date.from($0 as! String, format: format, timeZone: timeZone) }
        self.toJson = { return ($0 as! Date).dateString(format) }
    }
}

/// A converter for description the relationship between a string and bool
public class BoolConverter: Converter {
    public var toModel: ToModelConverter
    public var toJson: ToJsonConverter
    
    
    public init(key: String, trueWhen: String, whenFalse: String, caseSensitive: Bool = false) {
        var trueString = trueWhen
        if !caseSensitive {
            trueString = trueString.lowercased()
        }
        
        self.toModel = {
            let value = caseSensitive ? ($0 as! String) : ($0 as! String).lowercased()
            return (value == trueString) ? true : false
        }
        
        self.toJson = { return ($0 as! Bool) ? trueWhen : whenFalse}
    }
}
