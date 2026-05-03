//
//  TaskViewModel.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/05.
//

import Foundation
import SwiftUI
import WidgetKit

class TaskViewModel: ObservableObject {
    
    @Published var tasks: [Tasks]
    
    @Published var selectedTasks: [Tasks]
    @Published var selectedTasksIndex: Int?
    @Published var editTask: Tasks
    @Published var numberOfMonth: Int
    @Published var rkManager: RKManager
    @Published var latestDate: Date
    
    @Published var showCalendarFlag: Bool
    @Published var showEditRegularlyTaskAlart: Bool = false
    @Published var selectedRegularlyTaskDate: Date = Date()
    @Published var showHalfModal: Bool = true
    @Published var showSidebar: Bool = false
                
    init() {
        self.tasks = Tasks.defaulData
        self.selectedTasks = Tasks.defaulData
        self.selectedTasksIndex = nil
        self.editTask = Tasks.defaulData[0]
        self.numberOfMonth = 1
        self.rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)
        self.latestDate = Date()
        self.showCalendarFlag = true
        
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
        TaskColor.color(for: color)
    }
    
    // MARK: - Data Settings
    // カレンダーを更新
    func loadRKManager() {
        let firstDay = returnLatestDate(tasks: tasks)
        let today = Date()
        
        self.numberOfMonth = returnNumberOfMonth(minDate: firstDay, maxDate: today)
        
        self.rkManager = RKManager(calendar: Calendar.current, minimumDate: firstDay, maximumDate: today, mode: 0)
    }
    
    func returnNumberOfMonth(minDate: Date, maxDate: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        
        let firstDC = calendar.dateComponents([.year, .month], from: minDate)
        let todayDC = calendar.dateComponents([.year, .month], from: maxDate)
        guard let todayYear = todayDC.year, let todayMonth = todayDC.month,
              let firstYear = firstDC.year, let firstMonth = firstDC.month else {
            return 1
        }
        let yearDiff  = todayYear - firstYear
        let monthDiff = todayMonth - firstMonth
        let totalMonthDiff = yearDiff * 12 + monthDiff
        
        return totalMonthDiff + 1
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
        // 選択中のタスクとカレンダー表示を更新
        withAnimation {
            selectedTasks = tasks
            showCalendarFlag = true
        }
        saveTasks(tasks: tasks)
    }
    
    // タスクを削除
    func removeTasks(task: Tasks) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        tasks.remove(at: index)
        // 選択中のタスクとカレンダー表示を更新
        withAnimation {
            selectedTasks = tasks
            showCalendarFlag = true
        }
        saveTasks(tasks: tasks)
    }
    
    // タスクを非表示
    func hideTask(task: Tasks) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        withAnimation {
            // 全てのタスク画面から、タスクを表示したり非表示にしたり交互に可能にするためtoggle
            tasks[index].isAble.toggle()
            // 選択中のタスクとカレンダー表示を更新
            selectedTasks = tasks
            showCalendarFlag = true
        }
        saveTasks(tasks: tasks)
    }
    
    //　タスクを複製
    func duplicateTask(task: Tasks) {
        let newTask = Tasks(title: task.title, detail: task.detail, addedDate: Date(), spanType: task.spanType, span: task.span, doCount: task.doCount, spanDate: task.spanDate, doneDate: [], notification: task.notification, notificationHour: task.notificationHour, notificationMin: task.notificationMin, accentColor: task.accentColor, isAble: task.isAble)
        addTasks(task: newTask)
    }
    
    // タスクの表示・非表示を設定
    func isAbleChange(task: Tasks, isAble: Bool) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isAble = task.isAble
        }
        // 選択中のタスクとカレンダー表示を更新
        withAnimation {
            selectedTasks = tasks
            showCalendarFlag = true
        }
        saveTasks(tasks: tasks)
    }
    
    // 選択された日が今日かBoolで返す
    func isToday() -> Bool {
        if isSameDay(date1: Date(), date2: rkManager.selectedDate) {
            return true
        }
        return false
    }
    
    // MARK: - 日付関連
    // Dateから曜日のインデックスを返す
    func returnWeekdayFromDate(date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let weekdayIndex = calendar.component(.weekday, from: date) // 日曜日: 1, 月曜日: 2 ...
        
        return weekdayIndex
    }
    
    // Dateから日付: 2023-06-25 String を返す
    func returnDayStringLong(date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let id = dateFormatter.string(from: date)
        return id
    }
    
    // Date -> 0/0
    func returnDayString(date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let dayDC = Calendar.current.dateComponents([.month, .day], from: date)
        let month: String = String(dayDC.month ?? 0)
        let day: String = String(dayDC.day ?? 0)
        
        return month + "/" + day
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    func isSameWeek(date1: Date, date2: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let dateWeekIndex1 = calendar.component(.weekOfYear, from: date1)
        let yearIndex1 = calendar.component(.year, from: date1)
        let dateWeekIndex2 = calendar.component(.weekOfYear, from: date2)
        let yearIndex2 = calendar.component(.year, from: date2)
        
        return dateWeekIndex1 == dateWeekIndex2 && yearIndex1 == yearIndex2
    }
    
    func isSameMonth(date1: Date, date2: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let monthIndex1 = calendar.component(.month, from: date1)
        let yearIndex1 = calendar.component(.year, from: date1)
        let monthIndex2 = calendar.component(.month, from: date2)
        let yearIndex2 = calendar.component(.year, from: date2)
        
        return monthIndex1 == monthIndex2 && yearIndex1 == yearIndex2
    }
    
    func isSameYear(date1: Date, date2: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let yearIndex1 = calendar.component(.year, from: date1)
        let yearIndex2 = calendar.component(.year, from: date2)
        
        return yearIndex1 == yearIndex2
    }
    
    // MARK: - データ解析関連
    // その日すべき全てのタスクの数を返す
    func returnTaskCount(date: Date) -> Int {
        let tasks = tasks
        var taskCount = 0
        for taskIndex in 0..<tasks.count {
            let task = tasks[taskIndex]
            let spanType = task.spanType
            let span = task.span
            let spanDate = task.spanDate
            let addedDate = task.addedDate
            let weekdayIndex = returnWeekdayFromDate(date: date)
            let isAble = task.isAble
            // タスクがisAbleの時
            if isAble {
                // タスクを追加した日以降
                if isPrevDay(prevDate: addedDate, selectedDate: date) {
                    // 毎日行うタスクの場合
                    if spanType == .selected && spanDate.contains(weekdayIndex) {
                        taskCount += 1
                    } else if spanType == .custom {
                        if span == .day {
                            taskCount += 1
                        }
                    }
                }
            }
        }
        //print("date: \(date), taskCount: \(taskCount)")
        return taskCount
    }
    
    // その日にすべき全てのタスクのうち実際に行ったタスクの数を返す
    func returnDoneTaskCount(date: Date) -> Int {
        let tasks = tasks
        var doneTaskCount = 0
        for taskIndex in 0..<tasks.count {
            let task = tasks[taskIndex]
            let spanType = task.spanType
            let span = task.span
            let spanDate = task.spanDate
            let weekdayIndex = returnWeekdayFromDate(date: date)
            let isAble = task.isAble
            
            if isAble {
                if spanType == .selected && spanDate.contains(weekdayIndex) {
                    if isDone(task: task, date: date) {
                        doneTaskCount += 1
                    }
                    
                } else if spanType == .custom && span == .day {
                    if isDone(task: task, date: date) {
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
    
    // Customタスクの選択した日付におけるタスクを実行しなくてはいけない残りの数を返す
    func returnRemainCustomTaskCount(task: Tasks, date: Date) -> Int {
        let doneDates = task.doneDate
        let span = task.span
        let doCount = task.doCount
        let selectedDate = date
        var remainCount: Int = 0
        var didCount: Int = 0
        
        for date in doneDates {
            switch span {
            case .day:
                if isSameDay(date1: date, date2: selectedDate) {
                    didCount += 1
                }
            case .week:
                if isSameWeek(date1: date, date2: selectedDate) {
                    didCount += 1
                }
            case .month:
                if isSameMonth(date1: date, date2: selectedDate) {
                    didCount += 1
                }
            case .year:
                if isSameYear(date1: date, date2: selectedDate) {
                    didCount += 1
                }
            case .infinite:
                didCount += 1
            }
        }
        remainCount = doCount - didCount
        return remainCount
    }
    
    // 選択した日付に関連するタスクを返す
    func returnSelectedDateTasks(date: Date) -> [[Tasks]] {
        let tasks = tasks
        // 最終的に返すリスト
        var selectedDateTasks: [[Tasks]] = []
        
        var dailyTasks: [Tasks] = []
        var regularlyTasks: [Tasks] = []
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        
        for task in tasks {
            let selectedDate = date
            let addedDate    = task.addedDate
            let spanType     = task.spanType
            let span         = task.span
            let spanDate     = task.spanDate
            let weekdayIndex = returnWeekdayFromDate(date: selectedDate)
            let isAble       = task.isAble
            
            // 選択した日付よりも前にタスクを追加していた場合 & タスクが実施可能（isAble）の時
            if isPrevDay(prevDate: addedDate, selectedDate: selectedDate) && isAble {
                switch spanType {
                case .custom:
                    // １日単位のタスクはその日に実行するタスク一覧へ追加
                    if span == .day {
                        dailyTasks.append(task)
                    } else {
                        regularlyTasks.append(task)
                    }
                case .selected:
                    if spanDate.contains(weekdayIndex) {
                        dailyTasks.append(task)
                    }
                }
            }
        }
        // リストをspanTypeごとに並び替え
        selectedDateTasks.append(dailyTasks)
        selectedDateTasks.append(regularlyTasks)
        return selectedDateTasks
    }
    
    // 選択した日付に関連するタスクのうち、未達成のものを返す
    func returnSelectedDateUnFinishedTasks(date: Date, isDailyTask: Bool) -> [Tasks] {
        let tasks = tasks
        
        var dailyTasks: [Tasks] = []
        var regularlyTasks: [Tasks] = []
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        
        for task in tasks {
            let selectedDate = date
            let addedDate    = task.addedDate
            let spanType     = task.spanType
            let span         = task.span
            let spanDate     = task.spanDate
            let weekdayIndex = returnWeekdayFromDate(date: selectedDate)
            let isAble       = task.isAble
            
            // 選択した日付よりも前にタスクを追加していた場合 & タスクが実施可能（isAble）の時
            if isPrevDay(prevDate: addedDate, selectedDate: selectedDate) && isAble {
                // タスクが未達成の時
                if !isDone(task: task, date: selectedDate) {
                    switch spanType {
                    case .custom:
                        // １日単位のタスクはその日に実行するタスク一覧へ追加
                        if span == .day {
                            dailyTasks.append(task)
                        } else {
                            regularlyTasks.append(task)
                        }
                    case .selected:
                        if spanDate.contains(weekdayIndex) {
                            dailyTasks.append(task)
                        }
                    }
                }
            }
        }

        // 選択されたタスクを返す
        if isDailyTask {
            return dailyTasks
        } else {
            return regularlyTasks
        }
    }
    
    // 選択した日の達成したタスクの一覧を返す
    func returnSelectedDateFinishedTasks(date: Date) -> [Tasks] {
        let tasks = tasks
        // 最終的に返すリスト
        var selectedDateTasks: [Tasks] = []
        
        var dailyTasks: [Tasks] = []
        var regularlyTasks: [Tasks] = []
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        
        for task in tasks {
            let selectedDate = date
            let addedDate = task.addedDate
            let spanType = task.spanType
            let span = task.span
            let spanDate = task.spanDate
            let weekdayIndex = returnWeekdayFromDate(date: selectedDate)
            let isAble = task.isAble
            
            // 選択した日付よりも前にタスクを追加していた場合 & タスクが実施可能（isAble）の時
            if isPrevDay(prevDate: addedDate, selectedDate: selectedDate) && isAble {
                // タスクが達成の時
                if isDone(task: task, date: selectedDate) {
                    switch spanType {
                    case .custom:
                        if span == .day {
                            dailyTasks.append(task)
                        } else {
                            regularlyTasks.append(task)
                        }
                    case .selected:
                        if spanDate.contains(weekdayIndex) {
                            dailyTasks.append(task)
                        }
                    }
                }
            }
        }
        // リストをspanTypeごとに並び替え
        selectedDateTasks = dailyTasks + regularlyTasks
        return selectedDateTasks
    }
    
    // 選択した日付のタスクが実行されているかbool型で返す
    // true: 実行されている, false: まだ実行していない
    func isDone(task: Tasks, date: Date) -> Bool {
        let doneDates = task.doneDate
        let spanType = task.spanType
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        
        switch spanType {
        case .custom:
            let span = task.span
            let doCount = task.doCount
            var count: Int = 0
            // 指定期間に指定回数以上doneDateが含まれている場合、実行されている
            for doneDate in doneDates {
                switch span {
                case .day:
                    // selectedDateでdoCount以上doneDateが含まれる場合true
                    if isSameDay(date1: date, date2: doneDate) {
                        count += 1
                    }
                    if count >= doCount {
                        return true
                    }
                case .week:
                    // selectedDateを含むspan内にdoCount以上のdoneDateが含まれる場合true
                    if isSameWeek(date1: date, date2: doneDate) {
                        count += 1
                    }
                    if count >= doCount {
                        return true
                    }
                case .month:
                    // selectedDateを含むspan内にdoCount以上のdoneDateが含まれる場合true
                    if isSameMonth(date1: date, date2: doneDate) {
                        count += 1
                    }
                    if count >= doCount {
                        return true
                    }
                case .year:
                    // selectedDateを含むspan内にdoCount以上のdoneDateが含まれる場合true
                    if isSameYear(date1: date, date2: doneDate) {
                        count += 1
                    }
                    if count >= doCount {
                        return true
                    }
                case .infinite:
                    // doCount以上のdoneDateが含まれる場合true
                    count += 1
                    if count >= doCount {
                        return true
                    }
                }
            }
            
            return false
            
        case .selected:
            // doneDatesの中に選択した日付が含まれる場合、実行されている
            for doneDate in doneDates {
                if isSameDay(date1: date, date2: doneDate) {
                    return true
                }
            }
            return false
        
        }
    }
     
    // 2つの日付で、prevDateがselectedDateより前の日（同じ日も含む）かどうか判定
    // 追加日以降のタスクを選択したい時に利用
    func isPrevDay(prevDate: Date, selectedDate: Date) -> Bool {
        if isSameDay(date1: prevDate, date2: selectedDate) || prevDate < selectedDate {
            return true
        }
        
        return false
    }
    
    // タスクのタイトルを返す
    // 未設定の時は（タイトルなし）と表示する
    func titleString(task: Tasks) -> String {
        let title = task.title
        if title.isEmpty {
            return " (No title) "
        } else {
            return title
        }
    }
    
    // MARK: - UserDefaultsにデータを保存
    func saveTasks(tasks: [Tasks]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(tasks) else {
            #if DEBUG
            print("tasksの保存に失敗しました。")
            #endif
            return
        }
        UserDefaults.standard.set(data, forKey: UserDefaultsKeys.tasks)
        saveUnfinishedTasksForWidget()
    }

    func loadTasks() -> [Tasks]? {
        let jsonDecoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.tasks),
              let tasks = try? jsonDecoder.decode([Tasks].self, from: data) else {
            // 変更前のTasks型のデータをロードする　→ Tasksを変更した時に使う
            return loadPrevTasks()
        }
        return tasks
    }

    func loadPrevTasks() -> [Tasks]? {
        let jsonDecoder = JSONDecoder()
        // Tasksを変更した場合、構造体に合わせてtasksを更新する
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.tasks), let tasks = try? jsonDecoder.decode([prevTasks].self, from: data) else {
            #if DEBUG
            print("tasksのロードに失敗しました。")
            #endif
            return Tasks.defaulData
        }
        var newTasks: [Tasks] = []
        var newSpanType: TaskSpanType = .custom
        var span: Spans = .day
        for task in tasks {
            switch task.spanType {
            case .oneTime:
                newSpanType = .custom
                span = .infinite
            case .everyDay:
                newSpanType = .custom
                span = .day
            case .everyWeek:
                newSpanType = .custom
                span = .week
            case .everyMonth:
                newSpanType = .custom
                span = .month
            case .everyWeekday:
                newSpanType = .selected
                span = .day
            }
            
            newTasks.append(
                Tasks(title: task.title,
                      detail: task.detail,
                      addedDate: task.addedDate,
                      spanType: newSpanType,
                      span: span,
                      doCount: 1,
                      spanDate: task.spanDate,
                      doneDate: task.doneDate,
                      notification: task.notification,
                      notificationHour: task.notificationHour,
                      notificationMin: task.notificationMin,
                      accentColor: task.accentColor,
                      isAble: task.isAble)
            )
        }
        
        return newTasks
    }
    
    // Widget用にデータを保存
    func saveUnfinishedTasksForWidget() {
        var unfinishedTasks: [[Tasks]] = []
        unfinishedTasks += ([returnSelectedDateUnFinishedTasks(date: Date(), isDailyTask: true)])
        unfinishedTasks += ([returnSelectedDateUnFinishedTasks(date: Date(), isDailyTask: false)])
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(unfinishedTasks) else {
            #if DEBUG
            print("widget用のデータの保存に失敗しました。")
            #endif
            return
        }
        // App Groupsにデータを保存
        if let userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier) {
            userDefaults.set(data, forKey: UserDefaultsKeys.tasks)
        }
        // Widgetを更新
        WidgetCenter.shared.reloadTimelines(ofKind: "EverydayTaskWidget")
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
                if task.spanType == .custom && task.span == .day {
                    // まだタスクが完了していない場合
                    if !isDone(task: task, date: Date()) {
                        makeNotification(task: task, hour: task.notificationHour, min: task.notificationMin)
                    }
                } else if task.spanType == .selected {
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
        content.title = task.title
        content.body = task.detail
        content.sound = UNNotificationSound.default
        
        let dateComponent = DateComponents(hour: hour, minute: min)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // 登録された通知を全て削除
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
}
