//
//  AICoachReportDemoModels.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import Foundation
import UIKit

struct AICoachReportDemoData {
    let reportTitle: String
    let dateRangeText: String
    let targetText: String
    let completenessText: String
    let weeklySummaryTitle: String
    let weeklySummaryBody: String
    let weeklyPotentialValue: String
    let riskTip: String
    let actionTip: String
    let weightEntries: [AICoachReportPoint]
    let calorieEntries: [AICoachReportPoint]
    let nutrientEntries: [AICoachReportGroupedPoint]
    let trainingEntries: [AICoachReportTrainingItem]
    let weightFootnotes: [String]
    let calorieFootnotes: [String]
    let nutrientFootnotes: [String]
    let trainingFootnotes: [String]
    let actionItems: [String]
}

struct AICoachReportPoint {
    let label: String
    let value: Double
}

struct AICoachReportGroupedPoint {
    let label: String
    let firstValue: Double
    let secondValue: Double
    let thirdValue: Double
}

struct AICoachReportTrainingItem {
    let name: String
    let count: Int
}

enum AICoachReportDemoPalette {
    static let themeBlue = UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1)
    static let themeBlueLight = UIColor(red: 0.87, green: 0.93, blue: 1.00, alpha: 1)
    static let textPrimary = UIColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 1)
    static let textSecondary = UIColor(red: 0.36, green: 0.40, blue: 0.46, alpha: 1)
    static let border = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1)
    static let background = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
    static let cardBackground = UIColor.white
    static let nutrientPurple = UIColor(red: 0.56, green: 0.34, blue: 0.93, alpha: 1)
    static let nutrientYellow = UIColor(red: 0.98, green: 0.79, blue: 0.17, alpha: 1)
    static let nutrientOrange = UIColor(red: 0.99, green: 0.53, blue: 0.15, alpha: 1)
}

extension AICoachReportDemoData {
    static let mock = AICoachReportDemoData(
        reportTitle: "ELA AI教练分析报告",
        dateRangeText: "日期：2026年01月01日 - 2026年01月07日",
        targetText: "目标：增肌",
        completenessText: "数据完整度：饮食7/7，体重7/7，力量训练5/7",
        weeklySummaryTitle: "本周概括",
        weeklySummaryBody: "增肌状态在轨道，本周体重 74kg。对比上周体重 75kg，阶段性下降 1kg，但饮食记录完整、训练频率稳定，整体执行质量较高。",
        weeklyPotentialValue: "80%",
        riskTip: "潜在卡点：碳水缺口过大",
        actionTip: "最小调整动作：三餐强化主食",
        weightEntries: [
            .init(label: "04/01", value: 48),
            .init(label: "04/02", value: 52),
            .init(label: "04/03", value: 64),
            .init(label: "04/04", value: 68),
            .init(label: "04/05", value: 59),
            .init(label: "04/06", value: 48),
            .init(label: "04/07", value: 47)
        ],
        calorieEntries: [
            .init(label: "04/01", value: 420),
            .init(label: "04/02", value: 560),
            .init(label: "04/03", value: 450),
            .init(label: "04/04", value: 320),
            .init(label: "04/05", value: 450),
            .init(label: "04/06", value: 520),
            .init(label: "04/07", value: 350)
        ],
        nutrientEntries: [
            .init(label: "04/01", firstValue: 580, secondValue: 420, thirdValue: 470),
            .init(label: "04/02", firstValue: 210, secondValue: 470, thirdValue: 540),
            .init(label: "04/03", firstValue: 270, secondValue: 320, thirdValue: 160),
            .init(label: "04/04", firstValue: 250, secondValue: 440, thirdValue: 300),
            .init(label: "04/05", firstValue: 310, secondValue: 410, thirdValue: 480),
            .init(label: "04/06", firstValue: 310, secondValue: 120, thirdValue: 140),
            .init(label: "04/07", firstValue: 340, secondValue: 400, thirdValue: 510)
        ],
        trainingEntries: [
            .init(name: "胸", count: 3),
            .init(name: "肩", count: 2),
            .init(name: "背", count: 1),
            .init(name: "手", count: 1),
            .init(name: "腹", count: 1),
            .init(name: "腿", count: 3),
            .init(name: "推", count: 2),
            .init(name: "拉", count: 2)
        ],
        weightFootnotes: [
            "本周体重均值：74.5 kg",
            "上周体重均值：75 kg",
            "本周体重对比上周下降 1 kg（10%）"
        ],
        calorieFootnotes: [
            "本周热量摄入均值：523 kcal",
            "周末：2000 kcal",
            "本周热量摄入对比上周下降 40 kcal（10%）"
        ],
        nutrientFootnotes: [
            "碳水 240g",
            "蛋白质 240g",
            "脂肪 240g"
        ],
        trainingFootnotes: [
            "本周训练天数：5 天",
            "休息天数：2 天"
        ],
        actionItems: [
            "早餐增加 1 份主食，优先米饭、燕麦或全麦面包。",
            "训练后 30 分钟内补充碳水 + 蛋白质，减少恢复延迟。",
            "如果连续 3 天热量低于目标，下周把工作日主食总量上调 10%。"
        ]
    )
}
