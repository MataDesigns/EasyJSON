//
//  Any+Extensions.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/18/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

protocol AnyExtensions {}

extension AnyExtensions {
    
    static func construct(constructor: (Property.Description) throws -> Any) throws -> Any {
        return try Reflection.constructGenericType(self, constructor: constructor)
    }
    
    static func isValueTypeOrSubtype(_ value: Any) -> Bool {
        return value is Self
    }
    
    static func value(from storage: UnsafeRawPointer) -> Any {
        return storage.assumingMemoryBound(to: self).pointee
    }
    
    static func write(_ value: Any, to storage: UnsafeMutableRawPointer) throws {
        guard let this = value as? Self else {
            throw ReflectionError.valueIsNotType(value: value, type: self)
        }
        storage.assumingMemoryBound(to: self).initialize(to: this)
    }
    
}

extension AnyExtensions {
    
    mutating func mutableStorage() -> UnsafeMutableRawPointer {
        return Reflection.mutableStorage(instance: &self)
    }
    
    mutating func storage() -> UnsafeRawPointer {
        return Reflection.storage(instance: &self)
    }
    
    static func of(type: Any.Type) -> AnyExtensions.Type {
        var extensions: AnyExtensions.Type = Extensions.self
        withUnsafePointer(to: &extensions) { pointer in
            UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: Any.Type.self).pointee = type
        }
        return extensions
    }
    
    static func of(value: Any) -> AnyExtensions {
        var extensions: AnyExtensions = Extensions()
        withUnsafePointer(to: &extensions) { pointer in
            UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: Any.self).pointee = value
        }
        return extensions
    }
    
}

struct Extensions : AnyExtensions {}

//func extensions(of type: Any.Type) -> AnyExtensions.Type {
//    struct Extensions : AnyExtensions {}
//    var extensions: AnyExtensions.Type = Extensions.self
//    withUnsafePointer(to: &extensions) { pointer in
//        UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: Any.Type.self).pointee = type
//    }
//    return extensions
//}

//func extensions(of value: Any) -> AnyExtensions {
//    struct Extensions : AnyExtensions {}
//    var extensions: AnyExtensions = Extensions()
//    withUnsafePointer(to: &extensions) { pointer in
//        UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: Any.self).pointee = value
//    }
//    return extensions
//}

