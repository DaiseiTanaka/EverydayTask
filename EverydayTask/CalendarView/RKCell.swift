//
//  RKCell.swift
//  RKCalendar
//
//  Created by Raffi Kian on 7/14/19.
//  Copyright © 2019 Raffi Kian. All rights reserved.
//

import SwiftUI

struct RKCell: View {
    @ObservedObject var taskViewModel: TaskViewModel
    
    var rkDate: RKDate
    
    var cellWidth: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(rkDate.getText())
                    .fontWeight(rkDate.getFontWeight())
                    .foregroundColor(rkDate.getTextColor())
                    .font(.system(size: 12))
            }
            .frame(maxWidth: .infinity)
            .background(rkDate.getBackgroundColor())
            
            Spacer(minLength: 0)
            
            // 当日の全てのタスクを表示中
            if taskViewModel.selectedTasks.count != 1 {
                ZStack {
                    VStack {
                        Spacer(minLength: 0)
                        returnTaskAccentColor()
                            .cornerRadius(5)
                            .frame(maxHeight: rkDate.returnRectangleHeight())
                    }
                    
                    if rkDate.returnPercentage() != 0 {
                        VStack {
                            Spacer()
                            Text("\(rkDate.returnPercentage())%")
                                .foregroundColor(.white)
                                .font(.footnote.bold())
                            // 1/1は表示しない
//                            if rkDate.taskCount > 1 {
                            // 分数を表示
//                                Text("\(rkDate.doneTaskCount)/\(rkDate.taskCount)")
//                                    .foregroundColor(.white)
//                                    .font(.footnote.bold())
//                                    .padding(.bottom, 2)
//                            }
                        }
                    }
                }
            // 特定のタスクを選択中
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if rkDate.returnPercentage() != 0 {
                            Image(systemName: "checkmark.circle")
                                .font(.title)
                                .foregroundColor(returnTaskAccentColor())
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            
        }
        .frame(width: cellWidth, height: cellWidth*1.5)
    }
    
    private func returnTaskAccentColor() -> Color {
        // 全てのタスクを表示中
        if taskViewModel.selectedTasks.count != 1 {
            // タスクの達成割合に応じて色を変化
            let percentage = rkDate.returnPercentage()
            if percentage <= 20 {
                return Color.red
            } else if percentage <= 40 {
                return Color.orange
            } else if percentage <= 60 {
                return Color.yellow
            } else if percentage <= 80 {
                return Color.green
            } else {
                return Color.blue
            }
        // 特定のタスクを表示中
        } else {
            let colorString = taskViewModel.selectedTasks[0].accentColor
            let color = taskViewModel.returnColor(color: colorString)
            return color
        }
    }
    
}

#if DEBUG
//struct RKCell_Previews : PreviewProvider {
//    static var previews: some View {
//        Group {
//            RKCell(rkDate: RKDate(date: Date(), rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 0), isDisabled: false, isToday: false, isSelected: false, isBetweenStartAndEnd: false), cellWidth: CGFloat(32), runtime: 40)
//                .previewDisplayName("Control")
//            RKCell(rkDate: RKDate(date: Date(), rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 0), isDisabled: true, isToday: false, isSelected: false, isBetweenStartAndEnd: false), cellWidthPhone: CGFloat(32))
//                .previewDisplayName("Disabled Date")
//            RKCell(rkDate: RKDate(date: Date(), rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 0), isDisabled: false, isToday: true, isSelected: false, isBetweenStartAndEnd: false), cellWidthPhone: CGFloat(32))
//                .previewDisplayName("Today")
//            RKCell(rkDate: RKDate(date: Date(), rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 0), isDisabled: false, isToday: false, isSelected: true, isBetweenStartAndEnd: false), cellWidthPhone: CGFloat(32))
//                .previewDisplayName("Selected Date")
//            RKCell(rkDate: RKDate(date: Date(), rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 0), isDisabled: false, isToday: false, isSelected: false, isBetweenStartAndEnd: true), cellWidthPhone: CGFloat(32))
//                .previewDisplayName("Between Two Dates")
//        }
//        .previewLayout(.fixed(width: 300, height: 70))
//            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
//    }
//}
#endif


