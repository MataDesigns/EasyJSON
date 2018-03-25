//
//  Property.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/24/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit

/// An instance property
public struct Property {
    public let key: String
    public let value: Any
    
    /// An instance property description
    public struct Description {
        public let key: String
        public let type: Any.Type
        let offset: Int
        func write(_ value: Any, to storage: UnsafeMutableRawPointer) throws {
            return try Extensions.of(type: type).write(value, to: storage.advanced(by: offset))
        }
        
        internal func next(storage: UnsafeRawPointer) -> Property {
            return Property(
                key: self.key,
                value: Extensions.of(type: self.type).value(from: storage.advanced(by: self.offset))
            )
            
        }
    }
}

extension Property {
    
    internal static func getAll<T : NominalType>(forNominalType type: T) throws -> [Property.Description] {
        guard type.nominalTypeDescriptor.numberOfFields != 0 else { return [] }
        guard let fieldTypes = type.fieldTypes, let fieldOffsets = type.fieldOffsets else {
            throw ReflectionError.unexpected
        }
        let fieldNames = type.nominalTypeDescriptor.fieldNames
        return (0..<type.nominalTypeDescriptor.numberOfFields).map { i in
            return Property.Description(key: fieldNames[i], type: fieldTypes[i], offset: fieldOffsets[i])
        }
    }
    
    public static func getAll(for instance: Any) throws -> [Property] {
        let props = try Property.getAll(for: type(of: instance))
        var copy = Extensions.of(value: instance)
        let storage = copy.storage()
        return props.map { $0.next(storage: storage) }
    }
    
    public static func getAll(for type: Any.Type) throws -> [Property.Description] {
//        let hashedType = HashedType(type)
        
        if let nominalType = Metadata.Struct(type: type) {
            return try getAll(forNominalType: nominalType)
        } else if let nominalType = Metadata.Class(type: type) {
            return try nominalType.properties()
        } else {
            throw ReflectionError.notStruct(type: type)
        }
        
    }
}
