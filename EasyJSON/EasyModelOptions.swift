//
//  EasyModelOptions.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/22/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit

public struct EasyModelOptions {
    public var converters : [Converter]
    public var mappers: [KeyMap]
    public var snakeCased: Bool
    
    public init(snakeCased: Bool = false, converters: [Converter]? = nil, mappers: [KeyMap]? = nil) {
        self.snakeCased = snakeCased
        self.converters = converters ?? [Converter]()
        self.mappers = mappers ?? [KeyMap]()
    }
    
    public func converter(for key: String) -> Converter? {
        return converters.first(where: { (converter) -> Bool in
            return converter.key == key
        })
    }
    
    public func mapper(for modelKey: String) -> KeyMap? {
        return mappers.first(where: { (mappers) -> Bool in
            return mappers.modelKey == modelKey
        })
    }
}