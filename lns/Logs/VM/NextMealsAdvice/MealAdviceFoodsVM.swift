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

    /// 标签标题文本。
    private let titleLabel = UILabel()
    /// 删除标签的关闭按钮。
    private let closeButton = UIButton(type: .custom)
    /// 点击关闭按钮后的回调。
    var onRemove: (() -> Void)?

    /// 使用标题初始化一个已选食物标签。
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

    /// 不支持从 storyboard 或 xib 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 重新计算标题和关闭按钮的位置。
    override func layoutSubviews() {
        super.layoutSubviews()

        let buttonSize = kFitWidth(14)
        let closeX = bounds.width - kFitWidth(10) - buttonSize
        closeButton.frame = CGRect(x: closeX, y: (bounds.height - buttonSize) * 0.5, width: buttonSize, height: buttonSize)
        titleLabel.frame = CGRect(x: kFitWidth(12), y: 0, width: max(0, closeX - kFitWidth(10) - kFitWidth(12)), height: bounds.height)
    }

    /// 触发移除回调。
    @objc private func removeAction() {
        onRemove?()
    }
}

final class MealAdviceFoodsVM: UIView {

    /// 视图整体所占的高度。
    var selfHeight = kFitWidth(0)
    /// 当前视图关联的控制器，用于发起网络请求和承载提示。
    var controller = WHBaseViewVC()
    /// 点击“规划本餐摄入量”后的回调，返回已选食物数组。
    var confirmBlock: ((NSArray) -> Void)?

    /// 当前显示的数据列表类型。
    private var currentListType: MealAdviceFoodListType = .recent
    /// 当前搜索关键字，用于筛选列表数据。
    private var currentKeyword = ""
    /// 请求版本号，用于忽略过期网络响应。
    private var requestVersion = 0

    /// 最近添加的食物数据源。
    private var recentFoodsArray = NSMutableArray()
    /// 全部食物的数据源。
    private var allFoodsArray = NSMutableArray()
    /// 我的食物的数据源。
    private var myFoodsArray = NSMutableArray()
    /// 最近添加列表的筛选结果。
    private var filteredRecentFoodsArray = NSMutableArray()
    /// 我的食物列表的筛选结果。
    private var filteredMyFoodsArray = NSMutableArray()
    /// 当前已选中的食物列表。
    private var selectedFoodsArray = NSMutableArray()

    /// 已选食物标签视图集合。
    private var selectedChipViews: [MealAdviceSelectedFoodChipView] = []
    /// 已选食物区域的高度约束。
    private var selectedScrollHeightConstraint: Constraint?
    /// 最多允许选择的食物数量。
    private let maximumSelectedFoodsCount = 6
    /// 最近搜索暂无结果时使用的提示视图。
    private lazy var recentSearchNoDataVm = FoodsListHeaderNoDataVM(frame: .zero)
    /// 最近搜索暂无结果时使用的底部提示视图。
    private lazy var recentSearchFooterVm = FoodsListFooterVM(frame: .zero)

    /// 用于记录表格当前位置，方便刷新后恢复滚动位置。
    private struct TableViewAnchor {
        /// 锚点所在的行位置。
        let indexPath: IndexPath
        /// 锚点行在当前视图中的屏幕坐标。
        let screenY: CGFloat
    }

