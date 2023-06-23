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
        VStack {
            Text(task.detail)
                .font(.title3)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            // もしもタスクの実施履歴がなかった場合
            if task.doneDate.isEmpty {
                Text("No data.")
                    .font(.title3.bold())
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var taskList: some View {
        ForEach(Array(task.doneDate.enumerated()), id: \.element) { index, date in
            WeeklyAndMonthlyDetailListCell(taskViewModel: taskViewModel, rkManager: rkManager, task: task, date: date)
            HStack {
                Spacer()
                Rectangle()
                    .foregroundColor(returnContinuousCondition(index: index, task: task) ? returnCellBackgroundColor(opacity: cellOpacity) : .clear)
                    .frame(width: 5, height: returnContinuousCondition(index: index, task: task) ? 13 : 20)
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
    private func returnContinuousCondition(index: Int, task: Tasks) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let doneDate = task.doneDate.sorted()
        if index == doneDate.count - 1 {
            return false
        }
        let date = doneDate[index]
        let nextDate = doneDate[index+1]
        
        switch task.spanType {
        case .everyWeek:
            let weekDC = calendar.component(.weekOfYear, from: date)
            let nextWeekDC = calendar.component(.weekOfYear, from: nextDate)
            let weekDiff = nextWeekDC - weekDC
            if weekDiff != 1 {
                return false
            }
            
        case .everyMonth:
            let dayDC = Calendar.current.dateComponents([.year, .month], from: date)
            let nextDayDC = Calendar.current.dateComponents([.year, .month], from: nextDate)
            let sameYear: Bool = dayDC.year == nextDayDC.year
            let dayDiff = nextDayDC.month! - dayDC.month!
            // 1ヶ月差かつ同じ年
            if dayDiff != 1 || !sameYear{
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
