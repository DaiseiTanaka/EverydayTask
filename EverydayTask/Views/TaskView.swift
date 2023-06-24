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
    
    @AppStorage("cellStyle") private var cellStyle: TaskCellStyle = .twoColumns
    @State private var columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 10, maximum: 300)), count: 2)
    @State private var cellHeight: CGFloat = 80
    @State private var cellSpace: CGFloat = 10
    
    let generator = UINotificationFeedbackGenerator()
    
    @AppStorage("showRegularlyTaskList") private var showRegularlyTaskList: Bool = true
    @AppStorage("showOneTimeTaskList") private var showOneTimeTaskList: Bool = true
    @AppStorage("showDoneTasks") private var showDoneTasks: Bool = false

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    finishedText
                    
                    if !taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[0].isEmpty {
                        todaysTaskList
                    }
                    
                    if !taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[1].isEmpty || !taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[2].isEmpty {
                        regularlyTaskList
                    }
                    
                    if !taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[3].isEmpty {
                        oneTimeTaskList
                    }
                    
                    if returnDoneTaskCount() > 0 {
                        doneTaskList
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 80)
            }
            .navigationTitle("\(taskViewModel.returnDayString(date: rkManager.selectedDate))")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    header
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    changeCellStyleButton
                }
            }
        }
        .overlay(alignment: .bottomTrailing) { addTaskButton }
        .sheet(isPresented: $taskViewModel.showTaskSettingView, content: {
            TaskSettingView(rkManager: rkManager, taskViewModel: taskViewModel, task: taskViewModel.editTask, selectedWeekdays: taskViewModel.editTask.spanDate)
        })
        .sheet(isPresented: $taskViewModel.showAllTaskListViewFlag, content: {
            AllTaskListView(taskViewModel: taskViewModel, rkManager: rkManager)
        })
        .confirmationDialog(taskViewModel.editTask.title, isPresented: $taskViewModel.showTaskSettingAlart, titleVisibility: .visible) {
            Button("Edit this task?") {
                taskViewModel.showTaskSettingView.toggle()
            }
            Button("Duplicate this task?") {
                duplicateTask()
            }
            Button("Hide this task?") {
                hideTask()
            }
            Button("Delete this task?", role: .destructive) {
                taskViewModel.removeTasks(task: taskViewModel.editTask)
            }
        } message: {
            Text(taskViewModel.editTask.detail)
        }
        .onAppear {
            changeColumn(style: cellStyle)
        }
    }
}

