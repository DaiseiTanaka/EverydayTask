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
    private let cellHeight: CGFloat = 70
    private let cellOpacity: CGFloat = 1.0
    private let cellCornerRadius: CGFloat = 7
    
    
    var body: some View {
        ZStack {
            taskDetail
            
            if task.spanType != .custom {
                Image(systemName: "checkmark.circle")
                    .font(.title)
                    .foregroundColor(Color(UIColor.systemBackground))
            }
        }
        .frame(height: task.spanType == .custom ? 40 : cellHeight)
        .background(
            returnCellBackgroundColor(opacity: cellOpacity)
                .cornerRadius(cellCornerRadius)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
        )
        .onTapGesture {
            tappedCellAction()
        }
        .onLongPressGesture() {
            showEditAlart()
        }
    }
}

extension RegularlyTaskCell {
    
    private var taskDetail: some View {
        VStack {
            if task.spanType == .custom {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle")
                        .font(.title)
                        .foregroundColor(Color(UIColor.systemBackground))
                    
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
                
            } else {
                HStack {
                    Text(returnStartAndEndDate(date: date, spanType: task.spanType))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Spacer()
                HStack {
                    Image(systemName: "calendar.circle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text(returnDayString(date: date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
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
    
    // dateのStringを返す
    private func returnDateTime(date: Date) -> String {
        let span = task.span
        // calendar
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
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
    
    // 入力された日付の属する週の初めの日と、最後の日をString型（0/0 ~ 0/0）で返す
    private func returnStartAndEndDate(date: Date, spanType: TaskSpanType) -> String {
        switch spanType {
        case .everyWeek:
            return returnWeekString(date: date)
            
        case .everyMonth:
            return returnMonthString(date: date)
            
        default:
            return ""
        }
    }
    
    // 週の最初の日から最後の日までのStringを返す　0/0 ~ 0/0
    private func returnWeekString(date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        // weekdayIndexから1を引き、その週の初めの日までの日数の差を出す
        let firstWeekdayIndex: Int = taskViewModel.returnWeekdayFromDate(date: date) - 1
        // その週の最初の日
        let firstReturnDate = date.addingTimeInterval(TimeInterval(-60*60*24*firstWeekdayIndex))
        let firstDayDC = Calendar.current.dateComponents([.month, .day], from: firstReturnDate)
        let firstMonth: String = String(firstDayDC.month!)
        let firstDay: String = String(firstDayDC.day!)
        
        // 7からweekdayIndexを引き、その週の最後の日までの日数の差を出す
        let lastWeekdayIndex: Int = 7 - taskViewModel.returnWeekdayFromDate(date: date)
        // その週の最後の日
        let lastReturnDate = date.addingTimeInterval(TimeInterval(60*60*24*lastWeekdayIndex))
        let lastDayDC = Calendar.current.dateComponents([.month, .day], from: lastReturnDate)
        let lastMonth: String = String(lastDayDC.month!)
        let lastDay: String = String(lastDayDC.day!)
        
        return firstMonth + "/" + firstDay + " ~ " + lastMonth + "/" + lastDay
    }
    
    private func returnMonthString(date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let dayDC = Calendar.current.dateComponents([.month], from: date)
        let month: String = String(dayDC.month!)
        
        return month + "/1 ~"
    }
    
    // Date -> 0/0
    private func returnDayString(date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let dayDC = Calendar.current.dateComponents([.month, .day], from: date)
        let month: String = String(dayDC.month!)
        let day: String = String(dayDC.day!)
        
        return month + "/" + day
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
        generator.notificationOccurred(.success)

        taskViewModel.editTask = task
        taskViewModel.selectedRegularlyTaskDate = date
        taskViewModel.showEditRegularlyTaskAlart = true
    }
}

struct WeeklyAndMonthlyDetailListCell_Previews: PreviewProvider {
    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)

    static var previews: some View {
        RegularlyTaskCell(taskViewModel: TaskViewModel(), rkManager: rkManager, task: Tasks.previewData[0], date: Date())
    }
}
