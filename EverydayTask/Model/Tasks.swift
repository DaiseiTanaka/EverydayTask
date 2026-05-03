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
        Tasks(title: "Task1", detail: "Daily to-do", addedDate: Date(), spanType: .custom, span: .day, doCount: 1, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true),
        Tasks(title: "Task2", detail: "Weekly to-do", addedDate: Date(), spanType: .custom, span: .day, doCount: 3, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true)
    ]
}

// IMPORTANT: prevTasks は旧バージョンからのデータ移行に必要な構造体です。
// 絶対に削除しないでください。削除すると旧ユーザーのデータが読み込めなくなります。
// 参照: TaskViewModel.loadPrevTasks()
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

// MARK: - カラー変換
enum TaskColor {
    /// アクセントカラー名からColor型へ変換する
    static func color(for name: String) -> Color {
        switch name {
        case "Label":  return Color(UIColor.label)
        case "Black":  return Color.black
        case "Gray":   return Color.gray
        case "Red":    return Color.red
        case "Pink":   return Color.pink
        case "Orange": return Color.orange
        case "Cyan":   return Color.cyan
        case "Blue":   return Color.blue
        case "Indigo": return Color.indigo
        case "Yellow": return Color.yellow
        case "Green":  return Color.green
        default:       return Color.blue
        }
    }
}

// MARK: - 定数定義
enum AppConstants {
    static let appGroupIdentifier = "group.myproject.EverydayTask.widget2"
}

enum UserDefaultsKeys {
    static let tasks = "tasks"
}
