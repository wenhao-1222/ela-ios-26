//
//  MealAdviceFoodsVM.swift
//  lns
//
//  Created by LNS2 on 2026/8/5.
//

import Foundation
import UIKit
import SnapKit

fileprivate enum MealAdviceFoodListType {
    case recent
    case all
    case my

    var title: String {
        switch self {
        case .recent:
            return "最近添加"
        case .all:
            return "全部食物"
        case .my:
            return "我的食物"
        }
    }
}

final class MealAdviceSelectedFoodChipView: UIView {

    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .custom)
    var onRemove: (() -> Void)?

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = kFitWidth(16)
        clipsToBounds = true

        titleLabel.text = title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        titleLabel.lineBreakMode = .byTruncatingTail

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .COLOR_TEXT_TITLE_0f1214_50
        closeButton.addTarget(self, action: #selector(removeAction), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(closeButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttonSize = kFitWidth(14)
        let closeX = bounds.width - kFitWidth(10) - buttonSize
        closeButton.frame = CGRect(x: closeX, y: (bounds.height - buttonSize) * 0.5, width: buttonSize, height: buttonSize)
        titleLabel.frame = CGRect(x: kFitWidth(12), y: 0, width: max(0, closeX - kFitWidth(10) - kFitWidth(12)), height: bounds.height)
    }

    @objc private func removeAction() {
        onRemove?()
    }
}

final class MealAdviceFoodsVM: UIView {

    var selfHeight = kFitWidth(0)
    var controller = WHBaseViewVC()
    var confirmBlock: ((NSArray) -> Void)?

    private var currentListType: MealAdviceFoodListType = .recent
    private var currentKeyword = ""
    private var requestVersion = 0

    private var recentFoodsArray = NSMutableArray()
    private var allFoodsArray = NSMutableArray()
    private var myFoodsArray = NSMutableArray()
    private var filteredRecentFoodsArray = NSMutableArray()
    private var filteredMyFoodsArray = NSMutableArray()
    private var selectedFoodsArray = NSMutableArray()

    private var selectedChipViews: [MealAdviceSelectedFoodChipView] = []
    private var selectedScrollHeightConstraint: Constraint?
    private let maximumSelectedFoodsCount = 9

