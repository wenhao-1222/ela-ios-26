//
//  ElaLiveActivityWidget.swift
//  ElaLiveActivityWidget
//
//  Created by Elavatine on 2025/5/28.
//

import ActivityKit
import WidgetKit
import SwiftUI

/// View used in both lock screen and Dynamic Island
@available(iOSApplicationExtension 16.1, *)
struct LiveActivityContentView: View {
    var context: ActivityViewContext<ElaLiveActivityAttributes>

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                LiveActivityCaloriesRingView(caloriesTarget: context.state.caloriesTarget,
                                             calories: context.state.calories)
                    .frame(width: 40, height: 40)
                HStack {
                    LiveActivityMacroRingView(target: context.state.carbsTarget,
                                              current: context.state.carbs,
                                              themeColor: Color(UIColor.COLOR_CARBOHYDRATE),
                                              fillColor: Color(UIColor.COLOR_CARBOHYDRATE_FILL))
                        .frame(width: 24, height: 24)
                    LiveActivityMacroRingView(target: context.state.proteinTarget,
                                              current: context.state.protein,
                                              themeColor: Color(UIColor.COLOR_PROTEIN),
                                              fillColor: Color(UIColor.COLOR_PROTEIN_FILL))
                        .frame(width: 24, height: 24)
                    LiveActivityMacroRingView(target: context.state.fatTarget,
                                              current: context.state.fat,
                                              themeColor: Color(UIColor.COLOR_FAT),
                                              fillColor: Color(UIColor.COLOR_FAT_FILL))
                        .frame(width: 24, height: 24)
                }
            }
//            if context.attributes.showWater {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                    Text("550 ml")
                        .font(.caption2)
                }
//            }
        }
    }
}

@main
struct ElaLiveActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        ElaLiveActivityWidget()
    }
}

struct ElaLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ElaLiveActivityAttributes.self) { context in
            LiveActivityContentView(context: context)
                            .padding(4)
                            .activityBackgroundTint(Color.cyan)
                            .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                                   LiveActivityContentView(context: context)
                               }
            } compactLeading: {
                Text("\(context.state.calories)")
            } compactTrailing: {
                Text("550")
            } minimal: {
                Image(systemName: "flame")
            }
        }
    }
}
