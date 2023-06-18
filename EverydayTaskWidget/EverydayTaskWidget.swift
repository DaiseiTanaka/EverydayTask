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
        SimpleEntry(date: Date(), unfinishedTaskCount: 0, allUnfinishedTaskTitleList: [], todayUnfinishedTaskTitleList: [], futureUnfinishedTaskTitleList: [], oneTimeUnfinishedTaskTitleList: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let sampleList: [WidgetTask] = [
            WidgetTask(title: "Task1", id: UUID().uuidString),
            WidgetTask(title: "Task2", id: UUID().uuidString),
            WidgetTask(title: "Task3", id: UUID().uuidString),
            WidgetTask(title: "Task4", id: UUID().uuidString),
            WidgetTask(title: "Task5", id: UUID().uuidString),
            WidgetTask(title: "Task6", id: UUID().uuidString),
            WidgetTask(title: "Task7", id: UUID().uuidString),
            WidgetTask(title: "Task8", id: UUID().uuidString),
            WidgetTask(title: "Task9", id: UUID().uuidString),
            WidgetTask(title: "Task10", id: UUID().uuidString),
            WidgetTask(title: "Task11", id: UUID().uuidString),
            WidgetTask(title: "Task12", id: UUID().uuidString)
            
        ]
        let entry = SimpleEntry(date: Date(), unfinishedTaskCount: sampleList.count, allUnfinishedTaskTitleList: sampleList, todayUnfinishedTaskTitleList: sampleList, futureUnfinishedTaskTitleList: [], oneTimeUnfinishedTaskTitleList: [])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        var unfinishedTaskCount = 0
        var allUnfinishedTaskTitleListInput: [String] = []
        var todayUnfinishedTaskTitleListInput: [String] = []
        var futureUnfinishedTaskTitleListInput: [String] = []
        var oneTimeUnfinishedTaskTitleListInput: [String] = []
        //
        let userDefaults = UserDefaults(suiteName: "group.myproject.EverydayTask.widget")
        if let userDefaults = userDefaults {
            unfinishedTaskCount = userDefaults.integer(forKey: "unfinishedTaskCount")
            allUnfinishedTaskTitleListInput = userDefaults.stringArray(forKey: "allUnfinishedTaskTitleList") ?? []
            todayUnfinishedTaskTitleListInput = userDefaults.stringArray(forKey: "todayUnfinishedTaskTitleList") ?? []
            futureUnfinishedTaskTitleListInput = userDefaults.stringArray(forKey: "futureUnfinishedTaskTitleList") ?? []
            oneTimeUnfinishedTaskTitleListInput = userDefaults.stringArray(forKey: "oneTimeUnfinishedTaskTitleList") ?? []

        }
        
        var allUnfinishedTaskTitleList: [WidgetTask] = []
        var todayUnfinishedTaskTitleList: [WidgetTask] = []
        var futureUnfinishedTaskTitleList: [WidgetTask] = []
        var oneTimeUnfinishedTaskTitleList: [WidgetTask] = []
        for num in 0..<allUnfinishedTaskTitleListInput.count {
            allUnfinishedTaskTitleList.append(WidgetTask(title: allUnfinishedTaskTitleListInput[num], id: UUID().uuidString))
        }
        for num in 0..<todayUnfinishedTaskTitleListInput.count {
            todayUnfinishedTaskTitleList.append(WidgetTask(title: todayUnfinishedTaskTitleListInput[num], id: UUID().uuidString))
        }
        for num in 0..<futureUnfinishedTaskTitleListInput.count {
            futureUnfinishedTaskTitleList.append(WidgetTask(title: futureUnfinishedTaskTitleListInput[num], id: UUID().uuidString))
        }
        for num in 0..<oneTimeUnfinishedTaskTitleListInput.count {
            oneTimeUnfinishedTaskTitleList.append(WidgetTask(title: oneTimeUnfinishedTaskTitleListInput[num], id: UUID().uuidString))
        }
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, unfinishedTaskCount: unfinishedTaskCount, allUnfinishedTaskTitleList: allUnfinishedTaskTitleList, todayUnfinishedTaskTitleList: todayUnfinishedTaskTitleList, futureUnfinishedTaskTitleList: futureUnfinishedTaskTitleList, oneTimeUnfinishedTaskTitleList: oneTimeUnfinishedTaskTitleList)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let unfinishedTaskCount: Int
    let allUnfinishedTaskTitleList: [WidgetTask]
    let todayUnfinishedTaskTitleList: [WidgetTask]
    let futureUnfinishedTaskTitleList: [WidgetTask]
    let oneTimeUnfinishedTaskTitleList: [WidgetTask]
}

