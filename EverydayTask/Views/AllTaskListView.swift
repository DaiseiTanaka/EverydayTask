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
    @State private var searchText: String = ""
    @AppStorage("sortKey") private var sortKey = SortKey.spanType
    @State private var prevSelectedTasks: [Tasks] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if returnSortedTasks(key: sortKey).isEmpty {
                    emptyView
                } else {
                    allTaskList
                }
            }
            .navigationTitle("All Tasks")
            .navigationBarTitleDisplayMode(.inline)
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .sheet(isPresented: self.$showTaskSettingView, content: {
            TaskSettingView(rkManager: rkManager, taskViewModel: taskViewModel, task: taskViewModel.editTask, selectedWeekdays: taskViewModel.editTask.spanDate)
        })
        .onAppear {
            self.prevSelectedTasks = taskViewModel.selectedTasks
        }
        .onDisappear {
            if taskViewModel.selectedTasks != prevSelectedTasks {
                // タップされる前のカレンダーの状態に戻す
                taskViewModel.selectedTasks = self.prevSelectedTasks
                taskViewModel.loadRKManager()
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
        HStack(spacing: 3) {
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
                ForEach(Array(returnSortedTasks(key: sortKey).enumerated()), id: \.element) { index, task in
                    AllTaskCell(taskViewModel: taskViewModel, task: task, showTaskSettingView: $showTaskSettingView, prevSelectedTasks: $prevSelectedTasks)
                }
                .onDelete(perform: rowRemove)
            }
        }
    }
    
    private var addTaskButton: some View {
        Button {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
            
            taskViewModel.editTask = Tasks(title: "", detail: "", addedDate: Date(), spanType: .custom, span: .day, doCount: 1, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
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
        Menu {
            Section("Sort") {
                Picker("Sort", selection: $sortKey) {
                    ForEach(SortKey.allCases) {
                        Text(LocalizedStringKey($0.keyString))
                    }
                }
            }
        } label: {
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
        var tasks = taskViewModel.tasks
        // 何かが検索されている場合
        if !searchText.isEmpty {
            // タイトルと詳細でフィルタリング
            tasks = tasks.filter { $0.title.lowercased().contains(searchText.lowercased()) || $0.detail.lowercased().contains(searchText.lowercased())}
        }
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
        var sortedTasks = returnSortedTasks(key: sortKey)
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
    
    // 全てのタスクをspanTypeごとに仕分けして返す
    private func returnSortedTasksBySpanType(tasks: [Tasks]) -> [Tasks] {
        var sortedAllTasks: [Tasks] = []
        
        var dayTasks: [Tasks] = []
        var selectedTasks: [Tasks] = []
        var weekTasks: [Tasks] = []
        var monthTasks: [Tasks] = []
        var yearTasks: [Tasks] = []
        var infiniteTasks: [Tasks] = []
        
        for task in tasks {
            let spanType = task.spanType
            switch spanType {
            case .custom:
                switch task.span {
                case .day:
                    dayTasks.append(task)
                case .week:
                    weekTasks.append(task)
                case .month:
                    monthTasks.append(task)
                case .year:
                    yearTasks.append(task)
                case .infinite:
                    infiniteTasks.append(task)
                }

            case .selected:
                selectedTasks.append(task)
            }
        }
        
        sortedAllTasks = dayTasks + selectedTasks + weekTasks + monthTasks + yearTasks + infiniteTasks

        return sortedAllTasks
    }
}

struct AllTaskListView_Previews: PreviewProvider {
    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)

    static var previews: some View {
        AllTaskListView(taskViewModel: TaskViewModel(), rkManager: rkManager)
    }
}
