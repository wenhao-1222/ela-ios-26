//
//  ElaWeekProteinWidget.swift
//  ElaWeekProteinWidget
//
//  Created by LNS2 on 2024/8/19.
//

import WidgetKit
import SwiftUI

struct ElaWeekProteinWidgetEntryView: View {
    let entry: Provider.Entry

    var body: some View {
        ElaWeekRemainingWidgetEntryView(entry: entry, metric: .protein)
    }
}

struct ElaWeekProteinWidget: Widget {
    let kind: String = "ElaWeekProteinWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaWeekProteinWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WeekRemainingWidgetBackground(metric: .protein)
                    }
                    .edgesIgnoringSafeArea(.all)
            } else {
                ElaWeekProteinWidgetEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .configurationDisplayName("蛋白质")
        .description("今日剩余")
        .supportedFamilies([.systemSmall])
        .disableContentMarginsIfNeeded()
    }
}
