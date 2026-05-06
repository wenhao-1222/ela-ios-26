//
//  DietPlanFoodsAddAlertVM.swift
//  lns
//
//  Created by OpenAI Codex on 2026/3/13.
//

import UIKit
import MCToast
import SnapKit

class DietPlanFoodsAddAlertVM: UIView {
    private static let saveQueue = DispatchQueue(label: "com.lns.dietplan.foods.add.save")
    
    var whiteViewHeight = kFitWidth(256) + WHUtils().getBottomSafeAreaHeight()
    var daysArray = NSMutableArray()
    var todayIndex = 0
    var selectIndex = 0
    var queryDay = ""
    var sourceFoodsArray = NSArray()
    
    var updateBlock: ((String, Int) -> Void)?
    
    private let maxMealCount = 6
    private var preparedDate = ""
    private var preparedDayIndex = 0
    private var preparedMealIndex = 0
    private var hasPreparedSelection = false
    private var rangeStartDate = ""
    private var rangeEndDate = ""
    private lazy var dayCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone.current
        return calendar
    }()
    private lazy var inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    private lazy var displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private var targetDimAlpha: CGFloat {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
        } else {
            return 0.25
        }
    }
    
    private var mealsArray: [String] {
        let allMeals = ["第一餐", "第二餐", "第三餐", "第四餐", "第五餐", "第六餐"]
        let mealCount = max(1, min(UserInfoModel.shared.mealsNumber, maxMealCount))
        return Array(allMeals.prefix(mealCount))
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isHidden = true
        
        buildDaysArray()
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
           !isHidden {
            UIView.animate(withDuration: 0.2) {
                self.bgView.alpha = self.targetDimAlpha
            }
        }
    }
    
    private lazy var bgView: UIView = {
        let view = UIView(frame: bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .COLOR_ALERT_BG_BLACK
        view.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var whiteView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        view.addClipCorner(corners: [.topLeft, .topRight], radius: kFitWidth(10))
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var cancelBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        button.setTitleColor(.COLOR_BG_BLACK_40, for: .highlighted)
        button.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        return button
    }()
    
    lazy var titleLab: UILabel = {
        let label = UILabel()
        label.text = "添加到日志"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    lazy var confirmBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        button.setTitleColor(.COLOR_BG_BLACK_40, for: .highlighted)
        button.addTarget(self, action: #selector(confirmAddAction), for: .touchUpInside)
        return button
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_BG_BLACK_06
        return view
    }()
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 0, y: kFitWidth(50), width: SCREEN_WIDHT, height: kFitWidth(256)))
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
}

extension DietPlanFoodsAddAlertVM {
    func prepare(sdate: String, foodsArray: NSArray, startDate: String, endDate: String) {
        sourceFoodsArray = foodsArray
        updateDateRange(startDate: startDate, endDate: endDate, defaultDate: sdate)
        refreshPicker(defaultDate: sdate)
    }
    
    func preloadDefaultSelection(sdate: String, startDate: String, endDate: String) {
        updateDateRange(startDate: startDate, endDate: endDate, defaultDate: sdate)
        if daysArray.count == 0 {
            buildDaysArray()
        }
        
        let targetDate = clampedDateString(for: normalizedDateString(sdate))
        preparedDate = targetDate
        preparedDayIndex = indexForDate(targetDate)
        let targetDay = daysArray[safeDayIndex(preparedDayIndex)] as? String ?? Date().nextDay(days: 0)
        preparedMealIndex = firstEmptyMealIndex(for: targetDay)
        hasPreparedSelection = true
    }
    
    func showSelf() {
        isHidden = false
        bgView.isUserInteractionEnabled = false
        
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0
        
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.bgView.alpha = self.targetDimAlpha
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
    }
    
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
    
    func refreshPicker(defaultDate: String) {
        pickerView.reloadAllComponents()
        ensurePreparedSelection(for: defaultDate)
        
        selectIndex = safeDayIndex(preparedDayIndex)
        queryDay = daysArray[selectIndex] as? String ?? Date().nextDay(days: 0)
        
        pickerView.selectRow(selectIndex, inComponent: 0, animated: false)
        pickerView.reloadComponent(1)
        pickerView.selectRow(safeMealIndex(preparedMealIndex), inComponent: 1, animated: false)
    }
    
