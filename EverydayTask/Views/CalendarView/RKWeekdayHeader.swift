//
//  RKWeekdayHeader.swift
//  RKCalendar
//
//  Created by Raffi Kian on 7/14/19.
//  Copyright © 2019 Raffi Kian. All rights reserved.
//

import SwiftUI

struct RKWeekdayHeader : View {
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager
    
    @State var showSideMenuButton: Bool
     
    var body: some View {
        VStack {
            HStack {
                if showSideMenuButton {
                    // メニューボタン
                    sideMenuButton
                }
                
                Spacer()
                
                // 今日の日付へ移動
                // selectedDateが今日以外の時 or 特定のタスクを選択中の時
//                if !taskViewModel.isSameDay(date1: rkManager.selectedDate, date2: Date()) || taskViewModel.selectedTasks != taskViewModel.tasks{
//                    resetCalendarButton
//                }
            }
            
            weeks
        }
        .background(.ultraThinMaterial)
    }
}

extension RKWeekdayHeader {
    private var sideMenuButton: some View {
        Button(action: {
            withAnimation {
                taskViewModel.showSidebar.toggle()
                if taskViewModel.showHalfModal {
                    taskViewModel.showHalfModal = false
                } else {
                    taskViewModel.showHalfModal = true
                }
            }
        }) {
            Image(systemName: "line.horizontal.3")
                .font(.title)
                .foregroundColor(.secondary)
                .padding(.leading, 7)
                .padding(.bottom, 3)
        }
    }
    
//    private var resetCalendarButton: some View {
//        Button {
//            withAnimation {
//                rkManager.selectedDate = Date()
//                taskViewModel.selectedTasks = taskViewModel.tasks
//            }
//        } label: {
//            Image(systemName: "calendar.badge.clock")
//                .font(.title2)
//                .foregroundColor(.secondary)
//                .padding(.trailing, 10)
//        }
//    }
    
    private var weeks: some View {
        HStack(alignment: .center) {
            ForEach(self.getWeekdayHeaders(calendar: self.rkManager.calendar), id: \.self) { weekday in
                Text(weekday)
                    .font(.system(size: 15))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(self.rkManager.colors.weekdayHeaderColor)
            }
        }
    }
    
    private func getWeekdayHeaders(calendar: Calendar) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        var weekdaySymbols = formatter.shortStandaloneWeekdaySymbols
        let weekdaySymbolsCount = weekdaySymbols?.count ?? 0
        
        for _ in 0 ..< (1 - calendar.firstWeekday + weekdaySymbolsCount){
            let lastObject = weekdaySymbols?.last
            weekdaySymbols?.removeLast()
            weekdaySymbols?.insert(lastObject!, at: 0)
        }
        
        return weekdaySymbols ?? []
    }
}


#if DEBUG
struct RKWeekdayHeader_Previews : PreviewProvider {
    static var previews: some View {
        RKWeekdayHeader(taskViewModel: TaskViewModel(), rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 0), showSideMenuButton: true)
    }
}
#endif

