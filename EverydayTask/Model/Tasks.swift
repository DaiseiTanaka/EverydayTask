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
    case custom
    case selected
    
    var spanString: String {
        switch self {
        case .custom:
            return "Custom"
        case .selected:
            return "Select"
        }
    }
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

extension Tasks {
    static var previewData: [Tasks] = [
        Tasks(title: "Task1", detail: "Task for every day", addedDate: Date().addingTimeInterval(-60*60*24*70), spanType: .custom, span: .day, doCount: 1, spanDate: [], doneDate: [Date().addingTimeInterval(-60*60*24*17), Date().addingTimeInterval(-60*60*24*6),Date().addingTimeInterval(-60*60*24*5), Date().addingTimeInterval(-60*60*24*4),Date()], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
    ]
    
    static var Data: Tasks =
    Tasks(title: "", detail: "", addedDate: Date(), spanType: .custom, span: .day, doCount: 1, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
    
    static var defaulData: [Tasks] = [
        Tasks(title: "Task1", detail: "Every day", addedDate: Date(), spanType: .custom, span: .day, doCount: 1, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true),
        Tasks(title: "Task2", detail: "Every day", addedDate: Date(), spanType: .custom, span: .day, doCount: 1, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true)
    ]
}

// Modelを更新した時用　userdefaultsからデータを持ってくるときにmodelを修正する
struct prevTasks: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var title: String
    var detail: String
    var addedDate: Date
    var spanType: prevTaskSpanType
    var spanDate: [Int]
    var doneDate: [Date]
    var notification: Bool
    var notificationHour: Int
    var notificationMin: Int
    var accentColor: String
    var isAble: Bool
    
    init(title: String, detail: String, addedDate: Date, spanType: prevTaskSpanType, spanDate: [Int], doneDate: [Date], notification: Bool, notificationHour: Int, notificationMin: Int, accentColor: String, isAble: Bool) {
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

enum prevTaskSpanType: Codable {
    case oneTime
    case everyDay
    case everyWeek
    case everyMonth
    case everyWeekday
}
