//
//  JournalReportDailyNutritionProVM.swift
//  lns
//
//  Created by Codex on 2026/7/21.
//

import UIKit

/// 日报会员态营养详情中的一行展示数据。
private struct JournalReportDailyNutritionTarget {
    /// `FoodsNutritionCatalog` 统一维护的营养素配置，提供名称、key、单位、分组和排序。
    let item: FoodsNutritionCatalog.Item
    /// 用户的目标摄入量，优先从 `UserDefaults.nutritionDefaultMineral` 读取。
    var target: Double
    /// 是否按“上限型营养素”展示进度条。上限型目标表示越接近上限风险越高，所以使用斜条纹样式。
    let useUpperLimitProgressStyle: Bool

    /// 展示名称。维生素 A 在日报中需要带 RAE 标记。
    var title: String {
        if item.key == "vitaminA" {
            return "维生素 A(RAE)"
        }
        return item.title
    }
}

/// 日报营养详情的横向进度条。
/// 普通营养素使用实心进度；风险项或普通项超量部分使用斜条纹覆盖。
private class JournalReportNutritionProgressView: UIView {
    /// 0...1 的实色进度，传入值会在布局时裁剪。
    var solidProgress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 0...1 的斜纹覆盖进度，传入值会在布局时裁剪。
    var stripeProgress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    private let trackView = UIView()
    private let solidFillView = UIView()
    private let stripeFillView = UIView()
    private let stripeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        addSubview(trackView)
        addSubview(solidFillView)
        addSubview(stripeFillView)
        stripeFillView.layer.addSublayer(stripeLayer)
        trackView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        trackView.clipsToBounds = true
        solidFillView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_50
        solidFillView.clipsToBounds = true
        stripeFillView.backgroundColor = .clear
        stripeFillView.clipsToBounds = true
        stripeLayer.fillColor = UIColor.COLOR_TEXT_TITLE_0f1214.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        trackView.frame = bounds
        trackView.layer.cornerRadius = bounds.height/2
        layoutSolidFill()
        layoutStripeFill()
    }

    private func layoutSolidFill() {
        let clampedProgress = min(max(solidProgress, 0), 1)
        solidFillView.isHidden = clampedProgress <= 0
        if clampedProgress <= 0 {
            solidFillView.frame = .zero
            return
        }
        let fillWidth = bounds.width * clampedProgress
        solidFillView.frame = CGRect(x: 0, y: 0, width: fillWidth, height: bounds.height)
        solidFillView.layer.cornerRadius = bounds.height/2
    }

    private func layoutStripeFill() {
        let clampedProgress = min(max(stripeProgress, 0), 1)
        stripeFillView.isHidden = clampedProgress <= 0
        if clampedProgress <= 0 {
            stripeFillView.frame = .zero
            stripeLayer.path = nil
            return
        }
        let fillWidth = bounds.width * clampedProgress
        stripeFillView.frame = CGRect(x: 0, y: 0, width: fillWidth, height: bounds.height)
        stripeFillView.layer.cornerRadius = bounds.height/2
        refreshStripePath()
    }

    /// 在覆盖区域内绘制等宽、等距的平行四边形条纹，覆盖区域由 `stripeProgress` 的宽度决定。
    private func refreshStripePath() {
        guard stripeFillView.bounds.width > 0 else {
            stripeLayer.path = nil
            return
        }

        stripeLayer.frame = stripeFillView.bounds
        let path = UIBezierPath()
        let height = stripeFillView.bounds.height
        let width = stripeFillView.bounds.width
        let stripeWidth = kFitWidth(10)
        let gapWidth = kFitWidth(10)
        let skewOffset = height
        var x = -skewOffset
        while x < width + skewOffset {
            path.move(to: CGPoint(x: x, y: height))
            path.addLine(to: CGPoint(x: x + stripeWidth, y: height))
            path.addLine(to: CGPoint(x: x + stripeWidth + skewOffset, y: 0))
            path.addLine(to: CGPoint(x: x + skewOffset, y: 0))
            path.close()
            x += stripeWidth + gapWidth
        }
        stripeLayer.path = path.cgPath
    }
}

