//
//  Metadata+Struct.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/18/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

extension Metadata {
    struct Struct : NominalType {
        static let kind: Kind? = .struct
        var pointer: UnsafePointer<_Metadata._Struct>
        var nominalTypeDescriptor: NominalTypeDescriptor {
            return pointer.pointee.nominalTypeDescriptor
        }
    }
}

extension _Metadata {
    struct _Struct {
        var kind: Int
        var nominalTypeDescriptor: NominalTypeDescriptor
        var parent: Metadata?
    }
}
