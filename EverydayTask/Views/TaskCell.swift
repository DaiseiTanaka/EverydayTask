//
//  TaskCell.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/06.
//

import SwiftUI

struct TaskCell: View {
    
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager
    
    @Environment(\.locale) var locale

    var task: Tasks
    var cellHeight: CGFloat
    var cellStyle: TaskCellStyle
    
    @Binding var showTaskSettingAlart: Bool
    
    let generator = UINotificationFeedbackGenerator()
    
    let spanImageListNotExit: [Image] = [
        Image(systemName: "s.circle"),
        Image(systemName: "m.circle"),
        Image(systemName: "t.circle"),
        Image(systemName: "w.circle"),
        Image(systemName: "t.circle"),
        Image(systemName: "f.circle"),
        Image(systemName: "s.circle")
    ]
    let spanImageListExit: [Image] = [
        Image(systemName: "s.circle.fill"),
        Image(systemName: "m.circle.fill"),
        Image(systemName: "t.circle.fill"),
        Image(systemName: "w.circle.fill"),
        Image(systemName: "t.circle.fill"),
        Image(systemName: "f.circle.fill"),
        Image(systemName: "s.circle.fill")
    ]
    
    var body: some View {
        HStack {
            if cellStyle == .oneSmallColumns {
                oneSmallColumnsCell
            } else {
                twoColumnsCell
            }
        }
        .padding(.vertical, 4)
        .padding(.trailing, 4)
        .background(taskViewModel.isDone(task: task, date: rkManager.selectedDate) ? Color(UIColor.systemGray5) : Color("cellBackground"))
        .frame(minHeight: cellHeight)
        .frame(maxWidth: .infinity)
        .cornerRadius(cellStyle.cornerRadius)
        .shadow(color: !taskViewModel.isDone(task: task, date: rkManager.selectedDate) ? .black.opacity(0.2) : .clear, radius: cellStyle == .twoColumns ? 7 : 2, x: 0, y: 3)
        .overlay {
            RoundedRectangle(cornerRadius: cellStyle.cornerRadius)
                .stroke(lineWidth: 3)
                .fill(taskViewModel.selectedTasks == [task] ? Color.blue.opacity(0.4) : .clear)
        }
        .overlay(alignment: .topTrailing) {
            editButton
        }
        .overlay(alignment: cellStyle == .oneSmallColumns ? .leading : .topLeading) {
            doneTaskButton
                .padding(.leading, cellStyle == .oneSmallColumns ? 5 : 0)
        }
    }
}

extension TaskCell {
    private var oneSmallColumnsCell: some View {
        HStack {
            accentColor
            
            VStack(alignment: .leading) {
                HStack {
                    title
                    Spacer(minLength: 0)
                    span
                }
                Spacer(minLength: 0)

                detail
            }
            .padding(.leading, 15)
            .padding(.trailing, 30)
        }
    }
    
    private var twoColumnsCell: some View {
        HStack {
            accentColor
                .padding(.top, 25)
            VStack(alignment: .leading) {
                title
                
                detail
                
                Spacer(minLength: 0)
                
                span
            }
            .padding(.leading, 8)
            Spacer(minLength: 0)
        }
    }
    
    private var accentColor: some View {
        // タスクのアクセントカラー
        Rectangle()
            .frame(width: 7)
            .cornerRadius(5)
            .foregroundColor(taskViewModel.returnColor(color: task.accentColor))
    }
    
    private var title: some View {
        // タスクのタイトル
        Text(task.title)
            .font(.subheadline.bold())
            .foregroundColor(taskViewModel.isDone(task: task, date: rkManager.selectedDate) ? .secondary : .primary)
            .lineLimit(1)
            .padding(.trailing, 20)
            .padding(.leading, 10)
    }
    
    private var detail: some View {
        // タスクの詳細
        Text(task.detail)
            .font(.footnote)
            .foregroundColor(.secondary)
            .lineLimit(2)
            .padding(.leading, 10)
    }
    
