//
//  FoodsNutritionCatalog.swift
//  lns
//
//  Created by Codex on 2026/7/16.
//

import Foundation

final class FoodsNutritionCatalog {
    static let shared = FoodsNutritionCatalog()

    enum Section: Int, CaseIterable {
        ///运动表现与神经驱动
        case performanceAndNeuro
        ///深度恢复与结构健康
        case recoveryAndStructure
        ///内分泌与免疫防御
        case endocrineAndImmune
        ///代谢管理与尿酸风险
        case metabolicAndUricAcid
        ///心血管风险预警
        case cardiovascularRisk

        var title: String {
            switch self {
            case .performanceAndNeuro:
                return "运动表现与神经驱动"
            case .recoveryAndStructure:
                return "深度恢复与结构健康"
            case .endocrineAndImmune:
                return "内分泌与免疫防御"
            case .metabolicAndUricAcid:
                return "代谢管理与尿酸风险"
            case .cardiovascularRisk:
                return "心血管风险预警"
            }
        }

        var sortIndex: Int {
            rawValue
        }
    }

    struct Item {
        /// 营养元素展示名称，用于列表、输入工具条和详情展示。
        let title: String
        /// 营养元素在接口参数、本地字典中的字段名。
        let key: String
        /// 数值单位，例如 g、mg、μg。
        let unit: String
        /// 所属营养分组，用于详情页按模块聚合展示。
        let section: Section
        /// 在所属分组内的排序序号。
        let itemSortIndex: Int
        /// 允许输入的最小值。
        let minimumInputValue: Double
        /// 允许输入的最大值，nil 表示不限制上限。
        let maximumInputValue: Double?
        /// 输入时允许保留的最大小数位数。
        let maximumInputFractionDigits: Int
        /// 展示时允许保留的最大小数位数。
        let displayMaximumFractionDigits: Int

        /// 所属分组标题。
        var sectionTitle: String {
            section.title
        }

        /// 全局排序序号，先按分组排序，再按分组内序号排序。
        var sortIndex: Int {
            section.sortIndex * 100 + itemSortIndex
        }

        init(title: String,
             key: String,
             unit: String,
             section: Section,
             itemSortIndex: Int,
             minimumInputValue: Double = 0,
             maximumInputValue: Double? = 99999,
             maximumInputFractionDigits: Int = 4,
             displayMaximumFractionDigits: Int) {
            self.title = title
            self.key = key
            self.unit = unit
            self.section = section
            self.itemSortIndex = itemSortIndex
            self.minimumInputValue = minimumInputValue
            self.maximumInputValue = maximumInputValue
            self.maximumInputFractionDigits = maximumInputFractionDigits
            self.displayMaximumFractionDigits = displayMaximumFractionDigits
        }
    }

    struct SectionItems {
        let section: Section
        let items: [Item]
    }

    let flatItems: [Item]
    let createInputItems: [Item]
    let sectionItems: [SectionItems]
    private let itemMap: [String: Item]

    private init() {
        let items: [Item] = [
            Item(title: "纤维", key: "fibre", unit: "g", section: .metabolicAndUricAcid, itemSortIndex: 1, displayMaximumFractionDigits: 1),
            Item(title: "糖", key: "sugar", unit: "g", section: .metabolicAndUricAcid, itemSortIndex: 2, displayMaximumFractionDigits: 1),
            Item(title: "饱和脂肪", key: "saturatedFat", unit: "g", section: .cardiovascularRisk, itemSortIndex: 1, displayMaximumFractionDigits: 1),
            Item(title: "反式脂肪", key: "transFat", unit: "g", section: .cardiovascularRisk, itemSortIndex: 2, displayMaximumFractionDigits: 1),
            Item(title: "胆固醇", key: "cholesterol", unit: "mg", section: .cardiovascularRisk, itemSortIndex: 3, displayMaximumFractionDigits: 1),
            Item(title: "钠", key: "sodium", unit: "mg", section: .recoveryAndStructure, itemSortIndex: 1, displayMaximumFractionDigits: 1),
            Item(title: "钾", key: "potassium", unit: "mg", section: .recoveryAndStructure, itemSortIndex: 2, displayMaximumFractionDigits: 1),
            Item(title: "钙", key: "calcium", unit: "mg", section: .recoveryAndStructure, itemSortIndex: 3, displayMaximumFractionDigits: 1),
            Item(title: "铁", key: "iron", unit: "mg", section: .recoveryAndStructure, itemSortIndex: 4, displayMaximumFractionDigits: 1),
            Item(title: "维生素 A", key: "vitaminA", unit: "μg", section: .endocrineAndImmune, itemSortIndex: 1, displayMaximumFractionDigits: 1),
            Item(title: "维生素 C", key: "vitaminC", unit: "mg", section: .endocrineAndImmune, itemSortIndex: 2, displayMaximumFractionDigits: 1),
            Item(title: "嘌呤", key: "purine", unit: "mg", section: .metabolicAndUricAcid, itemSortIndex: 3, displayMaximumFractionDigits: 1),
            Item(title: "咖啡因", key: "caffeine", unit: "mg", section: .performanceAndNeuro, itemSortIndex: 1, displayMaximumFractionDigits: 1),
            Item(title: "肌酸", key: "creatine", unit: "mg", section: .performanceAndNeuro, itemSortIndex: 2, displayMaximumFractionDigits: 1)
        ]

        let sortedItems = items.sorted { $0.sortIndex < $1.sortIndex }
        flatItems = sortedItems
        createInputItems = items
        itemMap = Dictionary(uniqueKeysWithValues: sortedItems.map { ($0.key, $0) })

        var groupedItems: [SectionItems] = []
        for section in Section.allCases {
            let sectionItems = sortedItems.filter { $0.section == section }.sorted { $0.itemSortIndex < $1.itemSortIndex }
            if sectionItems.isEmpty == false {
                groupedItems.append(SectionItems(section: section, items: sectionItems))
            }
        }
        sectionItems = groupedItems
    }

    func item(forKey key: String) -> Item? {
        itemMap[key]
    }
}