/// 日报会员态营养详情的单个营养素行。
private class JournalReportDailyNutritionRowView: UIView {
    /// 行数据，包含营养素基础配置、目标值和进度条风险样式。
    private var rowData: JournalReportDailyNutritionTarget
    var tapBlock: ((FoodsNutritionCatalog.Item) -> Void)?
    private let rowHeight = kFitWidth(55)
    private let progressHeight = kFitWidth(4)
    private let intakeLabelWidth = kFitWidth(52)
    private let numberLabelWidth = kFitWidth(49)
    private let arrowWidth = kFitWidth(20)
    /// 当前摄入值，来自日报接口 `nutritionDetails`。
    private var intakeValue: Double = 0

    init(rowData: JournalReportDailyNutritionTarget) {
        self.rowData = rowData
        super.init(frame: .zero)
        initUI()
        updateIntake(0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = rowData.title
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.82
        return lab
    }()

    lazy var intakeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.75
        return lab
    }()

    lazy var targetLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.75
        return lab
    }()

    lazy var remainLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.75
        return lab
    }()

    lazy var arrowImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.setImgLocal(imgName: "plan_arrow_gray")
        return img
    }()

    lazy var progressView: JournalReportNutritionProgressView = {
        let vi = JournalReportNutritionProgressView()
        return vi
    }()
}

extension JournalReportDailyNutritionRowView {
    /// 外部布局使用的固定行高。
    var selfHeight: CGFloat {
        rowHeight
    }

    /// 刷新摄入、目标、剩余和进度条样式。
    /// - Parameter intake: 当前摄入值，来自日报接口 `nutritionDetails`。
    func updateIntake(_ intake: Double) {
        intakeValue = intake
        let target = rowData.target
        let remain = target - intake
        intakeLabel.text = displayIntegerText(intake)
        let targetText = displayIntegerText(target)
        targetLabel.text = rowData.useUpperLimitProgressStyle ? "<=\(targetText)" : targetText
        remainLabel.text = displayIntegerText(remain)

        let progress = target > 0 ? CGFloat(intake/target) : (intake > 0 ? 1 : 0)
        if rowData.useUpperLimitProgressStyle {
            let clampedProgress = min(max(progress, 0), 1)
            progressView.solidProgress = clampedProgress
            progressView.stripeProgress = clampedProgress
        } else if target > 0, intake > target {
            progressView.solidProgress = 1
            progressView.stripeProgress = min(max(progress - 1, 0), 1)
        } else {
            progressView.solidProgress = min(max(progress, 0), 1)
            progressView.stripeProgress = 0
        }
    }

    /// 目标缓存从接口刷新后，更新当前行目标并保留已有摄入值重新计算剩余和进度。
    func updateTarget(_ target: Double) {
        rowData.target = target
        updateIntake(intakeValue)
    }

    /// 初始化行内标题、数值、箭头和进度条布局。
    private func initUI() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rowTapAction)))

        addSubview(titleLabel)
        addSubview(intakeLabel)
        addSubview(targetLabel)
        addSubview(remainLabel)
        addSubview(arrowImageView)
        addSubview(progressView)

        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(kFitWidth(10))
            make.width.height.equalTo(arrowWidth)
        }
        remainLabel.snp.makeConstraints { make in
            make.right.equalTo(arrowImageView.snp.left).offset(kFitWidth(-2))
            make.centerY.equalTo(arrowImageView)
            make.width.equalTo(numberLabelWidth)
        }
        targetLabel.snp.makeConstraints { make in
            make.right.equalTo(remainLabel.snp.left).offset(kFitWidth(-8))
            make.centerY.equalTo(remainLabel)
            make.width.equalTo(numberLabelWidth)
        }
        intakeLabel.snp.makeConstraints { make in
            make.right.equalTo(targetLabel.snp.left).offset(kFitWidth(-8))
            make.centerY.equalTo(targetLabel)
            make.width.equalTo(intakeLabelWidth)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.lessThanOrEqualTo(intakeLabel.snp.left).offset(kFitWidth(-8))
            make.centerY.equalTo(intakeLabel)
        }
        progressView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(remainLabel)
            make.top.equalTo(kFitWidth(48))
            make.height.equalTo(progressHeight)
        }
    }

    /// 日报营养详情中的摄入、目标、剩余都展示整数，按四舍五入处理。
    private func displayIntegerText(_ value: Double) -> String {
        return "\(Int(value.rounded()))"
    }

    @objc private func rowTapAction() {
        tapBlock?(rowData.item)
    }
}

