//
//  AllTaskCell.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/18.
//

import SwiftUI

struct AllTaskCell: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @State var task: Tasks
    
    @Binding var showTaskSettingView: Bool
    @State private var showTaskSettingAlart: Bool = false
    @State private var showCalendarView: Bool = false
    @Binding var prevSelectedTasks: [Tasks]
    
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
            // タスクのアクセントカラー
            Rectangle()
                .frame(width: 7)
                .cornerRadius(5)
                .foregroundColor(taskViewModel.returnColor(color: task.accentColor))
            
            detail
                        
            Spacer(minLength: 0)
            
            actionButton
        }
        .frame(height: 55)
        .background(
            Color.black.opacity(0.000001)
                .onTapGesture {
                    let impactLight = UIImpactFeedbackGenerator(style: .rigid)
                    impactLight.impactOccurred()
                    // タップされたタスクをカレンダーに表示する
                    showCalendar()
                }
                .onLongPressGesture() {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    // アラートを表示
                    taskViewModel.editTask = task
                    showTaskSettingAlart.toggle()
                }
        )
        .sheet(isPresented: self.$showCalendarView, content: {
            selectedCalendarView
        })
        .confirmationDialog(taskViewModel.editTask.title, isPresented: $showTaskSettingAlart, titleVisibility: .visible) {
            Button("Edit this task?") {
                showTaskSettingView.toggle()
            }
            Button("Show calendar?") {
                // タップされたタスクをカレンダーに表示する
                showCalendar()
            }
            Button("Duplicate this task?") {
                taskViewModel.duplicateTask(task: taskViewModel.editTask)
            }
            Button(task.isAble ? "Hide this task?" : "Show this task?") {
                taskViewModel.hideTask(task: taskViewModel.editTask)
            }
            Button("Delete this task?", role: .destructive) {
                taskViewModel.removeTasks(task: taskViewModel.editTask)
            }
        } message: {
            Text(taskViewModel.editTask.detail)
        }
    }
}

extension AllTaskCell {
    private var detail: some View {
        VStack(alignment: .leading) {
            HStack {
                if !task.isAble {
                    Image(systemName: "eye.slash")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Text(task.title)
                    .lineLimit(1)
                    .font(task.isAble ? .body.bold() : .body)
                    .foregroundColor(task.isAble ? Color(UIColor.label) : .secondary)
            }
            
            Text(task.detail)
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer(minLength: 0)
            
            // タスクのスパン
            span
        }
    }
    
    private var span: some View {
        // タスクのスパン
        HStack(spacing: 3) {
            // addedDate
            HStack {
                Text("\(taskViewModel.returnDayString(date: task.addedDate)) ~ ")
                    .font(.footnote)
                    .foregroundColor(task.isAble ? .primary : .secondary)
                Spacer()
            }
            .frame(width: 50)

            if (task.spanType == .custom && task.span == .day) || task.spanType == .selected {
                if task.notification {
                    Image(systemName: "bell.badge")
                        .font(.footnote)
                        .foregroundColor(task.isAble ? .primary : .secondary)
                } else {
                    Image(systemName: "bell.slash")
                        .font(.footnote)
                        .foregroundColor(task.isAble ? .primary : .secondary)
                }
            }
            
            if task.spanType == .selected {
                spanImage
                
            } else if task.spanType == .custom {
                Text("\(task.doCount) /")
                    .font(.footnote)
                    .foregroundColor(task.isAble ? .primary : .secondary)
                    .lineLimit(1)
                Text(LocalizedStringKey(task.span.spanString))
                    .font(.footnote)
                    .foregroundColor(task.isAble ? .primary : .secondary)
                    .lineLimit(1)
            } else {
                Text(LocalizedStringKey(task.spanType.spanString))
                    .font(.footnote)
                    .foregroundColor(task.isAble ? .primary : .secondary)
                    .lineLimit(1)
            }
        }
    }
    
    private var actionButton: some View {
        Button {
            taskViewModel.editTask = task
            showTaskSettingAlart.toggle()
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
                .foregroundColor(.primary)
                .background(
                    Color.black.opacity(0.00001)
                        .frame(width: 70, height: 70)
                )
        }
    }
    
    private var isAbleToggle: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if !task.isAble {
                Text("Hidden")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            Toggle("", isOn: $task.isAble)
                .frame(width: 50)
                .onChange(of: task.isAble) { isAble in
                    taskViewModel.isAbleChange(task: task, isAble: isAble)
                }
        }
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
    
    // タスクがタップされたときに表示するカレンダー
    private var selectedCalendarView: some View {
        ZStack {
            if task.spanType == .custom {
                if task.span == .day {
                    VStack {
                        Text("\(task.title)")
                            .font(.title2.bold())
                        CalendarView(rkManager: taskViewModel.rkManager, taskViewModel: taskViewModel)
                    }
                } else {
                    RegularlyTaskView(taskViewModel: taskViewModel, rkManager: taskViewModel.rkManager, task: task)
                        .padding(.top, 20)
                }
            } else {
                VStack {
                    Text("\(task.title)")
                        .font(.title2.bold())
                    CalendarView(rkManager: taskViewModel.rkManager, taskViewModel: taskViewModel)
                    
                }
            }
        }
        .frame(maxWidth: .infinity)
        .presentationDetents([.large])
        .presentationCornerRadius(30)
        .presentationDragIndicator(.visible)
        .padding(.top)
        .overlay(alignment: .topLeading) { dismissButton }
    }
    
    private var dismissButton: some View {
        Button(action: {
            showCalendarView = false
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.secondary)
                .font(.title3)
                .padding()
        }
    }
    
    private func showCalendar() {
        // タップされたタスクをカレンダーに表示する
        taskViewModel.selectedTasks = [task]
        taskViewModel.loadRKManager()
        showCalendarView.toggle()
    }
}

struct AllTaskCell_Previews: PreviewProvider {
    @State static var showTaskSettingView: Bool = false
    @State static var prevSelectedTasks: [Tasks] = []
    static var previews: some View {
        AllTaskCell(taskViewModel: TaskViewModel(), task: Tasks.defaulData[0], showTaskSettingView: $showTaskSettingView, prevSelectedTasks: $prevSelectedTasks)
    }
}
