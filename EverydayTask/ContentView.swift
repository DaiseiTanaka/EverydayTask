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

    @State private var isPresented: Bool = true
    
    // For half mordal settings
    @State private var presentationDetent: PresentationDetent = .fraction(0.16)
    @State private var minViewHeight: PresentationDetent = .fraction(0.16)
    @State private var maxViewHeight: PresentationDetent = .fraction(0.47)
    @State private var buttonImage: Image = Image(systemName: "chevron.up.circle")
    
    @State private var badgeNum: Int = 0
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, err) in
            // 許可を申請
        }
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = 0
    }

    var body: some View {
        ZStack {
            if taskViewModel.showCalendarFlag {
                CalendarView(rkManager: rkManager, taskViewModel: taskViewModel)
            } else {
                WeeklyAndMonthlyDetailListView(taskViewModel: taskViewModel, task: taskViewModel.selectedTasks[0])
            }
        }
        .sheet(isPresented: $isPresented) {
            taskView
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
        // タスクを編集したらアプリのバッジの数を更新
        .onChange(of: taskViewModel.tasks) { _ in
            returnBadgeNumber()
        }
        // 日付が変わったらカレンダーを更新
        .onChange(of: returnTodayDay()) { _ in
            taskViewModel.loadRKManager()
        }
    }
}

extension ContentView {
    
    private var taskView: some View {
        TaskView(taskViewModel: taskViewModel, rkManager: taskViewModel.rkManager)
            .frame(maxWidth: .infinity)
            .presentationDetents([minViewHeight, maxViewHeight])

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
    
    private var changeViewSizeButton: some View {
        Button {
            presentationDetent = presentationDetent == minViewHeight ? maxViewHeight : minViewHeight
        } label: {
            buttonImage
                .font(.title)
                .foregroundColor(.secondary)
                .background(.clear)
                .padding()
        }
    }
    
    private func returnTodayDay() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let today = Date()
        let day: Int = calendar.component(.day, from: today)
        return day
    }
    
}

extension ContentView {
    // アプリのバッジの数を算出
    func returnBadgeNumber() {
        var badgeNum: Int = 0
        for task in taskViewModel.tasks {
            // 通知オンだった場合
            if task.notification {
                if task.spanType == .everyDay {
                    // まだタスクが完了していない場合
                    if !taskViewModel.isDone(task: task, date: Date()) {
                        badgeNum += 1
                    }
                } else if task.spanType == .everyWeekday {
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
