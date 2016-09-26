# EasyJSON

[![CI Status](http://img.shields.io/travis/Nicholas Mata/EasyJSON.svg?style=flat)](https://travis-ci.org/Nicholas Mata/EasyJSON)
[![Version](https://img.shields.io/cocoapods/v/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)
[![License](https://img.shields.io/cocoapods/l/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)
[![Platform](https://img.shields.io/cocoapods/p/EasyJSON.svg?style=flat)](http://cocoapods.org/pods/EasyJSON)

- [Usage](#usage)
    - **Intro -** [Creating Model](#creating-model)

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

## Author

Nicholas Mata, NicholasMata94@gmail.com

## License

EasyJSON is available under the MIT license. See the LICENSE file for more info.

## Usage

### Creating a Model

```swift
import EasyJSON

class Person: JSONModel {
    var firstName: String?
    var lastName: String?
}
```