extension TaskView {
    private var header: some View {
        HStack {
            Button {
                taskViewModel.showAllTaskListViewFlag = true
            } label: {
                Image(systemName: "list.bullet")
                    .font(.body.bold())
                    .foregroundColor(.secondary)
            }
                        
            if !showJumpToDodayButton() {
                Button {
                    withAnimation {
                        rkManager.selectedDate = Date()
                    }
                } label: {
                    Image(systemName: "calendar.badge.clock")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Today")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func showJumpToDodayButton() -> Bool {
        return taskViewModel.isSameDay(date1: rkManager.selectedDate, date2: Date())
    }
    
    private var finishedText: some View {
        VStack {
            // 選択された日のタスクが全て達成済みの時
            if taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[0].count == 0 {
                // 選択した日付にタスクが設定されていなかった場合
                if taskViewModel.returnTaskCount(date: rkManager.selectedDate) == 0 {
                    Text("No tasks have been set.")
                        .bold()
                        .foregroundColor(.secondary)
                // 選択した日付にタスクが設定されており、かつ選択された日が今日の時
                } else if taskViewModel.isSameDay(date1: rkManager.selectedDate, date2: Date()) {
                    VStack(alignment: .leading) {
                        Text("All tasks for today have been completed!")
                            .bold()
                            .foregroundColor(.secondary)
                        Text("Good job for today.")
                            .foregroundColor(.secondary)
                    }
                // 選択した日付にタスクが設定されており、かつ選択された日が今日以外の時
                } else {
                    Text("All tasks have been completed.")
                        .bold()
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var todaysTaskList: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: columns, spacing: cellSpace) {
                ForEach(taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[0], id: \.id) { task in
                    TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, cellHeight: cellHeight, cellStyle: cellStyle)
                        .onTapGesture {
                            updateCalendar(task: task)
                        }
                        .onLongPressGesture() {
                            longTapTaskAction(task: task)
                        }
                }
            }
        }
    }
    
    // 定期的なタスク
    private var regularlyTaskList: some View {
        VStack(spacing: 10) {
            Button {
                showRegularlyTaskList.toggle()
            } label: {
                HStack {
                    Image(systemName: showRegularlyTaskList ? "chevron.down" : "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.secondary)
                        .padding(.leading, 15)
                    Text("Regularly")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("(\(taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[1].count + taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[2].count))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            if showRegularlyTaskList {
                LazyVGrid(columns: columns, spacing: cellSpace) {
                    ForEach(taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[1], id: \.id) { task in
                        TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, cellHeight: cellHeight, cellStyle: cellStyle)
                            .onTapGesture {
                                updateCalendar(task: task)
                            }
                            .onLongPressGesture() {
                                longTapTaskAction(task: task)
                            }
                    }
                    ForEach(taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[2], id: \.id) { task in
                        TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, cellHeight: cellHeight, cellStyle: cellStyle)
                            .onTapGesture {
                                updateCalendar(task: task)
                            }
                            .onLongPressGesture() {
                                longTapTaskAction(task: task)
                            }
                    }
                }
            }
        }
    }
    
    // 一度のみのタスク
    private var oneTimeTaskList: some View {
        VStack(spacing: 10) {
            Button {
                showOneTimeTaskList.toggle()
            } label: {
                HStack {
                    Image(systemName: showOneTimeTaskList ? "chevron.down" : "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.secondary)
                        .padding(.leading, 15)
                    Text("One time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("(\(taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[3].count))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            if showOneTimeTaskList {
                LazyVGrid(columns: columns, spacing: cellSpace) {
                    ForEach(taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[3], id: \.id) { task in
                        TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, cellHeight: cellHeight, cellStyle: cellStyle)
                            .onTapGesture {
                                updateCalendar(task: task)
                            }
                            .onLongPressGesture() {
                                longTapTaskAction(task: task)
                            }
                    }
                }
            }
        }
    }
    
    // 完了済みのタスク
    private var doneTaskList: some View {
        VStack(spacing: 10) {
            Button {
                showDoneTasks.toggle()
            } label: {
                HStack {
                    Image(systemName: showDoneTasks ? "chevron.down" : "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.secondary)
                        .padding(.leading, 15)
                    Text("Completed tasks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("(\(returnDoneTaskCount()))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            if showDoneTasks {
                LazyVGrid(columns: columns, spacing: cellSpace) {
                    if !taskViewModel.returnSelectedDateFinishedTasks(date: rkManager.selectedDate).isEmpty {
                        ForEach(taskViewModel.returnSelectedDateFinishedTasks(date: rkManager.selectedDate), id: \.id) { task in
                            // 実行済みのタスク
                            if taskViewModel.isDone(task: task, date: rkManager.selectedDate) {
                                TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, cellHeight: cellHeight, cellStyle: cellStyle)
                                    .onTapGesture {
                                        updateCalendar(task: task)
                                    }
                                    .onLongPressGesture() {
                                        longTapTaskAction(task: task)
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 選択された日付のすでに実行されているタスクの数を返す
    // これはweekly, monthlyのタスクも含まれる
    private func returnDoneTaskCount() -> Int {
        var count: Int = 0
        for tasks in taskViewModel.returnSelectedDateTasks(date: rkManager.selectedDate) {
            if !tasks.isEmpty {
                for task in tasks {
                    if taskViewModel.isDone(task: task, date: rkManager.selectedDate) {
                        count += 1
                    }
                }
            }
        }
        return count
    }
    
    private var addTaskButton: some View {
        Button {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
            
            taskViewModel.editTask = Tasks(title: "", detail: "", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
            taskViewModel.showTaskSettingView = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundColor(Color(UIColor.systemBackground))
                .padding()
                .background(.tint.opacity(0.9))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                .padding(.trailing)
        }
    }
    
    private var showAllTaskButton: some View {
        Button {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
            
            taskViewModel.showAllTaskListViewFlag = true
        } label: {
            Image(systemName: "list.bullet")
                .font(.title2.bold())
                .foregroundColor(Color(UIColor.systemBackground))
                .padding()
                .background(.green.opacity(0.9))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                .padding(.leading)
        }
    }
    
    // 特定のタスクをタップした時の関数
    private func updateCalendar(task: Tasks) {
        let spanType = task.spanType
        if spanType != .oneTime {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
        }
        
        // 特定のタスクを表示中 or タスクが一つしか設定されていない場合ー＞weeklyやmonthlyのタスクを一つだけ設定していた場合は、カレンダーを更新する必要があるため。
        if taskViewModel.selectedTasks != [task] || taskViewModel.tasks.count == 1 {
            // 特定のタスクを表示
            if spanType == .everyWeek || spanType == .everyMonth {
                // 一つのみかつweekly or monthlyのタスクの場合、カレンダーを表示非表示を切り替える。これがないと、ずっとweeklyAndMonthlyTaskListViewが表示され続けてしまう。
                if taskViewModel.tasks.count == 1 {
                    taskViewModel.showCalendarFlag.toggle()
                } else {
                    taskViewModel.showCalendarFlag = false
                }
            } else {
                taskViewModel.showCalendarFlag = true
            }
            if spanType != .oneTime {
                taskViewModel.selectedTasks = [task]
            } else {
                taskViewModel.selectedTasks = taskViewModel.tasks
            }
        } else {
            // 全てのタスクを表示
            taskViewModel.showCalendarFlag = true
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
    
    // タスクを複製する
    private func duplicateTask() {
        let selectedTask = taskViewModel.editTask
        let addTask = Tasks(title: selectedTask.title, detail: selectedTask.detail, addedDate: Date(), spanType: selectedTask.spanType, spanDate: selectedTask.spanDate, doneDate: [], notification: selectedTask.notification, notificationHour: selectedTask.notificationHour, notificationMin: selectedTask.notificationMin, accentColor: selectedTask.accentColor, isAble: selectedTask.isAble)
        taskViewModel.addTasks(task: addTask)
    }
    
    // タスクを非表示
    private func hideTask() {
        let editTask = taskViewModel.editTask
        guard let index = taskViewModel.tasks.firstIndex(where: { $0.id == editTask.id }) else {
            return
        }
        taskViewModel.tasks[index].isAble = false
        taskViewModel.saveTasks(tasks: taskViewModel.tasks)
    }
    
    // cellのスタイルを変更する
    private var changeCellStyleButton: some View {
        Button {
            withAnimation {
                if cellStyle == .oneSmallColumns {
                    cellStyle = .twoColumns
                } else {
                    cellStyle = .oneSmallColumns
                }
                changeColumn(style: cellStyle)
            }
        } label: {
            Image(systemName: cellStyle == .oneSmallColumns ? "square.grid.2x2" : "square.fill.text.grid.1x2")
                .scaledToFit()
                .foregroundColor(.secondary)
        }
    }
    
    // columnを変更
    private func changeColumn(style: TaskCellStyle) {
        columns = style.columns
        cellHeight = style.height
        cellSpace = style.space
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
