//
//  MealAdviceNextViewModel.swift
//  lns
//
//  Created by Codex on 2026/8/10.
//

import Foundation

/// 下餐规划页的核心营养素状态。
struct MealAdviceNextCoreMetricState {
    /// 营养素的唯一键。
    let key: String
    /// 营养素的展示名称。
    let title: String
    /// 营养素的单位。
    let unit: String
    /// 当前选中食物的总摄入。
    let selectedValue: Double
    /// 今天的目标值。
    let targetValue: Double

    /// 当前剩余值，最小不小于 0。
    var remainingValue: Double {
        max(targetValue - selectedValue, 0)
    }
}

/// 下餐规划页的单个食物状态。
final class MealAdviceNextFoodItemViewModel {

    /// 用于计算比例的基础食物字典。
    private let baseFoodDict: NSDictionary
    /// 当前数量的基础数量。
    private let baseQuantity: Double
    /// 当前展示的单位。
    private let unitName: String

    /// 食物名称。
    let displayName: String
    /// 当前是否被选中。
    private(set) var isSelected: Bool
    /// 当前数量。
    private(set) var currentQuantity: Double
    /// 当前按数量换算后的全部营养值。
    private(set) var currentNutritionValues: [String: Double] = [:]
    /// 当前用于添加到日志的完整字典。
    private(set) var currentPayload: NSMutableDictionary = NSMutableDictionary()

    /// 创建一个食物状态对象。
    /// - Parameter rawDict: 接口返回的单个食物字典。
    init(rawDict: NSDictionary) {
        baseFoodDict = MealAdviceNextFoodItemViewModel.normalizedFoodDict(from: rawDict)
        displayName = MealAdviceNextFoodItemViewModel.displayName(from: baseFoodDict)
        isSelected = MealAdviceNextFoodItemViewModel.initialSelection(from: rawDict)
        unitName = MealAdviceNextFoodItemViewModel.unitName(from: baseFoodDict)
        baseQuantity = MealAdviceNextFoodItemViewModel.baseQuantity(from: baseFoodDict, unitName: unitName)
        currentQuantity = baseQuantity
        rebuildState()
    }

    /// 切换当前食物的勾选状态。
    func toggleSelection() {
        isSelected.toggle()
        rebuildState()
    }

    /// 更新当前数量。
    /// - Parameter text: 输入框里的数量文本。
    func updateQuantity(text: String) {
        let normalizedText = text.replacingOccurrences(of: ",", with: ".")
        guard let quantity = Double(normalizedText), quantity > 0 else { return }
        currentQuantity = quantity
        rebuildState()
    }

    /// 恢复到接口返回时的原始数量。
    func restoreOriginalQuantity() {
        currentQuantity = baseQuantity
        rebuildState()
    }

    /// 返回当前数量的展示文本。
    var quantityText: String {
        displayQuantityText(from: currentQuantity)
    }

    /// 返回当前卡路里的展示文本。
    var caloriesText: String {
        integerText(from: currentNutritionValues["calories"] ?? 0)
    }

    /// 返回当前单位。
    var displayUnitText: String {
        unitName
    }

    /// 返回当前勾选图标名称。
    var selectionIconName: String {
        isSelected ? "question_foods_selected_icon" : "question_foods_normal_icon"
    }

    /// 返回用于日志回传的完整字典。
    func payloadForLogs() -> NSDictionary {
        currentPayload
    }

    /// 重建当前数量、营养值和回传字典。
    private func rebuildState() {
        currentNutritionValues = scaledNutritionValues()
        currentPayload = buildPayload()
    }

    /// 计算当前数量下的全部营养值。
    private func scaledNutritionValues() -> [String: Double] {
        var values: [String: Double] = [:]
        let divisor = max(baseQuantity, 1)

        for item in FoodsNutritionCatalog.shared.flatItems {
            let baseValue = numericValue(in: baseFoodDict, key: item.key)
            guard baseValue > 0 else { continue }
            values[item.key] = baseValue / divisor * currentQuantity
        }

        let coreKeys = ["calories", "carbohydrate", "protein", "fat"]
        for key in coreKeys where values[key] == nil {
            values[key] = numericValue(in: baseFoodDict, key: key) / divisor * currentQuantity
        }
        return values
    }

