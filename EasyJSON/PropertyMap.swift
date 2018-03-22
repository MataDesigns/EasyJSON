//
//  PropertyMapper.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/22/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit

/// A protocol using to map a two string
public protocol KeyMap {
    var modelKey: String? {get set}
    var jsonKey: String? {get set}
}

/// A Map for a property and json key.
public class PropertyMap: KeyMap {
    public var modelKey: String?
    public var jsonKey: String?
    
    public init(modelKey: String?, jsonKey: String?) {
        self.modelKey = modelKey
        self.jsonKey = jsonKey
    }
}


/// A Map for hiding a property (empty map)
public class HidePropertyMap: KeyMap {
    public var modelKey: String?
    public var jsonKey: String?
    
    public init(modelKey: String?) {
        self.modelKey = modelKey
        self.jsonKey = nil
    }
}
