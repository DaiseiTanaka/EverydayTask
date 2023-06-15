//
//  TaskViewModel.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/05.
//

import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    
    @Published var tasks: [Tasks]
    
    @Published var selectedTasks: [Tasks]
    @Published var selectedTasksIndex: Int?
    @Published var editTask: Tasks
    @Published var numberOfMonth: Int
    @Published var rkManager: RKManager
    @Published var trueFlag: Bool
    @Published var latestDate: Date
    
    @Published var showTaskSettingView: Bool
    @Published var showTaskSettingAlart: Bool
    
    @Published var showCalendarFlag: Bool
                
    init() {
        self.tasks = Tasks.defaulData
        self.selectedTasks = Tasks.defaulData
        self.selectedTasksIndex = nil
        self.editTask = Tasks.defaulData[0]
        self.numberOfMonth = 1
        self.rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)
        self.trueFlag = true
        self.latestDate = Date()
        self.showTaskSettingView = false
        self.showTaskSettingAlart = false
        showCalendarFlag = true
        
        self.tasks = loadTasks() ?? Tasks.defaulData
        self.selectedTasks = tasks
    }
        
    // MARK: - Color Settings
    @Published var accentColors: [String] = [
        "Label",
        "Black",
        "Gray",
        "Red",
        "Pink",
        "Orange",
        "Cyan",
        "Blue",
        "Indigo",
        "Yellow",
        "Green"
    ]
    
    // タスクのアクセントカラーをString型からColor型へ変換する
    func returnColor(color: String) -> Color {
        switch color {
        case "Label":
            return Color(UIColor.label)
        case "Black":
            return Color.black
        case "Gray":
            return Color.gray
        case "Red":
            return Color.red
        case "Pink":
            return Color.pink
        case "Orange":
            return Color.orange
        case "Cyan":
            return Color.cyan
        case "Blue":
            return Color.blue
        case "Indigo":
            return Color.indigo
        case "Yellow":
            return Color.yellow
        case "Green":
            return Color.green
        default:
            return Color.blue
        }
    }
    
    // MARK: - Data Settings
    // カレンダーを更新
    func loadRKManager() {
        trueFlag = false
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")

        // タスクをタップしていない場合、全てのタスクの実施状態を表示する
        if selectedTasks == tasks {
            let firstDay = returnLatestDate(tasks: tasks)
            let firstDayMonth: Int = calendar.component(.month, from: firstDay)
            let today = Date()
            let todayMonth: Int = calendar.component(.month, from: today)

            self.numberOfMonth = todayMonth - firstDayMonth + 1
            self.rkManager = RKManager(calendar: Calendar.current, minimumDate: firstDay, maximumDate: today, mode: 0)
        // タスクを選択した時
        } else {
            let task = selectedTasks[0]
            let firstDay = task.addedDate
            let firstDayMonth: Int = calendar.component(.month, from: firstDay)
            let today = Date()
            let todayMonth: Int = calendar.component(.month, from: today)

            self.numberOfMonth = todayMonth - firstDayMonth + 1
            self.rkManager = RKManager(calendar: Calendar.current, minimumDate: firstDay, maximumDate: today, mode: 0)
        }
        trueFlag = true
        //print("num: \(numberOfMonth), rkm: \(rkManager.minimumDate)")

    }
        
    // タスクを追加
    func addTasks(task: Tasks) {
        // tasksにすでに存在するタスクを編集した場合
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        // 新しくタスクを追加した場合
        } else {
            withAnimation {
                tasks.insert(task, at: 0)
            }
        }

        saveTasks(tasks: tasks)
    }
    
    // タスクを削除
    func removeTasks(task: Tasks) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        tasks.remove(at: index)
        saveTasks(tasks: tasks)
    }
    
    // MARK: - 日付関連
    // Dateから曜日のインデックスを返す
    func returnWeekdayFromDate(date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let weekdayIndex = calendar.component(.weekday, from: date) // 日曜日: 1, 月曜日: 2 ...
        
        return weekdayIndex
    }
    
    // 選択した日付のタスクが実行されているかbool型で返す
    func isDone(task: Tasks, date: Date) -> Bool {
        let doneDates = task.doneDate
        for doneIndex in 0..<doneDates.count {
            let doneDate = doneDates[doneIndex]
            if isSameDay(date1: date, date2: doneDate) {
                return true
            }
        }
        return false
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    
    // MARK: - データ解析関連
    // その日すべき全てのタスクの数を返す
    func returnTaskCount(date: Date) -> Int {
        let tasks = selectedTasks
        var taskCount = 0
        for taskIndex in 0..<tasks.count {
            let task = tasks[taskIndex]
            let spanType = task.spanType
            let spanDate = task.spanDate
            let addedDate = task.addedDate.addingTimeInterval(-60*60*24*1)
            let weekdayIndex = returnWeekdayFromDate(date: date)
            // タスクを追加した日以降
            if addedDate <= date {
                // 毎日行うタスクの場合
                if spanType == .everyDay {
                    taskCount += 1
                // 決まった曜日に行うタスクの場合
                } else if spanType == .everyWeekday && spanDate.contains(weekdayIndex) {
                    taskCount += 1
                }
            }
        }
        //print("date: \(date), taskCount: \(taskCount)")
        return taskCount
    }
    
    // その日にすべき全てのタスクのうち実際に行ったタスクの数を返す
    func returnDoneTaskCount(date: Date) -> Int {
        let tasks = selectedTasks
        var doneTaskCount = 0
        for taskIndex in 0..<tasks.count {
            let task = tasks[taskIndex]
            let doneDates = task.doneDate
            let spanType = task.spanType
            let spanDate = task.spanDate
            let weekdayIndex = returnWeekdayFromDate(date: date)
            
            for dateIndex in 0..<doneDates.count {
                let doneDate = doneDates[dateIndex]
                if isSameDay(date1: doneDate, date2: date) {
                    if spanType == .everyDay {
                        doneTaskCount += 1

                    } else if spanType == .everyWeekday && spanDate.contains(weekdayIndex) {
                        doneTaskCount += 1

                    }
                }
            }
        }
        //print("date: \(date), doneTaskCount: \(doneTaskCount)")
        return doneTaskCount
    }
    
    // 最も古いタスクを追加した日付を返す
    func returnLatestDate(tasks: [Tasks]) -> Date {
        var latestDate: Date = Date()
        for taskIndex in 0..<tasks.count {
            let addedDate = tasks[taskIndex].addedDate
            if addedDate < latestDate {
                latestDate = addedDate
            }
        }

        return latestDate
    }
    
    // 直近の連続タスク実施時間を返す
    func returnContinuousCount(task: Tasks) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let today = Date()
        let doneDates = task.doneDate.sorted(by: >) // 降順にする
        var day = calendar.component(.day, from: today)
        var continuousCount: Int = 1
        // タスクを一度も実行していない場合
        if doneDates.count == 0 { return 0 }
        
        // 今日はまだタスクを実施していない場合
        if !isDone(task: task, date: today) { return 0 }
        
        for dateIndex in 0..<doneDates.count-1 {
            let day = calendar.component(.day, from: doneDates[dateIndex])
            let prevDay = calendar.component(.day, from: doneDates[dateIndex+1])
            if day - prevDay == 1 {
                continuousCount += 1
            } else {
                break
            }
        }
        return continuousCount
    }
    
    
    // MARK: - UserDefaultsにデータを保存
    func saveTasks(tasks: [Tasks]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(tasks) else {
            print("😭: tasksの保存に失敗しました。")
            return
        }
        UserDefaults.standard.set(data, forKey: "tasks")
        print("😄👍: tasksの保存に成功しました。")
    }
    
    func loadTasks() -> [Tasks]? {
        let jsonDecoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: "tasks"),
              let tasks = try? jsonDecoder.decode([Tasks].self, from: data) else {
            print("😭: tasksのロードに失敗しました。")
            return Tasks.defaulData
        }
        print("😄👍: tasksのロードに成功しました。")
        for task in tasks {
            print("😄\(task)")
        }
        return tasks
    }

}

