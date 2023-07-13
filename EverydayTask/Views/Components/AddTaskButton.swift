//
//  AddTaskButton.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/07/13.
//

import SwiftUI

struct AddTaskButton: View {
    @ObservedObject var taskViewModel: TaskViewModel

    @Binding var showViewFlag: Bool

    var body: some View {
        Button {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
            
            taskViewModel.editTask = Tasks(title: "", detail: "", addedDate: Date(), spanType: .custom, span: .day, doCount: 1, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)
            showViewFlag = true
            
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
}