    /// 构造用于日志添加的字典。
    private func buildPayload() -> NSMutableDictionary {
        let payload = NSMutableDictionary(dictionary: baseFoodDict)
        let quantityText = displayQuantityText(from: currentQuantity)

        payload.setValue(displayName, forKey: "fname")
        payload.setValue(baseFoodDict.stringValueForKey(key: "fid"), forKey: "fid")
        payload.setValue(quantityText, forKey: "qty")
        payload.setValue(quantityText, forKey: "specNum")
        payload.setValue(quantityText, forKey: "weight")
        payload.setValue(unitName, forKey: "spec")
        payload.setValue(unitName, forKey: "specName")
        payload.setValue(isSelected ? "1" : "0", forKey: "select")
        payload.setValue(isSelected ? "1" : "0", forKey: "state")
        payload.setValue(baseFoodDict, forKey: "foods")

        for item in FoodsNutritionCatalog.shared.flatItems {
            let value = currentNutritionValues[item.key] ?? 0
            payload.setValue(formattedNutritionText(value, fractionDigits: item.displayMaximumFractionDigits), forKey: item.key)
        }

        payload.setValue(integerText(from: currentNutritionValues["calories"] ?? 0), forKey: "calories")
        payload.setValue(formattedNutritionText(currentNutritionValues["carbohydrate"] ?? 0, fractionDigits: 1), forKey: "carbohydrate")
        payload.setValue(formattedNutritionText(currentNutritionValues["protein"] ?? 0, fractionDigits: 1), forKey: "protein")
        payload.setValue(formattedNutritionText(currentNutritionValues["fat"] ?? 0, fractionDigits: 1), forKey: "fat")
        payload.setValue(integerText(from: currentNutritionValues["calories"] ?? 0), forKey: "caloriesNumber")
        payload.setValue(formattedNutritionText(currentNutritionValues["carbohydrate"] ?? 0, fractionDigits: 1), forKey: "carbohydrateNumber")
        payload.setValue(formattedNutritionText(currentNutritionValues["protein"] ?? 0, fractionDigits: 1), forKey: "proteinNumber")
        payload.setValue(formattedNutritionText(currentNutritionValues["fat"] ?? 0, fractionDigits: 1), forKey: "fatNumber")
        return payload
    }

    /// 判断初始状态是否选中。
    /// - Parameter rawDict: 接口返回的单个食物字典。
    private static func initialSelection(from rawDict: NSDictionary) -> Bool {
        let hasSelectKey = rawDict.allKeys.contains { ($0 as? String) == "select" }
        let hasStateKey = rawDict.allKeys.contains { ($0 as? String) == "state" }
        let selectValue = rawDict.doubleValueForKey(key: "select")
        let stateValue = rawDict.doubleValueForKey(key: "state")
        if hasSelectKey || hasStateKey {
            return selectValue > 0 || stateValue > 0
        }
        return true
    }

    /// 获取单位名称。
    /// - Parameter dict: 食物基础字典。
    private static func unitName(from dict: NSDictionary) -> String {
        let defaultSpec = WHUtils.getSpecDefaultFromFoods(foodsDict: dict)
        let defaultName = defaultSpec.stringValueForKey(key: "specName")
        if defaultName.count > 0 { return defaultName }
        let specName = dict.stringValueForKey(key: "spec")
        if specName.count > 0 && specName.contains("[") == false { return specName }
        return "g"
    }

