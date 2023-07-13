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
    
    @State var addBottomSpace: Bool
        
    var body: some View {
        ZStack {
            RKViewController(taskViewModel: taskViewModel, rkManager: taskViewModel.rkManager, tappedBackground: true, addBottomSpace: addBottomSpace)
        }
    }
}


//struct CalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarView(rkManager: RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date(), mode: 0), taskViewModel: TaskViewModel())
//    }
//}
