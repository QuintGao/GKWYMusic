//
//  GKWYWidget.swift
//  GKWYWidget
//
//  Created by gaokun on 2020/11/11.
//  Copyright © 2020 gaokun. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct GKWYWidgetProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> GKWYWidgetEntry {
        GKWYWidgetEntry(date: Date(), configuration: GKWYWidgetConfigurationIntent(), list: GKWYData.getList())
    }

    // 小组件快照，添加小组件的时候会走这个方法，可以在这里请求数据，达到预览效果
    func getSnapshot(for configuration: GKWYWidgetConfigurationIntent, in context: Context, completion: @escaping (GKWYWidgetEntry) -> ()) {
        // 为保证数组有数据，这里做下处理
        var modeArr = configuration.modeArr
        if modeArr == nil || modeArr?.count == 0 {
            modeArr = GKWYData.getModeList()
        }
        
        // 请求数据
        GKWYDataLoader.request(modeArr: modeArr!) { (list) in
            let entry = GKWYWidgetEntry(date: Date(), configuration: configuration, list: list)
            completion(entry)
        }
    }

    func getTimeline(for configuration: GKWYWidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        // 下一次更新间隔以分钟为单位，间隔5分钟请求一次新的数据
        let updateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)
        
        // 为保证数组有数据，这里做下处理
        var modeArr = configuration.modeArr
        if modeArr == nil || modeArr?.count == 0 {
            modeArr = GKWYData.getModeList()
        }
        
        // 请求数据
        GKWYDataLoader.request(modeArr: modeArr!) { (list) in
            let entry = GKWYWidgetEntry(date: currentDate, configuration: configuration, list: list)
            let timeline = Timeline(entries: [entry], policy: .after(updateDate!))
            completion(timeline)
        }
    }
}

struct GKWYWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: GKWYWidgetConfigurationIntent
    let list: [GKWYData]
}

struct GKWYWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: GKWYWidgetEntry
    
    @ViewBuilder
    var body: some View {
        let data = entry.list[0]
        
        switch family {
        case .systemSmall:
            GKWYSmallView(data: data).widgetURL(URL(string: (typePrefix + data.type)))
        case .systemMedium:
            GKWYMediumView(list: entry.list)
        case .systemLarge:
            GKWYLargeView(list: entry.list)
        default:
            GKWYSmallView(data: entry.list[0])
        }
    }
}

@main
struct GKWYWidget: Widget {
    let kind: String = "GKWYWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: GKWYWidgetConfigurationIntent.self, provider: GKWYWidgetProvider()) { entry in
            GKWYWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("云音乐推荐")
        .description("快捷享用你的专属音乐，并可自定义精选功能")
    }
}

struct GKWYWidget_Previews: PreviewProvider {
    static var previews: some View {
        GKWYWidgetEntryView(entry: GKWYWidgetEntry(date: Date(), configuration: GKWYWidgetConfigurationIntent(), list: GKWYData.getList()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