    /// 获取基础数量。
    /// - Parameters:
    ///   - dict: 食物基础字典。
    ///   - unitName: 当前单位名称。
    private static func baseQuantity(from dict: NSDictionary, unitName: String) -> Double {
        let currentQty = dict.doubleValueForKey(key: "qty")
        if currentQty > 0 { return currentQty }

        let defaultSpec = WHUtils.getSpecDefaultFromFoods(foodsDict: dict)
        let defaultQty = defaultSpec.doubleValueForKey(key: "specNum")
        if defaultQty > 0 { return defaultQty }

        if unitName == "g" || unitName == "克" || unitName == "ml" || unitName == "毫升" {
            return 100
        }
        return 1
    }

    /// 获取食物展示名称。
    /// - Parameter dict: 食物基础字典。
    private static func displayName(from dict: NSDictionary) -> String {
        let fname = dict.stringValueForKey(key: "fname")
        if fname.count > 0 { return fname }
        let name = dict.stringValueForKey(key: "name")
        if name.count > 0 { return name }
        return ""
    }

    /// 规范化接口返回的食物字典。
    /// - Parameter dict: 原始字典。
    private static func normalizedFoodDict(from dict: NSDictionary) -> NSDictionary {
        if let foodsDict = dict["foods"] as? NSDictionary, foodsDict.count > 0 {
            return foodsDict
        }
        return dict
    }

    /// 读取指定字段的数值。
    /// - Parameters:
    ///   - dict: 数据字典。
    ///   - key: 字段名。
    private func numericValue(in dict: NSDictionary, key: String) -> Double {
        let rawValue = dict[key]
        if let number = rawValue as? NSNumber {
            return number.doubleValue
        }
        if let stringValue = rawValue as? String {
            return Double(stringValue.replacingOccurrences(of: ",", with: ".")) ?? 0
        }
        return 0
    }

    /// 格式化为整数展示。
    /// - Parameter value: 原始数值。
    private func integerText(from value: Double) -> String {
        String(Int(value.rounded()))
    }

