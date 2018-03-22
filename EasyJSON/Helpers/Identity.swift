//
//  Identity.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/18/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

/// Tests if `value` is `type` or a subclass of `type`
public func value(_ value: Any, is type: Any.Type) -> Bool {
    return extensions(of: type).isValueTypeOrSubtype(value)
}

/// Tests equality of any two existential types
public func ==(lhs: Any.Type, rhs: Any.Type) -> Bool {
    return Metadata(type: lhs) == Metadata(type: rhs)
}
