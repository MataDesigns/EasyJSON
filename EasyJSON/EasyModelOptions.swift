//
//  EasyModelOptions.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/22/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit


/// Used during serializing and deserializing EasyModel
public struct EasyModelOptions {
    
    /// An array of converters used with object mapping EasyModel
    public var converters : [ConverterKey: Converter]
    /// An array of maps used with object mapping EasyModel
    public var maps: [KeyMap]
    /// Whether or not the json is snake_cased
    public var snakeCased: Bool
    
    public init(snakeCased: Bool = false, converters: [ConverterKey:Converter]? = nil, maps: [KeyMap]? = nil) {
        self.snakeCased = snakeCased
        self.converters = converters ?? [ConverterKey:Converter]()
        self.maps = maps ?? [KeyMap]()
    }
    
    
    /// Get the converter for a specific property (key) if exists.
    ///
    /// - Parameter key: The property the converter is for.
    /// - Returns: The converter for the given property.
    public func converter(for key: ConverterKey) -> Converter? {
        guard let converter = converters[key] else {
            return nil
        }
        return converter    }
    
    
    /// Get the map for a specific property (key) if exists
    ///
    /// - Parameter modelKey: The property the map is for.
    /// - Returns: The map for the given property
    public func map(for modelKey: String) -> KeyMap? {
        return maps.first(where: { (map) -> Bool in
            return map.modelKey == modelKey
        })
    }
}
