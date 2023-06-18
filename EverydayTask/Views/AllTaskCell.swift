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
            
            isAbleToggle
        }
        .padding(.vertical, 3)
        .onDisappear {
            if taskViewModel.showAllTaskListViewFlag == false {
                if let index = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    taskViewModel.tasks[index].isAble = task.isAble
                    taskViewModel.saveTasks(tasks: taskViewModel.tasks)
                }
            }
        }
    }
}

extension AllTaskCell {
    private var detail: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .lineLimit(1)
                .font(.body.bold())
                .foregroundColor(task.isAble ? Color(UIColor.label) : .secondary)

            Text(task.detail)
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer(minLength: 0)
            
            // タスクのスパン
            HStack(spacing: 3) {
                Text("\(taskViewModel.returnDayString(date: task.addedDate)) ~ ")
                    .font(.footnote)
                    .foregroundColor(.secondary)

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
        }
    }
    
    private func returnSpanString(span: TaskSpanType) -> String {
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
}

struct AllTaskCell_Previews: PreviewProvider {
    static var previews: some View {
        AllTaskCell(taskViewModel: TaskViewModel(), task: Tasks.defaulData[0])
    }
}
