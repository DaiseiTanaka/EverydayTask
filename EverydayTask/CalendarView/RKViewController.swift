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
    
    @Binding var isPresented: Bool
    
    @ObservedObject var rkManager: RKManager
    
    //@State var numberOfMonth: Int
    
    var body: some View {
        ZStack {
            ScrollViewReader { (proxy: ScrollViewProxy) in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(0..<taskViewModel.numberOfMonth, id: \.self) { index in
                            RKMonth(taskViewModel: taskViewModel, isPresented: self.$isPresented, rkManager: self.rkManager, monthOffset: index)
                                .id(index)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 360)
                }
                .listStyle(.plain)
                .onAppear {
                    scrollToThisMonth(proxy: proxy)
                }
                .onChange(of: taskViewModel.tasks) { _ in
                    scrollToThisMonth(proxy: proxy)
                }
                .onChange(of: taskViewModel.selectedTasks) { _ in
                    scrollToThisMonth(proxy: proxy)
                }
                .onChange(of: rkManager.selectedDate) { newValue in
                    if taskViewModel.isSameDay(date1: newValue, date2: Date()) {
                        scrollToThisMonth(proxy: proxy)
                    }
                }
            }
            VStack {
                RKWeekdayHeader(rkManager: self.rkManager)
                Spacer()
            }
        }
    }
    
    func scrollToThisMonth(proxy: ScrollViewProxy) {
        let target: CGFloat = 0.0
        withAnimation {
            proxy.scrollTo(taskViewModel.numberOfMonth-1, anchor: UnitPoint(x: 0.5, y: target))
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

