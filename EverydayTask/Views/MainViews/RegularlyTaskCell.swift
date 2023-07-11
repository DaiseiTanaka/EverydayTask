//
//  WeeklyAndMonthlyDetailListCell.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/12.
//

import SwiftUI

struct RegularlyTaskCell: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager

    var task: Tasks
    var date: Date
        
    let generator = UINotificationFeedbackGenerator()
    private let cellHeight: CGFloat = 40
    private let cellOpacity: CGFloat = 1.0
    private let cellCornerRadius: CGFloat = 7
    
    
    var body: some View {
        ZStack {
            taskDetail
        }
        .frame(height: cellHeight)
        .background(
            returnCellBackgroundColor(opacity: cellOpacity)
                .cornerRadius(cellCornerRadius)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
        )
        .onTapGesture {
            tappedCellAction()
        }
        .onLongPressGesture() {
            generator.notificationOccurred(.success)
            showEditAlart()
        }
    }
}

extension RegularlyTaskCell {
    
    private var taskDetail: some View {
        VStack {
            HStack(spacing: 5) {
                Image(systemName: "checkmark.circle")
                    .font(.title)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .opacity(taskViewModel.isDone(task: task, date: date) ? 1.0 : 0.2)
                
                Spacer(minLength: 5)
                
                Image(systemName: "clock")
                    .foregroundColor(Color(UIColor.systemBackground))
                    .font(.subheadline)
                Text(returnDateTime(date: date))
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.systemBackground))
                
                Button {
                    showEditAlart()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBackground))
                }
            }
        }
        .padding(5)
    }
    
    // Cellの背景色を返す
    private func returnCellBackgroundColor(opacity: CGFloat) -> Color {
        let colorString: String = task.accentColor
        let color: Color = taskViewModel.returnColor(color: colorString).opacity(opacity)

        return color
    }
    
    // dateのStringを返す 0/0 00:00
    private func returnDateTime(date: Date) -> String {
        let span = task.span
        // calendar
        let calendar = Calendar(identifier: .gregorian)
        let dateDC = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        // dateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "HH:mm"
        
        var dateString: String = ""

        if span == .day {
            // 00:00
            dateString = dateFormatter.string(from: date)
                        
        } else {
            // 0/0 00:00
            dateString = "\(dateDC.month!)/\(dateDC.day!) " + dateFormatter.string(from: date)
        }
        
        return dateString
    }
    
    private func tappedCellAction() {
        if !taskViewModel.isSameDay(date1: date, date2: rkManager.selectedDate) {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
        }
        withAnimation {
            // 選択中の日付が今日の時は、selectedDateを更新
            // これがないと、リストから今日を選択した時に、選択したタスクの日時がselectedDateに反映されてしまう
            if taskViewModel.isSameDay(date1: date, date2: Date()) {
                rkManager.selectedDate = Date()
            } else {
                rkManager.selectedDate = date
            }
        }
    }
    
    private func showEditAlart() {
        // 選択中の履歴の詳細を取得し、保存する
        taskViewModel.editTask = task
        taskViewModel.selectedRegularlyTaskDate = date
        taskViewModel.showEditRegularlyTaskAlart = true
    }
}

//struct WeeklyAndMonthlyDetailListCell_Previews: PreviewProvider {
//    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)
//
//    static var previews: some View {
//        RegularlyTaskCell(taskViewModel: TaskViewModel(), rkManager: rkManager, task: Tasks.previewData[0], date: Date(), index: 1)
//    }
//}
