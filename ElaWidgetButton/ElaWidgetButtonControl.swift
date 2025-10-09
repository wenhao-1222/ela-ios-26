//
//  ElaWidgetButtonControl.swift
//  ElaWidgetButton
//
//  Created by Elavatine on 2024/9/25.
//

import AppIntents
import SwiftUI
import WidgetKit

struct ElaWidgetButtonControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "ElaWidgetButtonControl") {
            //Label("Elavatine", systemImage: "e.circle")  // e.circle.fill
            ControlWidgetButton(action: LaunchAppIntent()) { // <-- HERE
//                Image("control_widget_icon")
                Image(systemName: "e.circle.fill")
                    .tint(Color.blue)
                Text("Elavatine")
                Text("快速记录饮食")
            }
             
        }
        .displayName("快速记录饮食")
    }
}

extension ElaWidgetButtonControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }
}

struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start a timer"

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Start / stop the timer based on `value`.
        return .result()
    }
}

struct OpenContainerAction: AppIntent {
    
    // // 本地化字符串资源
    static let title: LocalizedStringResource = "WidgetButton"
    // 定义了执行意图时的操作。
    func perform() async throws -> some IntentResult & OpensIntent {
        // 保存数据到Group App容器，传递给主应用
        if let appGroupDefaults = UserDefaults(suiteName: "group.com.apple.iNFC") {
            if appGroupDefaults.bool(forKey: "widgetExtensionData") {
                appGroupDefaults.set(false, forKey: "widgetExtensionData")
            } else {
                appGroupDefaults.set(true, forKey: "widgetExtensionData")
            }
        }
        // 重要：打开容器App的操作
        return .result(opensIntent: OpenURLIntent(URL(string: "elavatinelns://")!))
    }
}

