//
//  EverydayTaskWidget.swift
//  EverydayTaskWidget
//
//  Created by 田中大誓 on 2023/06/15.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), allUnfinishedTaskList: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let sampleList: [[Tasks]] = [
            // Every day
            [Tasks(title: "Task1", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true),
             Tasks(title: "Task2", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
             Tasks(title: "Task3", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Black", isAble: true),
              Tasks(title: "Task4", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true)],
            // Every week
            [Tasks(title: "Task", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)],
            // Every month
            [Tasks(title: "Task", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)],
            // One time
            [Tasks(title: "Task", detail: "", addedDate: Date(), spanType: .oneTime, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Red", isAble: true)]
        ]
        let entry = SimpleEntry(date: Date(), allUnfinishedTaskList: sampleList)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        var unfinishedTasks: [[Tasks]] = []

        let userDefaults = UserDefaults(suiteName: "group.myproject.EverydayTask.widget")
        if let userDefaults = userDefaults {
            let jsonDecoder = JSONDecoder()
            guard let data = userDefaults.data(forKey: "unfinishedTasks"),
                  let tasks = try? jsonDecoder.decode([[Tasks]].self, from: data) else {
                print("😭: tasksのロードに失敗しました。")
                return
            }
            unfinishedTasks = tasks
        }
            
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, allUnfinishedTaskList: unfinishedTasks)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let allUnfinishedTaskList: [[Tasks]]
}

struct Tasks: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var title: String
    var detail: String
    var addedDate: Date
    var spanType: TaskSpanType
    var spanDate: [Int]
    var doneDate: [Date]
    var notification: Bool
    var notificationHour: Int
    var notificationMin: Int
    var accentColor: String
    var isAble: Bool
    
    init(title: String, detail: String, addedDate: Date, spanType: TaskSpanType, spanDate: [Int], doneDate: [Date], notification: Bool, notificationHour: Int, notificationMin: Int, accentColor: String, isAble: Bool) {
        self.title = title
        self.detail = detail
        self.addedDate = addedDate
        self.spanType = spanType
        self.spanDate = spanDate
        self.doneDate = doneDate
        self.notification = notification
        self.notificationHour = notificationHour
        self.notificationMin = notificationMin
        self.accentColor = accentColor
        self.isAble = isAble
    }
}

enum TaskSpanType: Codable {
    case oneTime
    case everyDay
    case everyWeek
    case everyMonth
    case everyWeekday
}

struct EverydayTaskWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 110, maximum: 300)), count: 2)
    let lineLimitSmall: Int = 5
    let lineLimitMedium: Int = 9
    let lineLimitLarge: Int = 20
    var previewList: [Tasks] {
        if !entry.allUnfinishedTaskList.isEmpty {
            return entry.allUnfinishedTaskList[0]
        } else {
            return []
        }
    }
    var previewListCount: Int {
        previewList.count
    }
    
    var body: some View {
        if !previewList.isEmpty {
            switch family {
            case .systemSmall: EverydayTaskSmall
            case .systemMedium: EverydayTaskMedium
            case .systemLarge: EverydayTaskLarge
            default: EverydayTaskLarge
            }
        } else {
            EverydayTaskEmpty
        }
    }
    
    // リストに表示するタスクの最大値を返す
    private func returnLineLimit(limit: Int) -> Int {
        if previewListCount > limit {
            return limit
        } else {
            return previewListCount
        }
    }
    
    // タスクのアクセントカラーをString型からColor型へ変換する
    private func returnColor(color: String) -> Color {
        switch color {
        case "Label":
            return Color(UIColor.label)
        case "Black":
            return Color.black
        case "Gray":
            return Color.gray
        case "Red":
            return Color.red
        case "Pink":
            return Color.pink
        case "Orange":
            return Color.orange
        case "Cyan":
            return Color.cyan
        case "Blue":
            return Color.blue
        case "Indigo":
            return Color.indigo
        case "Yellow":
            return Color.yellow
        case "Green":
            return Color.green
        default:
            return Color.blue
        }
    }
}

