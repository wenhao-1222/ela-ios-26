//
//  DietPlanCreateAllergyVM.swift
//  lns
//
//  Created by Codex on 2026/2/26.
//

class DietPlanCreateAllergyVM: UIView {

    var selectedIndex = -1
    var selectedIndexes: Set<Int> = []
    var selectedBlock: (() -> ())?

    private let fullDataArray: [String] = ["无", "花生", "坚果", "乳制品", "豆制品", "海鲜", "猪肉"]
    private let uricAcidDefaultTitles: [String] = ["豆制品", "海鲜"]
    var dataArray: [String] = ["无", "花生", "坚果", "乳制品", "豆制品", "海鲜", "猪肉"]

    private var itemViews: [DietPlanCreateItemVM] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        clipsToBounds = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "你是否有过敏或忌口？"
        lab.text = "再次确认你的忌口食物"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.showsVerticalScrollIndicator = false
        return scro
    }()

    lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()
    
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    
    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    
    lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    
    lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
}

extension DietPlanCreateAllergyVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(scrollView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        setConstraint()
        applyGoalFilter()
    }

    func setConstraint() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe + kFitWidth(58)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(59))
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(35))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(nextButtonTopOffset + kFitWidth(8)))
        }
        
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollView.snp.top)
            make.height.equalTo(kFitWidth(35))
        }
        
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.bottom)
            make.height.equalTo(kFitWidth(35))
        }

        contentView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.top.equalTo(kFitWidth(28))
            make.bottom.equalTo(kFitWidth(-28))
            make.width.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(2))
            make.bottom.equalToSuperview().offset(kFitWidth(-2))
        }
    }

    func refreshListUI() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemViews.removeAll()

        for (index, title) in dataArray.enumerated() {
            let itemVm = DietPlanCreateItemVM(frame: .zero)
            itemVm.updateUI(title: title, isSelected: selectedIndexes.contains(index))
            itemVm.tapBlock = { [weak self] in
                self?.selectItem(index: index)
            }
            stackView.addArrangedSubview(itemVm)
            itemVm.snp.makeConstraints { make in
                make.height.equalTo(itemVm.selfHeight)
            }
            itemViews.append(itemVm)
        }
    }

    func applyGoalFilter() {
        let oldDataArray = dataArray
        let oldSelectedTitles = selectedIndexes.compactMap { index -> String? in
            guard index >= 0, index < oldDataArray.count else { return nil }
            return oldDataArray[index]
        }

        dataArray = fullDataArray

        var newSelectedIndexes: Set<Int> = []
        for title in oldSelectedTitles {
            if let newIndex = dataArray.firstIndex(of: title) {
                newSelectedIndexes.insert(newIndex)
            }
        }
        if shouldApplyLowerUricAcidDefaultSelection {
            newSelectedIndexes = mergedIndexesByAddingTitles(uricAcidDefaultTitles, to: newSelectedIndexes)
        }
        applySelectionState(newSelectedIndexes, notify: true, forceNotify: true)
    }

    func restoreSelection(modelValue: String) {
        let selectedTitles = modelValue
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var restoredIndexes = Set<Int>()
        if selectedTitles.contains("无"), let noneIndex = dataArray.firstIndex(of: "无") {
            restoredIndexes.insert(noneIndex)
        } else {
            for title in selectedTitles {
                if let index = dataArray.firstIndex(of: title) {
                    restoredIndexes.insert(index)
                }
            }
        }
        
        if shouldApplyLowerUricAcidDefaultSelection {
            restoredIndexes = mergedIndexesByAddingTitles(uricAcidDefaultTitles, to: restoredIndexes)
        }
        applySelectionState(restoredIndexes, notify: false)
    }

    func selectItem(index: Int) {
        guard index >= 0 && index < dataArray.count else {
            return
        }
        
        let oldSelectedIndexes = selectedIndexes
        var newSelectedIndexes = selectedIndexes
        
        if index == 0 {
            if newSelectedIndexes.contains(0) {
                newSelectedIndexes.remove(0)
            } else {
                newSelectedIndexes.removeAll()
                newSelectedIndexes.insert(0)
            }
        } else {
            if newSelectedIndexes.contains(index) {
                newSelectedIndexes.remove(index)
            } else {
                newSelectedIndexes.remove(0)
                newSelectedIndexes.insert(index)
            }
        }

        if newSelectedIndexes == oldSelectedIndexes {
            return
        }
        applySelectionState(newSelectedIndexes,
                            previousSelectedIndexes: oldSelectedIndexes,
                            notify: true,
                            shouldRefreshAll: false)
    }

    func applyDefaultSelectionsForLowerUricAcidIfNeeded(notify: Bool = false) {
        guard shouldApplyLowerUricAcidDefaultSelection else {
            syncFoodAllergyModel()
            if notify {
                selectedBlock?()
            }
            return
        }
        let mergedIndexes = mergedIndexesByAddingTitles(uricAcidDefaultTitles, to: selectedIndexes)
        applySelectionState(mergedIndexes, notify: notify)
    }

    func enforceHighUricSelectionsIfNeeded(notify: Bool = false) {
        guard hasHighUricAcidAdjustment else {
            return
        }
        let mergedIndexes = mergedIndexesByAddingTitles(uricAcidDefaultTitles, to: selectedIndexes)
        applySelectionState(mergedIndexes, notify: notify)
    }

    // 后台 foodRestrictions 枚举映射：
    // 1花生 2坚果 3乳制品 4豆制品 5海鲜 6猪肉
    // 规则补充：
    // 1. 若目标包含“降低尿酸”，保留既有后台低嘌呤补充限制
    // 2. 若针对性饮食调整勾选“高尿酸”，强制包含[4,5]
    func buildFoodRestrictions() -> [Int] {
        let selectedTitles = QuestinonaireMsgModel.shared.foodAllergy
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let mapping: [String: Int] = [
            "花生": 1,
            "坚果": 2,
            "乳制品": 3,
            "豆制品": 4,
            "海鲜": 5,
            "猪肉": 6
        ]
        var values = Set<Int>()
        let isLowerUricAcidGoal = QuestinonaireMsgModel.shared.goal.contains("降低尿酸")
        if isLowerUricAcidGoal {
            values.insert(4)
            values.insert(5)
            values.insert(7)
            values.insert(8)
            values.insert(9)
            values.insert(10)
            values.insert(11)
            values.insert(12)
            values.insert(13)
            values.insert(14)
        }
        if hasHighUricAcidAdjustment {
            values.insert(4)
            values.insert(5)
        }
        if !selectedTitles.contains("无") {
            selectedTitles.compactMap { mapping[$0] }.forEach { values.insert($0) }
        }
        return values.sorted()
    }

    private var shouldApplyLowerUricAcidDefaultSelection: Bool {
        return QuestinonaireMsgModel.shared.goal.contains("降低尿酸")
    }

    private var hasHighUricAcidAdjustment: Bool {
        return QuestinonaireMsgModel.shared.specialAdjustmentType
            .split(whereSeparator: { ",，".contains($0) })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .contains("1")
    }

    private func mergedIndexesByAddingTitles(_ titles: [String], to baseIndexes: Set<Int>) -> Set<Int> {
        var result = baseIndexes
        var insertedRestriction = false
        for title in titles {
            guard let index = dataArray.firstIndex(of: title) else {
                continue
            }
            result.insert(index)
            insertedRestriction = true
        }
        if insertedRestriction, let noneIndex = dataArray.firstIndex(of: "无") {
            result.remove(noneIndex)
        }
        return result
    }

    private func applySelectionState(_ newSelectedIndexes: Set<Int>,
                                     previousSelectedIndexes: Set<Int>? = nil,
                                     notify: Bool,
                                     forceNotify: Bool = false,
                                     shouldRefreshAll: Bool = true) {
        let oldSelectedIndexes = previousSelectedIndexes ?? selectedIndexes
        let didChange = newSelectedIndexes != oldSelectedIndexes
        selectedIndexes = newSelectedIndexes
        selectedIndex = selectedIndexes.sorted().first ?? -1
        syncFoodAllergyModel()
        if shouldRefreshAll || itemViews.count != dataArray.count {
            refreshListUI()
        } else {
            updateChangedItemViews(from: oldSelectedIndexes, to: newSelectedIndexes)
        }
        if notify, didChange || forceNotify {
            selectedBlock?()
        }
    }

    private func updateChangedItemViews(from oldSelectedIndexes: Set<Int>, to newSelectedIndexes: Set<Int>) {
        for (index, itemView) in itemViews.enumerated() {
            let oldIsSelected = oldSelectedIndexes.contains(index)
            let newIsSelected = newSelectedIndexes.contains(index)
            guard oldIsSelected != newIsSelected else {
                continue
            }
            itemView.updateUI(title: dataArray[index], isSelected: newIsSelected)
        }
    }

    private func syncFoodAllergyModel() {
        if selectedIndexes.isEmpty {
            QuestinonaireMsgModel.shared.foodAllergy = ""
        } else {
            let selectedTitles = selectedIndexes.sorted().map { dataArray[$0] }
            QuestinonaireMsgModel.shared.foodAllergy = selectedTitles.joined(separator: ",")
        }
    }
}
