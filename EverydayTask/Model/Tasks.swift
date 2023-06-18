//
//  Tasks.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/05.
//

import Foundation
import SwiftUI

struct Tasks: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var title: String
    var detail: String
    var addedDate: Date
    var spanType: TaskSpanType
    var spanDate: [Int]
    var doneDate: [Date]
    var notification: Bool
    var notificationHour: Int
    var notificationMin: Int
    var accentColor: String
    var isAble: Bool
    
    init(title: String, detail: String, addedDate: Date, spanType: TaskSpanType, spanDate: [Int], doneDate: [Date], notification: Bool, notificationHour: Int, notificationMin: Int, accentColor: String, isAble: Bool) {
        self.title = title
        self.detail = detail
        self.addedDate = addedDate
        self.spanType = spanType
        self.spanDate = spanDate
        self.doneDate = doneDate
        self.notification = notification
        self.notificationHour = notificationHour
        self.notificationMin = notificationMin
        self.accentColor = accentColor
        self.isAble = isAble
    }
}

enum TaskSpanType: Codable {
    case oneTime
    case everyDay
    case everyWeek
    case everyMonth
    case everyWeekday
}

extension Tasks {
    
    static var previewData: [Tasks] = [
        Tasks(title: "Task1", detail: "Task for every day", addedDate: Date().addingTimeInterval(-60*60*24*30), spanType: .everyDay, spanDate: [], doneDate: [Date().addingTimeInterval(-60*60*24*17), Date().addingTimeInterval(-60*60*24*6),Date().addingTimeInterval(-60*60*24*5), Date().addingTimeInterval(-60*60*24*4),Date()], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true),
        Tasks(title: "Task2", detail: "", addedDate: Date().addingTimeInterval(-60*60*24*30), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Red", isAble: true),
        Tasks(title: "Task3", detail: "", addedDate: Date().addingTimeInterval(-60*60*24*30), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
        Tasks(title: "Task4", detail: "Once a week", addedDate: Date().addingTimeInterval(-60*60*24*35), spanType: .everyWeek, spanDate: [], doneDate: [Date().addingTimeInterval(-60*60*24*35), Date().addingTimeInterval(-60*60*24*21),Date().addingTimeInterval(-60*60*24*14), Date().addingTimeInterval(-60*60*24*7), Date()], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true)
//        ,
//        Tasks(title: "Task5", detail: "Once a month", addedDate: Date().addingTimeInterval(-60*60*24*200), spanType: .everyMonth, spanDate: [], doneDate: [Date().addingTimeInterval(-60*60*24*150), Date().addingTimeInterval(-60*60*24*90),Date().addingTimeInterval(-60*60*24*60), Date().addingTimeInterval(-60*60*24*30), Date()], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Black")
    ]
    
    static var Data: Tasks =
    Tasks(title: "", detail: "", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
    
    static var defaulData: [Tasks] = [
        Tasks(title: "Task1", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true),
        Tasks(title: "Task2", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true)
    ]
}


struct prevTasks: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var title: String
    var detail: String
    var addedDate: Date
    var spanType: TaskSpanType
    var spanDate: [Int]
    var doneDate: [Date]
    var notification: Bool
    var notificationHour: Int
    var notificationMin: Int
    var accentColor: String
    
    init(title: String, detail: String, addedDate: Date, spanType: TaskSpanType, spanDate: [Int], doneDate: [Date], notification: Bool, notificationHour: Int, notificationMin: Int, accentColor: String) {
        self.title = title
        self.detail = detail
        self.addedDate = addedDate
        self.spanType = spanType
        self.spanDate = spanDate
        self.doneDate = doneDate
        self.notification = notification
        self.notificationHour = notificationHour
        self.notificationMin = notificationMin
        self.accentColor = accentColor
    }
}