    @objc func confirmAddAction() {
        guard sourceFoodsArray.count > 0 else {
            MCToast.mc_text("食材信息为空")
            return
        }
        
        selectIndex = max(0, pickerView.selectedRow(inComponent: 0))
        queryDay = daysArray[safeDayIndex(selectIndex)] as? String ?? Date().nextDay(days: 0)
        let mealIndex = safeMealIndex(pickerView.selectedRow(inComponent: 1))
        
        hiddenSelf()
        addFoodsToMeal(sDate: queryDay, mealIndex: mealIndex)
    }
    
    @objc func nothingToDo() {
        
    }
}

extension DietPlanFoodsAddAlertVM {
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addShadow()
        
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(confirmBtn)
        whiteView.addSubview(lineView)
        whiteView.addSubview(pickerView)
        
        layoutWhiteViewFrame()
        setConstrait()
    }
    
    private func layoutWhiteViewFrame() {
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
        if #available(iOS 13.0, *) {
            whiteView.layer.cornerCurve = .continuous
        }
        whiteView.layer.masksToBounds = true
    }
    
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(48))
        }
        
        cancelBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(48))
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(cancelBtn)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(48))
            make.height.equalTo(kFitWidth(1))
        }
    }
    
    func buildDaysArray() {
        let arr = NSMutableArray()
        let fallbackDay = Date().nextDay(days: 0)
        let startString = normalizedRangeBoundary(rangeStartDate, fallbackDate: normalizedDateString(preparedDate))
        let endString = normalizedRangeBoundary(rangeEndDate, fallbackDate: startString)
        
        guard let start = date(from: startString),
              let end = date(from: endString) else {
            arr.add(fallbackDay)
            todayIndex = 0
            daysArray = arr
            return
        }
        
        let lowerDate = min(start, end)
        let upperDate = max(start, end)
        let dayCount = dayCalendar.dateComponents([.day], from: lowerDate, to: upperDate).day ?? 0
        
        for offset in 0...max(dayCount, 0) {
            if let date = dayCalendar.date(byAdding: .day, value: offset, to: lowerDate) {
                arr.add(inputDateFormatter.string(from: date))
            }
        }
        
        let todayString = Date().todayDate
        todayIndex = indexForDate(todayString, in: arr)
        daysArray = arr
    }
    
    func ensurePreparedSelection(for sdate: String) {
        let targetDate = clampedDateString(for: normalizedDateString(sdate))
        if hasPreparedSelection == false || preparedDate != targetDate {
            preloadDefaultSelection(sdate: targetDate, startDate: rangeStartDate, endDate: rangeEndDate)
        }
    }
    
    func indexForDate(_ dateString: String) -> Int {
        indexForDate(dateString, in: daysArray)
    }
    
    func normalizedDateString(_ dateString: String) -> String {
        let trimmed = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? Date().nextDay(days: 0) : trimmed
    }
    
    func safeDayIndex(_ index: Int) -> Int {
        guard daysArray.count > 0 else { return 0 }
        return min(max(index, 0), daysArray.count - 1)
    }
    
    func safeMealIndex(_ index: Int) -> Int {
        let maxIndex = max(mealsArray.count - 1, 0)
        return min(max(index, 0), maxIndex)
    }
    
    func updateDateRange(startDate: String, endDate: String, defaultDate: String) {
        let normalizedDefaultDate = normalizedDateString(defaultDate)
        let normalizedStart = normalizedRangeBoundary(startDate, fallbackDate: normalizedDefaultDate)
        let normalizedEnd = normalizedRangeBoundary(endDate, fallbackDate: normalizedStart)
        let rangeChanged = normalizedStart != rangeStartDate || normalizedEnd != rangeEndDate
        
        rangeStartDate = normalizedStart
        rangeEndDate = normalizedEnd
        
        if rangeChanged {
            buildDaysArray()
            hasPreparedSelection = false
        } else if daysArray.count == 0 {
            buildDaysArray()
        }
        
        let clampedDefaultDate = clampedDateString(for: normalizedDefaultDate)
        if preparedDate.isEmpty {
            preparedDate = clampedDefaultDate
        } else {
            preparedDate = clampedDateString(for: preparedDate)
        }
    }
}

