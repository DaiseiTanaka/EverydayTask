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
        var unfinishedTasks: [[Tasks]] = []

        let userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
        if let userDefaults = userDefaults {
            let jsonDecoder = JSONDecoder()
            guard let data = userDefaults.data(forKey: UserDefaultsKeys.tasks),
                  let tasks = try? jsonDecoder.decode([[Tasks]].self, from: data) else {
                return
            }
            unfinishedTasks = tasks
        }
        let entry = SimpleEntry(date: Date(), allUnfinishedTaskList: unfinishedTasks)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        var unfinishedTasks: [[Tasks]] = []

        let userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
        if let userDefaults = userDefaults {
            let jsonDecoder = JSONDecoder()
            guard let data = userDefaults.data(forKey: UserDefaultsKeys.tasks),
                  let tasks = try? jsonDecoder.decode([[Tasks]].self, from: data) else {
                #if DEBUG
                print("tasksのロードに失敗しました。")
                #endif
                return
            }
            unfinishedTasks = tasks
        }
            
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            guard let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) else {
                continue
            }
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
            switch family {
            case .systemSmall: EverydayTaskEmptySmall
            case .systemMedium: EverydayTaskEmpty
            case .systemLarge: EverydayTaskEmpty
            default: EverydayTaskEmpty
            }
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
        TaskColor.color(for: color)
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
                            .lineLimit(1)

                        Spacer(minLength: 0)
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
    
    // 今日のタスクを全て実施した時に表示する small
    var EverydayTaskEmptySmall: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("icon")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
                    .padding(.leading, 10)
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
            Text("All tasks for today have been completed!")
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Text("Good job for today.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
                .padding(.horizontal)
        }
        .padding(.vertical, 5)
    }
    
    // 今日のタスクを全て実施した時に表示する
    var EverydayTaskEmpty: some View {
        ZStack {
            VStack {
                HStack {
                    Image("icon")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(5)
                        .padding(.leading, 10)
                    Spacer()
                }
                Spacer()
            }
            VStack(alignment: .leading) {
                Text("All tasks for today have been completed!")
                    .font(.body.bold())
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Text("Good job for today.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding(.top)
        }
        .padding(.vertical, 5)
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