extension EverydayTaskWidgetEntryView {
    var EverydayTaskSmall: some View {
        HStack(spacing: 0) {
            VStack {
                Image("icon")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .cornerRadius(5)
                
                Spacer()
                Text("\(previewListCount)")
                    .font(.title.bold())
                //                Text(entry.date, style: .time)
                //                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            
            VStack(spacing: 4) {
                ForEach(previewList[0..<returnLineLimit(limit: lineLimitSmall)], id: \.id) { task in
                    HStack {
                        // タスクのアクセントカラー
                        Rectangle()
                            .frame(width: 5, height: 15)
                            .cornerRadius(5)
                            .foregroundColor(returnColor(color: task.accentColor))
                        
                        Text(task.title)
                            .font(.footnote)
                        Spacer()
                    }
                    Divider()
                }
                if previewListCount > lineLimitSmall {
                    HStack {
                        Text("+ \(previewListCount-returnLineLimit(limit: lineLimitSmall))")
                            .font(.footnote)
                        Spacer()
                    }
                }
                Spacer()
            }
            .padding(.trailing)
            .padding(.top, 10)
            
            Spacer(minLength: 0)
        }
    }
    
    var EverydayTaskMedium: some View {
        HStack(spacing: 10) {
            VStack {
                Image("icon")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .cornerRadius(5)
                
                Spacer()
                
                Text("\(previewListCount)")
                    .font(.title.bold())
            }
            .padding(.top)
            .padding(.bottom)
            .padding(.leading)
            
            Spacer(minLength: 0)
            
            VStack(spacing: 0) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(previewList[0..<returnLineLimit(limit: lineLimitMedium)], id: \.id) { task in
                        VStack(spacing: 4) {
                            HStack {
                                // タスクのアクセントカラー
                                Rectangle()
                                    .frame(width: 5, height: 15)
                                    .cornerRadius(5)
                                    .foregroundColor(returnColor(color: task.accentColor))
                                Text(task.title)
                                    .font(.footnote)
                                    .lineLimit(1)
                                Spacer()
                            }
                            Divider()
                        }
                    }
                    if previewListCount > lineLimitMedium {
                        HStack {
                            Text("+ \(previewListCount-returnLineLimit(limit: lineLimitMedium))")
                                .font(.footnote)
                            Spacer()
                        }
                    }
                }
                
                Spacer(minLength: 0)
                
//                if previewListCount > lineLimitMedium {
//                    HStack {
//                        Text("+ \(previewListCount-returnLineLimit(limit: lineLimitMedium))")
//                            .font(.footnote)
//                        Spacer()
//                    }
//                }
            }
            .padding(.trailing)
            .padding(.vertical, 15)
            
            Spacer(minLength: 0)
        }
    }
    
    var EverydayTaskLarge: some View {
        HStack(spacing: 10) {
            VStack {
                Image("icon")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .cornerRadius(5)
                
                Spacer()
                
                Text("\(previewListCount)")
                    .font(.title.bold())
                    .lineLimit(1)
            }
            .padding(.top)
            .padding(.bottom)
            .padding(.leading)
            
            Spacer(minLength: 0)
            
            VStack(spacing: 4) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(previewList[0..<returnLineLimit(limit: lineLimitLarge)], id: \.id) { task in
                        VStack(spacing: 4) {
                            HStack {
                                // タスクのアクセントカラー
                                Rectangle()
                                    .frame(width: 5, height: 15)
                                    .cornerRadius(5)
                                    .foregroundColor(returnColor(color: task.accentColor))
                                Text(task.title)
                                    .font(.footnote)
                                    .lineLimit(1)
                                Spacer()
                            }
                            Divider()
                        }
                    }
                }
                Spacer()
                if previewListCount > lineLimitLarge {
                    HStack {
                        Text("+ \(previewListCount-returnLineLimit(limit: lineLimitLarge))")
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
            .padding(.trailing)
            .padding(.top, 5)
            .padding(.vertical, 15)
            
            Spacer(minLength: 0)
        }
    }
    
    // 今日のタスクを全て実施した時に表示する
    var EverydayTaskEmpty: some View {
        VStack {
            HStack {
                Image("icon")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.top, 5)
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
            HStack {
                Spacer()
                Text("Fin.")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .background(.black)
    }
}

struct EverydayTaskWidget: Widget {
    let kind: String = "EverydayTaskWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EverydayTaskWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Everyday Task Widget")
        .description("You can see your today's Tasks!")
    }
}

struct EverydayTaskWidget_Previews: PreviewProvider {
    static let sampleList: [[Tasks]] = [
        // Every day
        [Tasks(title: "Task1", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true),
         Tasks(title: "Task2", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
         Tasks(title: "Task3", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Black", isAble: true),
          Tasks(title: "Task4", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true),
         Tasks(title: "Task5", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
         Tasks(title: "Task6", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Black", isAble: true),
          Tasks(title: "Task7", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true),
         Tasks(title: "Task8", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
         Tasks(title: "Task9", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Black", isAble: true),
          Tasks(title: "Task10", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true),
         Tasks(title: "Task11", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
         Tasks(title: "Task12", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Black", isAble: true),
          Tasks(title: "Task13", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true),
         Tasks(title: "Task14", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true),
        Tasks(title: "Task15", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
        Tasks(title: "Task16", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Black", isAble: true),
         Tasks(title: "Task17", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true),
        Tasks(title: "Task18", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
        Tasks(title: "Task19", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Black", isAble: true),
         Tasks(title: "Task20", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true),
        Tasks(title: "Task21", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Green", isAble: true),
        Tasks(title: "Task22", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Black", isAble: true),
         Tasks(title: "Task23", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Cyan", isAble: true)],
        // Every week
        [Tasks(title: "Task", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)],
        // Every month
        [Tasks(title: "Task", detail: "Every day", addedDate: Date(), spanType: .everyDay, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Blue", isAble: true)],
        // One time
        [Tasks(title: "Task", detail: "", addedDate: Date(), spanType: .oneTime, spanDate: [], doneDate: [], notification: false, notificationHour: 0, notificationMin: 0, accentColor: "Red", isAble: true)]
    ]
    static var previews: some View {
        Group {
            EverydayTaskWidgetEntryView(entry: SimpleEntry(date: Date(), allUnfinishedTaskList: sampleList))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            EverydayTaskWidgetEntryView(entry: SimpleEntry(date: Date(), allUnfinishedTaskList: sampleList))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            EverydayTaskWidgetEntryView(entry: SimpleEntry(date: Date(), allUnfinishedTaskList: sampleList))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            EverydayTaskWidgetEntryView(entry: SimpleEntry(date: Date(), allUnfinishedTaskList: sampleList))
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
        }
    }
}
