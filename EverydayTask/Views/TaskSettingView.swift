//
//  TaskSettingView.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/06/06.
//

import SwiftUI

struct TaskSettingView: View {
    @ObservedObject var rkManager: RKManager
    @ObservedObject var taskViewModel: TaskViewModel
    
    @Environment(\.dismiss) var dismiss

    @State var task: Tasks
    // 曜日選択用
    @State var selectedWeekdays: [Int]
    let weekdaysList: [String] = [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"
    ]
    
    @State private var focusTitleTextField: Bool = false
    @State private var focusDetailTextField: Bool = false

    var body: some View {
        NavigationView {
            Form {
                // タイトルを入力
                Section( header: Text("Title:")) {
                    TextField("Input Title", text: $task.title, onEditingChanged: { begin in
                        self.focusTitleTextField = begin
                    })
                }
                // 詳細を入力
                Section( header: Text("Detail:")) {
                    TextField("Input Detail", text: $task.detail, onEditingChanged: { begin in
                        self.focusDetailTextField = begin
                    })
                }
                // スパンを入力
                Section( header: Text("Repeat:")) {
                    Picker("Every Weekdays", selection: $task.spanType) {
                        Text("1 /Day")
                            .tag(TaskSpanType.everyDay)
                        Text("1 /Week")
                            .tag(TaskSpanType.everyWeek)
                        Text("1 /Month")
                            .tag(TaskSpanType.everyMonth)
                        Text("Custom")
                            .tag(TaskSpanType.everyWeekday)
                    }
                    .pickerStyle(.segmented)
                    
                    // 選択中のスパンを表示
                    selectedSpanTypeView
                }
                // アクセントカラーを入力
                Section( header: Text("Accent color:")) {
                    Picker("Select accent color", selection: $task.accentColor) {
                        ForEach(taskViewModel.accentColors, id: \.self) { color in
                            HStack {
                                Circle()
                                    .frame(width: 30)
                                    .foregroundColor(taskViewModel.returnColor(color: color))
                                Text(color)
                            }
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // 毎日のタスク or 各週のタスクの場合のみ通知を設定可能
                if task.spanType == .everyDay || task.spanType == .everyWeekday {
                    // 通知
                    Section( header: Text("Notification:")) {
                        HStack {
                            if task.notification {
                                Image(systemName: "bell.badge")
                            } else {
                                Image(systemName: "bell.slash")
                            }
                            Toggle("Add notification", isOn: $task.notification)
                        }
                        // 通知オンだった場合
                        if task.notification {
                            PickerView(hourSelected: $task.notificationHour, minSelected: $task.notificationMin)
                        }
                    }
                }
            }
            .navigationBarItems(leading: cancelButton, trailing: okButton)
        }
        // 画面タップでキーボードを閉じる
        .simultaneousGesture(focusTitleTextField || focusDetailTextField ? TapGesture().onEnded {
            UIApplication.shared.closeKeyboard()
        } : nil)
        .onDisappear {
            taskViewModel.showCalendarFlag = true
            taskViewModel.selectedTasks = taskViewModel.tasks
        }
    }
}

extension TaskSettingView {
    
    private var selectedSpanTypeView: some View {
        List {
            switch task.spanType {
            case .everyDay:
                HStack {
                    Text("Every day")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "checkmark")
                }
                
            case .everyWeek:
                HStack {
                    Text("Once a week")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "checkmark")
                }
                
            case .everyMonth:
                HStack {
                    Text("Once a month")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "checkmark")
                }
                
            case .everyWeekday:
                ForEach(self.getWeekdayHeaders(calendar: rkManager.calendar), id: \.self) { item in
                    MultipleSelectionRow(
                        title: item,
                        isSelected:
                            contains(list: selectedWeekdays, element: returnWeekdayIndexFromString(weekday: item))) {
                                // すでに選択されていたコンポーネントをタップした場合、選択を解除
                                if self.selectedWeekdays.contains(returnWeekdayIndexFromString(weekday: item)) {
                                    self.selectedWeekdays.removeAll(where: { $0 == returnWeekdayIndexFromString(weekday: item) })
                                }
                                // タップしたコンポーネントを選択済みリストへ追加
                                else {
                                    self.selectedWeekdays.append(returnWeekdayIndexFromString(weekday: item))
                                }
                                task.spanDate = selectedWeekdays
                            }
                }
            }
        }
    }
    
    // 数値配列の要素検索
    func contains(list: [Int], element: Int) -> Bool {
        for num in 0..<list.count {
            let listItem = list[num]
            if listItem == element {
                return true
            }
        }
        return false
    }
    
    // [Sunday ,,, Saturday]を返す
    func getWeekdayHeaders(calendar: Calendar) -> [String] {
        let formatter = DateFormatter()
        var weekdaySymbols = formatter.standaloneWeekdaySymbols
        let weekdaySymbolsCount = weekdaySymbols?.count ?? 0
        
        for _ in 0 ..< (1 - calendar.firstWeekday + weekdaySymbolsCount){
            let lastObject = weekdaySymbols?.last
            weekdaySymbols?.removeLast()
            weekdaySymbols?.insert(lastObject!, at: 0)
        }
        
        return weekdaySymbols ?? []
    }
    
    func returnWeekdayIndexFromString(weekday: String) -> Int {
        switch weekday {
        case "Sunday":
            return 1
        case "Monday":
            return 2
        case "Tuesday":
            return 3
        case "Wednesday":
            return 4
        case "Thursday":
            return 5
        case "Friday":
            return 6
        case "Saturday":
            return 7
        case "日曜日":
            return 1
        case "月曜日":
            return 2
        case "火曜日":
            return 3
        case "水曜日":
            return 4
        case "木曜日":
            return 5
        case "金曜日":
            return 6
        case "土曜日":
            return 7
        default:
            return 0
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
            dismiss()
        }, label: {
            Text("Cancel")
                .foregroundColor(.red)
        })
    }
    
    private var okButton: some View {
        Button(action: {
            let impactLight = UIImpactFeedbackGenerator(style: .rigid)
            impactLight.impactOccurred()
            taskViewModel.addTasks(task: task)
            dismiss()
            
        }, label: {
            Text("OK")
                .bold()
                .foregroundColor(.blue)
        })
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
        .foregroundColor(self.isSelected ? .primary : .secondary)
    }
}

struct TaskSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        //TaskSettingView(taskViewModel: TaskViewModel(), task: Tasks.previewData[0])
    }
}
