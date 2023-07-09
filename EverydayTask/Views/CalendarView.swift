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
    
        //@State private var trueFlag = true
    
    var body: some View {
        RKViewController(taskViewModel: taskViewModel, rkManager: taskViewModel.rkManager, isPresented: $taskViewModel.trueFlag, tappedBackground: true)
        
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
