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


/// A protocol for encoding and decoding a specific key
public protocol Converter {
    var key: String {get}
    var toModel: ToModelConverter {get}
    var toJson: ToJsonConverter {get}
}

// Encoding and decoding a specific property
public class PropertyConverter: Converter {
    public var key: String
    public var toModel: ToModelConverter
    public var toJson: ToJsonConverter
    
    public init(key: String, toModel: @escaping ToModelConverter, toJson: @escaping ToJsonConverter) {
        self.key = key
        self.toModel = toModel
        self.toJson = toJson
    }
}

/// A converter for relationship between a string and date
public class DateConverter: Converter {
    public var key: String
    public var toModel: ToModelConverter
    public var toJson: ToJsonConverter
    
    public init(key: String, format:String) {
        self.key = key
        toModel = { return Date.from($0 as! String, format: format) }
        toJson = { return ($0 as! Date).dateString(format) }
    }
}


/// A converter for description the relationship between a string and bool
public class BoolConverter: Converter {
    public var key: String
    public var toModel: ToModelConverter
    public var toJson: ToJsonConverter
    
    public init(key: String, trueWhen: String, whenFalse: String, caseSensitive: Bool = false) {
        self.key = key
        var trueString = trueWhen
        if !caseSensitive {
            trueString = trueString.lowercased()
        }
        toModel = {
            let value = caseSensitive ? ($0 as! String) : ($0 as! String).lowercased()
            return (value == trueString) ? true : false
            
        }
        toJson = {
            return ($0 as! Bool) ? trueWhen : whenFalse
        }
    }
}
