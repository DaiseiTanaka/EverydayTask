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
    var cellStyle: TaskCellStyle
    
    @Binding var showTaskSettingAlart: Bool
    
    @Binding var showRegularlyTaskAlart: Bool
    
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            switch cellStyle {
            case .list:
                oneSmallColumnsCell
            case .grid:
                twoColumnsCell
            }
        }
        .padding(.vertical, 4)
        .padding(.trailing, 4)
        .background(returnCellBackgroundColor())
        .frame(minHeight: cellStyle.height)
        .frame(maxWidth: .infinity)
        .cornerRadius(cellStyle.cornerRadius)
        .shadow(color: returnShadowColor(), radius: returnCellRadius(), x: 0, y: 3)
        .overlay { cellStroke }
        .overlay(alignment: cellStyle == .list ? .trailing : .topTrailing) { editButton }
        .overlay(alignment: cellStyle == .list ? .leading : .topLeading) { doneTaskButton }
    }
}

extension TaskCell {
    private var oneSmallColumnsCell: some View {
        HStack {
            accentColor
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    title
                    
                    Spacer(minLength: 0)
                    
                    SpanView(taskViewModel: taskViewModel, task: task, showAddedDate: false)
                }
                
                Spacer(minLength: 0)

                detail
            }
            .padding(.leading, 15)
            .padding(.trailing, 40)
        }
    }
    
    private var twoColumnsCell: some View {
        HStack {
            accentColor
                .padding(.top, 25)
            VStack(alignment: .leading) {
                title
                    .padding(.leading, 8)

                detail
                    .padding(.leading, 8)

                Spacer(minLength: 0)
                
                SpanView(taskViewModel: taskViewModel, task: task, showAddedDate: false)
            }
            Spacer(minLength: 0)
        }
    }
    
    // 選択されたセルの枠
    private var cellStroke: some View {
        RoundedRectangle(cornerRadius: cellStyle.cornerRadius)
            .stroke(lineWidth: 3)
            .fill(taskViewModel.selectedTasks == [task] ? Color.blue.opacity(0.4) : .clear)
    }
    
    // タスクのアクセントカラー
    private var accentColor: some View {
        Rectangle()
            .frame(width: 7)
            .cornerRadius(5)
            .foregroundColor(taskViewModel.returnColor(color: task.accentColor))
    }
    
    // タスクのタイトル
    private var title: some View {
        ZStack {
            Text(LocalizedStringKey(taskViewModel.titleString(task: task)))
                .lineLimit(cellStyle == .list ? nil : 1)
        }
        .font(.subheadline.bold())
        .foregroundColor(taskViewModel.isDone(task: task, date: rkManager.selectedDate) ? .secondary : .primary)
        .padding(.trailing, cellStyle == .list ? 10 : 30)
        .padding(.leading, 10)
    }
    
    // タスクの詳細
    private var detail: some View {
        Text(task.detail)
            .font(.footnote)
            .foregroundColor(.secondary)
            .lineLimit(cellStyle == .list ? nil : 2)
            .padding(.leading, 10)
    }
    
    private var editButton: some View {
        Button {
            taskViewModel.editTask = task
            showTaskSettingAlart.toggle()
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
                .foregroundColor(.primary)
                .padding(10)
        }
    }
    
    // タスク実施ボタン
    private var doneTaskButton: some View {
        Button {
            tapDoneTaskButtonAction(task: task)
            
        } label: {
            // タスク実行済みの時
            if taskViewModel.isDone(task: task, date: rkManager.selectedDate) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                    .padding(5)
                    .padding(.leading, cellStyle == .list ? 5 : 0)
            // タスクがまだ実行されていない時
            } else {
                // sapnTypeがカスタムかつ、残りのタスク実施回数が２回以上の時、実施ボタンに数字を表示する
                if task.spanType == .custom && taskViewModel.returnRemainCustomTaskCount(task: task, date: rkManager.selectedDate) >= 2 {
                    Text("\(taskViewModel.returnRemainCustomTaskCount(task: task, date: rkManager.selectedDate))")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(Color.red))
                        .padding(5)
                        .padding(.leading, cellStyle == .list ? 7 : 0)
                        .animation(nil, value: 0)
                        .transition(.scale)
                    
                } else {
                    Image(systemName: "circle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(5)
                        .padding(.leading, cellStyle == .list ? 5 : 0)
                }
            }
        }
    }
    
    private func returnCellBackgroundColor() -> Color {
        if taskViewModel.isDone(task: task, date: rkManager.selectedDate) {
            return Color("cellBackgroundDone")
        } else {
            return Color("cellBackground")
        }
    }
    
    private func returnShadowColor() -> Color {
        if !taskViewModel.isDone(task: task, date: rkManager.selectedDate) {
            return Color.black.opacity(0.2)
        } else {
            return Color.clear
        }
    }
    
    private func returnCellRadius() -> CGFloat {
        switch cellStyle {
        case .list:
            return 4
        case .grid:
            return 7
        }
    }
    
    // タスク実施ボタンをタップした時のアクション
    private func tapDoneTaskButtonAction(task: Tasks) {
        if taskViewModel.isSameDay(date1: rkManager.selectedDate, date2: Date()) {
            rkManager.selectedDate = Date()
        }
        let selectedDate = rkManager.selectedDate
        let spanType = task.spanType
        
        if spanType == .selected {
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
            
        } else if spanType == .custom {
            if !taskViewModel.isDone(task: task, date: selectedDate) {
                generator.notificationOccurred(.success)
                if let index = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    withAnimation {
                        taskViewModel.tasks[index].doneDate.append(selectedDate)
                        taskViewModel.tasks[index].doneDate.sort()
                        updateSelectedTasks(index: index)
                    }
                }
            } else {
                let impactLight = UIImpactFeedbackGenerator(style: .rigid)
                impactLight.impactOccurred()
                // 編集画面へ移動するか選択するアラートを表示
                taskViewModel.editTask = task
                showRegularlyTaskAlart = true
            }
        }
        
        taskViewModel.saveTasks(tasks: taskViewModel.tasks)
        //print("doneTaskButtonTapped! selectedTasks:\n\(taskViewModel.selectedTasks)")
    }
    
    // タスクを完了した時に表示するタスクを更新する
    // このコードがないと、weekly, monthlyタスク用の画面を表示中に、everyDay, everyWeekdayのタスクを完了させると、画面がバグる
    // weekly, monthlyのタスクを完了した瞬間は、カレンダー画面へ移動したくない
    private func updateSelectedTasks(index: Int) {
        if taskViewModel.showCalendarFlag || taskViewModel.tasks[index].spanType == .selected {
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
    @State static var showRegularlyTaskAlart: Bool = false
        
    static var previews: some View {
        TaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: Tasks.previewData[0], cellStyle: .list, showTaskSettingAlart: $showTaskSettingAlart, showRegularlyTaskAlart: $showRegularlyTaskAlart)
            .frame(width: UIScreen.main.bounds.width / 2 - 20)
    }
}
