//
//  AICoachReportDemoModels.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import Foundation
import UIKit

struct AICoachReportListItem: Equatable {
    let reportId: String
    let startDate: String
    let endDate: String

    var navigationDateRangeText: String {
        AICoachReportDateTextBuilder.navigationDateRangeText(startDate: startDate, endDate: endDate)
    }

    var pickerDateRangeText: String {
        AICoachReportDateTextBuilder.pickerDateRangeText(startDate: startDate, endDate: endDate)
    }
}

enum AICoachReportRecommendationStatus: Int {
    case decrease = -1
    case maintain = 0
    case increase = 1

    var defaultTitleText: String {
        switch self {
        case .decrease:
            return "降低摄入"
        case .maintain:
            return "维持当前目标"
        case .increase:
            return "提高摄入"
        }
    }

    var iconName: String? {
        switch self {
        case .decrease:
            return "ai_coach_recommend_down_icon"
        case .maintain:
            return nil
        case .increase:
            return "ai_coach_recommend_up_icon"
        }
    }
}

struct AICoachReportNextWeekRecommendation {
    let buttonNum: Int
    let status: AICoachReportRecommendationStatus
    let titleText: String
    let caloriesValue: Double?
    let carbohydrateValue: Double?
    let proteinValue: Double?
    let fatValue: Double?
    let caloriesText: String
    let carbohydrateText: String
    let proteinText: String
    let fatText: String
    let isValid: Bool

    var primaryButtonTitle: String {
        if status == .maintain {
            return "知道了"
        }
        return buttonNum == 2 ? "仅更新目标" : "更新目标"
    }

    var secondaryButtonTitle: String? {
        guard status != .maintain, buttonNum == 2 else { return nil }
        return "更新目标与食谱"
    }

    static let empty = AICoachReportNextWeekRecommendation(
        buttonNum: 1,
        status: .maintain,
        titleText: "",
        caloriesValue: nil,
        carbohydrateValue: nil,
        proteinValue: nil,
        fatValue: nil,
        caloriesText: "--",
        carbohydrateText: "--",
        proteinText: "--",
        fatText: "--",
        isValid: false
    )
}

enum AICoachReportRecommendationBuilder {
    static func build(from dataDict: NSDictionary) -> AICoachReportNextWeekRecommendation {
        let payload = recommendationPayload(from: dataDict)
        let hasStatus = payload["nextWeekRecommendationStatus"] is NSNumber || payload["nextWeekRecommendationStatus"] is NSString || payload["nextWeekRecommendationStatus"] is String
        let hasTitle = payload.stringValueForKey(key: "nextWeekRecommendationText").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        let hasValue = hasValue(for: "calories", in: payload)
            || hasValue(for: "carbohydrate", in: payload)
            || hasValue(for: "protein", in: payload)
            || hasValue(for: "fat", in: payload)
        let isValid = payload.count > 0 && (hasStatus || hasTitle || hasValue)

        let status = AICoachReportRecommendationStatus(rawValue: Int(payload.doubleValueForKey(key: "nextWeekRecommendationStatus"))) ?? .maintain
        let titleText = preferredRecommendationTitle(from: payload, fallback: status.defaultTitleText)
        let caloriesValue = numericValue(for: "calories", in: payload)
        let carbohydrateValue = numericValue(for: "carbohydrate", in: payload)
        let proteinValue = numericValue(for: "protein", in: payload)
        let fatValue = numericValue(for: "fat", in: payload)

        return AICoachReportNextWeekRecommendation(
            buttonNum: max(Int(payload.doubleValueForKey(key: "buttonNum")), 1),
            status: status,
            titleText: titleText,
            caloriesValue: caloriesValue,
            carbohydrateValue: carbohydrateValue,
            proteinValue: proteinValue,
            fatValue: fatValue,
            caloriesText: numberText(for: caloriesValue),
            carbohydrateText: numberText(for: carbohydrateValue),
            proteinText: numberText(for: proteinValue),
            fatText: numberText(for: fatValue),
            isValid: isValid
        )
    }

    private static func recommendationPayload(from dataDict: NSDictionary) -> NSDictionary {
        if let payload = dataDict["data"] as? NSDictionary {
            return payload
        }
        if let payload = dataDict["data"] as? [String: Any] {
            return payload as NSDictionary
        }
        return dataDict
    }

