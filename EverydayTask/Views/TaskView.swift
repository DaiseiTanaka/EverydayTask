//
//  TaskView.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/05.
//

import SwiftUI

struct TaskView: View {
    
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 10, maximum: 300)), count: 2)
    let generator = UINotificationFeedbackGenerator()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            todaysTaskList
                .padding(.top, 10)
            regularlyTaskList
                .padding(.bottom, 60)
        }
        .overlay(alignment: .bottomTrailing) {
            addTaskButton
        }
        .sheet(isPresented: $taskViewModel.showTaskSettingView, content: {
            TaskSettingView(rkManager: rkManager, taskViewModel: taskViewModel, task: taskViewModel.editTask, selectedWeekdays: taskViewModel.editTask.spanDate)
        })
        .confirmationDialog(taskViewModel.editTask.title, isPresented: $taskViewModel.showTaskSettingAlart, titleVisibility: .visible) {
            Button("Edit this task?") {
                taskViewModel.showTaskSettingView.toggle()
            }
            Button("Delete this task?", role: .destructive) {
                taskViewModel.removeTasks(task: taskViewModel.editTask)
            }
        } message: {
            Text(taskViewModel.editTask.detail)
        }
    }
}

extension TaskView {
    
    private var todaysTaskList: some View {
        VStack(spacing: 10) {
            HStack {
                Text(returnDayString(date: rkManager.selectedDate))
                    .foregroundColor(.secondary)
                    .padding(.leading, 15)
                
                if !showJumpToDodayButton() {
                    Button {
                        withAnimation {
                            rkManager.selectedDate = Date()
                        }
                    } label: {
                        Image(systemName: "calendar.badge.clock")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.leading, 5)
                    }
                } else {
                    Text("Today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(returnSelectedDateTasks()[0], id: \.id) { task in
                    TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task)
                        .onTapGesture {
                            updateCalendar(task: task)
                        }
                        .onLongPressGesture() {
                            longTapTaskAction(task: task)
                        }
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    private func showJumpToDodayButton() -> Bool {
        return taskViewModel.isSameDay(date1: rkManager.selectedDate, date2: Date())
    }
    
    private var regularlyTaskList: some View {
        VStack(spacing: 10) {
            if returnSelectedDateTasks()[1].count != 0 || returnSelectedDateTasks()[2].count != 0 {
                HStack {
                    Text("Regularly")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.leading, 15)
                    Spacer()
                }
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(returnSelectedDateTasks()[1], id: \.id) { task in
                    TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task)
                        .onTapGesture {
                            updateCalendar(task: task)
                        }
                        .onLongPressGesture() {
                            longTapTaskAction(task: task)
                        }
                }
                ForEach(returnSelectedDateTasks()[2], id: \.id) { task in
                    TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task)
                        .onTapGesture {
                            updateCalendar(task: task)
                        }
                        .onLongPressGesture() {
                            longTapTaskAction(task: task)
                        }
                }
            }
            .padding(.horizontal, 10)
        }
    }

    // Date -> 0/0
    private func returnDayString(date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let dayDC = Calendar.current.dateComponents([.month, .day], from: date)
        let month: String = String(dayDC.month!)
        let day: String = String(dayDC.day!)
        
        return month + "/" + day
    }
    
