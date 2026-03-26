//
//  AICoachReportDemoModels.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import Foundation
import UIKit

struct AICoachReportDemoData {
    let navigationTitle: String
    let navigationDateRange: String
    let reportTitle: String
    let reportDateRange: String
    let targetText: String
    let completenessText: String
    let weeklySummaryTitle: String
    let weeklySummaryLines: [String]
    let confidenceText: String
    let weeklyPotentialTitle: String
    let weeklyPotentialValue: String
    let riskTip: String
    let actionTip: String
    let weightChart: AICoachReportLineChartData
    let calorieChart: AICoachReportBarChartData
    let nutrientChart: AICoachReportGroupedBarChartData
    let trainingChart: AICoachReportTrainingCardData
    let dailyComparisonTable: AICoachReportWeekTableData
    let nextPageTitle: String
    let nextPageItems: [String]
}

struct AICoachReportLineChartData {
    let yAxisTexts: [String]
    let minValue: CGFloat
    let maxValue: CGFloat
    let entries: [AICoachReportLinePoint]
    let footerRows: [AICoachReportFooterRow]
}

struct AICoachReportLinePoint {
    let axisLabel: String
    let plottedValue: CGFloat?
    let valueText: String
}

struct AICoachReportBarChartData {
    let yAxisTexts: [String]
    let maxValue: CGFloat
    let entries: [AICoachReportBarPoint]
    let footerRows: [AICoachReportFooterRow]
}

struct AICoachReportBarPoint {
    let axisLabel: String
    let value: CGFloat?
}

struct AICoachReportGroupedBarChartData {
    let yAxisTexts: [String]
    let maxValue: CGFloat
    let entries: [AICoachReportGroupedBarPoint]
    let legendItems: [AICoachReportLegendItem]
}

struct AICoachReportGroupedBarPoint {
    let axisLabel: String
    let values: [CGFloat]
}

struct AICoachReportLegendItem {
    let title: String
    let valueText: String
    let percentText: String
    let color: UIColor
}

struct AICoachReportTrainingCardData {
    let title: String
    let leftItems: [AICoachReportTrainingItem]
    let rightItems: [AICoachReportTrainingItem]
    let bottomLeftText: String
    let bottomRightText: String
}

struct AICoachReportTrainingItem {
    let title: String
    let count: Int
    let maxCount: Int
}

struct AICoachReportWeekTableData {
    let title: String
    let columnTitles: [String]
    let rows: [AICoachReportWeekTableRow]
}

struct AICoachReportWeekTableRow {
    let values: [String]
}

struct AICoachReportFooterRow {
    let leftText: String
    let rightText: String?
}

enum AICoachReportDemoPalette {
    static let themeBlue = UIColor(hex: "177CF5")
    static let themeBlueDark = UIColor(hex: "1275F0")
    static let themeBlueLight = UIColor(hex: "DCEBFF")
    static let chartFillBlue = UIColor(hex: "D5E8FF")
    static let pageBackground = UIColor(hex: "F5F5F7")
    static let cardBackground = UIColor.white
    static let border = UIColor(hex: "DADDE4")
    static let softPanel = UIColor(hex: "F1F1F2")
    static let grid = UIColor(hex: "E7EAF0")
    static let textPrimary = UIColor(hex: "0f1214")
    static let textSecondary = UIColor(hex: "535761")
    static let textTertiary = UIColor(hex: "8B8F97")
    static let nutrientPurple = UIColor(hex: "8E47F8")
    static let nutrientYellow = UIColor(hex: "F5C51E")
    static let nutrientOrange = UIColor(hex: "FF8A1E")
    static let bulletBlue = UIColor(hex: "007AFF")
}

