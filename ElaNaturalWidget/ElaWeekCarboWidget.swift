//
//  ElaWeekCarboWidget.swift
//  ElaWeekCarboWidget
//
//  Created by LNS2 on 2024/8/19.
//

import WidgetKit
import SwiftUI

struct ElaWeekCarboWidgetEntryView: View {
    let entry: Provider.Entry

    var body: some View {
        ElaWeekRemainingWidgetEntryView(entry: entry, metric: .carbohydrate)
    }
}

struct ElaWeekCarboWidget: Widget {
    let kind: String = "ElaWeekCarboWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaWeekCarboWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WeekRemainingWidgetBackground(metric: .carbohydrate)
                    }
                    .edgesIgnoringSafeArea(.all)
            } else {
                ElaWeekCarboWidgetEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .configurationDisplayName("碳水化合物")
        .description("今日剩余")
        .supportedFamilies([.systemSmall])
        .disableContentMarginsIfNeeded()
    }
}