    private static func preferredRecommendationTitle(from dict: NSDictionary, fallback: String) -> String {
        let text = dict.stringValueForKey(key: "nextWeekRecommendationText").trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? fallback : text
    }

    private static func hasValue(for key: String, in dict: NSDictionary) -> Bool {
        guard let rawValue = dict[key], (rawValue is NSNull) == false else { return false }
        if let stringValue = rawValue as? String {
            return stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
        return true
    }

    private static func numericValue(for key: String, in dict: NSDictionary) -> Double? {
        guard hasValue(for: key, in: dict) else { return nil }
        return dict.doubleValueForKey(key: key)
    }

    private static func numberText(for value: Double?) -> String {
        guard let value else { return "--" }
        return WHUtils.convertStringToStringNoDigit("\(value.rounded())") ?? "\(Int(value.rounded()))"
    }
}

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
    let weeklyInsightText: String
    let nextWeekTopTaskText: String
    let moreInsights: [String]
    let alternativeTasks: [String]
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

enum AICoachReportDateTextBuilder {
    static func buildList(from array: NSArray) -> [AICoachReportListItem] {
        let dictArray = array.compactMap { $0 as? NSDictionary }
        return dictArray.compactMap { dict in
            let reportId = dict.stringValueForKey(key: "id")
            guard reportId.isEmpty == false else { return nil }
            return AICoachReportListItem(
                reportId: reportId,
                startDate: dict.stringValueForKey(key: "startDate"),
                endDate: dict.stringValueForKey(key: "endDate")
            )
        }
    }

    static func navigationDateRangeText(startDate: String, endDate: String) -> String {
        compactRangeText(startDate: startDate, endDate: endDate)
    }

    static func pickerDateRangeText(startDate: String, endDate: String) -> String {
        compactRangeText(startDate: startDate, endDate: endDate)
    }

    private static func compactRangeText(startDate: String, endDate: String) -> String {
        let startText = format(dateString: startDate, targetFormatter: "yyyy/MM/dd")
        let endFullText = format(dateString: endDate, targetFormatter: "yyyy/MM/dd")
        let endMonthDayText = format(dateString: endDate, targetFormatter: "MM/dd")

        guard startText.isEmpty == false, endFullText.isEmpty == false else { return "" }

        let startYear = String(startDate.prefix(4))
        let endYear = String(endDate.prefix(4))
        let endText = (startYear == endYear && endMonthDayText.isEmpty == false) ? endMonthDayText : endFullText
        return "\(startText) – \(endText)"
    }