extension DietPlanFoodsAddAlertVM: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return daysArray.count
        } else {
            return mealsArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(45)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if component == 0 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: kFitWidth(160), height: kFitWidth(45)))
            label.font = .systemFont(ofSize: 20, weight: .regular)
            label.textAlignment = .center
            label.text = displayText(for: daysArray[row] as? String ?? "")
            
            setUpPickerStyleRowStyle(row: row, component: component)
            return label
        } else {
            let label = UILabel(frame: CGRect(x: kFitWidth(20), y: 0, width: kFitWidth(72), height: kFitWidth(45)))
            label.text = mealsArray[row]
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.font = .systemFont(ofSize: 20, weight: .regular)
            setUpPickerStyleRowStyle(row: row, component: component)
            return label
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectIndex = safeDayIndex(row)
            queryDay = daysArray[selectIndex] as? String ?? Date().nextDay(days: 0)
            let mealIndex = firstEmptyMealIndex(for: queryDay)
            preparedDate = queryDay
            preparedDayIndex = selectIndex
            preparedMealIndex = mealIndex
            hasPreparedSelection = true
            pickerView.reloadComponent(1)
            pickerView.selectRow(mealIndex, inComponent: 1, animated: true)
        } else {
            preparedMealIndex = safeMealIndex(row)
        }
    }
    
    func setUpPickerStyleRowStyle(row: Int, component: Int) {
        DispatchQueue.main.async {
            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
            label?.textColor = .THEME
        }
    }
}

private extension DietPlanFoodsAddAlertVM {
    func date(from dateString: String) -> Date? {
        inputDateFormatter.date(from: dateString)
    }
    
    func normalizedRangeBoundary(_ dateString: String, fallbackDate: String) -> String {
        let normalized = normalizedDateString(dateString)
        return date(from: normalized) == nil ? normalizedDateString(fallbackDate) : normalized
    }
    
    func clampedDateString(for dateString: String) -> String {
        guard daysArray.count > 0 else {
            return normalizedDateString(dateString)
        }
        
        let normalized = normalizedDateString(dateString)
        guard let targetDate = date(from: normalized),
              let firstDay = daysArray.firstObject as? String,
              let lastDay = daysArray.lastObject as? String,
              let firstDate = date(from: firstDay),
              let lastDate = date(from: lastDay) else {
            return daysArray.firstObject as? String ?? normalized
        }
        
        if targetDate < firstDate {
            return firstDay
        }
        
        if targetDate > lastDate {
            return lastDay
        }
        
        return normalized
    }
    
    func indexForDate(_ dateString: String, in source: NSArray) -> Int {
        for index in 0..<source.count {
            if let day = source[index] as? String, day == dateString {
                return index
            }
        }
        
        return 0
    }
    
    func displayText(for dateString: String) -> String {
        if dateString == Date().todayDate {
            return "今天"
        }
        
        if dateString == Date().nextDay(days: 1) {
            return "明天"
        }
        
        guard let date = date(from: dateString) else {
            return dateString
        }
        return displayDateFormatter.string(from: date)
    }
    
    func firstEmptyMealIndex(for sDate: String) -> Int {
        let mealCount = max(1, min(UserInfoModel.shared.mealsNumber, maxMealCount))
        let meals = targetMealsArray(for: sDate)
        
        for index in 0..<mealCount {
            let foodsArray = meals[index] as? NSArray ?? []
            if mealHasFoods(foodsArray) == false {
                return index
            }
        }
        
        return 0
    }
    
    func mealHasFoods(_ foodsArray: NSArray) -> Bool {
        if foodsArray.count == 0 {
            return false
        }
        
        for item in foodsArray {
            let dict = item as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "state") == "1" {
                return true
            }
        }
        