/// 日报会员态“营养详情”卡片。
class JournalReportDailyNutritionProVM: UIView {
    /// 白色卡片宽度，与日报其他卡片保持一致。
    private let whiteWidth = SCREEN_WIDHT - kFitWidth(32)
    private let headerHeight = kFitWidth(56)
    private let sectionTitleHeight = kFitWidth(46)
    private let rowHeight = kFitWidth(55)
    private let hintTopGap = kFitWidth(20)
    private let hintHeight = kFitWidth(20)
    private let hintBottomGap = kFitWidth(26)
    /// 分组标题视图集合，便于后续需要刷新样式或复用时定位。
    private var sectionTitleLabels: [UILabel] = []
    /// 按营养素 key 索引的行视图，接口数据回来后可以直接局部刷新。
    private var rowViews: [String: JournalReportDailyNutritionRowView] = [:]
    /// 当前卡片要展示的全部营养素行数据。
    private var rows: [JournalReportDailyNutritionTarget] = []
    /// 最近一次日报接口数据。目标缓存异步刷新后，用它重新刷新摄入、剩余和进度。
    private var reportMsgDict = NSDictionary()
    /// 防止目标缓存缺失时重复触发微量元素目标接口。
    private var isRequestingDefaultMineral = false
    /// 外部容器布局使用的整体高度。
    var selfHeight = kFitWidth(0)
    var hintTapBlock:(()->())?
    var itemTapBlock: ((FoodsNutritionCatalog.Item) -> Void)?

    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: 0))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        buildRows()
        selfHeight = calculatedHeight
        self.frame.size.height = selfHeight
        initUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nutritionDefaultMineralDidChange),
                                               name: NOTIFI_NAME_NUTRITION_DEFAULT_MINERAL_DID_CHANGE,
                                               object: nil)
        requestDefaultMineralIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    lazy var whiteView: UIView = {
        let vi = UIView(frame: CGRect(x: kFitWidth(16), y: 0, width: whiteWidth, height: selfHeight))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        return vi
    }()

    lazy var nameHeadLabel: UILabel = {
        return headLabel("名称", alignment: .left)
    }()

    lazy var totalHeadLabel: UILabel = {
        return headLabel("摄入", alignment: .right)
    }()

    lazy var targetHeadLabel: UILabel = {
        return headLabel("目标", alignment: .right)
    }()

    lazy var remainHeadLabel: UILabel = {
        return headLabel("剩余", alignment: .right)
    }()

    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0
        return vi
    }()

    lazy var hintIconLabel: UILabel = {
        let lab = UILabel()
        lab.text = "?"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_35
        lab.font = .systemFont(ofSize: 10, weight: .medium)
        lab.layer.borderWidth = kFitWidth(1)
        lab.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_35.cgColor
        lab.layer.cornerRadius = kFitWidth(8)
        lab.clipsToBounds = true
        return lab
    }()

    lazy var hintLabel: UILabel = {
        let lab = UILabel()
        lab.text = "Elavatine是如何计算推荐摄入量的?"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_35
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.8
        return lab
    }()
}

