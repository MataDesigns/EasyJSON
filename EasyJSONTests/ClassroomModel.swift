//
//  SnakeCasedModel.swift
//  EasyJSONTests
//
//  Created by Nicholas Mata on 3/25/18.
//  Copyright © 2018 MataDesigns. All rights reserved.
//

import UIKit
import EasyJSON

let myClassroom: [String:Any?] = [
    "id": 1,
    "name": "Computer Science",
    "grade_average": 75.6,
    "days_of_the_week": [0,2,4],
    "students": [
        ["id": 654, "first_name": "Nicholas", "last_name": "Mata"],
        ["id": 134, "first_name": "Baoquan", "last_name": "Dinh"]
    ],
    "teacher": classroomTeacher
]

let classroomTeacher: [String: Any?] = ["id": 194, "first_name": "Jake", "last_name": "Amberson", "employee_id": 83]

enum Day: Int {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
}

struct DayArrayConverter: Converter {
    var toModel: ToModelConverter {
        return {
            let rawArray = $0 as! [Int]
            var dayArray = [Day]()
            for rawDay in rawArray {
                guard let day = Day(rawValue: rawDay) else {
                    continue
                }
                dayArray.append(day)
            }
            return dayArray
        }
    }
    
    var toJson: ToJsonConverter {
        return {
            let dayArray = $0 as! [Day]
            var rawArray = [Int]()
            for day in dayArray {
                rawArray.append(day.rawValue)
            }
            return rawArray
        }
    }
}

class ClassroomModel: EasyModel {
    
    override var _options_: EasyModelOptions {
        var converter = [ConverterKey: Converter]()
        converter[.key("daysOfTheWeek")] = DayArrayConverter()
        return EasyModelOptions(snakeCased: true, converters: converter)
    }
    
    var id: Int!
    var name: String!
    var gradeAverage: Double!
    var daysOfTheWeek = [Day]()
    
    
    var students = [StudentModel]()
    var teacher = TeacherModel()
}

class StudentModel: UserModel {
    override var _options_: EasyModelOptions {
        return EasyModelOptions(snakeCased: true)
    }
}

class TeacherModel: UserModel {
    override var _options_: EasyModelOptions {
        return EasyModelOptions(snakeCased: true)
    }
    
    var employeeId: Int!
}
