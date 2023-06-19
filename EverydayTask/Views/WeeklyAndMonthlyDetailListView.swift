//
//  WeeklyAndMonthlyDetailListView.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/12.
//

import SwiftUI

struct WeeklyAndMonthlyDetailListView: View {
    
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager
    
    var task: Tasks
    
    private let cellOpacity: CGFloat = 0.5
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                title
                
                detail
                
                taskList
            }
        }
    }
}

extension WeeklyAndMonthlyDetailListView {
    private var title: some View {
        Text(task.title)
            .font(.title.bold())
            .padding(.bottom, 5)
    }
    
    private var detail: some View {
        Text(task.detail)
            .font(.title3)
            .foregroundColor(.secondary)
            .padding(.bottom, 10)
    }
    
    private var taskList: some View {
        ForEach(Array(task.doneDate.enumerated()), id: \.element) { index, date in
            WeeklyAndMonthlyDetailListCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, date: date)
            HStack {
                Spacer()
                Rectangle()
                    .foregroundColor(returnContinuousCondition(index: index, date: date) ? returnCellBackgroundColor(opacity: cellOpacity) : .clear)
                    .frame(width: 5, height: returnContinuousCondition(index: index, date: date) ? 13 : 20)
                Spacer()
            }
        }
    }
    
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
}

struct WeeklyAndMonthlyDetailListView_Previews: PreviewProvider {
    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)

    static var previews: some View {
        Group {
            WeeklyAndMonthlyDetailListView(taskViewModel: TaskViewModel(), rkManager: rkManager, task: Tasks.previewData[2])
            WeeklyAndMonthlyDetailListView(taskViewModel: TaskViewModel(), rkManager: rkManager, task: Tasks.previewData[3])
        }
    }
}