    /// 按给定起始位置初始化整个食物推荐面板。
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT - frame.origin.y))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        selfHeight = SCREEN_HEIGHT - frame.origin.y

        initUI()
        reloadCurrentList()
    }

    /// 不支持从 storyboard 或 xib 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 视图布局更新时，修正空态与渐变层的位置。
    override func layoutSubviews() {
        super.layoutSubviews()

        noDataView.center = CGPoint(x: tableView.bounds.width * 0.5, y: kFitWidth(134))
        layoutRecentSearchPromptViews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
    
    /// 主题或外观变化时，重新刷新渐变层颜色。
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

    /// 提示文案，说明选择食物后会如何计算本餐克重。
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

    /// 搜索框外层背景容器。
    lazy var searchBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        return vi
    }()

    /// 搜索图标。
    lazy var searchIconImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_search_icon")
        img.isUserInteractionEnabled = true
        return img
    }()

    /// 输入食物名称的搜索框。
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

    /// 已添加食物标题，显示已选数量。
    lazy var selectedTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()

    /// 已选食物的横向滚动容器。
    lazy var selectedScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.isScrollEnabled = false
        scroll.alwaysBounceHorizontal = false
        scroll.alwaysBounceVertical = false
        scroll.backgroundColor = .clear
        return scroll
    }()

    /// 当前列表分区标题。
    lazy var sectionTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "最近添加"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()

    /// “全部食物”切换按钮。
    lazy var allFoodsButton: UIButton = makeTabButton(title: "全部食物")
    /// “我的食物”切换按钮。
    lazy var myFoodsButton: UIButton = makeTabButton(title: "我的食物")

    /// tab 下划线指示条。
    lazy var tabLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        return vi
    }()

    /// 列表头部容器。
    lazy var listHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    /// 顶部分类按钮组合容器。
    lazy var tabButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ allFoodsButton, myFoodsButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = kFitWidth(6)
        return stack
    }()

    /// 列表展示的主表格视图。
    let tableView = UITableView(frame: .zero, style: .plain)

    /// 没有数据时居中的空状态视图。
    lazy var noDataView: TableViewNoDataVM = {
        let vi = TableViewNoDataVM(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        return vi
    }()

    /// 底部确认按钮。
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

    /// 表格底部渐变遮罩容器。
    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    /// 表格顶部渐变遮罩容器。
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    /// 表格底部渐变层。
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
    /// 表格顶部渐变层。
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
    /// 初始化界面结构、约束和默认状态。
    func initUI() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.register(FoodsListAddTableViewCell.classForCoder(), forCellReuseIdentifier: "FoodsListAddTableViewCell")
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

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
        tableView.addSubview(recentSearchNoDataVm)

        addSubview(topGradientView)
        addSubview(bottomGradientView)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        topGradientView.layer.addSublayer(topGradientLayer)

        addSubview(confirmButton)

        noDataView.center = CGPoint(x: tableView.frame.width * 0.5, y: kFitWidth(134))
        noDataView.noDataLabel.text = "- 暂无数据 -"
        recentSearchNoDataVm.isHidden = true
        recentSearchNoDataVm.searchFoodsButton.addTarget(self, action: #selector(searchAllFoodsAction), for: .touchUpInside)
        recentSearchFooterVm.searchFoodsButton.addTarget(self, action: #selector(searchAllFoodsAction), for: .touchUpInside)

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
        updateRecentSearchPromptState()
    }

    /// 重新计算最近搜索提示视图的位置。
    func layoutRecentSearchPromptViews() {
        recentSearchNoDataVm.frame = CGRect(
            x: 0,
            y: kFitWidth(18),
            width: tableView.bounds.width,
            height: recentSearchNoDataVm.selfHeight
        )
    }

    /// 创建顶部分类切换按钮。
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

    /// 刷新分类 tab 的选中态和下划线位置。
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
        updateRecentSearchPromptState()
    }

    /// 刷新已选食物标题与确认按钮状态。
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

    /// 刷新已选食物标签区域，并保持表格位置稳定。
    private func refreshSelectionUI() {
        let anchor = captureTableViewAnchor()
        refreshSelectedState()
        refreshSelectedFoodsView()
        tableView.reloadData()
        restoreTableViewAnchor(anchor)
    }

    /// 将表格滚动到顶部。
    private func resetTableViewOffsetToTop() {
        tableView.layoutIfNeeded()
        tableView.setContentOffset(.zero, animated: false)
    }

    /// 重新布局已选食物标签视图。
    func refreshSelectedFoodsView() {
        selectedChipViews.forEach { $0.removeFromSuperview() }
        selectedChipViews.removeAll()

        let chipHeight = kFitWidth(32)
        let hasSelected = selectedFoodsArray.count > 0
        selectedScrollView.isHidden = !hasSelected

        guard hasSelected else {
            selectedScrollHeightConstraint?.update(offset: chipHeight)
            selectedScrollView.contentSize = .zero
            setNeedsLayout()
            layoutIfNeeded()
            return
        }

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

    /// 捕获当前表格首个可见行的位置锚点，用于刷新后恢复滚动偏移。
    private func captureTableViewAnchor() -> TableViewAnchor? {
        layoutIfNeeded()
        guard let indexPath = tableView.indexPathsForVisibleRows?.first else { return nil }
        let rowRect = tableView.rectForRow(at: indexPath)
        let screenY = tableView.convert(CGPoint(x: 0, y: rowRect.minY), to: self).y
        return TableViewAnchor(indexPath: indexPath, screenY: screenY)
    }

    /// 按锚点恢复表格滚动位置，避免标签区域变化后内容跳动。
    private func restoreTableViewAnchor(_ anchor: TableViewAnchor?) {
        guard let anchor = anchor else { return }
        layoutIfNeeded()
        let rowRect = tableView.rectForRow(at: anchor.indexPath)
        let currentScreenY = tableView.convert(CGPoint(x: 0, y: rowRect.minY), to: self).y
        let movement = currentScreenY - anchor.screenY
        guard abs(movement) > 0.5 else { return }
        tableView.setContentOffset(
            CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + movement),
            animated: false
        )
    }

    /// 根据当前分类重新加载对应列表数据。
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

    /// 加载最近添加的食物，并按当前关键字筛选。
    func loadRecentFoods() {
        let sourceArray = UserDefaults.getHistoryFoods()
        recentFoodsArray = NSMutableArray(array: sourceArray)
        filteredRecentFoodsArray = filteredFoods(in: recentFoodsArray, keyword: currentKeyword)
        tableView.reloadData()
        resetTableViewOffsetToTop()
        updateNoDataState()
    }

    /// 从缓存加载“我的食物”并按当前关键字筛选。
    func loadMyFoodsFromCache() {
        myFoodsArray = NSMutableArray(array: UserDefaults.getMyFoods())
        filteredMyFoodsArray = filteredFoods(in: myFoodsArray, keyword: currentKeyword)
        tableView.reloadData()
        resetTableViewOffsetToTop()
        updateNoDataState()
    }

    /// 刷新空状态显示逻辑。
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
        let isRecentKeywordEmptyResult = currentListType == .recent && currentKeyword.count > 0 && !hasData
        noDataView.isHidden = hasData || isRecentKeywordEmptyResult
        if !hasData {
            switch currentListType {
            case .recent:
                noDataView.noDataLabel.text = "- 无最近数据 -"
            case .all:
                noDataView.noDataLabel.text = "- 暂无数据 -"
            case .my:
                noDataView.noDataLabel.text = "- 暂无数据 -"
            }
        }
        updateRecentSearchPromptState()
    }

    /// 刷新最近搜索时的底部提示内容。
    func updateRecentSearchPromptState() {
        let shouldShowPrompt = currentListType == .recent && currentKeyword.count > 0
        recentSearchNoDataVm.isHidden = true
        tableView.tableFooterView = nil

        guard shouldShowPrompt else { return }

        recentSearchFooterVm.setNoDataText(text: currentKeyword)
        recentSearchFooterVm.frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.width,
            height: recentSearchFooterVm.selfHeight
        )

        if filteredRecentFoodsArray.count > 0 {
            tableView.tableFooterView = recentSearchFooterVm
        } else {
            recentSearchNoDataVm.setNoDataText(text: currentKeyword)
            recentSearchNoDataVm.isHidden = false
            layoutRecentSearchPromptViews()
        }
    }

    /// 根据关键字过滤食物数组。
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

    /// 将原始数据规范化为实际食物字典。
    func normalizedFoodDict(from rawDict: NSDictionary) -> NSDictionary {
        if let foodsDict = rawDict["foods"] as? NSDictionary, foodsDict.count > 0 {
            return foodsDict
        }
        return rawDict
    }

    /// 获取食物展示名称。
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

    /// 获取食物唯一标识，用于去重和选中判断。
    func foodIdentityKey(from dict: NSDictionary) -> String {
        let foodsDict = normalizedFoodDict(from: dict)
        let fid = foodsDict.stringValueForKey(key: "fid")
        if fid.count > 0 {
            return fid
        }
        let name = foodDisplayName(from: foodsDict)
        return name.count > 0 ? name : "\(foodsDict.hash)"
    }

    /// 判断某个食物是否已经被选中。
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

    /// 切换某个食物的选中状态。
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

    /// 从已选列表中移除指定食物。
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

    /// 处理顶部分类按钮点击。
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

    /// 处理搜索框输入变化。
    @objc func searchTextChanged() {
        currentKeyword = normalizedSearchKeyword()
        guard currentListType == .recent else { return }
        loadRecentFoods()
    }

    /// 处理搜索图标点击，按当前关键字刷新列表。
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

    /// 处理“搜索全部食物”按钮点击。
    @objc func searchAllFoodsAction() {
        searchTextField.resignFirstResponder()
        guard currentKeyword.count > 0 else { return }
        currentListType = .all
        refreshTabState()
        reloadCurrentList()
    }

    /// 读取并清洗搜索框中的关键字。
    func normalizedSearchKeyword() -> String {
        let text = searchTextField.text ?? ""
        return text.disable_emoji(text: text as NSString)
    }

    /// 处理底部确认按钮点击。
    @objc func confirmAction() {
        guard selectedFoodsArray.count > 0 else { return }
        confirmBlock?(NSArray(array: selectedFoodsArray as? [Any] ?? []))
    }
}

