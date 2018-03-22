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
        var nominalTypeDescriptorOffsetLocation: Int {
            return 1
        }
    }
}

extension _Metadata {
    struct _Struct {
        var kind: Int
        var nominalTypeDescriptorOffset: Int
        var parent: Metadata?
    }
}
