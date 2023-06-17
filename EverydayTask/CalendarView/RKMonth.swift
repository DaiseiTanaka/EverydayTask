//
//  RKMonth.swift
//  RKCalendar
//
//  Created by Raffi Kian on 7/14/19.
//  Copyright © 2019 Raffi Kian. All rights reserved.
//

import SwiftUI

struct RKMonth: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager
    @Binding var isPresented: Bool
    
    
    let monthOffset: Int
    @Binding var tappedBackground: Bool
    
    private let cellWidthPhone = CGFloat(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 7 - 22/7)
    let calendarUnitYMD = Set<Calendar.Component>([.year, .month, .day])
    let daysPerWeek = 7
    var monthsArray: [[Date]] {
        monthArray()
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.center, spacing: 5) {
            Text(getMonthHeader()).foregroundColor(self.rkManager.colors.monthHeaderColor)
            VStack(alignment: .leading, spacing: 3) {
                ForEach(monthsArray, id:  \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(row, id:  \.self) { column in
                            HStack(spacing: 0) {
                                if self.isThisMonth(date: column) {
                                    RKCell(taskViewModel: taskViewModel,
                                           rkDate: RKDate(
                                            date: column,
                                            rkManager: self.rkManager,
                                            isDisabled: !self.isEnabled(date: column),
                                            isToday: self.isToday(date: column),
                                            isSelected: self.isSpecialDate(date: column),
                                            isBetweenStartAndEnd: self.isBetweenStartAndEnd(date: column),
                                            taskCount: taskViewModel.returnTaskCount(date: column),
                                            doneTaskCount: taskViewModel.returnDoneTaskCount(date: column))
                                    )
                                    .frame(width: cellWidthPhone, height: cellWidthPhone*1.5)
                                    .onTapGesture {
                                        self.dateTapped(date: column)
                                    }
                                    .background {
                                        Color(UIColor.systemBackground)
                                            .onTapGesture {
                                                self.dateTapped(date: column)
                                            }
                                    }
                                } else {
                                    // 日付のない空白の部分
                                    VStack {
                                        Text(" ")
                                            .frame(width: cellWidthPhone, height: cellWidthPhone*1.5)
                                        Spacer()
                                    }
                                    // 余白をタップしたら、現在の日付を選択し、カレンダーを下までスクロールする
                                    .onTapGesture {
                                        rkManager.selectedDate = Date()
                                        tappedBackground.toggle()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .background(
            rkManager.colors.monthBackColor
        )
        .onTapGesture {
            rkManager.selectedDate = Date()
        }
    }
    
    func dateTapped(date: Date) {
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()
        
        withAnimation {
            if self.rkManager.calendar.isDate(self.rkManager.selectedDate, inSameDayAs: date) {
                self.rkManager.selectedDate = Date()
            } else {
                if taskViewModel.isSameDay(date1: date, date2: Date()) {
                    self.rkManager.selectedDate = Date()
                } else {
                    self.rkManager.selectedDate = date
                }
            }
        }
        //print(rkManager.selectedDate)
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    func isThisMonth(date: Date) -> Bool {
        return self.rkManager.calendar.isDate(date, equalTo: firstOfMonthForOffset(), toGranularity: .month)
    }
    
    func monthArray() -> [[Date]] {
        var rowArray = [[Date]]()
        for row in 0 ..< (numberOfDays(offset: monthOffset) / 7) {
            var columnArray = [Date]()
            for column in 0 ... 6 {
                let abc = self.getDateAtIndex(index: (row * 7) + column)
                columnArray.append(abc)
            }
            rowArray.append(columnArray)
        }
        return rowArray
    }
    
    func getMonthHeader() -> String {
        let headerDateFormatter = DateFormatter()
        headerDateFormatter.calendar = rkManager.calendar
        //headerDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy MM月", options: 0, locale: rkManager.calendar.locale)
        
        headerDateFormatter.dateFormat = "yyyy年 MM月"
        return headerDateFormatter.string(from: firstOfMonthForOffset()).uppercased()
    }
    
    func getDateAtIndex(index: Int) -> Date {
        let firstOfMonth = firstOfMonthForOffset()
        let weekday = rkManager.calendar.component(.weekday, from: firstOfMonth)
        var startOffset = weekday - rkManager.calendar.firstWeekday
        startOffset += startOffset >= 0 ? 0 : daysPerWeek
        var dateComponents = DateComponents()
        dateComponents.day = index - startOffset
        
        return rkManager.calendar.date(byAdding: dateComponents, to: firstOfMonth)!
    }
    
    func numberOfDays(offset : Int) -> Int {
        let firstOfMonth = firstOfMonthForOffset()
        let rangeOfWeeks = rkManager.calendar.range(of: .weekOfMonth, in: .month, for: firstOfMonth)
        
        return (rangeOfWeeks?.count)! * daysPerWeek
    }
    
    func firstOfMonthForOffset() -> Date {
        var offset = DateComponents()
        offset.month = monthOffset
        
        return rkManager.calendar.date(byAdding: offset, to: RKFirstDateMonth())!
    }
    
    func RKFormatDate(date: Date) -> Date {
        let components = rkManager.calendar.dateComponents(calendarUnitYMD, from: date)
        
        return rkManager.calendar.date(from: components)!
    }
    
    func RKFormatAndCompareDate(date: Date, referenceDate: Date) -> Bool {
        let refDate = RKFormatDate(date: referenceDate)
        let clampedDate = RKFormatDate(date: date)
        return refDate == clampedDate
    }
    
    func RKFirstDateMonth() -> Date {
        var components = rkManager.calendar.dateComponents(calendarUnitYMD, from: rkManager.minimumDate)
        components.day = 1
        
        return rkManager.calendar.date(from: components)!
    }
    
    // MARK: - Date Property Checkers
    
    func isToday(date: Date) -> Bool {
        return RKFormatAndCompareDate(date: date, referenceDate: Date())
    }
    
    func isSpecialDate(date: Date) -> Bool {
        return isSelectedDate(date: date) ||
        isStartDate(date: date) ||
        isEndDate(date: date) ||
        isOneOfSelectedDates(date: date)
    }
    
    func isOneOfSelectedDates(date: Date) -> Bool {
        return self.rkManager.selectedDatesContains(date: date)
    }
    
    func isSelectedDate(date: Date) -> Bool {
        if rkManager.selectedDate == nil {
            return false
        }
        return RKFormatAndCompareDate(date: date, referenceDate: rkManager.selectedDate)
    }
    
    func isStartDate(date: Date) -> Bool {
        if rkManager.startDate == nil {
            return false
        }
        return RKFormatAndCompareDate(date: date, referenceDate: rkManager.startDate)
    }
    
    func isEndDate(date: Date) -> Bool {
        if rkManager.endDate == nil {
            return false
        }
        return RKFormatAndCompareDate(date: date, referenceDate: rkManager.endDate)
    }
    
    func isBetweenStartAndEnd(date: Date) -> Bool {
        if rkManager.startDate == nil {
            return false
        } else if rkManager.endDate == nil {
            return false
        } else if rkManager.calendar.compare(date, to: rkManager.startDate, toGranularity: .day) == .orderedAscending {
            return false
        } else if rkManager.calendar.compare(date, to: rkManager.endDate, toGranularity: .day) == .orderedDescending {
            return false
        }
        return true
    }
    
    func isOneOfDisabledDates(date: Date) -> Bool {
        return self.rkManager.disabledDatesContains(date: date)
    }
    
    func isEnabled(date: Date) -> Bool {
        let clampedDate = RKFormatDate(date: date)
        if rkManager.calendar.compare(clampedDate, to: rkManager.minimumDate, toGranularity: .day) == .orderedAscending || rkManager.calendar.compare(clampedDate, to: rkManager.maximumDate, toGranularity: .day) == .orderedDescending {
            return false
        }
        return !isOneOfDisabledDates(date: date)
    }
    
    func isStartDateAfterEndDate() -> Bool {
        if rkManager.startDate == nil {
            return false
        } else if rkManager.endDate == nil {
            return false
        } else if rkManager.calendar.compare(rkManager.endDate, to: rkManager.startDate, toGranularity: .day) == .orderedDescending {
            return false
        }
        return true
    }
}

#if DEBUG
//struct RKMonth_Previews : PreviewProvider {
//    static var previews: some View {
//        RKMonth(isPresented: .constant(false),rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 0), monthOffset: 0)
//    }
//}
#endif

