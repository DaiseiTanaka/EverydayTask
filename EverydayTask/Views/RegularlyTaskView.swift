//
//  WeeklyAndMonthlyDetailListView.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/12.
//

import SwiftUI

struct RegularlyTaskView: View {
    
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager
    
    var task: Tasks
    
    private let cellOpacity: CGFloat = 0.5
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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 5) {
                        title
                        
                        detail
                    }
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing) {
                        Spacer()
                        span
                    }
                }
                .padding(.bottom, 15)
                
                taskList
                
                ZStack { }
                .frame(height: 400)
            }
            .padding(.horizontal, 10)
        }
    }
}

extension RegularlyTaskView {
    private var title: some View {
        Text(task.title != "" ? task.title : " (No title) ")
            .font(.title.bold())
    }
    
    private var detail: some View {
        VStack(alignment: .leading) {
            Text(task.detail)
                .font(.body)
                .foregroundColor(.secondary)
            // もしもタスクの実施履歴がなかった場合
            if task.doneDate.isEmpty {
                Text("No data.")
                    .font(.title3.bold())
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var span: some View {
        HStack(spacing: 3) {
            Spacer()
            if task.spanType == .everyWeekday {
                spanImage
                
            } else if task.spanType == .custom {
                Text("\(task.doCount) /")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(LocalizedStringKey(task.span.spanString))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            } else {
                Text(LocalizedStringKey(taskViewModel.returnSpanToString(span: task.spanType)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: 150)
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
    
    private var taskList: some View {
        ForEach(Array(task.doneDate.enumerated()), id: \.offset) { index, date in
            if task.spanType == .custom {
                HStack(alignment: .bottom) {
                    // リストの先頭には必ず日付を表示
                    if index == 0 {
                        Text(returnHeaderDateString(date: date))
                            .font(.title3.bold())
                            .padding(.leading, 5)
                            .padding(.bottom, 5)
                        Spacer()
                        Text("\(task.doCount - taskViewModel.returnRemainCustomTaskCount(task: task, date: date))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)
                        Text((task.doCount - taskViewModel.returnRemainCustomTaskCount(task: task, date: date)) == 1 ? "item" : "items")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.trailing, 5)
                            .padding(.bottom, 5)
                        // doneDate[index]とdoneDate[index-1]がそれぞれ違うスパンに属する時日付を表示
                    } else if showHeader(prevDate: date, date: task.doneDate[index - 1]) {
                        Text(returnHeaderDateString(date: date))
                            .font(.title3.bold())
                            .padding(.leading, 5)
                            .padding(.bottom, 5)
                        Spacer()
                        Text("\(task.doCount - taskViewModel.returnRemainCustomTaskCount(task: task, date: date))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)
                        Text((task.doCount - taskViewModel.returnRemainCustomTaskCount(task: task, date: date)) == 1 ? "item" : "items")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.trailing, 5)
                            .padding(.bottom, 5)
                    }
                }
            }
            
            RegularlyTaskCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, date: date)
            
            Rectangle()
                .foregroundColor(returnContinuousCondition(index: index, task: task) ? returnCellBackgroundColor(opacity: cellOpacity) : .clear)
                .frame(width: 5, height: returnContinuousCondition(index: index, task: task) ? 13 : 20)
        }
    }
    
    // Cellの背景色を返す
    private func returnCellBackgroundColor(opacity: CGFloat) -> Color {
        let colorString: String = task.accentColor
        let color: Color = taskViewModel.returnColor(color: colorString).opacity(opacity)

        return color
    }
    
    // 日付をセルの上に表示する日付を返す
    private func returnHeaderDateString(date: Date) -> String {
        let spanType = task.spanType
        let span = task.span
        var calendar = Calendar(identifier: .gregorian)
        let dayDC = calendar.dateComponents([.year, .month, .day], from: date)
        
        let dateFormatter = DateFormatter()
        
        if spanType == .everyWeek {
            return returnWeekString(date: date)
            
        } else if spanType == .everyMonth {
            dateFormatter.dateFormat = "MMMM"
            return dateFormatter.string(from: date)
            
        } else if spanType == .custom {
            switch span {
            case .day:
                return "\(dayDC.month!)/\(dayDC.day!)"
                
            case .week:
                return returnWeekString(date: date)
                
            case .month:
                dateFormatter.dateFormat = "MMMM"
                return dateFormatter.string(from: date)
                
            case .year:
                return "\(dayDC.year!)"
                
            case .infinite:
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .none
                return dateFormatter.string(from: date) + " ~"
            }
        }
        
        return ""
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
    
    // 日付をセルの上に表示するかどうかのBoolを返す　true: 表示する
    private func showHeader(prevDate: Date, date: Date) -> Bool {
        let spanType = task.spanType
        let span = task.span
        
        if spanType == .everyWeek {
            if !taskViewModel.isSameWeek(date1: prevDate, date2: date) {
                return true
            }
        } else if spanType == .everyMonth {
            if !taskViewModel.isSameMonth(date1: prevDate, date2: date) {
                return true
            }
        } else if spanType == .custom {
            switch span {
            case .day:
                if !taskViewModel.isSameDay(date1: prevDate, date2: date) {
                    return true
                }
            case .week:
                if !taskViewModel.isSameWeek(date1: prevDate, date2: date) {
                    return true
                }
            case .month:
                if !taskViewModel.isSameMonth(date1: prevDate, date2: date) {
                    return true
                }
            case .year:
                if !taskViewModel.isSameYear(date1: prevDate, date2: date) {
                    return true
                }
            case .infinite:
                return false
            }
        }
        
        return false
    }

    // Cellの間のラインが繋がるかどうかのBoolを返す　→ true: 表示する
    private func returnContinuousCondition(index: Int, task: Tasks) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let doneDate = task.doneDate.sorted()
        let span = task.span
        // 最後の一個はつけない
        if index == doneDate.count - 1 {
            return false
        }
        let date = doneDate[index]
        let nextDate = doneDate[index+1]
        let dateDC = calendar.dateComponents([.year, .month, .weekOfYear, .day], from: date)
        let nextDateDC = calendar.dateComponents([.year, .month, .weekOfYear, .day], from: nextDate)
        // 同期間か判定
        let sameYear = dateDC.year == nextDateDC.year
        let sameMonth = nextDateDC.month! == dateDC.month!
        let sameWeek = nextDateDC.weekOfYear! == dateDC.weekOfYear!
        let sameDay = nextDateDC.day! == dateDC.day!
        
        switch task.spanType {
        case .everyWeek:
            let weekDC = calendar.component(.weekOfYear, from: date)
            let nextWeekDC = calendar.component(.weekOfYear, from: nextDate)
            let weekDiff = nextWeekDC - weekDC
            if weekDiff == 1 {
                return true
            }
            
        case .everyMonth:
            let dayDC = Calendar.current.dateComponents([.year, .month], from: date)
            let nextDayDC = Calendar.current.dateComponents([.year, .month], from: nextDate)
            let sameYear: Bool = dayDC.year == nextDayDC.year
            let dayDiff = nextDayDC.month! - dayDC.month!
            // 1ヶ月差かつ同じ年
            if dayDiff == 1 && sameYear {
                return true
            }
        case .custom:
            switch span {
            case .day:
                if sameYear && sameMonth && sameWeek && sameDay {
                    return true
                }
            case .week:
                if sameYear && sameMonth && sameWeek {
                    return true
                }
            case .month:
                if sameYear && sameMonth {
                    return true
                }
            case .year:
                if sameYear {
                    return true
                }
            case .infinite:
                return true
            }
            
        default:
            return false
        }
        
        return false
    }
}

struct WeeklyAndMonthlyDetailListView_Previews: PreviewProvider {
    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)

    static var previews: some View {
        Group {
            RegularlyTaskView(taskViewModel: TaskViewModel(), rkManager: rkManager, task: Tasks.previewData[2])
            RegularlyTaskView(taskViewModel: TaskViewModel(), rkManager: rkManager, task: Tasks.previewData[3])
        }
    }
}