extension JournalReportDailyNutritionProVM {
    /// 根据分组数、行数和底部提示计算卡片高度。
    var calculatedHeight: CGFloat {
        var height = headerHeight + kFitWidth(1)
        for section in FoodsNutritionCatalog.shared.sectionItems {
            height += sectionTitleHeight
            height += CGFloat(section.items.count) * rowHeight
        }
        height += hintTopGap + hintHeight + hintBottomGap
        return height
    }

    /// 用日报接口 `nutritionDetails` 刷新摄入值。
    func updateData(reportMsgDict: NSDictionary) {
        self.reportMsgDict = reportMsgDict
        for row in rows {
            let intake = intakeValue(forKey: row.item.key, reportMsgDict: reportMsgDict)
            rowViews[row.item.key]?.updateIntake(intake)
        }
        requestDefaultMineralIfNeeded()
    }

    /// 非今日日志不请求日报接口时，从日志明细中本地汇总其他营养成分摄入值。
    func updateData(dayDict: NSDictionary) {
        self.reportMsgDict = [:]
        for row in rows {
            let intake = intakeValue(for: row.item, dayDict: dayDict)
            rowViews[row.item.key]?.updateIntake(intake)
        }
        requestDefaultMineralIfNeeded()
    }

    /// 按 `FoodsNutritionCatalog.sectionItems` 生成展示行。
    /// 目标值从用户默认微量元素目标缓存读取，缓存不存在或字段缺失时按 0 展示。
    private func buildRows() {
        rows = FoodsNutritionCatalog.shared.sectionItems.flatMap { sectionItems in
            sectionItems.items.map { item in
                let target = targetValue(for: item)
                return JournalReportDailyNutritionTarget(item: item,
                                                         target: target,
                                                         useUpperLimitProgressStyle: upperLimitStyleKeys.contains(item.key))
            }
        }
    }

    /// 目标缓存为空时，主动拉取后台微量元素目标；本地不做默认目标值兜底。
    private func requestDefaultMineralIfNeeded() {
        guard UserDefaults.hasNutritionDefaultMineralCache() == false else { return }
        guard isRequestingDefaultMineral == false else { return }

        isRequestingDefaultMineral = true
        WHNetworkUtil.shareManager().POST(urlString: URL_get_default_nutrition_minerals_get, parameters: nil) { responseObject in
            self.isRequestingDefaultMineral = false
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            UserDefaults.setNutritionDefaultMineral(dataDict)
            self.refreshTargetsFromCache()
        }
    }

    /// 后台目标缓存更新后，重新读取每一行目标值并刷新展示。
    private func refreshTargetsFromCache() {
        buildRows()
        for row in rows {
            rowViews[row.item.key]?.updateTarget(row.target)
            let intake = intakeValue(forKey: row.item.key, reportMsgDict: reportMsgDict)
            rowViews[row.item.key]?.updateIntake(intake)
        }
    }

    @objc private func nutritionDefaultMineralDidChange() {
        refreshTargetsFromCache()
    }

    /// 创建卡片头部、分组标题、营养素行和底部说明。
    private func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(nameHeadLabel)
        whiteView.addSubview(totalHeadLabel)
        whiteView.addSubview(targetHeadLabel)
        whiteView.addSubview(remainHeadLabel)
        whiteView.addSubview(lineView)

        setHeaderConstraints()
        var currentY = headerHeight + kFitWidth(1)
        for section in FoodsNutritionCatalog.shared.sectionItems {
            let sectionLabel = sectionLabel(section.section.title)
            sectionTitleLabels.append(sectionLabel)
            whiteView.addSubview(sectionLabel)
            sectionLabel.frame = CGRect(x: kFitWidth(20), y: currentY, width: whiteWidth - kFitWidth(40), height: sectionTitleHeight)
            currentY += sectionTitleHeight

            for item in section.items {
                guard let rowData = rows.first(where: { $0.item.key == item.key }) else { continue }
                let rowView = JournalReportDailyNutritionRowView(rowData: rowData)
                rowView.tapBlock = { [weak self] item in
                    self?.itemTapBlock?(item)
                }
                rowViews[item.key] = rowView
                whiteView.addSubview(rowView)
                rowView.frame = CGRect(x: kFitWidth(20), y: currentY, width: whiteWidth - kFitWidth(40), height: rowView.selfHeight)
                currentY += rowView.selfHeight
            }
        }

