//
//  EasyModel.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 10/17/16.
//  Copyright © 2016 MataDesigns. All rights reserved.
//

import UIKit

class EasyModel: NSObject {
    /**
     * Gets the property name and mirror found in this object.
     * This is a helper method used to get information about the properties
     * of the object.
     */
    private func propertyMirrors() -> [(String, Mirror)] {
        var results: [(String, Mirror)] = []
        
        for child in Mirror(reflecting: self).children
        {
            if let name = child.label{
                results.append((name, Mirror(reflecting: child.value)))
            }
        }
        
        return results
    }
}