extension MealAdviceFoodsVM: UITableViewDelegate, UITableViewDataSource {
    /// 返回表格分区数量。
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

    /// 返回当前分区行数。
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

    /// 构建列表单元格并填充对应数据。
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

    /// 配置单元格的选中态与禁用态图标。
    func applySelectionState(to cell: FoodsListAddTableViewCell?, dict: NSDictionary) {
        guard let cell = cell else { return }
        let isSelected = isSelectedFood(dict: dict)
        let isDisabled = selectedFoodsArray.count >= maximumSelectedFoodsCount && !isSelected
        cell.updateSelectionAccessory(isSelected: isSelected, isDisabled: isDisabled)
        cell.setSelectionDisabled(isDisabled)
    }

    /// 处理列表项点击，切换选中状态。
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

    /// 固定列表行高。
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(72)
    }

}

extension MealAdviceFoodsVM {
    /// 请求全部食物列表。
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
                self.resetTableViewOffsetToTop()
                self.updateNoDataState()
            }
        } failure: { [weak self] _ in
            guard let self = self else { return }
            guard token == self.requestVersion else { return }
            DispatchQueue.main.async {
                guard token == self.requestVersion else { return }
                self.allFoodsArray.removeAllObjects()
                self.tableView.reloadData()
                self.resetTableViewOffsetToTop()
                self.updateNoDataState()
            }
        }
    }

    /// 请求我的食物列表。
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
                self.resetTableViewOffsetToTop()
                self.updateNoDataState()

                if self.currentKeyword.count == 0 {
                    UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArr), forKey: .myFoodsList)
                }
            }
        }
    }

    /// 生成并返回新的请求版本号。
    private func nextRequestVersion() -> Int {
        requestVersion += 1
        return requestVersion
    }
}

extension MealAdviceFoodsVM: UITextFieldDelegate {
    /// 限制搜索框不以空白字符开头输入。
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === searchTextField else { return true }

        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return !(updatedText.first?.isWhitespace ?? false)
    }

    /// 回车时直接触发搜索。
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchAction()
        return true
    }
}
