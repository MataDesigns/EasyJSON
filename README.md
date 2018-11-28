# DEPRECATED - Swift 4.2 adds native support [Learn More](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types)

# EasyJSON

[![CI Status](http://img.shields.io/travis/MataDesigns/EasyJSON.svg?style=flat)](https://travis-ci.org/MataDesigns/EasyJSON)
[![Version](https://img.shields.io/cocoapods/v/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)
[![License](https://img.shields.io/cocoapods/l/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)
[![Platform](https://img.shields.io/cocoapods/p/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)

EasyJSON is a simple JSON to Object mapper.

- [Features](#features)
- [Usage](#usage)
    - **Intro -** [Creating Model](#creating-model), [Filling Model](#filling-model), [Model To JSON](#model-to-json)
    - **Advanced -** [KeyMaps](#keymaps), [Converters](#converters), [Mapping SubObjects](#mapping-subobjects)

## Requirements
- iOS 9.0+
- Xcode 8.0+
- Swift 3.0+

## Installation

### Cocoapods
EasyJSON is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "EasyJSON"
```

### Carthage
 To install it, simple add the following line to your Cartfile
```ruby
github "MataDesigns/EasyJSON"
```

## Features

- ✅ Allow custom mapping to and from JSON
- ✅ Map properties that are also subclasses of EasyModel
- ✅ Allow custom handler for a parsing a specific property
- ✅ Map subobjects
- ✅ snake_case🐍 and camelCase🐪 support

## Usage

### Important !!! currently only class are supported (if you use structs this will not work)

### Intro

#### Creating Model

Just create a class whos subclass is a EasyModel.

```swift
import EasyJSON

class Person: EasyModel {
    var id: Int!
    var firstName: String?
    var lastName: String?
}
```

#### Filling Model

To go from JSON to Model.

1. Create a empty Model
2. Call fill(withJson:)
3. Your model is now filled with the information from the dictionary.

**So long as the keys match the property name exactly.**

If your Dictionary keys are different from the property names go to [KeyMaps](#keymaps).

```swift
import EasyJSON

// Person Model

let json = ["id": 1, "firstName": "Jane", "lastName": "Doe"]
let person = Person()
person.fill(withDict: json)

print(person.id)        // Prints 1
print(person.firstName) // Prints Jane
print(person.lastName)  // Prints Doe
```

#### Model To JSON

```swift
import EasyJSON

let json = person.toJson()
print(json) // Prints ["id": 1, "firstName": "Jane", "lastName": "Doe"]
```

## Advanced

### KeyMaps

You can make custom keymaps by implementing the KeyMap protocol.<br/>
Currently we provide two KeyMaps.

#### PropertyMap
Now what about when your JSON is different from your property names?

```swift
import EasyJSON

class Person: EasyModel {
    override var _options_: EasyModelOptions {
    	var maps = [KeyMap]()
        maps.append(PropertyMap(modelKey: "id", jsonKey: "personId"))
        return EasyModelOptions(maps: maps)
    }
    
    var id: Int!
    var firstName: String?
    var lastName: String?
}
```
Then you can now use the following json to fill then object.

```swift
let json = ["personId": 1, "firstName": "Jane", "lastName": "Doe"]

let person = Person()
person.fill(withDict: json)

print(person.id)        // Prints 1
print(person.firstName) // Prints Jane
print(person.lastName)  // Prints Doe
```

#### HidePropertyMap
Now what about when you have a property that has nothing to do with the json?
```swift
import EasyJSON

class Person: EasyModel {
    override var _options_: EasyModelOptions {
    	var maps = [KeyMap]()
        maps.append(HidePropertyMap(modelKey: "fullName"))
        return EasyModelOptions(maps: maps)
    }
    
    var id: Int!
    var firstName: String?
    var lastName: String?
    var fullName: String {
        var name = ""
        name = name + (firstName ?? "")
        name = name + (lastName != nil ? " " + lastName! : "")
        return name
    }
}
```
Then you fill or toJson the property is hidden

```swift
let json = ["personId": 1, "firstName": "Jane", "lastName": "Doe"]

let person = Person()
person.fill(withDict: json)

print(person.id)        // Prints 1
print(person.firstName) // Prints Jane
print(person.lastName)  // Prints Doe
print(person.fullName)  // Prints Jane Doe

let jsonDict = person.toJson()
print(jsonDict["fullName"]) // Prints nothing fullName key doesn't exist.
```

### Converters
You can make custom converter by implementing the Converter protocol.<br/>
Converters can be applied to either a specific type or a specific key.<br/>
(Key ConverterKey takes priority over Type ConverterKey)<br/>
Currently we provide two Converters.<br/>
#### DateConverter
String to Date
```swift
{
   "id": 1,
   "firstName": "Nicholas",
   "lastName": "Mata",
   "birthday": "02/18/1994",
   "createdOn": "2017-01-28T10:00:48",
   "updatedOn": "2017-01-28T10:00:48"
}
```
So the Dates are just Strings so how do we change this into a Date Type 
and then convert back when turning into json?
```swift
import EasyJSON

class Person: EasyModel {
    override var _options_: EasyModelOptions {
    	var converters = [ConverterKey:Converter]()
	converters[.key("birthDate")] = DateConverter(format: "MM/dd/yy")
        converters[.type(Date.self)] = DateConverter(format: "yyyy-MM-dd'T'HH:mm:ss")
        return EasyModelOptions(converters: converters)
    }
    
    var id: Int!
    var firstName: String?
    var lastName: String?
    
    var birthday: Date?
    var createdOn: Date?
    var updatedOn: Date?
}
```

Thats it then you can use it like any other Date type.

#### BoolConverter
String to Bool
```swift
{
   "id": 1,
   "firstName": "Nicholas",
   "lastName": "Mata",
   "isBestFriend" : "No"
}
```
So how do we turn a string into a bool?
```swift
import EasyJSON

class Person: EasyModel {
    override var _options_: EasyModelOptions {
    	var converters = [ConverterKey:Converter]()
	converters[.key("isBestFriend")] = BoolConverter(trueWhen: "Yes", whenFalse: "No", caseSensitive: false)
        return EasyModelOptions(converters: converters)
    }
    
    var id: Int!
    var firstName: String?
    var lastName: String?
    var isBestFriend: Bool = false
}
```

### Mapping SubObjects

Now lets say you have something like this.

```swift
class Student: EasyModel {
    var id: Int!
    var firstName: String?
    var lastName: String?
}

class Classroom: EasyModel {
    var id: Int!
    var name: String?
    var students: [Student]?
}
```
And your JSON looks something like this

```json
{
	"id": 1,
	"name": "Computer Science",
	"students": [{
		"id": 1,
		"firstName": "Nicholas",
		"lastName": "Mata"
	}, 
	{
		"id":2,
		"firstName": "Jane",
		"lastName": "Doe"
	}]
}
```
It just simply works.


## Author

Nicholas Mata, nicholas@matadesigns.net

## License

EasyJSON is available under the MIT license. See the LICENSE file for more info.
