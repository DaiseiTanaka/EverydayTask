//
//  RKDate.swift
//  RKCalendar
//
//  Created by Raffi Kian on 7/14/19.
//  Copyright © 2019 Raffi Kian. All rights reserved.
//

import SwiftUI

struct RKDate {
    
    var date: Date
    let rkManager: RKManager
    
    var isDisabled: Bool = false
    var isToday: Bool = false
    var isSelected: Bool = false
    var isBetweenStartAndEnd: Bool = false
    var taskCount: Int = 0
    var doneTaskCount: Int = 0
    
    init(date: Date, rkManager: RKManager, isDisabled: Bool, isToday: Bool, isSelected: Bool, isBetweenStartAndEnd: Bool, taskCount: Int, doneTaskCount: Int) {
        self.date = date
        self.rkManager = rkManager
        self.isDisabled = isDisabled
        self.isToday = isToday
        self.isSelected = isSelected
        self.isBetweenStartAndEnd = isBetweenStartAndEnd
        self.taskCount = taskCount
        self.doneTaskCount = doneTaskCount
    }

    func returnPercentage() -> Int {
        var rate: Double = 0
        if taskCount != 0 {
            rate = Double(doneTaskCount) / Double(taskCount)
        }
        let percentage = Int(rate * 100)
        return percentage
    }
    
    func returnRectangleHeight() -> CGFloat {
        let maxHeight: CGFloat = 55
        let minHeight: CGFloat = 0
        var height: CGFloat = 0
        if taskCount != 0 {
            let stepHeight: CGFloat = (maxHeight - minHeight) / CGFloat(taskCount)
            height = stepHeight * CGFloat(doneTaskCount) + minHeight
        }
        return height
    }
    
    func getText() -> String {
        let day = formatDate(date: date, calendar: self.rkManager.calendar)
        return day
    }
    
    func getTextColor() -> Color {
        var textColor = rkManager.colors.textColor
        if isDisabled {
            textColor = rkManager.colors.disabledColor
        } else if isSelected {
            textColor = rkManager.colors.selectedColor
        } else if isToday {
            textColor = rkManager.colors.todayColor
        } else if isBetweenStartAndEnd {
            textColor = rkManager.colors.betweenStartAndEndColor
        }
        return textColor
    }
    
    func getBackgroundColor() -> Color {
        var backgroundColor = rkManager.colors.textBackColor
        if isBetweenStartAndEnd {
            backgroundColor = rkManager.colors.betweenStartAndEndBackColor
        }
        if isToday {
            backgroundColor = rkManager.colors.todayBackColor
        }
        if isDisabled {
            backgroundColor = rkManager.colors.disabledBackColor
        }
        if isSelected {
            backgroundColor = rkManager.colors.selectedBackColor
        }
        return backgroundColor
    }
    
    func getFontWeight() -> Font.Weight {
        var fontWeight = Font.Weight.medium
        if isDisabled {
            fontWeight = Font.Weight.thin
        } else if isSelected {
            fontWeight = Font.Weight.heavy
        } else if isToday {
            fontWeight = Font.Weight.heavy
        } else if isBetweenStartAndEnd {
            fontWeight = Font.Weight.heavy
        }
        return fontWeight
    }
    
    // MARK: - Date Formats
    
    func formatDate(date: Date, calendar: Calendar) -> String {
        let formatter = dateFormatter()
        return stringFrom(date: date, formatter: formatter, calendar: calendar)
    }
    
    func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "d"
        return formatter
    }
    
    func stringFrom(date: Date, formatter: DateFormatter, calendar: Calendar) -> String {
        if formatter.calendar != calendar {
            formatter.calendar = calendar
        }
        return formatter.string(from: date)
    }
}

