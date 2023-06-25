//
//  AllTaskListView.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/18.
//

import SwiftUI

struct AllTaskListView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager

    @Environment(\.dismiss) var dismiss
    
    @State private var toggleFlag: Bool = true
    @State private var showSortAlart: Bool = false
    @State private var showTaskSettingView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if returnSortedTasks(key: taskViewModel.sortKey).isEmpty {
                    emptyView
                } else {
                    allTaskList
                }
            }
            .navigationTitle("All Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    sortButton
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    dismissButton
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    addTaskButton
                }
            }
        }
        .sheet(isPresented: self.$showTaskSettingView, content: {
            TaskSettingView(rkManager: rkManager, taskViewModel: taskViewModel, task: taskViewModel.editTask, selectedWeekdays: taskViewModel.editTask.spanDate)
        })
        .confirmationDialog("Sorted by", isPresented: $showSortAlart, titleVisibility: .visible) {
            Button(LocalizedStringKey(returnSortKeyString(sortKey: .spanType))) {
                taskViewModel.sortKey = .spanType
            }
            Button(LocalizedStringKey(returnSortKeyString(sortKey: .addedDate))) {
                taskViewModel.sortKey = .addedDate
            }
            Button(LocalizedStringKey(returnSortKeyString(sortKey: .title))) {
                taskViewModel.sortKey = .title
            }
        }
    }
}

extension AllTaskListView {
    private var emptyView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No tasks have been set.")
                .font(.title3.bold())
                .foregroundColor(.secondary)
                .padding(.top)
            Text("Please add task from the plus button.")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    // リストのヘッダー
    private var header: some View {
        HStack {
            Spacer()
            if taskViewModel.tasks.count > 1 {
                Text("\(taskViewModel.tasks.count)")
                Text("items")
            } else if taskViewModel.tasks.count != 0 {
                Text("\(taskViewModel.tasks.count)")
                Text("item")
            }
        }
    }
    
    private var allTaskList: some View {
        List {
            Section(header: header) {
                ForEach(Array(returnSortedTasks(key: taskViewModel.sortKey).enumerated()), id: \.element) { index, task in
                    AllTaskCell(taskViewModel: taskViewModel, task: task)
                        .background(
                            Color.black.opacity(0.000001)
                                .onTapGesture {
                                    let impactLight = UIImpactFeedbackGenerator(style: .rigid)
                                    impactLight.impactOccurred()
                                    
                                    taskViewModel.editTask = task
                                    showTaskSettingView = true
                                }
                        )
                }
                .onDelete(perform: rowRemove)
            }
        }
    }
    
    private var addTaskButton: some View {
        Button {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
            
            taskViewModel.editTask = Tasks(title: "", detail: "", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
            showTaskSettingView = true
        } label: {
            Image(systemName: "plus")
                .font(.title3.bold())
                .foregroundColor(Color(UIColor.systemBackground))
                .padding(8)
                .background(.tint)
                .clipShape(Circle())
        }
    }
    
    private var sortButton: some View {
        Button(action: {
            showSortAlart = true
        }) {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
    }
    
    private var dismissButton: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.secondary)
                .font(.title3)
        }
    }
    
    private func returnSortedTasks(key: SortKey) -> [Tasks] {
        let tasks = taskViewModel.tasks
        var sortedTasks: [Tasks] = []
        switch key {
        case .title:
            sortedTasks = tasks.sorted(by: {$0.title < $1.title})
            return sortedTasks
        case .addedDate:
            sortedTasks = tasks.sorted(by: {$0.addedDate < $1.addedDate})
            return sortedTasks
        case .spanType:
            sortedTasks = returnSortedTasksBySpanType(tasks: tasks)
            return sortedTasks
        }
    }
    
    // 行削除処理
    private func rowRemove(offsets: IndexSet) {
        var sortedTasks = returnSortedTasks(key: taskViewModel.sortKey)
        sortedTasks.remove(atOffsets: offsets)
        taskViewModel.tasks = sortedTasks.sorted(by: {$0.addedDate < $1.addedDate})
        
    }
    
    // ヘッダーのテキストを返す
    private func returnHeaderText(index: Int) -> String {
        if index == 0 { return "Every day" }
        else if index == 1 { return "Every week" }
        else if index == 2 { return "Every month" }
        else if index == 3 { return "Custom" }
        else { return "One time" }
    }
    
    // sortKeyをStringへ変換
    private func returnSortKeyString(sortKey: SortKey) -> String {
        switch sortKey {
        case .title:
            if taskViewModel.sortKey == .title {
                return "〉Title"
            } else {
                return "Title"
            }
        case .addedDate:
            if taskViewModel.sortKey == .addedDate {
                return "〉Added date"
            } else {
                return"Added date"
            }
        case .spanType:
            if taskViewModel.sortKey == .spanType {
                return "〉Span type"
            } else {
                return"Span type"
            }
        }
    }
    
    // 全てのタスクをspanTypeごとに仕分けして返す
    private func returnSortedTasksBySpanType(tasks: [Tasks]) -> [Tasks] {
        var sortedAllTasks: [Tasks] = []
        var everyDayTasks: [Tasks] = []
        var everyWeekTasks: [Tasks] = []
        var everyMonthTasks: [Tasks] = []
        var everyWeekdayTasks: [Tasks] = []
        var oneTimeTasks: [Tasks] = []
        
        for task in tasks {
            let spanType = task.spanType
            switch spanType {
            case .oneTime:
                oneTimeTasks.append(task)
            case .everyDay:
                everyDayTasks.append(task)
            case .everyWeek:
                everyWeekTasks.append(task)
            case .everyMonth:
                everyMonthTasks.append(task)
            case .everyWeekday:
                everyWeekdayTasks.append(task)
            }
        }
        sortedAllTasks = everyDayTasks + everyWeekTasks + everyMonthTasks + everyWeekdayTasks + oneTimeTasks

        return sortedAllTasks
    }
}

struct AllTaskListView_Previews: PreviewProvider {
    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)

    static var previews: some View {
        AllTaskListView(taskViewModel: TaskViewModel(), rkManager: rkManager)
    }
}
