//
//  Reflection.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/18/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit

class Reflection {
    static func constructGenericType<T>(_ type: T.Type = T.self, constructor: (Property.Description) throws -> Any) throws -> T {
        if Metadata(type: T.self)?.kind == .struct {
            return try constructValueType(constructor)
        } else {
            throw ReflectionError.notStruct(type: T.self)
        }
    }
    
    static private func constructValueType<T>(_ constructor: (Property.Description) throws -> Any) throws -> T {
        guard Metadata(type: T.self)?.kind == .struct else { throw ReflectionError.notStruct(type: T.self) }
        let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        defer { pointer.deallocate(capacity: 1) }
        var values: [Any] = []
        try constructType(storage: UnsafeMutableRawPointer(pointer), values: &values, properties: Property.getAll(for: T.self), constructor: constructor)
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
}

extension Reflection {
    /// Get value for key from instance
    public static func get(_ key: String, from instance: Any) throws -> Any {
        guard let value = try Property.getAll(for: instance).first(where: { $0.key == key })?.value else {
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
        guard let property = try Property.getAll(for: type).first(where: { $0.key == key }) else { throw ReflectionError.instanceHasNoKey(type: type, key: key) }
        return property
    }
}