struct EverydayTaskWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 110, maximum: 300)), count: 2)
    let lineLimitSmall: Int = 5
    let lineLimitMedium: Int = 10
    let lineLimitLarge: Int = 20
    
    var body: some View {
        if entry.todayUnfinishedTaskTitleList.count != 0 {
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
        let listCount = entry.todayUnfinishedTaskTitleList.count
        if listCount > limit {
            return limit
        } else {
            return listCount
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
                Text("\(entry.unfinishedTaskCount)")
                    .font(.title.bold())
                //                Text(entry.date, style: .time)
                //                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            
            VStack(spacing: 4) {
                ForEach(entry.todayUnfinishedTaskTitleList[0..<returnLineLimit(limit: lineLimitSmall)], id: \.id) { title in
                    HStack {
                        Text(title.title)
                            .font(.footnote)
                        Spacer()
                    }
                    Divider()
                }
                if entry.todayUnfinishedTaskTitleList.count > lineLimitSmall {
                    HStack {
                        Text("+ \(entry.todayUnfinishedTaskTitleList.count-returnLineLimit(limit: lineLimitSmall))")
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
                
                Text("\(entry.unfinishedTaskCount)")
                    .font(.title.bold())
            }
            .padding(.top)
            .padding(.bottom)
            .padding(.leading)
            
            Spacer(minLength: 0)
            
            VStack {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(entry.todayUnfinishedTaskTitleList[0..<returnLineLimit(limit: lineLimitMedium)], id: \.id) { title in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title.title)
                                .font(.footnote)
                                .lineLimit(1)
                            Divider()
                        }
                    }
                }
                
                Spacer(minLength: 0)
                
                if entry.todayUnfinishedTaskTitleList.count > lineLimitMedium {
                    HStack {
                        Text("+ \(entry.todayUnfinishedTaskTitleList.count-returnLineLimit(limit: lineLimitMedium))")
                            .font(.footnote)
                        Spacer()
                    }
                }
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
                
                Text("\(entry.unfinishedTaskCount)")
                    .font(.title.bold())
                    .lineLimit(1)
            }
            .padding(.top)
            .padding(.bottom)
            .padding(.leading)
            
            Spacer(minLength: 0)
            
            VStack {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(entry.todayUnfinishedTaskTitleList[0..<returnLineLimit(limit: lineLimitLarge)], id: \.id) { title in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title.title)
                                .font(.footnote)
                                .lineLimit(1)
                            Divider()
                        }
                    }
                }
                Spacer()
                if entry.todayUnfinishedTaskTitleList.count > lineLimitLarge {
                    HStack {
                        Text("+ \(entry.todayUnfinishedTaskTitleList.count-returnLineLimit(limit: lineLimitLarge))")
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
        .background(entry.todayUnfinishedTaskTitleList.count != 0 ? Color(UIColor.systemBackground) : .black)
    }
}

struct WidgetTask: Identifiable {
    let title, id: String
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
    static let sampleList: [WidgetTask] = [
        //                WidgetTask(title: "Task111111111111111111111111111111111", id: UUID().uuidString),
        //        WidgetTask(title: "Task2", id: UUID().uuidString),
        //        WidgetTask(title: "Task3", id: UUID().uuidString),
        //        WidgetTask(title: "Task4", id: UUID().uuidString),
        //        WidgetTask(title: "Task5", id: UUID().uuidString),
        //        WidgetTask(title: "Task6", id: UUID().uuidString),
        //        WidgetTask(title: "Task7", id: UUID().uuidString),
        //        WidgetTask(title: "Task8", id: UUID().uuidString),
        //        WidgetTask(title: "Task9", id: UUID().uuidString),
        //        WidgetTask(title: "Task10", id: UUID().uuidString),
        //        WidgetTask(title: "Task11", id: UUID().uuidString),
        //        WidgetTask(title: "Task12", id: UUID().uuidString),
        //        WidgetTask(title: "Task13", id: UUID().uuidString),
        //        WidgetTask(title: "Task14", id: UUID().uuidString),
        //        WidgetTask(title: "Task15", id: UUID().uuidString),
        //        WidgetTask(title: "Task16", id: UUID().uuidString),
        //        WidgetTask(title: "Task17", id: UUID().uuidString),
        //        WidgetTask(title: "Task18", id: UUID().uuidString),
        //        WidgetTask(title: "Task19", id: UUID().uuidString),
        //        WidgetTask(title: "Task20", id: UUID().uuidString),
        //        WidgetTask(title: "Task21", id: UUID().uuidString),
        //        WidgetTask(title: "Task22", id: UUID().uuidString),
        //        WidgetTask(title: "Task23", id: UUID().uuidString)
        
    ]
    static var previews: some View {
        Group {
            EverydayTaskWidgetEntryView(entry: SimpleEntry(date: Date(), unfinishedTaskCount: sampleList.count, allUnfinishedTaskTitleList: sampleList, todayUnfinishedTaskTitleList: sampleList, futureUnfinishedTaskTitleList: [], oneTimeUnfinishedTaskTitleList: []))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            EverydayTaskWidgetEntryView(entry: SimpleEntry(date: Date(), unfinishedTaskCount: sampleList.count, allUnfinishedTaskTitleList: sampleList, todayUnfinishedTaskTitleList: sampleList, futureUnfinishedTaskTitleList: [], oneTimeUnfinishedTaskTitleList: []))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            EverydayTaskWidgetEntryView(entry: SimpleEntry(date: Date(), unfinishedTaskCount: sampleList.count, allUnfinishedTaskTitleList: sampleList, todayUnfinishedTaskTitleList: sampleList, futureUnfinishedTaskTitleList: [], oneTimeUnfinishedTaskTitleList: []))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            EverydayTaskWidgetEntryView(entry: SimpleEntry(date: Date(), unfinishedTaskCount: sampleList.count, allUnfinishedTaskTitleList: sampleList, todayUnfinishedTaskTitleList: sampleList, futureUnfinishedTaskTitleList: [], oneTimeUnfinishedTaskTitleList: []))
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
        }
    }
}
