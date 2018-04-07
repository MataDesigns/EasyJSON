# EasyJSON

[![CI Status](http://img.shields.io/travis/MataDesigns/EasyJSON.svg?style=flat)](https://travis-ci.org/MataDesigns/EasyJSON)
[![Version](https://img.shields.io/cocoapods/v/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)
[![License](https://img.shields.io/cocoapods/l/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)
[![Platform](https://img.shields.io/cocoapods/p/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)

EasyJSON is a simple JSON to Object mapper.

- [Features](#features)
- [Usage](#usage)
    - **Intro -** [Creating Model](#creating-model), [Filling Model](#filling-model), [Model To JSON](#model-to-json)
    - **Advanced -** [Custom Mapping](#custom-mapping), [Mapping SubObjects](#mapping-subobjects)

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

If your Dictionary keys are different from the property names go to [Custom Mapping](#custom-mapping).

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

### Custom Mapping

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

### Mapping SubObjects

Now lets say you have something like this.

```swift
class Student: EasyModel {
    var id: Int = -1
    var firstName: String?
    var lastName: String?
}

class Classroom: EasyModel {
    var id: Int = -1
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
