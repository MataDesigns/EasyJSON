//
//  TestModelConversion.swift
//  EasyJSONTests
//
//  Created by Nicholas Mata on 3/22/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit
import EasyJSON

class TestModelWithOptions: EasyModel {
    fileprivate var snakeCased:Bool
    
    override var _options_: EasyModelOptions {
        let timeConverter = DateConverter(key: "time", format: "HH:mm")
        let isGuestConverter = BoolConverter(key: "isValid", trueWhen: "Yes", whenFalse: "No")
        
        let hideSnake = HidePropertyMap(modelKey: "snakeCased")
        
        let converters: [Converter] = [timeConverter, isGuestConverter]
        let maps: [KeyMap] = [hideSnake]
        return EasyModelOptions(snakeCased: snakeCased, converters: converters, maps: maps)
    }
    
    public var id: Int!
    public var isValid: Bool!
    public var time: Date?
    
    required init(snakeCased: Bool) {
        self.snakeCased = snakeCased
        super.init()
    }
    
    required init() {
        self.snakeCased = false
    }
}
