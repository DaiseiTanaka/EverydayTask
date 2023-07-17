//
//  ContentView.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/05.
//

import SwiftUI

struct ContentView: View {
    @StateObject var rkManager = RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date(), mode: 0)
    @StateObject var taskViewModel = TaskViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    // For half mordal settings
    @State private var presentationDetent: PresentationDetent = .fraction(0.5)
    @State private var selectedPresentationDetent: PresentationDetent = .fraction(0.5)
    let minViewHeight: PresentationDetent = .fraction(0.12)
    let maxViewHeight: PresentationDetent = .fraction(0.5)
    @State private var buttonImage: Image = Image(systemName: "chevron.up.circle")
    
    @State private var badgeNum: Int = 0
    @State var showHalfModal: Bool = true
    @State var showSidebar: Bool = false
    @State var showAllTaskView: Bool = false
    private let sideBarWidth: CGFloat = UIScreen.main.bounds.width * 0.7

    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, err) in
            // 許可を申請
        }
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = 0
    }

    var body: some View {
        ZStack(alignment: .leading) {
            mainView
                .offset(x: showSidebar ? sideBarWidth : 0)
            
            // サイドメニュー
            SideMenuView(taskViewModel: taskViewModel, rkManager: taskViewModel.rkManager, showHalfModal: $showHalfModal, isOpen: $showSidebar, showAllTaskView: $showAllTaskView, sideBarWidth: sideBarWidth)
                .offset(x: showSidebar ? 0 : -sideBarWidth)
        }
    }
}

extension ContentView {
    private var mainView: some View {
        ZStack {
            if taskViewModel.showCalendarFlag {
                CalendarView(rkManager: rkManager, taskViewModel: taskViewModel, addBottomSpace: true)
            } else {
                RegularlyTaskView(taskViewModel: taskViewModel, rkManager: taskViewModel.rkManager, task: taskViewModel.selectedTasks[0])
            }
            
            ZStack {}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(showSidebar ? Color("disableFieldColor") : .clear)
                //.offset(x: showSidebar ? UIScreen.main.bounds.width / 2 : 0)
                .onTapGesture {
                    withAnimation {
                        showSidebar = false
                        showHalfModal = true
                    }
                }
        }
        .overlay(alignment: .topLeading) {
            // サイドバー表示中　or カレンダー非表示中はボタンを非表示にする
            showSidebar || !taskViewModel.showCalendarFlag ? nil : sideMenuButton
        }
        .sheet(isPresented: $showHalfModal) {
            taskView
        }
        .fullScreenCover(isPresented: $showAllTaskView) {
            AllTaskListView(taskViewModel: taskViewModel, rkManager: taskViewModel.rkManager)
        }
        .onAppear {
            taskViewModel.loadRKManager()
            returnBadgeNumber()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                print("\nバックグラウンド！")
                // 通知を設定
                taskViewModel.setNotification()
                // tasksを保存
                taskViewModel.saveTasks(tasks: taskViewModel.tasks)
            }
            if phase == .active {
                print("\nフォアグラウンド！")
                // 通知を削除
                taskViewModel.removeNotification()
            }
            if phase == .inactive {
                print("\nバックグラウンドorフォアグラウンド直前")
                // Widget用のデータを更新
                taskViewModel.saveUnfinishedTasksForWidget()
            }
        }
        // タスクを編集したらアプリのバッジの数を更新 & tasksを保存
        .onChange(of: taskViewModel.tasks) { _ in
            returnBadgeNumber()
        }
        // 日付が変わったらカレンダーを更新
        .onChange(of: returnTodayDay()) { _ in
            taskViewModel.loadRKManager()
        }
    }
    
    private var taskView: some View {
        TaskView(taskViewModel: taskViewModel, rkManager: taskViewModel.rkManager)
            .frame(maxWidth: .infinity)
            .presentationDetents([minViewHeight, maxViewHeight], selection: $selectedPresentationDetent)
            .presentationCornerRadius(30)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(
                .enabled(upThrough: maxViewHeight)
            )
            .interactiveDismissDisabled()
            //.overlay(changeViewSizeButton, alignment: .topTrailing)
            //.presentationBackground(Color(UIColor.systemGray6))
            //.presentationBackground(.ultraThickMaterial)
    }
    
    private var sideMenuButton: some View {
        // メニューボタン
        Button(action: {
            withAnimation {
                showSidebar.toggle()
                if showHalfModal {
                    showHalfModal = false
                } else {
                    showHalfModal = true
                }
            }
        }) {
            Image(systemName: "line.horizontal.3")
                .imageScale(.large)
        }
        .padding(10)
        .foregroundColor(.primary)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .padding(.top, 15)
        .padding(10)
    }
    
    private func returnTodayDay() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let today = Date()
        let day: Int = calendar.component(.day, from: today)
        return day
    }
    
    // アプリのバッジの数を算出
    func returnBadgeNumber() {
        var badgeNum: Int = 0
        for task in taskViewModel.tasks {
            // 通知オンだった場合
            if task.notification {
                if task.spanType == .custom && task.span == .day {
                    // まだタスクが完了していない場合
                    if !taskViewModel.isDone(task: task, date: Date()) {
                        badgeNum += 1
                    }
                } else if task.spanType == .selected {
                    let spanDate = task.spanDate
                    let weekIndex = taskViewModel.returnWeekdayFromDate(date: Date())
                    // 今日が設定した曜日だった場合
                    if spanDate.contains(weekIndex) {
                        // まだタスクが完了していない場合
                        if !taskViewModel.isDone(task: task, date: Date()) {
                            badgeNum += 1
                        }
                    }
                }
            }
        }
        self.badgeNum = badgeNum
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = self.badgeNum
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
            
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
