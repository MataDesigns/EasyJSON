//
//  PersonModel.swift
//  EasyJSONTests
//
//  Created by Nicholas Mata on 3/22/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit
import EasyJSON

let myAddressDict: [String: Any?] = [
    "id": 1,
    "streetAddress": "123 1st Street",
    "extendedAddress": nil,
    "city": "San Diego",
    "state": "California",
    "zipcode": "92093"
]

let myDict: [String: Any?] = [
    "id": 1,
    "firstName": "Nicholas",
    "middleName": nil,
    "lastName": "Mata",
    "facebookId": nil,
    "address": myAddressDict,
    "friends": [friendOne, friendTwo]
]

let friendOneAddress: [String: Any?] = [
    "id": 5,
    "streetAddress": "42 West Street",
    "extendedAddress": nil,
    "city": "San Jose",
    "state": "California",
    "zipcode": "95062"
]

let friendOne: [String: Any?] = [
    "id": 3,
    "firstName": "Baoquan",
    "middleName": nil,
    "lastName": "Dinh",
    "facebookId": nil,
    "address": friendOneAddress,
    "friends": []
]

let friendTwoAddress: [String: Any?] = [
    "id": 72,
    "streetAddress": "31 Washington Street",
    "extendedAddress": nil,
    "city": "Torrance",
    "state": "California",
    "zipcode": "95062"
]

let friendTwo: [String: Any?] = [
    "id" : 15,
    "firstName": "Ignacio",
    "middleName": nil,
    "lastName": "Sepulveda",
    "facebookId": nil,
    "address": friendTwoAddress,
    "friends": []
]

class UserModel: EasyModel {
    var id: Int!
    var firstName: String?
    var middleName: String?
    var lastName: String?
}

class PersonModel: UserModel {
    var facebookId: Int?
    var address: AddressModel!
    var friends = [PersonModel]()
}

class AddressModel: EasyModel {
    var id: Int!
    var streetAddress: String?
    var extendedAddress: String?
    
    var city: String?
    var state: String?
    var zipcode: String?
}
