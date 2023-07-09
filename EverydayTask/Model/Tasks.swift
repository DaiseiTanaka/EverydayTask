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
    var span: Spans
    var doCount: Int
    var spanDate: [Int]
    var doneDate: [Date]
    var notification: Bool
    var notificationHour: Int
    var notificationMin: Int
    var accentColor: String
    var isAble: Bool
    
    init(title: String, detail: String, addedDate: Date, spanType: TaskSpanType, span: Spans, doCount: Int, spanDate: [Int], doneDate: [Date], notification: Bool, notificationHour: Int, notificationMin: Int, accentColor: String, isAble: Bool) {
        self.title = title
        self.detail = detail
        self.addedDate = addedDate
        self.spanType = spanType
        self.span = span
        self.doCount = doCount
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
    case custom
}

enum Spans: String, Codable, CaseIterable, Identifiable {
    case day
    case week
    case month
    case year
    case infinite
    var id: Self { return self }

    var spanString: String {
        switch self {
        case .day:
            return "Day"
        case .week:
            return "Week"
        case .month:
            return "Month"
        case .year:
            return "Year"
        case .infinite:
            return "Infinite"
        }
    }
}

enum SortKey: String, CaseIterable, Identifiable {
    case spanType
    case title
    case addedDate
    var id: Self { return self }
    
    var keyString: String {
        switch self {
        case .spanType:
            return "Span type"
        case .title:
            return "Title"
        case .addedDate:
            return "Added date"
        }
    }
}

enum TaskCellStyle: String, CaseIterable, Identifiable  {
    case list
    case grid
    var id: Self { return self }
    
    var styleString: String {
        switch self {
        case .list:
            return "List"
        case .grid:
            return "Grid"
        }
    }
    
    var columns: [GridItem] {
        switch self {
        case .list:
            return Array(repeating: .init(.flexible(minimum: 10, maximum: 500)), count: 1)
        case .grid:
            return Array(repeating: .init(.flexible(minimum: 10, maximum: 500)), count: 2)
        }
    }
    
    var height: CGFloat {
        switch self {
        case .list:
            return 40
        case .grid:
            return 80
        }
    }
    
    var space: CGFloat {
        switch self {
        case .list:
            return 4
        case .grid:
            return 10
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .list:
            return 5
        case .grid:
            return 10
        }
    }
}

extension Tasks {
    
    static var previewData: [Tasks] = [
        Tasks(title: "Task1", detail: "Task for every day", addedDate: Date().addingTimeInterval(-60*60*24*70), spanType: .everyDay, span: .day, doCount: 1, spanDate: [], doneDate: [Date().addingTimeInterval(-60*60*24*17), Date().addingTimeInterval(-60*60*24*6),Date().addingTimeInterval(-60*60*24*5), Date().addingTimeInterval(-60*60*24*4),Date()], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
//        ,
//        Tasks(title: "Task2", detail: "", addedDate: Date().addingTimeInterval(-60*60*24*70), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Red", isAble: true),
//        Tasks(title: "Task3", detail: "", addedDate: Date().addingTimeInterval(-60*60*24*70), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
//        Tasks(title: "Task4", detail: "Once a week", addedDate: Date().addingTimeInterval(-60*60*24*35), spanType: .everyWeek, spanDate: [], doneDate: [Date().addingTimeInterval(-60*60*24*35), Date().addingTimeInterval(-60*60*24*21),Date().addingTimeInterval(-60*60*24*14), Date().addingTimeInterval(-60*60*24*7), Date()], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true),
//        Tasks(title: "Task5", detail: "Once a month", addedDate: Date().addingTimeInterval(-60*60*24*135), spanType: .everyMonth, spanDate: [], doneDate: [Date().addingTimeInterval(-60*60*24*135), Date().addingTimeInterval(-60*60*24*75), Date().addingTimeInterval(-60*60*24*45), Date().addingTimeInterval(-60*60*24*15)], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true)
    ]
    
    static var Data: Tasks =
    Tasks(title: "", detail: "", addedDate: Date(), spanType: .everyDay, span: .day, doCount: 1, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
    
    static var defaulData: [Tasks] = [
        Tasks(title: "Task1", detail: "Every day", addedDate: Date(), spanType: .everyDay, span: .day, doCount: 1, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true),
        Tasks(title: "Task2", detail: "Every day", addedDate: Date(), spanType: .everyDay, span: .day, doCount: 1, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true)
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
