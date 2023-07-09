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
    
    @State private var cellStyle: TaskCellStyle = .grid
    @AppStorage("cellStyleAS") private var cellStyleAS: TaskCellStyle = .grid
    @AppStorage("selectedStyle") private var selectedStyle: TaskCellStyle = .grid
    @State private var columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 10, maximum: 300)), count: 2)
    @State private var cellHeight: CGFloat = 80
    
    let generator = UINotificationFeedbackGenerator()
    
    @State var showTaskSettingView: Bool = false
    @State var showTaskSettingAlart: Bool = false
    @State var showAllTaskListViewFlag: Bool = false
    @State var showChangeCellStyleAlart: Bool = false
    @State var showRegularlyTaskAlart: Bool = false

    @AppStorage("showRegularlyTaskList") private var showRegularlyTaskList: Bool = true
    @AppStorage("showOneTimeTaskList") private var showOneTimeTaskList: Bool = true
    @AppStorage("showDoneTasks") private var showDoneTasks: Bool = false

    @State private var offset = CGFloat.zero
    @State private var closeOffset = CGFloat.zero
    @State private var openOffset = CGFloat.zero
    
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
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    withAnimation {
                        if (value.translation.width < -50) {
                            self.rkManager.selectedDate = self.rkManager.selectedDate.addingTimeInterval(60*60*24)
                        } else if (value.translation.width > 50) {
                            self.rkManager.selectedDate = self.rkManager.selectedDate.addingTimeInterval(-60*60*24)
                        }
                    }
                }
        )
        .onAppear {
            cellStyle = cellStyleAS
        }
        .sheet(isPresented: $showTaskSettingView, content: {
            TaskSettingView(rkManager: rkManager, taskViewModel: taskViewModel, task: taskViewModel.editTask, selectedWeekdays: taskViewModel.editTask.spanDate)
        })
        .sheet(isPresented: $showAllTaskListViewFlag, content: {
            AllTaskListView(taskViewModel: taskViewModel, rkManager: rkManager)
        })
        .confirmationDialog(taskViewModel.editTask.title, isPresented: $showTaskSettingAlart, titleVisibility: .visible) {
            Button("Edit this task?") {
                showTaskSettingView.toggle()
            }
            if taskViewModel.editTask.spanType == .custom {
                Button("Show this task history?") {
                    taskViewModel.showCalendarFlag = false
                }
            }
            Button("Duplicate this task?") {
                taskViewModel.duplicateTask(task: taskViewModel.editTask)
            }
            Button("Hide this task?") {
                taskViewModel.hideTask(task: taskViewModel.editTask)
            }
            Button("Delete this task?", role: .destructive) {
                taskViewModel.removeTasks(task: taskViewModel.editTask)
            }
        } message: {
            Text(taskViewModel.editTask.detail)
        }
        .confirmationDialog(taskViewModel.editTask.title, isPresented: $showRegularlyTaskAlart, titleVisibility: .visible) {
            Button("Edit history") {
                taskViewModel.showCalendarFlag = false
            }
        } message: {
            Text(taskViewModel.editTask.detail)
        }
        .confirmationDialog(taskViewModel.editTask.title, isPresented: $taskViewModel.showEditRegularlyTaskAlart, titleVisibility: .visible) {
            Button("Delete this history?", role: .destructive) {
                guard let taskIndex = taskViewModel.tasks.firstIndex(where: { $0.id == taskViewModel.editTask.id }) else {
                    return
                }
                guard let dateIndex = taskViewModel.tasks[taskIndex].doneDate.firstIndex(where: { $0 == taskViewModel.selectedRegularlyTaskDate }) else {
                    return
                }
                taskViewModel.tasks[taskIndex].doneDate.remove(at: dateIndex)
                withAnimation {
                    taskViewModel.selectedTasks = [taskViewModel.tasks[taskIndex]]
                }
                taskViewModel.saveTasks(tasks: taskViewModel.tasks)
            }
        } message: {
            Text(returnDateTime(date: taskViewModel.selectedRegularlyTaskDate))
        }
    }
}