    /// 按指定小数位格式化文本。
    /// - Parameters:
    ///   - value: 原始数值。
    ///   - fractionDigits: 最大小数位数。
    private func formattedNutritionText(_ value: Double, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.usesGroupingSeparator = false
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = max(fractionDigits, 0)
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// 格式化数量文本，去掉多余的尾随零。
    /// - Parameter value: 原始数量。
    private func displayQuantityText(from value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.usesGroupingSeparator = false
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

/// 下餐规划页的核心数据管理器。
final class MealAdviceNextViewModel {

    /// 接口返回的原始结果字典。
    private let responseDict: NSDictionary
    /// 本次计划对应的日志日期。
    let sDate: String
    /// 今天的营养目标。
    private let goalNutritionDict: NSDictionary
    /// 当前页面的所有食物状态。
    private(set) var foodItems: [MealAdviceNextFoodItemViewModel] = []
    /// 当前已选中食物的全部营养总量。
    private(set) var selectedNutritionTotals: [String: Double] = [:]

    /// 创建页面数据管理器。
    /// - Parameters:
    ///   - responseDict: 接口返回结果字典。
    ///   - sDate: 从日志页进入时的日期。
    init(responseDict: NSDictionary, sDate: String) {
        self.responseDict = responseDict
        self.sDate = sDate
        self.goalNutritionDict = NutritionDefaultModel.shared.getTodayGoal()
        reloadData()
    }

    /// 是否至少勾选了一个食物。
    var hasSelectedFoods: Bool {
        foodItems.contains(where: { $0.isSelected })
    }

    /// 刷新接口结果并重建页面数据。
    func reloadData() {
        foodItems = buildFoodItems()
        refreshSelectedTotals()
    }

    /// 切换某一行食物的勾选状态。
    /// - Parameter index: 食物索引。
    func toggleSelection(at index: Int) {
        guard foodItems.indices.contains(index) else { return }
        foodItems[index].toggleSelection()
        refreshSelectedTotals()
    }

    /// 更新某一行食物的数量。
    /// - Parameters:
    ///   - index: 食物索引。
    ///   - text: 输入框中的数量文本。
    func updateQuantity(at index: Int, text: String) {
        guard foodItems.indices.contains(index) else { return }
        foodItems[index].updateQuantity(text: text)
        refreshSelectedTotals()
    }

    /// 恢复某一行食物的原始数量。
    /// - Parameter index: 食物索引。
    func restoreQuantity(at index: Int) {
        guard foodItems.indices.contains(index) else { return }
        foodItems[index].restoreOriginalQuantity()
        refreshSelectedTotals()
    }

    /// 返回用于添加到日志的食物数组。
    func selectedFoodPayloads() -> [NSDictionary] {
        foodItems
            .filter { $0.isSelected }
            .map { $0.payloadForLogs() }
    }

    /// 返回顶部的四个核心营养状态。
    var coreMetricStates: [MealAdviceNextCoreMetricState] {
        [
            coreMetricState(key: "calories", title: "热量", unit: "千卡"),
            coreMetricState(key: "carbohydrate", title: "碳水", unit: "g"),
            coreMetricState(key: "protein", title: "蛋白质", unit: "g"),
            coreMetricState(key: "fat", title: "脂肪", unit: "g")
        ]
    }

    /// 构造当前核心营养状态。
    /// - Parameters:
    ///   - key: 营养素字段名。
    ///   - title: 展示名称。
    ///   - unit: 展示单位。
    private func coreMetricState(key: String, title: String, unit: String) -> MealAdviceNextCoreMetricState {
        let selectedValue = selectedNutritionTotals[key] ?? 0
        let targetValue = goalValue(for: key)
        return MealAdviceNextCoreMetricState(key: key, title: title, unit: unit, selectedValue: selectedValue, targetValue: targetValue)
    }

    /// 构造食物状态数组。
    private func buildFoodItems() -> [MealAdviceNextFoodItemViewModel] {
        let rawFoodArray = readFoodArray()
        return rawFoodArray.map { MealAdviceNextFoodItemViewModel(rawDict: $0) }
    }

    /// 读取接口返回的食物数组。
    private func readFoodArray() -> [NSDictionary] {
        if let foodsArray = responseDict["foods"] as? NSArray {
            return foodsArray.compactMap { $0 as? NSDictionary }
        }
        if let dataArray = responseDict["data"] as? NSArray {
            return dataArray.compactMap { $0 as? NSDictionary }
        }
        return []
    }

    /// 刷新当前选中食物的总营养。
    private func refreshSelectedTotals() {
        var totals: [String: Double] = [:]

        for item in foodItems where item.isSelected {
            for (key, value) in item.currentNutritionValues {
                totals[key, default: 0] += value
            }
        }

        for item in FoodsNutritionCatalog.shared.flatItems {
            totals[item.key, default: 0] += 0
        }

        selectedNutritionTotals = totals
    }

    /// 获取核心营养的目标值。
    /// - Parameter key: 核心营养字段名。
    private func goalValue(for key: String) -> Double {
        let goalKeys: [String]
        switch key {
        case "calories":
            goalKeys = ["calories"]
        case "carbohydrate":
            goalKeys = ["carbohydrate", "carbohydrates"]
        case "protein":
            goalKeys = ["protein", "proteins"]
        case "fat":
            goalKeys = ["fat", "fats"]
        default:
            goalKeys = [key]
        }

        for goalKey in goalKeys {
            if let value = goalNutritionDict[goalKey] {
                if let number = value as? NSNumber {
                    return number.doubleValue
                }
                if let stringValue = value as? String {
                    return Double(stringValue.replacingOccurrences(of: ",", with: ".")) ?? 0
                }
            }
        }

        switch key {
        case "calories":
            return Double(NutritionDefaultModel.shared.calories) ?? 0
        case "carbohydrate":
            return Double(NutritionDefaultModel.shared.carbohydrate) ?? 0
        case "protein":
            return Double(NutritionDefaultModel.shared.protein) ?? 0
        case "fat":
            return Double(NutritionDefaultModel.shared.fat) ?? 0
        default:
            return 0
        }
    }
}
