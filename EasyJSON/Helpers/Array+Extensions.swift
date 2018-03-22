//
//  Array+Extensions.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 3/18/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

protocol UTF8Initializable {
    init?(validatingUTF8: UnsafePointer<CChar>)
}

extension String : UTF8Initializable {}

extension Array where Element : UTF8Initializable {

    init(utf8Strings: UnsafePointer<CChar>) {
        var strings = [Element]()
        var pointer = utf8Strings
        while let string = Element(validatingUTF8: pointer) {
            strings.append(string)
            while pointer.pointee != 0 {
                pointer.advance()
            }
            pointer.advance()
            guard pointer.pointee != 0 else { break }
        }
        self = strings
    }

}
