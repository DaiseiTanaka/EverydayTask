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

enum SortKey {
    case title
    case addedDate
    case spanType
}

enum TaskCellStyle: String {
    case oneColumns = "One columns"
    case oneSmallColumns = "One small columns"
    case twoColumns = "Two columns"
    case twoSmallColumns = "Two small columns"
    case threeColumns = "Three columns"
    
    var columns: [GridItem] {
        switch self {
        case .oneColumns:
            return Array(repeating: .init(.flexible(minimum: 10, maximum: 500)), count: 1)
        case .oneSmallColumns:
            return Array(repeating: .init(.flexible(minimum: 10, maximum: 500)), count: 1)
        case .twoColumns:
            return Array(repeating: .init(.flexible(minimum: 10, maximum: 500)), count: 2)
        case .twoSmallColumns:
            return Array(repeating: .init(.flexible(minimum: 10, maximum: 500)), count: 2)
        case .threeColumns:
            return Array(repeating: .init(.flexible(minimum: 10, maximum: 500)), count: 3)
        }
    }
    
    var height: CGFloat {
        switch self {
        case .oneColumns:
            return 80
        case .oneSmallColumns:
            return 40
        case .twoColumns:
            return 80
        case .twoSmallColumns:
            return 60
        case .threeColumns:
            return 60
        }
    }
    
    var space: CGFloat {
        switch self {
        case .oneColumns:
            return 5
        case .oneSmallColumns:
            return 5
        case .twoColumns:
            return 10
        case .twoSmallColumns:
            return 10
        case .threeColumns:
            return 10
        }
    }
}

extension Tasks {
    
    static var previewData: [Tasks] = [
        Tasks(title: "Task1", detail: "Task for every day", addedDate: Date().addingTimeInterval(-60*60*24*70), spanType: .everyDay, spanDate: [], doneDate: [Date().addingTimeInterval(-60*60*24*17), Date().addingTimeInterval(-60*60*24*6),Date().addingTimeInterval(-60*60*24*5), Date().addingTimeInterval(-60*60*24*4),Date()], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true),
        Tasks(title: "Task2", detail: "", addedDate: Date().addingTimeInterval(-60*60*24*70), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Red", isAble: true),
        Tasks(title: "Task3", detail: "", addedDate: Date().addingTimeInterval(-60*60*24*70), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
        Tasks(title: "Task4", detail: "Once a week", addedDate: Date().addingTimeInterval(-60*60*24*35), spanType: .everyWeek, spanDate: [], doneDate: [Date().addingTimeInterval(-60*60*24*35), Date().addingTimeInterval(-60*60*24*21),Date().addingTimeInterval(-60*60*24*14), Date().addingTimeInterval(-60*60*24*7), Date()], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true),
        Tasks(title: "Task5", detail: "Once a month", addedDate: Date().addingTimeInterval(-60*60*24*135), spanType: .everyMonth, spanDate: [], doneDate: [Date().addingTimeInterval(-60*60*24*135), Date().addingTimeInterval(-60*60*24*75), Date().addingTimeInterval(-60*60*24*45), Date().addingTimeInterval(-60*60*24*15)], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true)
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
