//
//  Span.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/07/13.
//

import SwiftUI

struct Span: View {
    @ObservedObject var taskViewModel: TaskViewModel
    
    var task: Tasks
    
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
        HStack(spacing: 3) {
            addedDateText

            if (task.spanType == .custom && task.span == .day) || task.spanType == .selected {
                notificationBadge
            }
            
            if task.spanType == .selected {
                spanImage
                
            } else if task.spanType == .custom {
                spanText
                
            }
        }
    }
}

extension Span {
    private var addedDateText: some View {
        HStack {
            Text("\(taskViewModel.returnDayString(date: task.addedDate)) ~ ")
                .font(.footnote)
                .foregroundColor(task.isAble ? .primary : .secondary)
            Spacer()
        }
        .frame(width: 50)
    }
    
    private var notificationBadge: some View {
        ZStack {
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
    }
    
    private var spanText: some View {
        HStack(spacing: 3) {
            Text("\(task.doCount) /")
                .font(.footnote)
                .foregroundColor(task.isAble ? .primary : .secondary)
                .lineLimit(1)
            Text(LocalizedStringKey(task.span.spanString))
                .font(.footnote)
                .foregroundColor(task.isAble ? .primary : .secondary)
                .lineLimit(1)
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
