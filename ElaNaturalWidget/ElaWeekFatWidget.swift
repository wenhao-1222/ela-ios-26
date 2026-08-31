//
//  ElaWeekFatWidget.swift
//  ElaWeekFatWidget
//
//  Created by LNS2 on 2024/8/19.
//

import WidgetKit
import SwiftUI

struct ElaWeekFatWidgetEntryView: View {
    let entry: Provider.Entry

    var body: some View {
        ElaWeekRemainingWidgetEntryView(entry: entry, metric: .fat)
    }
}

struct ElaWeekFatWidget: Widget {
    let kind: String = "ElaWeekFatWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaWeekFatWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WeekRemainingWidgetBackground(metric: .fat)
                    }
                    .edgesIgnoringSafeArea(.all)
            } else {
                ElaWeekFatWidgetEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .configurationDisplayName("脂肪")
        .description("今日剩余")
        .supportedFamilies([.systemSmall])
        .disableContentMarginsIfNeeded()
    }
}