        whiteView.addSubview(hintIconLabel)
        whiteView.addSubview(hintLabel)
        hintIconLabel.frame = CGRect(x: kFitWidth(82), y: currentY + hintTopGap + kFitWidth(2), width: kFitWidth(16), height: kFitWidth(16))
        hintLabel.frame = CGRect(x: hintIconLabel.frame.maxX + kFitWidth(6), y: currentY + hintTopGap, width: whiteWidth - hintIconLabel.frame.maxX - kFitWidth(36), height: hintHeight)

        let hintTapView = UIView(frame: CGRect(x: kFitWidth(56),
                                               y: currentY + kFitWidth(8),
                                               width: whiteWidth - kFitWidth(112),
                                               height: kFitWidth(36)))
        hintTapView.backgroundColor = .clear
        hintTapView.isUserInteractionEnabled = true
        hintTapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hintTapAction)))
        whiteView.addSubview(hintTapView)

        updateData(reportMsgDict: [:])
    }

    /// 设置表头四列和分割线约束。
    private func setHeaderConstraints() {
        nameHeadLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(21))
            make.width.equalTo(kFitWidth(110))
        }
        remainHeadLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-36))
            make.centerY.equalTo(nameHeadLabel)
            make.width.equalTo(kFitWidth(49))
        }
        targetHeadLabel.snp.makeConstraints { make in
            make.right.equalTo(remainHeadLabel.snp.left).offset(kFitWidth(-8))
            make.centerY.equalTo(remainHeadLabel)
            make.width.equalTo(kFitWidth(49))
        }
        totalHeadLabel.snp.makeConstraints { make in
            make.right.equalTo(targetHeadLabel.snp.left).offset(kFitWidth(-8))
            make.centerY.equalTo(targetHeadLabel)
            make.width.equalTo(kFitWidth(52))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(headerHeight)
            make.height.equalTo(kFitWidth(1))
        }
    }

    /// 创建表头列标题。
    private func headLabel(_ text: String, alignment: NSTextAlignment) -> UILabel {
        let lab = UILabel()
        lab.text = text
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textAlignment = alignment
        return lab
    }

    /// 创建分组标题。
    private func sectionLabel(_ text: String) -> UILabel {
        let lab = UILabel()
        lab.text = text
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 15, weight: .semibold)
        return lab
    }

    /// 上限型营养素 key 集合。
    ///
    /// 这些营养素的“目标”更接近安全上限或风险阈值，不是越多越好。
    /// 所以即使当前摄入未超过目标，也按斜条纹进度样式显示，例如饱和脂肪。
    private var upperLimitStyleKeys: Set<String> {
        ["caffeine", "sugar", "purine", "saturatedFat", "transFat", "cholesterol"]
    }

    /// 从 `UserDefaults.nutritionDefaultMineral` 中读取某个营养素的目标值。
    ///
    /// 后端缓存可能是 `{ key: 目标值 }`，也可能是 `{ key: { target: 目标值 } }`
    /// 或列表结构；这里统一做兼容解析，读不到时返回 0。
    private func targetValue(for item: FoodsNutritionCatalog.Item) -> Double {
        let cache = UserDefaults.getDictionary(forKey: .nutritionDefaultMineral) as NSDictionary? ?? [:]
        return targetValue(in: cache, for: item) ?? 0
    }

    /// 在字典缓存中按营养素 key 查找目标值。
    private func targetValue(in dict: NSDictionary, for item: FoodsNutritionCatalog.Item) -> Double? {
        if let value = numberValue(from: dict[item.key]) {
            return value
        }
        if let nestedDict = dict[item.key] as? NSDictionary,
           let value = targetValue(inTargetDict: nestedDict) {
            return value
        }

        for listKey in ["list", "items", "data", "minerals"] {
            guard let array = dict[listKey] as? NSArray,
                  let value = targetValue(in: array, for: item) else { continue }
            return value
        }
        return nil
    }

    /// 在列表缓存中找到匹配营养素 key 的条目，再读取条目的目标字段。
    private func targetValue(in array: NSArray, for item: FoodsNutritionCatalog.Item) -> Double? {
        for element in array {
            guard let dict = element as? NSDictionary else { continue }
            let keys = ["key", "code", "name", "field", "nutritionKey"]
            let isMatched = keys.contains { dict.rawStringValueForKey(key: $0) == item.key }
            guard isMatched else { continue }
            if let value = targetValue(inTargetDict: dict) {
                return value
            }
        }
        return nil
    }

    /// 从单个目标配置字典中读取目标数值。
    private func targetValue(inTargetDict dict: NSDictionary) -> Double? {
        for key in ["target", "targetValue", "value", "default", "amount", "num"] {
            if let value = numberValue(from: dict[key]) {
                return value
            }
        }
        return nil
    }

    /// 将 UserDefaults 中可能出现的 String、NSNumber、Int、Double 等值统一转成 Double。
    private func numberValue(from value: Any?) -> Double? {
        guard let value = value, !(value is NSNull) else { return nil }
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        if let string = value as? String {
            let normalized = string.replacingOccurrences(of: ",", with: ".")
            guard normalized.count > 0 else { return nil }
            return Double(normalized)
        }
        return Double("\(value)".replacingOccurrences(of: ",", with: "."))
    }

    /// 从日报接口数据中读取当前摄入值。
    /// 当前结构为 `nutritionDetails.groupX.<nutritionKey>.intake`，这里按 key 递归查找，避免绑定具体 group 编号。
    private func intakeValue(forKey key: String, reportMsgDict: NSDictionary) -> Double {
        guard let nutritionDetails = reportMsgDict["nutritionDetails"] as? NSDictionary else {
            return 0
        }
        return intakeValue(forKey: key, in: nutritionDetails) ?? 0
    }

    /// 在 `nutritionDetails` 的嵌套字典中查找指定营养素的 intake 字段。
    private func intakeValue(forKey key: String, in dict: NSDictionary) -> Double? {
        if let itemDict = dict[key] as? NSDictionary,
           let intake = numberValue(from: itemDict["intake"]) {
            return intake
        }

        for value in dict.allValues {
            guard let childDict = value as? NSDictionary,
                  let intake = intakeValue(forKey: key, in: childDict) else { continue }
            return intake
        }
        return nil
    }

    /// 优先读当天顶层汇总字段；不存在时遍历 foods 中 state 为 1 的食物累加。
    private func intakeValue(for item: FoodsNutritionCatalog.Item, dayDict: NSDictionary) -> Double {
        if let topLevelValue = nutritionValue(forKey: "\(item.key)Double", in: dayDict) {
            return topLevelValue
        }
        if let topLevelValue = nutritionValue(forKey: item.key, in: dayDict) {
            return topLevelValue
        }

        let mealsArray = dayDict["foods"] as? NSArray ?? []
        var total = Double(0)
        for i in 0..<mealsArray.count {
            let foodsArray = mealsArray[i] as? NSArray ?? []
            for j in 0..<foodsArray.count {
                let foodDict = foodsArray[j] as? NSDictionary ?? [:]
                guard foodDict.stringValueForKey(key: "state") == "1" else { continue }
                total += nutritionValue(forKey: item.key, in: foodDict) ?? 0
            }
        }
        return max(total, 0)
    }

    private func nutritionValue(forKey key: String, in dict: NSDictionary) -> Double? {
        let rawValue = dict.rawStringValueForKey(key: key)
        guard rawValue.count > 0 else { return nil }
        return max(dict.doubleValueForKey(key: key), 0)
    }

    @objc private func hintTapAction() {
        hintTapBlock?()
    }
}
