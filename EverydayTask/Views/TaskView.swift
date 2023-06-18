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
            
            oneTimeTaskList
                .padding(.bottom, 80)
        }
        .overlay(alignment: .bottomTrailing) {
            addTaskButton
        }
        .sheet(isPresented: $taskViewModel.showTaskSettingView, content: {
            TaskSettingView(rkManager: rkManager, taskViewModel: taskViewModel, task: taskViewModel.editTask, selectedWeekdays: taskViewModel.editTask.spanDate)
        })
        .overlay(alignment: .bottomLeading) {
            allTaskButton
        }
        .sheet(isPresented: $taskViewModel.showAllTaskListViewFlag, content: {
            AllTaskListView(taskViewModel: taskViewModel, rkManager: rkManager)
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
                Text(taskViewModel.returnDayString(date: rkManager.selectedDate))
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
                ForEach(taskViewModel.returnSelectedDateTasks(date: rkManager.selectedDate)[0], id: \.id) { task in
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
    
    // 定期的なタスク
    private var regularlyTaskList: some View {
        VStack(spacing: 10) {
            if taskViewModel.returnSelectedDateTasks(date: rkManager.selectedDate)[1].count != 0 || taskViewModel.returnSelectedDateTasks(date: rkManager.selectedDate)[2].count != 0 {
                HStack {
                    Text("Regularly")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.leading, 15)
                    Spacer()
                }
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(taskViewModel.returnSelectedDateTasks(date: rkManager.selectedDate)[1], id: \.id) { task in
                    TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task)
                        .onTapGesture {
                            updateCalendar(task: task)
                        }
                        .onLongPressGesture() {
                            longTapTaskAction(task: task)
                        }
                }
                ForEach(taskViewModel.returnSelectedDateTasks(date: rkManager.selectedDate)[2], id: \.id) { task in
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
    
    // 一度のみのタスク
    private var oneTimeTaskList: some View {
        VStack(spacing: 10) {
            if taskViewModel.returnSelectedDateTasks(date: rkManager.selectedDate)[3].count != 0 {
                HStack {
                    Text("One time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.leading, 15)
                    Spacer()
                }
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(taskViewModel.returnSelectedDateTasks(date: rkManager.selectedDate)[3], id: \.id) { task in
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

    private var addTaskButton: some View {
        Button {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
            
            taskViewModel.editTask = Tasks(title: "", detail: "", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
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
    
    private var allTaskButton: some View {
        Button {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
            
            taskViewModel.showAllTaskListViewFlag = true
        } label: {
            Image(systemName: "list.bullet")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(.green.opacity(0.7))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                .padding(.leading)
        }
    }
    
    // 特定のタスクをタップした時の関数
    private func updateCalendar(task: Tasks) {
        let impactLight = UIImpactFeedbackGenerator(style: .rigid)
        impactLight.impactOccurred()
        
        // spanTypeによってCalendarViewの種類を変える
        if task.spanType == .everyDay || task.spanType == .everyWeekday || task.spanType == .oneTime {
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