extension TaskView {
    private var header: some View {
        HStack {
            Button {
                showAllTaskListViewFlag = true
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
            LazyVGrid(columns: cellStyle.columns, spacing: cellStyle.space) {
                ForEach(taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[0], id: \.id) { task in
                    TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, cellStyle: cellStyle, showTaskSettingAlart: $showTaskSettingAlart, showRegularlyTaskAlart: $showRegularlyTaskAlart)
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
                LazyVGrid(columns: cellStyle.columns, spacing: cellStyle.space) {
                    ForEach(taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[1], id: \.id) { task in
                        TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, cellStyle: cellStyle, showTaskSettingAlart: $showTaskSettingAlart, showRegularlyTaskAlart: $showRegularlyTaskAlart)
                            .onTapGesture {
                                updateCalendar(task: task)
                            }
                            .onLongPressGesture() {
                                longTapTaskAction(task: task)
                            }
                    }
                    ForEach(taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[2], id: \.id) { task in
                        TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, cellStyle: cellStyle, showTaskSettingAlart: $showTaskSettingAlart, showRegularlyTaskAlart: $showRegularlyTaskAlart)
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
                LazyVGrid(columns: cellStyle.columns, spacing: cellStyle.space) {
                    ForEach(taskViewModel.returnSelectedDateUnFinishedTasks(date: rkManager.selectedDate)[3], id: \.id) { task in
                        TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, cellStyle: cellStyle, showTaskSettingAlart: $showTaskSettingAlart, showRegularlyTaskAlart: $showRegularlyTaskAlart)
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
                LazyVGrid(columns: cellStyle.columns, spacing: cellStyle.space) {
                    if !taskViewModel.returnSelectedDateFinishedTasks(date: rkManager.selectedDate).isEmpty {
                        ForEach(taskViewModel.returnSelectedDateFinishedTasks(date: rkManager.selectedDate), id: \.id) { task in
                            // 実行済みのタスク
                            if taskViewModel.isDone(task: task, date: rkManager.selectedDate) {
                                TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, cellStyle: cellStyle, showTaskSettingAlart: $showTaskSettingAlart, showRegularlyTaskAlart: $showRegularlyTaskAlart)
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
            
            taskViewModel.editTask = Tasks(title: "", detail: "", addedDate: Date(), spanType: .everyDay, span: .day, doCount: 1, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
            showTaskSettingView = true
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
            
            showAllTaskListViewFlag = true
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
    
    // cellのスタイルを変更する
    private var changeCellStyleButton: some View {
        ZStack {
            switch cellStyle {
            case .list:
                Button {
                    withAnimation {
                        cellStyle = .grid
                    }
                } label: {
                    Image(systemName: "square.fill.text.grid.1x2")
                        .foregroundColor(.secondary)
                        .font(.body.bold())
                }
            case .grid:
                Button {
                    withAnimation {
                        cellStyle = .list
                    }
                } label: {
                    Image(systemName: "square.grid.2x2")
                        .foregroundColor(.secondary)
                        .font(.body.bold())
                }
            }
        }
        .onChange(of: cellStyle) { newValue in
            // userdefaultsに保存
            cellStyleAS = newValue
        }
//        Menu {
//            Picker("Sort", selection: $selectedStyle) {
//                ForEach(TaskCellStyle.allCases) {
//                    Text(LocalizedStringKey($0.styleString))
//                }
//            }
//            .onSubmit {
//                withAnimation {
//                    cellStyle = selectedStyle
//                }
//            }
//        } label: {
//            switch cellStyle {
//            case .list:
//                Image(systemName: "square.fill.text.grid.1x2")
//                    .foregroundColor(.secondary)
//                    .font(.body.bold())
//            case .grid:
//                Image(systemName: "square.grid.2x2")
//                    .foregroundColor(.secondary)
//                    .font(.body.bold())
//            }
//        }
//        .menuOrder(.fixed)
    }
    
    // 特定のタスクをタップした時の関数
    private func updateCalendar(task: Tasks) {
        let spanType = task.spanType
        let span = task.span
        if spanType != .oneTime {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
        }
        
        // 特定のタスクを表示中 or タスクが一つしか設定されていない場合ー＞weeklyやmonthlyのタスクを一つだけ設定していた場合は、カレンダーを更新する必要があるため。
        if taskViewModel.selectedTasks != [task] || taskViewModel.tasks.count == 1 {
            // 特定のタスクを表示
            if spanType == .everyWeek || spanType == .everyMonth || (spanType == .custom && span != .day) {
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
        //print("Task tapped! selectedTasks:\n\(taskViewModel.selectedTasks)")
    }
    
    // dateのStringを返す
    private func returnDateTime(date: Date) -> String {
        let span = taskViewModel.editTask.span
        let dateFormatter = DateFormatter()
        var dateString: String = ""

        if span == .day {
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .medium
             
            dateString = dateFormatter.string(from: date)
                        
        } else {
            dateFormatter.calendar = Calendar(identifier: .gregorian)
    //        dateFormatter.locale = Locale(identifier: "ja_JP")
    //        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
             
            /// 自動フォーマットのスタイル指定
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
             
            /// データ変換（Date→テキスト）
            dateString = dateFormatter.string(from: date)
        }
        
        return dateString
    }
    
    // タスクを長押しした時のアクション
    private func longTapTaskAction(task: Tasks) {
        generator.notificationOccurred(.success)
        taskViewModel.editTask = task
        showTaskSettingView = true
    }
}

struct TaskView_Previews: PreviewProvider {
    //@StateObject static var taskViewModel = TaskViewModel()
    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)
    @State static var presentationDetent: PresentationDetent = .fraction(0.5)

    static var previews: some View {
        //ContentView()
        TaskView(taskViewModel: TaskViewModel(), rkManager: rkManager)
    }
}