        return foodsArray.count > 0
    }
    
    func targetMealsArray(for sDate: String) -> NSMutableArray {
        let foodsArray = LogsSQLiteManager.getInstance().getLogsByDate(sDate: sDate)?.modelToDict()["foods"] as? NSArray ?? []
        let result = NSMutableArray(array: foodsArray)
        
        while result.count < maxMealCount {
            result.add(NSArray())
        }
        
        return result
    }
    
    func addFoodsToMeal(sDate: String, mealIndex: Int) {
        let targetMeals = targetMealsArray(for: sDate)
        let sourceFoods = buildSourceFoods(mealIndex: mealIndex)
        let targetMealFoods = targetMeals[mealIndex] as? NSArray ?? []
        let mergedFoods = dealTargetMealFoods(foodsArray: sourceFoods, targetFoodsArray: targetMealFoods)
        
        targetMeals.replaceObject(at: mealIndex, with: mergedFoods)
        saveDataToSqlDB(mealsArr: targetMeals, sDate: sDate, mealIndex: mealIndex)
    }
    
    func buildSourceFoods(mealIndex: Int) -> NSArray {
        let result = NSMutableArray()
        
        for index in 0..<sourceFoodsArray.count {
            let foodsMsgDict = sourceFoodsArray[index] as? NSDictionary ?? [:]
            let foodsDict = foodsMsgDict["foods"] as? NSDictionary ?? [:]
            let foodMsg = NSMutableDictionary(dictionary: foodsMsgDict)
            
            if foodMsg.stringValueForKey(key: "qty") == "" || foodMsg.stringValueForKey(key: "qty") == "0" {
                let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: foodsDict)
                
                foodMsg.setValue(normalizedString(foodsDict["fname"]), forKey: "fname")
                foodMsg.setValue(normalizedString(foodsDict["protein"]), forKey: "proteinNumber")
                foodMsg.setValue(normalizedString(foodsDict["carbohydrate"]), forKey: "carbohydrateNumber")
                foodMsg.setValue(normalizedString(foodsDict["fat"]), forKey: "fatNumber")
                foodMsg.setValue(normalizedString(foodsDict["calories"]), forKey: "caloriesNumber")
                foodMsg.setValue(normalizedString(foodsDict["protein"]), forKey: "protein")
                foodMsg.setValue(normalizedString(foodsDict["carbohydrate"]), forKey: "carbohydrate")
                foodMsg.setValue(normalizedString(foodsDict["fat"]), forKey: "fat")
                foodMsg.setValue(normalizedString(foodsDict["calories"]), forKey: "calories")
                foodMsg.setValue(foodsDict, forKey: "foods")
                foodMsg.setValue(specDefault.stringValueForKey(key: "specName"), forKey: "specName")
                foodMsg.setValue(specDefault.stringValueForKey(key: "specName"), forKey: "spec")
                foodMsg.setValue(normalizedString(specDefault["specNum"]), forKey: "weight")
                foodMsg.setValue(normalizedString(specDefault["specNum"]), forKey: "specNum")
                foodMsg.setValue(specDefault.doubleValueForKey(key: "specNum"), forKey: "qty")
            } else {
                if foodsDict.stringValueForKey(key: "fname").count > 0 {
                    foodMsg.setValue(foodsDict.stringValueForKey(key: "fname"), forKey: "fname")
                }
                
                foodMsg.setValue(normalizedString(foodsMsgDict["qty"]), forKey: "weight")
                foodMsg.setValue(normalizedString(foodsMsgDict["qty"]), forKey: "specNum")
                foodMsg.setValue(foodsMsgDict.doubleValueForKey(key: "qty"), forKey: "qty")
                foodMsg.setValue(normalizedString(foodsMsgDict["protein"]), forKey: "proteinNumber")
                foodMsg.setValue(normalizedString(foodsMsgDict["carbohydrate"]), forKey: "carbohydrateNumber")
                foodMsg.setValue(normalizedString(foodsMsgDict["fat"]), forKey: "fatNumber")
                foodMsg.setValue(normalizedString(foodsMsgDict["calories"]), forKey: "caloriesNumber")
                foodMsg.setValue(normalizedString(foodsMsgDict["protein"]), forKey: "protein")
                foodMsg.setValue(normalizedString(foodsMsgDict["carbohydrate"]), forKey: "carbohydrate")
                foodMsg.setValue(normalizedString(foodsMsgDict["fat"]), forKey: "fat")
                foodMsg.setValue(normalizedString(foodsMsgDict["calories"]), forKey: "calories")
                foodMsg.setValue(foodsMsgDict.stringValueForKey(key: "spec"), forKey: "specName")
                foodMsg.setValue(foodsMsgDict.stringValueForKey(key: "spec"), forKey: "spec")
                foodMsg.setValue(foodsDict, forKey: "foods")
            }
            
            if foodMsg.stringValueForKey(key: "fname").isEmpty {
                foodMsg.setValue(foodsDict.stringValueForKey(key: "fname"), forKey: "fname")
            }
            if foodMsg.stringValueForKey(key: "spec").isEmpty {
                let spec = foodsMsgDict.stringValueForKey(key: "spec")
                let fallbackSpec = foodsDict.stringValueForKey(key: "specName")
                foodMsg.setValue(spec.isEmpty ? fallbackSpec : spec, forKey: "spec")
            }
            if foodMsg.stringValueForKey(key: "specName").isEmpty {
                foodMsg.setValue(foodMsg.stringValueForKey(key: "spec"), forKey: "specName")
            }
            
            foodMsg.setValue("1", forKey: "state")
            foodMsg.setValue("1", forKey: "isSelect")
            foodMsg.setValue("1", forKey: "select")
            foodMsg.setValue("\(mealIndex + 1)", forKey: "sn")
            result.add(foodMsg)
        }
        
        return result
    }
    
    func normalizedString(_ value: Any?) -> String {
        if let stringValue = value as? String {
            return stringValue.replacingOccurrences(of: ",", with: ".")
        }
        if let numberValue = value as? NSNumber {
            return numberValue.stringValue.replacingOccurrences(of: ",", with: ".")
        }
        if let doubleValue = value as? Double {
            return "\(doubleValue)".replacingOccurrences(of: ",", with: ".")
        }
        if let floatValue = value as? Float {
            return "\(floatValue)".replacingOccurrences(of: ",", with: ".")
        }
        if let intValue = value as? Int {
            return "\(intValue)"
        }
        return "0"
    }
    
    func dealTargetMealFoods(foodsArray: NSArray, targetFoodsArray: NSArray) -> NSArray {
        let resultFoodsArray = NSMutableArray(array: targetFoodsArray)
        
        for i in 0..<foodsArray.count {
            let dict = NSMutableDictionary(dictionary: foodsArray[i] as? NSDictionary ?? [:])
            if dict.stringValueForKey(key: "isSelect") == "1" {
                let dictFid = dict.stringValueForKey(key: "fid")
                var hasSameFoods = false
                
                for j in 0..<resultFoodsArray.count {
                    let foodsMsg = resultFoodsArray[j] as? NSDictionary ?? [:]
                    let foodsFid = foodsMsg["fid"] as? String ?? "\(foodsMsg["fid"] as? Int ?? -2)"
                    let foodsSpec = foodsMsg["spec"] as? String ?? ""
                    
                    if dictFid != "-1" && dictFid == foodsFid && dict["spec"] as? String ?? "" == foodsSpec {
                        hasSameFoods = true
                        let foodsDict = NSMutableDictionary(dictionary: dict)
                        
                        let calories = dict.doubleValueForKey(key: "calories") + foodsMsg.doubleValueForKey(key: "calories")
                        let carbohydrate = dict.doubleValueForKey(key: "carbohydrate") + foodsMsg.doubleValueForKey(key: "carbohydrate")
                        let protein = dict.doubleValueForKey(key: "protein") + foodsMsg.doubleValueForKey(key: "protein")
                        let fat = dict.doubleValueForKey(key: "fat") + foodsMsg.doubleValueForKey(key: "fat")
                        let qty = dict.doubleValueForKey(key: "qty") + foodsMsg.doubleValueForKey(key: "qty")
                        
                        foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(calories)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                        foodsDict.setValue("\(carbohydrate)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                        foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                        foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                        foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(calories)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "caloriesNumber")
                        foodsDict.setValue("\(carbohydrate)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateNumber")
                        foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "proteinNumber")
                        foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fatNumber")
                        foodsDict.setValue("\(qty)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                        foodsDict.setValue("\(qty)".replacingOccurrences(of: ",", with: "."), forKey: "weight")
                        foodsDict.setValue("\(qty)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                        foodsDict.setValue("1", forKey: "state")
                        foodsDict.setValue("0", forKey: "isSelect")
                        
                        resultFoodsArray.replaceObject(at: j, with: foodsDict)
                        break
                    }
                }
                
                if hasSameFoods == false {
                    let foodsDict = NSMutableDictionary(dictionary: dict)
                    foodsDict.setValue("1", forKey: "state")
                    foodsDict.setValue("0", forKey: "isSelect")
                    resultFoodsArray.add(foodsDict)
                }
            }
        }
        
        return resultFoodsArray
    }
    
    func saveDataToSqlDB(mealsArr: NSArray, sDate: String, mealIndex: Int) {
        Self.saveQueue.async {
            var caloriTotal = Double(0)
            var carboTotal = Double(0)
            var proteinTotal = Double(0)
            var fatTotal = Double(0)
            
            for i in 0..<mealsArr.count {
                let mealPerArr = mealsArr[i] as? NSArray ?? []
                for j in 0..<mealPerArr.count {
                    let dictTemp = mealPerArr[j] as? NSDictionary ?? [:]
                    if dictTemp.stringValueForKey(key: "state") == "1" {
                        caloriTotal += dictTemp.doubleValueForKey(key: "calories")
                        carboTotal += dictTemp.doubleValueForKey(key: "carbohydrate")
                        proteinTotal += dictTemp.doubleValueForKey(key: "protein")
                        fatTotal += dictTemp.doubleValueForKey(key: "fat")
                    }
                }
            }
            
            caloriTotal = String(format: "%.0f", caloriTotal.rounded()).doubleValue
            carboTotal = String(format: "%.0f", carboTotal.rounded()).doubleValue
            proteinTotal = String(format: "%.0f", proteinTotal.rounded()).doubleValue
            fatTotal = String(format: "%.0f", fatTotal.rounded()).doubleValue
            
            LogsSQLiteManager.getInstance().updateLogs(sDate: sDate,
                                                       eTime: Date().currentSeconds,
                                                       foods: WHUtils.getJSONStringFromArray(array: mealsArr),
                                                       caloriNum: "\(caloriTotal)",
                                                       proteinNum: "\(proteinTotal)",
                                                       carboNum: "\(carboTotal)",
                                                       fatsNum: "\(fatTotal)")
            LogsSQLiteManager.getInstance().updateMealsTime(foodsArray: mealsArr, sDate: sDate)
            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: sDate, update: false)
            // Batch rapid local saves for the same day, then upload once to avoid optimistic lock conflicts.
            LogsSQLiteUploadManager().scheduleUploadLogsBySDate(sdate: sDate)
            LogsMealsAlertSetManage().refreshClockAlertMsg()
            
            DispatchQueue.main.async {
                WidgetUtils().reloadWidgetData()
                self.updateBlock?(sDate, mealIndex)
                self.navigateToLogsRoot(sDate: sDate)
//                MCToast.mc_text("已添加到日志")
            }
        }
    }
    
    func navigateToLogsRoot(sDate: String) {
        if let tabBarController = findTabBarController() {
            if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
                selectedNavigationController.popToRootViewController(animated: true)
            } else if let selectedViewController = tabBarController.selectedViewController?.navigationController {
                selectedViewController.popToRootViewController(animated: true)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dietPlanFoodsAddToLogs"),
                                            object: nil,
                                            userInfo: ["sdate": sDate])
        }
    }
    
    func findTabBarController() -> UITabBarController? {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        return findTabBarController(from: keyWindow?.rootViewController)
    }
    
    func findTabBarController(from viewController: UIViewController?) -> UITabBarController? {
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        if let navigationController = viewController as? UINavigationController {
            return findTabBarController(from: navigationController.viewControllers.first)
        }
        if let tabBarController = viewController?.tabBarController {
            return tabBarController
        }
        for child in viewController?.children ?? [] {
            if let tabBarController = findTabBarController(from: child) {
                return tabBarController
            }
        }
        if let presentedViewController = viewController?.presentedViewController {
            return findTabBarController(from: presentedViewController)
        }
        return nil
    }
}