extension AICoachReportDemoData {
    static let mock = AICoachReportDemoData(
        navigationTitle: "AI 教练分析",
        navigationDateRange: "2026/01/26 – 02/01",
        reportTitle: "ELA AI教练分析报告",
        reportDateRange: "日期： 2026年01月01日 – 2026年01月07日",
        targetText: "目标： 增肌",
        completenessText: "数据完整度： 饮食x/7，体重x/7，力量训练x/7",
        weeklySummaryTitle: "本周概括",
        weeklySummaryLines: [
            "增肌状态在轨道，本周体重 74kg。均值 73.5kg，对",
            "比上周体重 75kg（均值74.6kg），降低 1kg。"
        ],
        confidenceText: "数据综合置信度 高",
        weeklyPotentialTitle: "本周潜力利用率",
        weeklyPotentialValue: "80%",
        riskTip: "潜在卡点：碳水缺口过大",
        actionTip: "最小调整动作：三餐强化主食",
        weightChart: AICoachReportLineChartData(
            yAxisTexts: ["70", "60", "50", "40"],
            minValue: 40,
            maxValue: 70,
            entries: [
                .init(axisLabel: "04/01", plottedValue: 46, valueText: "48"),
                .init(axisLabel: "04/02", plottedValue: 61, valueText: "52"),
                .init(axisLabel: "04/03", plottedValue: 65, valueText: "64"),
                .init(axisLabel: "04/04", plottedValue: 58.5, valueText: "68"),
                .init(axisLabel: "04/05", plottedValue: 48, valueText: "74"),
                .init(axisLabel: "04/06", plottedValue: nil, valueText: ""),
                .init(axisLabel: "04/07", plottedValue: 46.5, valueText: "")
            ],
            footerRows: [
                .init(leftText: "本周体重均值：0 kg", rightText: nil),
                .init(leftText: "周内波动：0%", rightText: nil),
                .init(leftText: "本周体重对比上周下降 0 kg（0%）", rightText: nil)
            ]
        ),
        calorieChart: AICoachReportBarChartData(
            yAxisTexts: ["600", "400", "200", "0"],
            maxValue: 600,
            entries: [
                .init(axisLabel: "04/01", value: 420),
                .init(axisLabel: "04/02", value: 560),
                .init(axisLabel: "04/03", value: 450),
                .init(axisLabel: "04/04", value: 320),
                .init(axisLabel: "04/05", value: 450),
                .init(axisLabel: "04/06", value: nil),
                .init(axisLabel: "04/07", value: 350)
            ],
            footerRows: [
                .init(leftText: "本周热量摄入均值：0 kcal", rightText: nil),
                .init(leftText: "周末：0kcal", rightText: "工作日：0kcal"),
                .init(leftText: "本周热量摄入对比上周下降 0 kcal（0%）", rightText: nil)
            ]
        ),
        nutrientChart: AICoachReportGroupedBarChartData(
            yAxisTexts: ["600", "400", "200", "0"],
            maxValue: 600,
            entries: [
                .init(axisLabel: "04/01", values: [580, 420, 470]),
                .init(axisLabel: "04/02", values: [210, 470, 540]),
                .init(axisLabel: "04/03", values: [270, 320, 160]),
                .init(axisLabel: "04/04", values: [250, 440, 300]),
                .init(axisLabel: "04/05", values: [310, 410, 480]),
                .init(axisLabel: "04/06", values: [310, 120, 140]),
                .init(axisLabel: "04/07", values: [340, 400, 510])
            ],
            legendItems: [
                .init(title: "碳水 240g", valueText: "240g", percentText: "9.85%", color: AICoachReportDemoPalette.nutrientPurple),
                .init(title: "蛋白质 240g", valueText: "240g", percentText: "53.31%", color: AICoachReportDemoPalette.nutrientYellow),
                .init(title: "脂肪 240g", valueText: "240g", percentText: "36.84%", color: AICoachReportDemoPalette.nutrientOrange)
            ]
        ),
        trainingChart: AICoachReportTrainingCardData(
            title: "力量训练部分",
            leftItems: [
                .init(title: "胸", count: 3, maxCount: 3),
                .init(title: "肩", count: 2, maxCount: 3),
                .init(title: "背", count: 1, maxCount: 3),
                .init(title: "手", count: 1, maxCount: 3),
                .init(title: "腹", count: 1, maxCount: 3)
            ],
            rightItems: [
                .init(title: "腿", count: 3, maxCount: 3),
                .init(title: "推", count: 2, maxCount: 3)
            ],
            bottomLeftText: "本周训练天数： 5 天",
            bottomRightText: "休息天数： 2 天"
        ),
        dailyComparisonTable: AICoachReportWeekTableData(
            title: "本周每日体重 & 营养素&热量&消耗对照表",
            columnTitles: ["日期", "体重(kg)", "热量(kcal)", "蛋白(g)", "碳水(g)", "脂肪(g)", "训练标签"],
            rows: [
                .init(values: ["04/01", "73.0", "2050", "128", "210", "58", "胸"]),
                .init(values: ["04/02", "72.8", "2120", "135", "220", "60", "休息"]),
                .init(values: ["04/03", "72.6", "2060", "122", "205", "57", "腿"]),
                .init(values: ["04/04", "72.3", "1980", "130", "185", "55", "背"]),
                .init(values: ["04/05", "72.2", "2850", "140", "360", "78", "胸"]),
                .init(values: ["04/06", "-", "2750", "92", "330", "90", "休息"]),
                .init(values: ["04/07", "72.1", "2300", "125", "240", "68", "腿"])
            ]
        ),
        nextPageTitle: "下周行动建议",
        nextPageItems: [
            "早餐增加 1 份主食，优先米饭、燕麦或全麦面包。",
            "训练后 30 分钟内补充碳水 + 蛋白质，减少恢复延迟。",
            "若连续 3 天热量低于目标，下周把工作日主食总量上调 10%。"
        ]
    )
}
