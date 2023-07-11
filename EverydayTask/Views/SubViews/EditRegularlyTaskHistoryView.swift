//
//  EditRegularlyTaskHistoryView.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/07/10.
//

import SwiftUI

struct EditRegularlyTaskHistoryView: View {
    @ObservedObject var taskViewModel: TaskViewModel

    @State var task: Tasks
    @State var date: Date
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDate: Date = Date()
    @State private var showPreviousDate: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "clock")
                    Text("What time did you complete this task?")
                    Spacer(minLength: 0)
                }
                
                // Pickerで日時を更新した時に元の日時を表示する
                if showPreviousDate {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text("Previous date:")
                            .foregroundColor(.secondary)
                        Text(returnDateTime())
                            .bold()
                            .foregroundColor(.secondary)
                        Spacer(minLength: 0)
                    }
                    .padding(.bottom)
                }
                
                DatePicker("", selection: $selectedDate, in: task.addedDate...Date())
                    .labelsHidden()
                
                Spacer()
            }
            .padding(.horizontal, 10)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    okButton
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
            }
        }
        .onAppear {
            // 画面ロード時にPickerの日時を更新
            selectedDate = date
        }
        .onChange(of: selectedDate) { _ in
            // selectedDateが編集されたときに、元の日付を表示する
            withAnimation {
                if date != selectedDate {
                    showPreviousDate = true
                }
            }
        }
    }
}

extension EditRegularlyTaskHistoryView {
    private var cancelButton: some View {
        Button(action: {
            dismiss()
        }, label: {
            Text("Cancel")
                .foregroundColor(.red)
        })
    }
    
    private var okButton: some View {
        Button(action: {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
            // 変更を保存
            let doneDate = task.doneDate
            guard let dateIndex = doneDate.firstIndex(where: { $0 == date }) else {
                return
            }
            guard let taskIndex = taskViewModel.tasks.firstIndex(where: { $0.id == task.id }) else {
                return
            }
            task.doneDate[dateIndex] = selectedDate
            taskViewModel.tasks[taskIndex] = task
            taskViewModel.saveTasks(tasks: taskViewModel.tasks)
            
            // 表示中のタスクを更新
            withAnimation {
                taskViewModel.selectedTasks = [task]
            }
            
            dismiss()
            
        }, label: {
            Text("OK")
                .bold()
                .foregroundColor(.blue)
        })
    }
    
    // dateのStringを返す 0/0 00:00
    private func returnDateTime() -> String {
        // calendar
        let calendar = Calendar(identifier: .gregorian)
        let dateDC = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        // dateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "HH:mm"
        
        var dateString: String = ""

        // 0/0 00:00
        dateString = "\(dateDC.month!)/\(dateDC.day!) " + dateFormatter.string(from: date)
        
        return dateString
    }
}

//struct EditRegularlyTaskHistoryView_Previews: PreviewProvider {
//    @State static var historyHourSelected: Int = 0
//    @State static var historyMinSelected: Int = 0
//
//    static var previews: some View {
//        EditRegularlyTaskHistoryView(task: Tasks.previewData[0], historyHourSelected: historyHourSelected, historyMinSelected: historyMinSelected)
//    }
//}
