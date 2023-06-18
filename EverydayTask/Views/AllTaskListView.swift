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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(returnSortedAllTask(tasks: taskViewModel.tasks).enumerated()), id: \.element) { index, tasks in
                    if tasks.count != 0 {
                        Section(header: Text(returnHeaderText(index: index))) {
                            ForEach(tasks, id: \.id) { task in
                                NavigationLink(destination: TaskSettingView(rkManager: rkManager,
                                                                            taskViewModel: taskViewModel,
                                                                            task: task,
                                                                            selectedWeekdays: task.spanDate)) {
                                    AllTaskCell(taskViewModel: taskViewModel, task: task)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("All Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
    }
}

extension AllTaskListView {
    
    private var ableButton: some View {
        Image(systemName: "")
    }
    
    // ヘッダーのテキストを返す
    private func returnHeaderText(index: Int) -> String {
        if index == 0 { return "Every day" }
        else if index == 1 { return "Every week" }
        else if index == 2 { return "Every month" }
        else if index == 3 { return "Custom" }
        else { return "One time" }
    }
    
    // 全てのタスクをspanTypeごとに仕分けして返す
    /// returnSortedAllTask[0] = everyDayTasks
    /// returnSortedAllTask[1] = everyWeekTasks
    /// returnSortedAllTask[2] = everyMonthTasks
    /// returnSortedAllTask[3] = everyWeekdayTasks
    /// returnSortedAllTask[4] = oneTimeTasks
    private func returnSortedAllTask(tasks: [Tasks]) -> [[Tasks]] {
        var sortedAllTasks: [[Tasks]] = []
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
        sortedAllTasks.append(everyDayTasks)
        sortedAllTasks.append(everyWeekTasks)
        sortedAllTasks.append(everyMonthTasks)
        sortedAllTasks.append(everyWeekdayTasks)
        sortedAllTasks.append(oneTimeTasks)

        return sortedAllTasks
    }
}

struct AllTaskListView_Previews: PreviewProvider {
    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)

    static var previews: some View {
        AllTaskListView(taskViewModel: TaskViewModel(), rkManager: rkManager)
    }
}
