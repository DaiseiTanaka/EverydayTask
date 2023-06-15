//
//  WeeklyAndMonthlyDetailListView.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/12.
//

import SwiftUI

struct WeeklyAndMonthlyDetailListView: View {
    
    @ObservedObject var taskViewModel: TaskViewModel
    
    var task: Tasks
    
    private let cellHeight: CGFloat = 70
    private let cellOpacity: CGFloat = 0.5
    private let cellCornerRadius: CGFloat = 10
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Text(task.title)
                    .font(.title.bold())
                    .padding(.bottom, 5)
                Text(task.detail)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                ForEach(Array(task.doneDate.enumerated()), id: \.element) { index, date in
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .font(.title)
                            .foregroundColor(taskViewModel.returnColor(color: task.accentColor))
                        Spacer()
                    }
                    .frame(height: cellHeight)
                    .background(returnCellBackgroundColor(opacity: cellOpacity).cornerRadius(cellCornerRadius)                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3))
                    .padding(.horizontal, 10)
                    .overlay(alignment: .topLeading) {
                        VStack {
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
                        .padding(.top, 5)
                        .padding(.leading, 15)
                        .padding(.bottom, 5)
                    }
                    
                    HStack {
                        Spacer()
                        Rectangle()
                            .foregroundColor(returnContinuousCondition(index: index, date: date) ? returnCellBackgroundColor(opacity: cellOpacity) : .clear)
                            .frame(width: 5, height: returnContinuousCondition(index: index, date: date) ? 13 : 20)
                        Spacer()
                    }
                }
            }
        }
        
    }
}

extension WeeklyAndMonthlyDetailListView {
    // Cellの背景色を返す
    private func returnCellBackgroundColor(opacity: CGFloat) -> Color {
        let colorString: String = task.accentColor
        let color: Color = taskViewModel.returnColor(color: colorString).opacity(opacity)

        return color
    }
    
    // Cellの間のラインが繋がるかどうかのBoolを返す　→ true: 表示する
    private func returnContinuousCondition(index: Int, date: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        
        if index == task.doneDate.count - 1 {
            return false
        }
        
        switch task.spanType {
        case .everyWeek:
            let weekDC = calendar.component(.weekOfYear, from: date)
            let nextWeekDC = calendar.component(.weekOfYear, from: task.doneDate[index + 1])
            let weekDiff = nextWeekDC - weekDC
            if weekDiff != 1 {
                return false
            }
            
        case .everyMonth:
            let dayDC = Calendar.current.dateComponents([.month, .day], from: date)
            let nextDayDC = Calendar.current.dateComponents([.month, .day], from: task.doneDate[index + 1])
            let dayDiff = nextDayDC.month! - dayDC.month!
            if dayDiff != 1 {
                return false
            }
            
        default:
            return true
        }
        
        
        return true
    }
    
    // 入力された日付の属する週の初めの日と、最後の日をString型（0/0 ~ 0/0）で返す
    private func returnStartAndEndDate(date: Date, spanType: TaskSpanType) -> String {
        switch spanType {
        case .everyWeek:
            return returnWeekFirstDayString(date: date) + " ~ " + returnWeekLastDayString(date: date)
            
        case .everyMonth:
            return returnMonthString(date: date)
            
        default:
            return ""
        }
    }
    
    private func returnWeekFirstDayString(date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        // weekdayIndexから1を引き、その週の初めの日までの日数の差を出す
        let weekdayIndex: Int = taskViewModel.returnWeekdayFromDate(date: date) - 1
        // その週の最初の日
        let returnDate = date.addingTimeInterval(TimeInterval(-60*60*24*weekdayIndex))
        let dayDC = Calendar.current.dateComponents([.month, .day], from: returnDate)
        let month: String = String(dayDC.month!)
        let day: String = String(dayDC.day!)
        
        return month + "/" + day
    }
    
    private func returnWeekLastDayString(date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        // 7からweekdayIndexを引き、その週の最後の日までの日数の差を出す
        let weekdayIndex: Int = 7 - taskViewModel.returnWeekdayFromDate(date: date)
        // その週の最後の日
        let returnDate = date.addingTimeInterval(TimeInterval(60*60*24*weekdayIndex))
        let dayDC = Calendar.current.dateComponents([.month, .day], from: returnDate)
        let month: String = String(dayDC.month!)
        let day: String = String(dayDC.day!)
        
        return month + "/" + day
    }
    
    private func returnMonthString(date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let dayDC = Calendar.current.dateComponents([.month], from: date)
        let month: String = String(dayDC.month!)
        
        return month + "月"
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
}

struct WeeklyAndMonthlyDetailListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeeklyAndMonthlyDetailListView(taskViewModel: TaskViewModel(), task: Tasks.previewData[2])
            WeeklyAndMonthlyDetailListView(taskViewModel: TaskViewModel(), task: Tasks.previewData[3])
        }
    }
}