    // 選択した日付に関連するタスクを返す
    private func returnSelectedDateTasks() -> [[Tasks]] {
        let tasks = taskViewModel.tasks
        // 最終的に返すリスト
        var selectedDateTasks: [[Tasks]] = []
        
        var dailyTasks: [Tasks] = []
        var weeklyTasks: [Tasks] = []
        var monthlyTasks: [Tasks] = []
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        
        for taskIndex in 0..<tasks.count {
            let task = tasks[taskIndex]
            let selectedDate = rkManager.selectedDate
            
            let addedDate = task.addedDate.addingTimeInterval(-60*60*24*1)
            let spanType = task.spanType
            let spanDate = task.spanDate
            let doneDate = task.doneDate
            let weekdayIndex = taskViewModel.returnWeekdayFromDate(date: selectedDate)
            
            // 選択した日付よりも前にタスクを追加していた場合
            if addedDate < selectedDate {
                switch spanType {
                case .everyDay:
                    dailyTasks.append(task)
                case .everyWeekday:
                    // rkManager.selectedDateがspanDate内にある場合
                    if spanDate.contains(weekdayIndex) {
                        dailyTasks.append(task)
                    }
                case .everyWeek:
                    // 一度もタスクを実行していない場合
                    if doneDate.count == 0 {
                        weeklyTasks.append(task)
                    }
                    // rkManager.selectedDateと同じ週のdateがtask.doneDate内に無いとき or に表示
                    for doneDateIndex in 0..<doneDate.count {
                        let date = doneDate[doneDateIndex]
                        let doneDateDate = calendar.component(.day, from: date)
                        let selectedDateDate = calendar.component(.day, from: selectedDate)
                        let doneDateWeekIndex = calendar.component(.weekOfYear, from: date)
                        let selectedWeekIndex = calendar.component(.weekOfYear, from: selectedDate)
                        // doneDate[index]の週と、選択中の週が同じ場合
                        if doneDateWeekIndex == selectedWeekIndex {
                            // doneDate[index]の日付と、選択中の日付が同じ場合
                            if doneDateDate == selectedDateDate {
                                weeklyTasks.append(task)
                            }
                            break
                        }
                        // doneDate内に選択中の日付と同じ週のdoneDate[index]が無い場合
                        if doneDateIndex == doneDate.count-1 {
                            weeklyTasks.append(task)
                        }
                    }
                    
                case .everyMonth:
                    // 一度もタスクを実行していない場合
                    if doneDate.count == 0 {
                        monthlyTasks.append(task)
                    }
                    // rkManager.selectedDateと同じ月のdateがtask.doneDate内に無いときに表示
                    for doneDateIndex in 0..<doneDate.count {
                        let date = doneDate[doneDateIndex]
                        let doneDateDate = calendar.component(.day, from: date)
                        let selectedDateDate = calendar.component(.day, from: selectedDate)
                        let doneDateMonth = calendar.component(.month, from: date)
                        let selectedMonth = calendar.component(.month, from: selectedDate)
                        // doneDate[index]の週と、選択中の月が同じ場合
                        if doneDateMonth == selectedMonth  {
                            // doneDate[index]の日付と、選択中の日付が同じ場合
                            if doneDateDate == selectedDateDate {
                                monthlyTasks.append(task)
                            }
                            break
                        }
                        // doneDate内に選択中の日付と同じ月のdoneDate[index]が無い場合
                        if doneDateIndex == doneDate.count-1 {
                            monthlyTasks.append(task)
                        }
                    }
                }
            }
        }
        // リストをspanTypeごとに並び替え
        selectedDateTasks.append(dailyTasks)
        selectedDateTasks.append(weeklyTasks)
        selectedDateTasks.append(monthlyTasks)
        return selectedDateTasks
    }
    
    private var addTaskButton: some View {
        HStack(spacing: 10) {
//            if taskViewModel.selectedTasks.count == 1 {
//                // タスク編集
//                Button {
//                    
//                } label: {
//                    Image(systemName: "trash")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .padding(10)
//                        .background(.red.opacity(0.7))
//                        .clipShape(Circle())
//                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
//                }
//                //
//                Button {
//                    
//                } label: {
//                    Image(systemName: "pencil")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .padding(10)
//                        .background(.green.opacity(0.7))
//                        .clipShape(Circle())
//                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
//                }
//            }
            
            Button {
                let impactLight = UIImpactFeedbackGenerator(style: .rigid)
                impactLight.impactOccurred()
                
                taskViewModel.editTask = Tasks(title: "", detail: "", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue")
                taskViewModel.showTaskSettingView = true
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(.tint.opacity(0.7))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                    .padding(.trailing)
            }
        }
    }
    
    // 特定のタスクをタップした時の関数
    private func updateCalendar(task: Tasks) {
        let impactLight = UIImpactFeedbackGenerator(style: .rigid)
        impactLight.impactOccurred()
        
        // spanTypeによってCalendarViewの種類を変える
        if task.spanType == .everyDay || task.spanType == .everyWeekday {
            taskViewModel.showCalendarFlag = true
        } else {
            if taskViewModel.selectedTasks != [task] {
                taskViewModel.showCalendarFlag = false
            } else {
                taskViewModel.showCalendarFlag = true
            }
        }
        
        // 特定のタスクを選択した時 -> 選択したタスクを表示
        if taskViewModel.selectedTasks != [task] {
            taskViewModel.selectedTasks = [task]
            // 選択中のタスクを再度タップした時、全てのタスクを表示する
        } else {
            taskViewModel.selectedTasks = taskViewModel.tasks
        }
        // rkManagerを更新　→ カレンダーの表示形式を更新
        // カレンダーの始まりの日が更新される。
        // カレンダーの始まりの日はデフォルトで、保存されているタスクの最も古い追加日に設定されているた、必要ないと判断
        //taskViewModel.loadRKManager()
        print("Task tapped! selectedTasks:\n\(taskViewModel.selectedTasks)")
    }
    
    // タスクを長押しした時のアクション
    private func longTapTaskAction(task: Tasks) {
        generator.notificationOccurred(.success)
        taskViewModel.editTask = task
        taskViewModel.showTaskSettingView = true
        
    }
    
}

struct TaskView_Previews: PreviewProvider {
    //@StateObject static var taskViewModel = TaskViewModel()
    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)
    
    static var previews: some View {
        //ContentView()
        TaskView(taskViewModel: TaskViewModel(), rkManager: rkManager)
    }
}
