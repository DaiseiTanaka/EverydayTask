//
//  Span.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/07/13.
//

import SwiftUI

struct SpanView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    
    var task: Tasks
    var showAddedDate: Bool
    
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
        HStack(spacing: 0) {
            if showAddedDate {
                addedDateText
            }
            
            spanDetail
            
            if (task.spanType == .custom && task.span == .day) || task.spanType == .selected {
                notificationBadge
            }
        }
    }
}

extension SpanView {
    private var addedDateText: some View {
        HStack(spacing: 3) {
            Image(systemName: "calendar.badge.plus")
            
            Text("\(taskViewModel.returnDayString(date: task.addedDate)) ~ ")
                .bold()

            Spacer(minLength: 0)
        }
        .foregroundColor(.secondary)
        .font(.footnote)
        .frame(width: 80)
    }
    
    private var spanDetail: some View {
        HStack(spacing: 0) {
            if task.spanType == .selected {
                spanImage
            } else if task.spanType == .custom {
                spanText
            }
        }
    }
    
    private var notificationBadge: some View {
        HStack(spacing: 0) {
            Text("・")
            if task.notification {
                Image(systemName: "bell.badge")
            } else {
                Image(systemName: "bell.slash")
            }
        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }
    
    private var spanText: some View {
        HStack(spacing: 3) {
            Image(systemName: "arrow.2.squarepath")

            Text("\(task.doCount) /")
                .lineLimit(1)
                .bold()

            Text(LocalizedStringKey(task.span.spanString))
                .lineLimit(1)
                .bold()
        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }
    
    private var spanImage: some View {
        HStack(spacing: 1) {
            ForEach(1..<8) { index in
                if task.spanDate.contains(index) {
                    spanImageListExit[index-1]
                        
                } else {
                    spanImageListNotExit[index-1]
                        .opacity(0.5)
                }
            }
        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}