    private struct TableViewAnchor {
        let indexPath: IndexPath
        let screenY: CGFloat
        let contentOffsetY: CGFloat
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT - frame.origin.y))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        selfHeight = SCREEN_HEIGHT - frame.origin.y

        initUI()
        reloadCurrentList()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        noDataView.center = CGPoint(x: tableView.bounds.width * 0.5, y: kFitWidth(134))
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bottomGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        topGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "这餐计划吃什么？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textAlignment = .center
        return lab
    }()

    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "选择食物后，我们会根据今天的剩余营养目标\n推荐这一餐中每种食物的摄入克重"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()

    lazy var searchBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        return vi
    }()

    lazy var searchIconImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_search_icon")
        img.isUserInteractionEnabled = true
        return img
    }()

    lazy var searchTextField: ChineseTextField = {
        let text = ChineseTextField()
        text.placeholder = "请输入想要搜索的食物"
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.clearButtonMode = .whileEditing
        text.returnKeyType = .search
        text.textNumber = 50
        text.delegate = self
        text.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        return text
    }()

    lazy var selectedTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()

    lazy var selectedScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.isScrollEnabled = false
        scroll.alwaysBounceHorizontal = false
        scroll.alwaysBounceVertical = false
        scroll.backgroundColor = .clear
        return scroll
    }()

    lazy var sectionTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "最近添加"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()

    lazy var allFoodsButton: UIButton = makeTabButton(title: "全部食物")
    lazy var myFoodsButton: UIButton = makeTabButton(title: "我的食物")

    lazy var tabLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        return vi
    }()

    lazy var listHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    lazy var tabButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ allFoodsButton, myFoodsButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = kFitWidth(6)
        return stack
    }()

    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        table.register(FoodsListAddTableViewCell.classForCoder(), forCellReuseIdentifier: "FoodsListAddTableViewCell")
        table.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        return table
    }()

    lazy var noDataView: TableViewNoDataVM = {
        let vi = TableViewNoDataVM(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        return vi
    }()

    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("规划本餐摄入量", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(27)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()

    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
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
}

extension MealAdviceFoodsVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsLabel)
        addSubview(searchBgView)
        searchBgView.addSubview(searchIconImg)
        searchBgView.addSubview(searchTextField)
        searchIconImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchAction)))
        addSubview(selectedTitleLabel)
        addSubview(selectedScrollView)
        addSubview(listHeaderView)
        listHeaderView.addSubview(sectionTitleLabel)
        listHeaderView.addSubview(tabButtonsStackView)
        listHeaderView.addSubview(tabLineView)
        addSubview(tableView)
        tableView.addSubview(noDataView)

        addSubview(topGradientView)
        addSubview(bottomGradientView)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        topGradientView.layer.addSublayer(topGradientLayer)

        addSubview(confirmButton)

        noDataView.center = CGPoint(x: tableView.frame.width * 0.5, y: kFitWidth(134))
        noDataView.noDataLabel.text = "- 暂无数据 -"

        selectedScrollView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(selectedTitleLabel.snp.bottom).offset(kFitWidth(12))
            selectedScrollHeightConstraint = make.height.equalTo(0).constraint
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(16) + WHUtils().getNavigationBarHeight())
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
        }
        searchBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(44))
            make.height.equalTo(kFitWidth(36))
        }
        searchIconImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(22))
        }
        searchTextField.snp.makeConstraints { make in
            make.left.equalTo(searchIconImg.snp.right).offset(kFitWidth(12))
            make.right.equalTo(kFitWidth(-16))
            make.top.bottom.equalToSuperview()
        }
        selectedTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(21))
            make.top.equalTo(searchBgView.snp.bottom).offset(kFitWidth(25))
        }
        listHeaderView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(selectedScrollView.snp.bottom).offset(kFitWidth(16))
            make.height.equalTo(kFitWidth(28))
        }
        sectionTitleLabel.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        tabButtonsStackView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        tabLineView.snp.makeConstraints { make in
            make.width.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(4))
            make.bottom.equalToSuperview()
            make.centerX.equalTo(allFoodsButton.snp.centerX)
        }
        tableView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(listHeaderView.snp.bottom).offset(kFitWidth(4))
            make.bottom.equalTo(confirmButton.snp.top)//.offset(-kFitWidth(16))
        }
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
            make.height.equalTo(kFitWidth(54))
        }
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tableView.snp.top)
            make.height.equalTo(kFitWidth(35))
        }
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(tableView)
            make.height.equalTo(kFitWidth(35))
        }

        refreshTabState()
        refreshSelectedState()
        refreshSelectedFoodsView()
    }

    func makeTabButton(title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.setTitleColor(.THEME, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: kFitWidth(2), bottom: 0, right: kFitWidth(2))
        btn.titleLabel?.lineBreakMode = .byTruncatingTail
        btn.addTarget(self, action: #selector(tabButtonAction(_:)), for: .touchUpInside)
        return btn
    }

    func refreshTabState() {
        allFoodsButton.isSelected = currentListType == .all
        myFoodsButton.isSelected = currentListType == .my

        let buttons = [ allFoodsButton, myFoodsButton]
        for button in buttons {
            button.titleLabel?.font = button.isSelected ? .systemFont(ofSize: 12, weight: .medium) : .systemFont(ofSize: 12, weight: .regular)
            button.setTitleColor(button.isSelected ? .THEME : .COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        }
        sectionTitleLabel.text = currentListType.title
        let targetButton: UIButton?
        switch currentListType {
        case .recent:
            targetButton = nil
        case .all:
            targetButton = allFoodsButton
        case .my:
            targetButton = myFoodsButton
        }
        tabLineView.isHidden = targetButton == nil
        if let targetButton = targetButton {
            tabLineView.snp.remakeConstraints { make in
                make.width.equalTo(kFitWidth(24))
                make.height.equalTo(kFitWidth(4))
                make.bottom.equalToSuperview()
                make.centerX.equalTo(targetButton.snp.centerX)
            }
        }
        setNeedsLayout()
    }

    func refreshSelectedState() {
        let attr = NSMutableAttributedString(
            string: "已添加",
            attributes: [
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        )
        attr.append(NSAttributedString(
            string: "·\(selectedFoodsArray.count)",
            attributes: [
                .foregroundColor: UIColor.THEME,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        ))
        selectedTitleLabel.attributedText = attr
        confirmButton.isEnabled = selectedFoodsArray.count > 0
    }

    private func captureTableViewAnchor() -> TableViewAnchor? {
        layoutIfNeeded()
        guard let indexPath = tableView.indexPathsForVisibleRows?.first,
              let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }

        let screenY = cell.convert(.zero, to: self).y
        return TableViewAnchor(
            indexPath: indexPath,
            screenY: screenY,
            contentOffsetY: tableView.contentOffset.y
        )
    }

    private func restoreTableViewAnchor(_ anchor: TableViewAnchor?) {
        guard let anchor = anchor else { return }
        layoutIfNeeded()
        guard let cell = tableView.cellForRow(at: anchor.indexPath) else { return }

        let currentScreenY = cell.convert(.zero, to: self).y
        let movement = currentScreenY - anchor.screenY
        tableView.setContentOffset(
            CGPoint(x: tableView.contentOffset.x, y: anchor.contentOffsetY + movement),
            animated: false
        )
    }

    private func refreshSelectionUI() {
        let anchor = captureTableViewAnchor()
        refreshSelectedState()
        refreshSelectedFoodsView()
        tableView.reloadData()
        restoreTableViewAnchor(anchor)
    }

    func refreshSelectedFoodsView() {
        selectedChipViews.forEach { $0.removeFromSuperview() }
        selectedChipViews.removeAll()

        let hasSelected = selectedFoodsArray.count > 0
        selectedScrollView.isHidden = !hasSelected

        guard hasSelected else {
            selectedScrollHeightConstraint?.update(offset: 0)
            selectedScrollView.contentSize = .zero
            setNeedsLayout()
            layoutIfNeeded()
            return
        }

        let chipHeight = kFitWidth(32)
        let columnSpacing = kFitWidth(8)
        let rowSpacing = kFitWidth(12)
        let columnCount = 3
        let rowCount = (selectedFoodsArray.count + columnCount - 1) / columnCount
        let gridHeight = CGFloat(rowCount) * chipHeight + CGFloat(rowCount - 1) * rowSpacing
        selectedScrollHeightConstraint?.update(offset: gridHeight)
        layoutIfNeeded()

        let availableWidth = selectedScrollView.bounds.width > 0
            ? selectedScrollView.bounds.width
            : SCREEN_WIDHT - kFitWidth(32)
        let chipWidth = (availableWidth - CGFloat(columnCount - 1) * columnSpacing) / CGFloat(columnCount)

        for index in 0..<selectedFoodsArray.count {
            let dict = selectedFoodsArray[index] as? NSDictionary ?? [:]
            let title = foodDisplayName(from: dict)
            let chip = MealAdviceSelectedFoodChipView(title: title)
            chip.onRemove = { [weak self] in
                self?.removeSelectedFood(dict: dict)
            }
            let row = index / columnCount
            let column = index % columnCount
            let chipX = CGFloat(column) * (chipWidth + columnSpacing)
            let chipY = CGFloat(row) * (chipHeight + rowSpacing)
            chip.frame = CGRect(x: chipX, y: chipY, width: chipWidth, height: chipHeight)
            selectedScrollView.addSubview(chip)
            selectedChipViews.append(chip)
        }
        selectedScrollView.contentSize = CGSize(width: availableWidth, height: gridHeight)
        setNeedsLayout()
        layoutIfNeeded()
    }

    func reloadCurrentList() {
        currentKeyword = normalizedSearchKeyword()

        switch currentListType {
        case .recent:
            _ = nextRequestVersion()
            loadRecentFoods()
        case .all:
            sendAllFoodsRequest()
        case .my:
            sendMyFoodsRequest()
        }
    }

    func loadRecentFoods() {
        let sourceArray = UserDefaults.getHistoryFoods()
        recentFoodsArray = NSMutableArray(array: sourceArray)
        filteredRecentFoodsArray = filteredFoods(in: recentFoodsArray, keyword: currentKeyword)
        tableView.reloadData()
        updateNoDataState()
    }

    func loadMyFoodsFromCache() {
        myFoodsArray = NSMutableArray(array: UserDefaults.getMyFoods())
        filteredMyFoodsArray = filteredFoods(in: myFoodsArray, keyword: currentKeyword)
        tableView.reloadData()
        updateNoDataState()
    }

    func updateNoDataState() {
        let hasData: Bool
        switch currentListType {
        case .recent:
            hasData = filteredRecentFoodsArray.count > 0
        case .all:
            hasData = allFoodsArray.count > 0
        case .my:
            hasData = filteredMyFoodsArray.count > 0
        }
        noDataView.isHidden = hasData
        if !hasData {
            switch currentListType {
            case .recent:
                noDataView.noDataLabel.text = "- 无最近数据 -"
            case .all:
                noDataView.noDataLabel.text = "- 暂无数据 -"
            case .my:
                noDataView.noDataLabel.text = "- 暂无我的食物 -"
            }
        }
    }

    func filteredFoods(in array: NSMutableArray, keyword: String) -> NSMutableArray {
        guard keyword.count > 0 else {
            return NSMutableArray(array: array)
        }

        let result = NSMutableArray()
        for index in 0..<array.count {
            let rawDict = array[index] as? NSDictionary ?? [:]
            let displayDict = normalizedFoodDict(from: rawDict)
            if foodDisplayName(from: rawDict).contains(keyword) || foodDisplayName(from: displayDict).contains(keyword) {
                result.add(rawDict)
            }
        }
        return result
    }

    func normalizedFoodDict(from rawDict: NSDictionary) -> NSDictionary {
        if let foodsDict = rawDict["foods"] as? NSDictionary, foodsDict.count > 0 {
            return foodsDict
        }
        return rawDict
    }

    func foodDisplayName(from dict: NSDictionary) -> String {
        let foodsDict = normalizedFoodDict(from: dict)
        if let name = foodsDict["fname"] as? String, name.count > 0 {
            return name
        }
        if let name = foodsDict["name"] as? String, name.count > 0 {
            return name
        }
        return ""
    }

    func foodIdentityKey(from dict: NSDictionary) -> String {
        let foodsDict = normalizedFoodDict(from: dict)
        let fid = foodsDict.stringValueForKey(key: "fid")
        if fid.count > 0 {
            return fid
        }
        let name = foodDisplayName(from: foodsDict)
        return name.count > 0 ? name : "\(foodsDict.hash)"
    }

    func isSelectedFood(dict: NSDictionary) -> Bool {
        let key = foodIdentityKey(from: dict)
        for index in 0..<selectedFoodsArray.count {
            let item = selectedFoodsArray[index] as? NSDictionary ?? [:]
            if foodIdentityKey(from: item) == key {
                return true
            }
        }
        return false
    }

    func toggleSelection(dict: NSDictionary) {
        let normalized = normalizedFoodDict(from: dict)
        let key = foodIdentityKey(from: normalized)
        var removeIndex: Int?
        for index in 0..<selectedFoodsArray.count {
            let item = selectedFoodsArray[index] as? NSDictionary ?? [:]
            if foodIdentityKey(from: item) == key {
                removeIndex = index
                break
            }
        }

        if let removeIndex = removeIndex {
            selectedFoodsArray.removeObject(at: removeIndex)
        } else {
            guard selectedFoodsArray.count < maximumSelectedFoodsCount else { return }
            selectedFoodsArray.add(normalized)
        }

        refreshSelectionUI()
    }

    func removeSelectedFood(dict: NSDictionary) {
        let key = foodIdentityKey(from: dict)
        for index in stride(from: selectedFoodsArray.count - 1, through: 0, by: -1) {
            let item = selectedFoodsArray[index] as? NSDictionary ?? [:]
            if foodIdentityKey(from: item) == key {
                selectedFoodsArray.removeObject(at: index)
                break
            }
        }
        refreshSelectionUI()
    }

    @objc func tabButtonAction(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        if sender == allFoodsButton {
            currentListType = .all
        } else if sender == myFoodsButton {
            currentListType = .my
        }
        refreshTabState()
        reloadCurrentList()
    }

    @objc func searchTextChanged() {
        currentKeyword = normalizedSearchKeyword()
    }

    @objc func searchAction() {
        searchTextField.resignFirstResponder()
        currentKeyword = normalizedSearchKeyword()

        if currentKeyword.isEmpty {
            currentListType = .recent
        } else if currentListType != .my {
            currentListType = .all
        }

        refreshTabState()
        reloadCurrentList()
    }

    func normalizedSearchKeyword() -> String {
        let text = searchTextField.text ?? ""
        return text.disable_emoji(text: text as NSString)
    }

    @objc func confirmAction() {
        guard selectedFoodsArray.count > 0 else { return }
        confirmBlock?(selectedFoodsArray)
    }
}

extension MealAdviceFoodsVM: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        updateNoDataState()
        switch currentListType {
        case .recent:
            return 1
        case .all:
            return 1
        case .my:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentListType {
        case .recent:
            return filteredRecentFoodsArray.count
        case .all:
            return allFoodsArray.count
        case .my:
            return filteredMyFoodsArray.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsListAddTableViewCell") as? FoodsListAddTableViewCell

        switch currentListType {
        case .recent:
            let dict = filteredRecentFoodsArray[indexPath.row] as? NSDictionary ?? [:]
            cell?.updateUIForHistory(dict: dict, keywords: currentKeyword)
            cell?.addButtonVm.isHidden = true
            cell?.addButtonVm.alpha = 0
            applySelectionState(to: cell, dict: dict)
        case .all:
            let dict = allFoodsArray[indexPath.row] as? NSDictionary ?? [:]
            cell?.updateUI(dict: dict, keywords: currentKeyword)
            applySelectionState(to: cell, dict: dict)
        case .my:
            let dict = filteredMyFoodsArray[indexPath.row] as? NSDictionary ?? [:]
            cell?.updateUI(dict: dict, keywords: currentKeyword)
            applySelectionState(to: cell, dict: dict)
        }

        return cell ?? FoodsListAddTableViewCell()
    }

    func applySelectionState(to cell: FoodsListAddTableViewCell?, dict: NSDictionary) {
        guard let cell = cell else { return }
        let isSelected = isSelectedFood(dict: dict)
        let isDisabled = selectedFoodsArray.count >= maximumSelectedFoodsCount && !isSelected
        let selectedImage = isSelected
            ? UIImage(named: "question_foods_selected_icon")
            : UIImage(named: "question_foods_normal_icon")

        let iconView = UIImageView(image: selectedImage)
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false
        iconView.alpha = isDisabled ? 0.45 : 1
        iconView.frame = CGRect(x: 0, y: 0, width: kFitWidth(24), height: kFitWidth(24))
        cell.accessoryView = iconView
        cell.setSelectionDisabled(isDisabled)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentListType {
        case .recent:
            let dict = filteredRecentFoodsArray[indexPath.row] as? NSDictionary ?? [:]
            toggleSelection(dict: dict)
        case .all:
            let dict = allFoodsArray[indexPath.row] as? NSDictionary ?? [:]
            toggleSelection(dict: dict)
        case .my:
            let dict = filteredMyFoodsArray[indexPath.row] as? NSDictionary ?? [:]
            toggleSelection(dict: dict)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(72)
    }

}

extension MealAdviceFoodsVM {
    func sendAllFoodsRequest() {
        let token = nextRequestVersion()
        let param = [
            "fname": currentKeyword,
            "uid": "\(UserInfoModel.shared.uId)"
        ]
        UserInfoModel.shared.postNum = 3
        UserInfoModel.shared.failToastNum = 0
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_list, parameters: param as [String: AnyObject], isNeedToast: true, vc: controller) { [weak self] responseObject in
            guard let self = self else { return }
            guard token == self.requestVersion else { return }

            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataArr = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            let bestArray = dataArr["best"] as? NSArray ?? []
            let moreArray = dataArr["more"] as? NSArray ?? []

            DispatchQueue.main.async {
                guard token == self.requestVersion else { return }
                self.allFoodsArray.removeAllObjects()
                self.allFoodsArray.addObjects(from: bestArray as? [Any] ?? [])
                self.allFoodsArray.addObjects(from: moreArray as? [Any] ?? [])
                self.tableView.reloadData()
                self.updateNoDataState()
            }
        } failure: { [weak self] _ in
            guard let self = self else { return }
            guard token == self.requestVersion else { return }
            DispatchQueue.main.async {
                guard token == self.requestVersion else { return }
                self.allFoodsArray.removeAllObjects()
                self.tableView.reloadData()
                self.updateNoDataState()
            }
        }
    }

    func sendMyFoodsRequest() {
        let token = nextRequestVersion()
        let param = ["fname": currentKeyword]
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_list_my, parameters: param as [String: AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            guard token == self.requestVersion else { return }

            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DispatchQueue.main.async {
                guard token == self.requestVersion else { return }
                self.myFoodsArray = NSMutableArray(array: dataArr)
                self.filteredMyFoodsArray = NSMutableArray(array: dataArr)
                self.filteredMyFoodsArray = self.filteredFoods(in: self.myFoodsArray, keyword: self.currentKeyword)
                self.tableView.reloadData()
                self.updateNoDataState()

                if self.currentKeyword.count == 0 {
                    UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArr), forKey: .myFoodsList)
                }
            }
        }
    }

    private func nextRequestVersion() -> Int {
        requestVersion += 1
        return requestVersion
    }
}

extension MealAdviceFoodsVM: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === searchTextField else { return true }

        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return !(updatedText.first?.isWhitespace ?? false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchAction()
        return true
    }
}