    private var span: some View {
        // タスクのスパン
        HStack(spacing: 3) {
            if task.spanType == .everyDay || task.spanType == .everyWeekday {
                if task.notification {
                    Image(systemName: "bell.badge")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "bell.slash")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if task.spanType == .everyWeek {
                Image(systemName: "w.circle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if task.spanType == .everyMonth {
                Image(systemName: "m.circle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if task.spanType == .oneTime {
                Image(systemName: "1.circle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if task.spanType == .everyWeekday {
                spanImage
            } else {
                Text(returnSpanString(span: task.spanType))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
    
    private func returnSpanString(span: TaskSpanType) -> String {
//        if locale.identifier == "ja" {
//            switch span {
//            case .everyDay:
//                return "毎日"
//            case .everyWeek:
//                return "週一"
//            case .everyMonth:
//                return "月一"
//            case .everyWeekday:
//                // everyWeekdayの時はspanImageを返す
//                return ""
//            }
//        } else {
            switch span {
            case .oneTime:
                return "One time"
            case .everyDay:
                return "Every day"
            case .everyWeek:
                return "Once a week"
            case .everyMonth:
                return "Once a month"
            case .everyWeekday:
                // everyWeekdayの時はspanImageを返す
                return ""
            }
        //}

    }
    
    private var spanImage: some View {
        HStack(spacing: 2) {
            ForEach(1..<8) { index in
                if task.spanDate.contains(index) {
                    spanImageListExit[index-1]
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    spanImageListNotExit[index-1]
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .opacity(0.5)
                }
            }
        }
    }
    
    private var editButton: some View {
        Button {
            taskViewModel.editTask = task
            showTaskSettingAlart.toggle()
            
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
                .foregroundColor(.blue)
                .background(.clear)
                .padding(5)
        }
    }
    // タスク実施ボタン
    private var doneTaskButton: some View {
        Button {
            tapDoneTaskButtonAction(task: task)
        } label: {
            if taskViewModel.isDone(task: task, date: rkManager.selectedDate) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                    .padding(5)
            } else {
                Image(systemName: "circle")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(5)
            }
        }
    }
    // タスク実施ボタンをタップした時のアクション
    private func tapDoneTaskButtonAction(task: Tasks) {
        let selectedDate = rkManager.selectedDate
        let spanType = task.spanType
        
        if spanType == .oneTime {
            generator.notificationOccurred(.success)
            if let index = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                if !taskViewModel.isDone(task: task, date: selectedDate) {
                    withAnimation {
                        // 実行済みにする
                        taskViewModel.tasks[index].doneDate.append(selectedDate)
                        updateSelectedTasks(index: index)
                    }
                } else {
                    withAnimation {
                        // 実行履歴を全て削除する
                        taskViewModel.tasks[index].doneDate.removeAll()
                        updateSelectedTasks(index: index)
                    }
                }
            }
            
        } else if spanType == .everyDay || spanType == .everyWeekday {
            // 選択したタスクがまだ実行済みではなかった場合 -> 実行履歴に追加
            if !taskViewModel.isDone(task: task, date: selectedDate) {
                generator.notificationOccurred(.success)
                
                if let index = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    withAnimation {
                        // 実行済みにする
                        taskViewModel.tasks[index].doneDate.append(selectedDate)
                        updateSelectedTasks(index: index)
                    }
                }
                // 選択したタスクが実行済みであった場合 -> 実行履歴を削除
            } else {
                let impactLight = UIImpactFeedbackGenerator(style: .rigid)
                impactLight.impactOccurred()
                
                if let index = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    // タスクを未達成の状態にする
                    let selectedTaskDoneDates = taskViewModel.tasks[index].doneDate
                    for doneDateIndex in 0..<selectedTaskDoneDates.count {
                        let doneDate = selectedTaskDoneDates[doneDateIndex]
                        if taskViewModel.isSameDay(date1: selectedDate, date2: doneDate) {
                            // 上書き
                            withAnimation {
                                taskViewModel.tasks[index].doneDate.remove(at: doneDateIndex)
                                taskViewModel.tasks[index].doneDate.sort()
                                updateSelectedTasks(index: index)
                            }
                        }
                    }
                }
            }
            
        } else if spanType == .everyWeek {
            if !taskViewModel.isDone(task: task, date: selectedDate) {
                generator.notificationOccurred(.success)
                if let index = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    withAnimation {
                        taskViewModel.tasks[index].doneDate.append(selectedDate)
                        // WeeklyAndMonthlyDetailListViewに日付順で表示するため
                        taskViewModel.tasks[index].doneDate.sort()
                        updateSelectedTasks(index: index)
                    }
                }
            } else {
                let impactLight = UIImpactFeedbackGenerator(style: .rigid)
                impactLight.impactOccurred()
                if let index = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    // タスクを未達成の状態にする
                    let selectedTaskDoneDates = taskViewModel.tasks[index].doneDate
                    for doneDateIndex in 0..<selectedTaskDoneDates.count {
                        let doneDate = selectedTaskDoneDates[doneDateIndex]
                        if taskViewModel.isSameWeek(date1: selectedDate, date2: doneDate) {
                            // 上書き
                            withAnimation {
                                taskViewModel.tasks[index].doneDate.remove(at: doneDateIndex)
                                taskViewModel.tasks[index].doneDate.sort()
                                updateSelectedTasks(index: index)
                            }
                        }
                    }
                }
            }
            
        } else if spanType == .everyMonth {
            if !taskViewModel.isDone(task: task, date: selectedDate) {
                generator.notificationOccurred(.success)
                if let index = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    withAnimation {
                        taskViewModel.tasks[index].doneDate.append(selectedDate)
                        // WeeklyAndMonthlyDetailListViewに日付順で表示するため
                        taskViewModel.tasks[index].doneDate.sort()
                        updateSelectedTasks(index: index)
                    }
                }
            } else {
                let impactLight = UIImpactFeedbackGenerator(style: .rigid)
                impactLight.impactOccurred()
                if let index = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    // タスクを未達成の状態にする
                    let selectedTaskDoneDates = taskViewModel.tasks[index].doneDate
                    for doneDateIndex in 0..<selectedTaskDoneDates.count {
                        let doneDate = selectedTaskDoneDates[doneDateIndex]
                        if taskViewModel.isSameMonth(date1: selectedDate, date2: doneDate) {
                            // 上書き
                            withAnimation {
                                taskViewModel.tasks[index].doneDate.remove(at: doneDateIndex)
                                taskViewModel.tasks[index].doneDate.sort()
                                updateSelectedTasks(index: index)
                            }
                        }
                    }
                }
            }
        }
        
