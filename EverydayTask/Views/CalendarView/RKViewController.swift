//
//  RKViewController.swift
//  RKCalendar
//
//  Created by Raffi Kian on 7/14/19.
//  Copyright © 2019 Raffi Kian. All rights reserved.
//

import SwiftUI

struct RKViewController: View {
    
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager

    @State var tappedBackground: Bool
    @State var addBottomSpace: Bool
    
    @State var id: String = ""

    var body: some View {
        ScrollViewReader { (proxy: ScrollViewProxy) in
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(0..<taskViewModel.numberOfMonth, id: \.self) { index in
                            RKMonth(taskViewModel: taskViewModel, rkManager: self.rkManager, monthOffset: index, tappedBackground: self.$tappedBackground, id: $id)
                        }
                        
                        if addBottomSpace {
                            ZStack {}
                                .frame(height: 400)
                        }
                    }
                    .padding(.top, 50)

                }
                .background(
                    rkManager.colors.monthBackColor
                )
                // 画面がロードされた時は下へスクロール
                .onAppear {
                    // 画面がロードされてすぐ
                    self.id = taskViewModel.returnDayStringLong(date: Date())
                    scrollToThisMonth(proxy: proxy, date: rkManager.selectedDate)
                }
                // 選択している日付の位置までスクロール
                .onChange(of: rkManager.selectedDate) { newValue in
                    //if taskViewModel.isSameDay(date1: newValue, date2: Date()) {
                        scrollToThisMonth(proxy: proxy, date: rkManager.selectedDate)
                    //}
                }
                // カレンダーの余白をタップした時は下へスクロール
                .onChange(of: tappedBackground) { _ in
                    scrollToThisMonth(proxy: proxy, date: rkManager.selectedDate)
                }
                
                VStack {
                    RKWeekdayHeader(taskViewModel: taskViewModel, rkManager: self.rkManager)
                    Spacer()
                }
                // ヘッダーをタップすると一番上へスクロール
                .onTapGesture {
                    scrollToThisMonth(proxy: proxy, date: taskViewModel.returnLatestDate(tasks: taskViewModel.tasks))
                }
            }
        }
    }
    
    func scrollToThisMonth(proxy: ScrollViewProxy, date: Date) {
        let target: CGFloat = 0.4
        let id: String = taskViewModel.returnDayStringLong(date: date)
        withAnimation {
            //proxy.scrollTo(id, anchor: UnitPoint(x: 0.5, y: target))
            proxy.scrollTo(id, anchor: UnitPoint(x: 1.0, y: target))
        }
    }
    
//    
//    func RKMaximumDateMonthLastDay() -> Date {
//        var components = rkManager.calendar.dateComponents([.year, .month, .day], from: rkManager.maximumDate)
//        components.month! += 1
//        components.day = 0
//        
//        return rkManager.calendar.date(from: components)!
//    }
}

#if DEBUG
//struct RKViewController_Previews : PreviewProvider {
//    static var previews: some View {
//        Group {
//            RKViewController(isPresented: .constant(false), rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 0))
//            RKViewController(isPresented: .constant(false), rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*32), mode: 0))
//                .environment(\.colorScheme, .dark)
//                .environment(\.layoutDirection, .rightToLeft)
//        }
//    }
//}
#endif