    private static func format(dateString: String, targetFormatter: String) -> String {
        let trimmedDate = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedDate.isEmpty == false else { return "" }
        return Date().changeDateFormatter(dateString: trimmedDate, formatter: "yyyy-MM-dd", targetFormatter: targetFormatter)
    }
}

enum AICoachReportDemoPalette {
    static let themeBlue = UIColor(hex: "007AFF")
    static let themeBlueDark = UIColor(hex: "007AFF")
    static let themeBlueLight = UIColor(hex: "DCEBFF")
    static let chartFillBlue = UIColor(hex: "007AFF")
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
    static let empty = AICoachReportDemoData(
        navigationTitle: "AI 教练分析",
        navigationDateRange: "",
        reportTitle: "ELA AI教练分析报告",
        reportDateRange: "日期： -",
        targetText: "目标： -",
        completenessText: "数据完整度： 饮食0/7，体重0/7，力量训练0/7",
        weeklySummaryTitle: "本周概括",
        weeklySummaryLines: [],
        confidenceText: "",
        weeklyPotentialTitle: "本周潜力利用率",
        weeklyPotentialValue: "-",
        riskTip: "潜在卡点：-",
        actionTip: "最小调整动作：-",
        weightChart: AICoachReportLineChartData(
            yAxisTexts: [],
            minValue: 0,
            maxValue: 0,
            entries: [],
            footerRows: [
                .init(leftText: "本周体重均值： -", rightText: nil),
                .init(leftText: "周内波动： -", rightText: nil),
                .init(leftText: "本周体重对比上周 -", rightText: nil)
            ]
        ),
        calorieChart: AICoachReportBarChartData(
            yAxisTexts: [],
            maxValue: 0,
            entries: [],
            footerRows: [
                .init(leftText: "本周热量摄入均值： -", rightText: nil),
                .init(leftText: "周末：-", rightText: "工作日：-"),
                .init(leftText: "本周热量摄入对比上周 -", rightText: nil)
            ]
        ),
        nutrientChart: AICoachReportGroupedBarChartData(
            yAxisTexts: [],
            maxValue: 0,
            entries: [],
            legendItems: [
                .init(title: "碳水 -", valueText: "-", percentText: "-", color: AICoachReportDemoPalette.nutrientPurple),
                .init(title: "蛋白质 -", valueText: "-", percentText: "-", color: AICoachReportDemoPalette.nutrientYellow),
                .init(title: "脂肪 -", valueText: "-", percentText: "-", color: AICoachReportDemoPalette.nutrientOrange)
            ]
        ),
        trainingChart: AICoachReportTrainingCardData(
            title: "力量训练",
            leftItems: [],
            rightItems: [],
            bottomLeftText: "本周训练天数： 0 天",
            bottomRightText: "休息天数： 0 天"
        ),
        dailyComparisonTable: AICoachReportWeekTableData(
            title: "本周记录总览",
            columnTitles: ["日期", "体重(kg)", "热量(kcal)", "蛋白(g)", "碳水(g)", "脂肪(g)", "力量训练"],
            rows: []
        ),
        weeklyInsightText: "",
        nextWeekTopTaskText: "",
        moreInsights: [],
        alternativeTasks: [],
        nextPageTitle: "",
        nextPageItems: []
    )

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
                .init(axisLabel: "04/01", plottedValue: 46, valueText: ""),
                .init(axisLabel: "04/02", plottedValue: 61, valueText: ""),
                .init(axisLabel: "04/03", plottedValue: 65, valueText: ""),
                .init(axisLabel: "04/04", plottedValue: 58.5, valueText: ""),
                .init(axisLabel: "04/05", plottedValue: 48, valueText: ""),
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
            title: "力量训练",
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
            bottomLeftText: "本周训练天数： 0 天",
            bottomRightText: "休息天数： 0 天"
        ),
        dailyComparisonTable: AICoachReportWeekTableData(
            title: "本周记录总览",
            columnTitles: ["日期", "体重(kg)", "热量(kcal)", "蛋白(g)", "碳水(g)", "脂肪(g)", "力量训练"],
            rows: [
                .init(values: ["04/01", "73.0", "2050", "128", "210", "58", "胸"]),
                .init(values: ["04/02", "72.8", "2120", "135", "220", "60", "休息"]),
                .init(values: ["04/03", "72.6", "2060", "122", "205", "57", "腿"]),
                .init(values: ["04/04", "72.3", "1980", "130", "185", "55", "背"]),
                .init(values: ["04/05", "72.2", "2850", "140", "360", "78", "胸"]),
                .init(values: ["04/06", "-", "2750", "92", "330", "90", "休"]),
                .init(values: ["04/07", "72.1", "2300", "125", "240", "68", "腿"])
            ]
        ),
        weeklyInsightText: "蛋白质摄入接近目标，优质蛋白来源丰富且多样化。碳水摄入严重不足，仅为目标的38.4%，显著限制增肌合成效率。",
        nextWeekTopTaskText: "优先提升复合碳水摄入，在每餐主食中增加高密度碳水来源，如米饭、燕麦、红薯等。每日至少安排3次主食餐，每次生重60–100克大米或等效碳水；训练后立即补充50克以上快碳（如香蕉+米饭）以促进合成。",
        moreInsights: [
            "总热量缺口高达1366 kcal/天，长期将阻碍肌肉增长。",
            "脂肪摄入虽接近目标，但部分来自加工肉和油炸食品，影响恢复质量。",
            "水果摄入频次高但集中在车厘子等低糖品种，未能有效补碳。"
        ],
        alternativeTasks: [
            "系统性提升热量密度，在现有餐单基础上增加高热量健康食材，如果酱、全脂奶、牛油果。",
            "优化脂肪来源结构，减少炸鱼块、猪油糕等饱和脂肪，替换为三文鱼、坚果、橄榄油等抗炎脂肪。",
            "策略性选择高糖水果，用香蕉、芒果、葡萄替代部分车厘子，在加餐中提供快速碳水支持。"
        ],
        nextPageTitle: "下周行动建议",
        nextPageItems: [
            "早餐增加 1 份主食，优先米饭、燕麦或全麦面包。",
            "训练后 30 分钟内补充碳水 + 蛋白质，减少恢复延迟。",
            "若连续 3 天热量低于目标，下周把工作日主食总量上调 10%。"
        ]
    )
}