        taskViewModel.saveTasks(tasks: taskViewModel.tasks)
        print("doneTaskButtonTapped! selectedTasks:\n\(taskViewModel.selectedTasks)")
    }
    
    // タスクを完了した時に表示するタスクを更新する
    // このコードがないと、weekly, monthlyタスク用の画面を表示中に、everyDay, everyWeekdayのタスクを完了させると、画面がバグる
    // weekly, monthlyのタスクを完了した瞬間は、カレンダー画面へ移動したくない
    private func updateSelectedTasks(index: Int) {
        if taskViewModel.showCalendarFlag || taskViewModel.tasks[index].spanType == .everyDay || taskViewModel.tasks[index].spanType == .everyWeekday {
            taskViewModel.selectedTasks = taskViewModel.tasks
            taskViewModel.showCalendarFlag = true
        } else {
            taskViewModel.selectedTasks = [taskViewModel.tasks[index]]
        }
    }
    
}

struct TaskCell_Previews: PreviewProvider {
    static var taskViewModel = TaskViewModel()
    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)
    @State static var showTaskSettingAlart: Bool = false
        
    static var previews: some View {
        TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: Tasks.previewData[0], cellHeight: 80, cellStyle: .twoColumns, showTaskSettingAlart: $showTaskSettingAlart)
            .frame(width: UIScreen.main.bounds.width / 2 - 20)
    }
}
