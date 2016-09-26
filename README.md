# EasyJSON

[![CI Status](http://img.shields.io/travis/Nicholas Mata/EasyJSON.svg?style=flat)](https://travis-ci.org/Nicholas Mata/EasyJSON)
[![Version](https://img.shields.io/cocoapods/v/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)
[![License](https://img.shields.io/cocoapods/l/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)
[![Platform](https://img.shields.io/cocoapods/p/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)

- [Usage](#usage)
    - **Intro -** [Creating Model](#creating-model), [Filling Model](#filling-model), [Model To JSON](#model-to-json)
    - **Advanced -** [Custom Mapping](#custom-mapping), [Mapping SubObjects](#mapping-subobjects)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 9.0+
- Xcode 8.0+
- Swift 3.0+

## Installation

EasyJSON is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "EasyJSON"
```

## Usage

### Intro

#### Creating Model

Just create a class whos subclass is a JSONModel.

**IMPORTANT** Properties that are type **Int** need a default value.

```swift
import EasyJSON

class Person: JSONModel {
    var id: Int = -1
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
person.fill(withJson: json)

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

#### From Json

Now what about when your JSON is different from your property names?

```swift
import EasyJSON

class Person: JSONModel {
    var id: Int = -1
    var firstName: String?
    var lastName: String?
    
    required init() {
        super.init()
        mapFromJson = ["PersonID", "id"]
    }
}
```
Then you can now use the following json to fill then object.

```swift
let json = ["PersonID": 1, "firstName": "Jane", "lastName": "Doe"]

let person = Person()
person.fill(withJson: json)

print(person.id)        // Prints 1
print(person.firstName) // Prints Jane
print(person.lastName)  // Prints Doe
```

#### To Json

Now what about when you want it to output JSON different from your property names?

```swift
import EasyJSON

class Person: JSONModel {
    var id: Int = -1
    var firstName: String?
    var lastName: String?
    
    required init() {
        super.init()
        mapToJson = ["id", "PersonID"]
    }
}
```

Then you can now use the following json to fill then object.

```swift
import EasyJSON 

let json = person.toJson()
print(json) // Prints ["PersonID": 1, "firstName": "Jane", "lastName": "Doe"]
```

### Mapping SubObjects

Now lets say you have something like this.

```swift
class Student: JSONModel {
    var id: Int = -1
    var firstName: String?
    var lastName: String?
}

class Classroom: JSONModel {
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
It is as simple as adding

```swift
class Classroom: JSONModel {
    
    // Properties
    
    // This is where the magic happens!
    required init() {
        super.init()
        subObjects = ["students", Student.self]
    }
}
```
Now Classroom will also fill the students property when given JSON.


## Author

Nicholas Mata, NicholasMata94@gmail.com

## License

EasyJSON is available under the MIT license. See the LICENSE file for more info.
