//
//  SideMenu.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/25.
//

import SwiftUI

struct SideMenuView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager

    @Binding var showHalfModal: Bool
    @Binding var isOpen: Bool
    @Binding var showAllTaskView: Bool
    @State var sideBarWidth: CGFloat
        
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                // サイドメニューのコンテンツ
                title
                
                buttonList
                
                Spacer()
            }
            .frame(maxWidth: sideBarWidth, maxHeight: .infinity)

        }
        .padding(.horizontal)
        .frame(maxWidth: sideBarWidth, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background(
            Color(UIColor.systemBackground)
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            withAnimation {
                                if value.translation.width < -50 {
                                    isOpen = false
                                    
                                    if showHalfModal {
                                        showHalfModal = false
                                    } else {
                                        showHalfModal = true
                                    }
                                }
                            }
                        }
                )
        )
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    withAnimation {
                        if value.translation.width < -50 {
                            isOpen = false
                            
                            if showHalfModal {
                                showHalfModal = false
                            } else {
                                showHalfModal = true
                            }
                        }
                    }
                }
        )
    }
}

extension SideMenuView {
    private var title: some View {
        HStack {
            Text("EverydayTask")
                .font(.title)
                .foregroundColor(.secondary)
            
            Spacer()
            
        }
        .padding(.top, 60)
        .padding(.bottom)
    }
    
    private var buttonList: some View {
        VStack(alignment: .leading, spacing: 0) {
            taskButton(type: .today, itemCount: returnItemCount(taskType: .today))
            
            taskButton(type: .tomorrow, itemCount: returnItemCount(taskType: .tomorrow))
            
            taskButton(type: .all, itemCount: returnItemCount(taskType: .all))
            
            Divider()
        }
    }
    
    private func taskButton(type: PreviewTaskType, itemCount: Int) -> some View {
        Button {
            // previewTasksを更新
            switch type {
            case .today:
                // selectedDateを今日にして閉じる
                rkManager.selectedDate = Date()
                close()
            case .tomorrow:
                // selectedDateを明日にして、画面を閉じる
                rkManager.selectedDate = Date().addingTimeInterval(60*60*24)
                close()
            case .all:
                showAllTaskView = true
            }
            
        } label: {
            HStack {
                Image(systemName: type.imageString)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.primary)
                
                Text(LocalizedStringKey(type.title))
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 0は表示しない
                if itemCount > 0 {
                    Text("\(itemCount)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 45)
        }
    }
    
    private var spanHeader: some View {
        Text("Span")
            .font(.footnote)
            .foregroundColor(.secondary)
    }
    
    private func returnItemCount(taskType: PreviewTaskType) -> Int {
        switch taskType {
        case .today:
            return taskViewModel.returnSelectedDateUnFinishedTasks(date: Date(), isDailyTask: true).count
        case .tomorrow:
            return taskViewModel.returnSelectedDateUnFinishedTasks(date: Date().addingTimeInterval(60*60*24), isDailyTask: true).count
        case .all:
            return taskViewModel.tasks.count
        }
    }
    
    private func close() {
        withAnimation {
            isOpen = false
            showHalfModal = true
        }
    }
}

enum PreviewTaskType {
    case today
    case tomorrow
    case all
    
    var title: String {
        switch self {
        case .today:
            return "Today"
        case .tomorrow:
            return "Tomorrow"
        case .all:
            return "All"
        }
    }
    
    var imageString: String {
        switch self {
        case .today:
            return "sun.min"
        case .tomorrow:
            return "sun.and.horizon"
        case .all:
            return "list.bullet"
        }
    }
}

struct SideMenuView_Previews: PreviewProvider {
    @StateObject static var taskViewModel = TaskViewModel()
    static let rkManager = RKManager(calendar: Calendar.current, minimumDate: Date().addingTimeInterval(-60*60*24*7), maximumDate: Date(), mode: 0)
    @State static var presentationDetent: PresentationDetent = .fraction(0.5)

    static var previews: some View {
        ContentView()
    }
}