// MARK: - 通知関連
extension TaskViewModel {
    func setNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            if granted {
                self.setTodayNotification()
            } else {
                //非許可
            }
        }
    }

    
    // 今日締め切りのタスクの通知を設定する
    // .everyDay     -> まだタスクが完了していない場合通知を追加
    // .everyWeekday -> 今日が当日かつ、まだタスクが完了していない場合通知を追加
    func setTodayNotification() {
        for task in tasks {
            // 通知オンだった場合
            if task.notification {
                if task.spanType == .everyDay {
                    // まだタスクが完了していない場合
                    if !isDone(task: task, date: Date()) {
                        makeNotification(task: task, hour: task.notificationHour, min: task.notificationMin)
                    }
                } else if task.spanType == .everyWeekday {
                    let spanDate = task.spanDate
                    let weekIndex = returnWeekdayFromDate(date: Date())
                    // 今日が設定した曜日だった場合
                    if spanDate.contains(weekIndex) {
                        // まだタスクが完了していない場合
                        if !isDone(task: task, date: Date()) {
                            makeNotification(task: task, hour: task.notificationHour, min: task.notificationMin)
                        }
                    }
                }
            }
        }
    }
    
    // 入力された時間に通知を追加
    func makeNotification(task: Tasks, hour: Int, min: Int) {
        let content = UNMutableNotificationContent()
        content.title = "It's TIME for \(task.title)"
        content.body = "Let's COMPLETE it！👍"
        content.sound = UNNotificationSound.default
        
        let dateComponent = DateComponents(hour: hour, minute: min)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        print(task.title + String(format: "🔔%02d:%02dに通知をセットしました！", hour, min))
    }
    
    // 登録された通知を全て削除
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        print("All notifications are removed")
    }
    
}