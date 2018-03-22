//
//  Reflection.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/18/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit

class Reflection {
    /// Create a struct with a constructor method. Return a value of `property.type` for each property.
    static public func construct<T>(_ type: T.Type = T.self, constructor: (Property.Description) throws -> Any) throws -> T {
        return try constructGenericType(constructor: constructor)
    }
    
    static func constructGenericType<T>(_ type: T.Type = T.self, constructor: (Property.Description) throws -> Any) throws -> T {
        if Metadata(type: T.self)?.kind == .struct {
            return try constructValueType(constructor)
        } else {
            throw ReflectionError.notStruct(type: T.self)
        }
    }
    
    /// Create a struct with a constructor method. Return a value of `property.type` for each property.
    static public func construct(_ type: Any.Type, constructor: (Property.Description) throws -> Any) throws -> Any {
        return try extensions(of: type).construct(constructor: constructor)
    }
    
    static private func constructValueType<T>(_ constructor: (Property.Description) throws -> Any) throws -> T {
        guard Metadata(type: T.self)?.kind == .struct else { throw ReflectionError.notStruct(type: T.self) }
        let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        defer { pointer.deallocate(capacity: 1) }
        var values: [Any] = []
        try constructType(storage: UnsafeMutableRawPointer(pointer), values: &values, properties: properties(T.self), constructor: constructor)
        return pointer.move()
    }
    
    static private func constructType(storage: UnsafeMutableRawPointer, values: inout [Any], properties: [Property.Description], constructor: (Property.Description) throws -> Any) throws {
        var errors = [Error]()
        for property in properties {
            do {
                let value = try constructor(property)
                values.append(value)
                try property.write(value, to: storage)
            } catch {
                errors.append(error)
            }
        }
        if errors.count > 0 {
            throw ConstructionErrors(errors: errors)
        }
    }
    
    /// Create a struct from a dictionary.
    static public func construct<T>(_ type: T.Type = T.self, dictionary: [String: Any]) throws -> T {
        return try constructGenericType(constructor: constructorForDictionary(dictionary))
    }
    
    /// Create a struct from a dictionary.
    static public func construct(_ type: Any.Type, dictionary: [String: Any]) throws -> Any {
        return try construct(type, constructor: constructorForDictionary(dictionary))
    }
    
    static private func constructorForDictionary(_ dictionary: [String: Any]) -> (Property.Description) throws -> Any {
        return { property in
            if let value = dictionary[property.key] {
                return value
            } else if let expressibleByNilLiteral = property.type as? ExpressibleByNilLiteral.Type {
                return expressibleByNilLiteral.init(nilLiteral: ())
            } else {
                throw ReflectionError.requiredValueMissing(key: property.key)
            }
        }
    }
}

extension Reflection {
    /// Get value for key from instance
    public static func get(_ key: String, from instance: Any) throws -> Any {
        guard let value = try properties(instance).first(where: { $0.key == key })?.value else {
            throw ReflectionError.instanceHasNoKey(type: type(of: instance), key: key)
        }
        return value
    }
    
    /// Get value for key from instance as type `T`
    public static func get<T>(_ key: String, from instance: Any) throws -> T {
        let any: Any = try get(key, from: instance)
        guard let value = any as? T else {
            throw ReflectionError.valueIsNotType(value: any, type: T.self)
        }
        return value
    }
}

extension Reflection {
    static func mutableStorage<T>(instance: inout T) -> UnsafeMutableRawPointer {
        return mutableStorage(instance: &instance, type: type(of: instance))
    }
    
    static func mutableStorage<T>(instance: inout T, type: Any.Type) -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(mutating: storage(instance: &instance, type: type))
    }
    
    static func storage<T>(instance: inout T) -> UnsafeRawPointer {
        return storage(instance: &instance, type: type(of: instance))
    }
    
    static func storage<T>(instance: inout T, type: Any.Type) -> UnsafeRawPointer {
        return withUnsafePointer(to: &instance) { pointer in
            if type is AnyClass {
                return UnsafeRawPointer(bitPattern: UnsafePointer<Int>(pointer).pointee)!
            } else {
                return UnsafeRawPointer(pointer)
            }
        }
    }
}

extension Reflection {
    /// Set value for key of an instance
    static public func set(_ value: Any, key: String, for instance: inout Any) throws {
        let type = Swift.type(of: instance)
        try property(type: type, key: key).write(value, to: mutableStorage(instance: &instance, type: type))
    }
    
    /// Set value for key of an instance
    static public func set(_ value: Any, key: String, for instance: AnyObject) throws {
        var copy: Any = instance
        try set(value, key: key, for: &copy)
    }
    
    /// Set value for key of an instance
    static public func set<T>(_ value: Any, key: String, for instance: inout T) throws {
        try property(type: T.self, key: key).write(value, to: mutableStorage(instance: &instance))
    }
    
    static private func property(type: Any.Type, key: String) throws -> Property.Description {
        guard let property = try properties(type).first(where: { $0.key == key }) else { throw ReflectionError.instanceHasNoKey(type: type, key: key) }
        return property
    }
}
