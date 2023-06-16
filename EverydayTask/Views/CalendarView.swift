//
//  CalendarView.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/05.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var rkManager: RKManager
    @ObservedObject var taskViewModel: TaskViewModel

    @State private var trueFlag = true
    //@State private var rkManager1 = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)
    //@State private var numberOfMonth: Int = 2
    
    var body: some View {
        RKViewController(taskViewModel: taskViewModel, isPresented: $trueFlag, rkManager: taskViewModel.rkManager)
//            .overlay(alignment: .top) {
//                if taskViewModel.selectedTasks.count == 1 {
//                    Text("\(taskViewModel.returnContinuousCount(task: taskViewModel.selectedTasks[0]))")
//                }
//            }
    }
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date(), mode: 0), taskViewModel: TaskViewModel())
    }
}
