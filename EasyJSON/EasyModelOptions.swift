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
    public var maps: [KeyMap]
    public var snakeCased: Bool
    
    public init(snakeCased: Bool = false, converters: [Converter]? = nil, maps: [KeyMap]? = nil) {
        self.snakeCased = snakeCased
        self.converters = converters ?? [Converter]()
        self.maps = maps ?? [KeyMap]()
    }
    
    public func converter(for key: String) -> Converter? {
        return converters.first(where: { (converter) -> Bool in
            return converter.key == key
        })
    }
    
    public func map(for modelKey: String) -> KeyMap? {
        return maps.first(where: { (map) -> Bool in
            return map.modelKey == modelKey
        })
    }
}