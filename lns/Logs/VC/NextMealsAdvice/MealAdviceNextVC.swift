//
//  MealAdviceNextVC.swift
//  lns
//
//  Created by Codex on 2026/8/10.
//

import UIKit
import MCToast
import SnapKit

/// 下餐规划结果页。
final class MealAdviceNextVC: WHBaseViewVC {

    /// 页面对应的规划数据管理器。
    private let viewModel: MealAdviceNextViewModel
    /// 页面日志日期。
    private let sDate: String
    /// 当前日志页点击的餐序号，1 开始，0 表示未指定。
    private let mealIndex: Int
    /// 红框内的滚动容器。
    private let scrollView = UIScrollView()
    /// 滚动内容容器。
    private let contentView = UIView()
    /// 滚动内容的纵向布局栈。
    private let contentStackView = UIStackView()
    /// 滚动区域顶部渐变遮罩容器。
    private let topGradientView = UIView()
    /// 滚动区域底部渐变遮罩容器。
    private let bottomGradientView = UIView()
    /// 滚动区域顶部渐变层。
    private let topGradientLayer = CAGradientLayer()
    /// 滚动区域底部渐变层。
    private let bottomGradientLayer = CAGradientLayer()
    /// 右上角关闭按钮。
    private let closeButton = UIButton(type: .custom)
    /// 页面标题。
    private let titleLabel = UILabel()
    /// 顶部营养摘要容器。
    private let headlineView = UIView()
    /// 顶部四项营养摘要栈。
    private let topMetricsStackView = UIStackView()
    /// 食物列表卡片。
    private let foodListCardView = UIView()
    /// 食物列表表格。
    private let foodTableView = UITableView(frame: .zero, style: .plain)
    /// 食物列表高度约束。
    private var foodTableHeightConstraint: Constraint?
    /// 建议份量不合理？
    private let tipsCardView = UIView()
    /// icon
    private let tipsIcon = UIImageView()
    /// 内容
    private let tipsStackView = UIStackView()
    /// 提示标题。
    private let tipsTitleLabel = UILabel()
    /// 提示说明。
    private let tipsContentLabel = UILabel()

    /// 本餐后剩余卡片。
    private let remainingCardView = UIView()
    /// 本餐后剩余标题。
    private let remainingTitleLabel = UILabel()
    /// 本餐后剩余圆环栈。
    private let remainingMetricsStackView = UIStackView()
    /// 底部确认按钮。
    private let addToLogsButton = UIButton(type: .custom)
    /// 顶部营养摘要视图数组。
    private var topMetricViews: [MealAdviceNextTopMetricView] = []
    /// 底部圆环营养视图数组。
    private var ringMetricViews: [MealAdviceNextRingMetricView] = []
    /// 顶部和底部营养卡片共用的颜色顺序。
    private let metricColors: [UIColor] = [.COLOR_CALORI, .COLOR_CARBOHYDRATE, .COLOR_PROTEIN, .COLOR_FAT]
    /// 超出剩余时的圆环颜色，保持和日志页顶部圆圈一致。
    private let metricOverflowColors: [UIColor] = [
        WHColor_RGB(r: 28, g: 70, b: 140),
        WHColor_RGB(r: 62, g: 36, b: 101),
        WHColor_RGB(r: 135, g: 102, b: 13),
        WHColor_RGB(r: 116, g: 66, b: 25)
    ]
    /// 列表行高。
    private let foodRowHeight = kFitWidth(65)


    lazy var tipsAlertVm : QuestionnaireBodyFatAlertVM = {
        let vm = QuestionnaireBodyFatAlertVM.init(frame: .zero)
        vm.titleLabel.text = "建议份量不合理？"
        vm.contentLabelOne.text = "当所选食物无法覆盖剩余营养目标时，建议份量可能不符合预期。请根据剩余目标搭配不同食物：\n\n蛋白质：鸡胸肉、鸡腿肉、鱼肉等\n碳水：米饭、糙米、燕麦等\n脂肪：牛油果、橄榄油、坚果等"
        vm.contentLabelTwo.text = ""
        vm.contentLabelThree.text = ""
        return vm
    }()

    /// 创建下餐规划结果页。
    /// - Parameters:
    ///   - planDict: 接口返回的规划结果。
    ///   - sDate: 从日志页进入时的日期。
    ///   - mealIndex: 从日志页进入时点击的餐序号。
    init(planDict: NSDictionary, sDate: String, mealIndex: Int = 0) {
        self.viewModel = MealAdviceNextViewModel(responseDict: planDict, sDate: sDate)
        self.sDate = sDate
        self.mealIndex = mealIndex
        super.init(nibName: nil, bundle: nil)
    }

    /// 禁止从 storyboard 创建。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        reloadData()
        updateInteractivePopGestureBlocked(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInteractivePopGestureBlocked(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateInteractivePopGestureBlocked(true)
        setKeyboardExtensionAllowed(false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreFullscreenInteractivePopGesture()
        setKeyboardExtensionAllowed(true)
    }

    deinit {
        restoreFullscreenInteractivePopGesture()
        setKeyboardExtensionAllowed(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
}

extension MealAdviceNextVC {
    /// 搭建页面结构。
    private func buildUI() {
        view.backgroundColor = .COLOR_BG_F2

        view.addSubview(closeButton)
        view.addSubview(headlineView)
        view.addSubview(scrollView)
        view.addSubview(addToLogsButton)
        view.addSubview(topGradientView)
        view.addSubview(bottomGradientView)
        view.addSubview(tipsAlertVm)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        topGradientView.isUserInteractionEnabled = false
        bottomGradientView.isUserInteractionEnabled = false
        topGradientView.backgroundColor = .clear
        bottomGradientView.backgroundColor = .clear

        topGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        topGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        topGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        topGradientLayer.locations = [0, 1]

        bottomGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        bottomGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        bottomGradientLayer.locations = [0, 1]
//
        closeButton.setImage(UIImage(named: "navi_close_icon"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)

        titleLabel.text = "建议摄入量"
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 24, weight: .medium)
        titleLabel.textAlignment = .center

        topMetricsStackView.axis = .horizontal
        topMetricsStackView.alignment = .fill
        topMetricsStackView.distribution = .fillEqually
        topMetricsStackView.spacing = kFitWidth(13)

        headlineView.backgroundColor = .clear
        foodListCardView.backgroundColor = .COLOR_CARD_BG_WHITE
        foodListCardView.layer.cornerRadius = kFitWidth(12)
        foodListCardView.clipsToBounds = true

        foodTableView.separatorStyle = .none
        foodTableView.backgroundColor = .clear
        foodTableView.delegate = self
        foodTableView.dataSource = self
        foodTableView.isScrollEnabled = false
        foodTableView.rowHeight = foodRowHeight
        foodTableView.estimatedRowHeight = foodRowHeight
        foodTableView.register(MealAdviceNextFoodCell.classForCoder(), forCellReuseIdentifier: "MealAdviceNextFoodCell")
        foodTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))

        tipsCardView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        tipsCardView.layer.cornerRadius = kFitWidth(12)
        tipsCardView.clipsToBounds = true
        tipsCardView.isUserInteractionEnabled = true
        tipsCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tipsCardTapAction)))

        tipsIcon.image = UIImage(named: "tips_icon")
        tipsIcon.contentMode = .scaleAspectFit

        tipsTitleLabel.text = "建议份量不合理？"
        tipsTitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        tipsTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)

        tipsContentLabel.text = "当所选食物无法覆盖剩余营养目标时，建议份量可能不符合预期。请根据剩余目标搭配不同食物：\n\n蛋白质：鸡胸肉、鸡腿肉、鱼肉等\n碳水：米饭、糙米、燕麦等\n脂肪：牛油果、橄榄油、坚果等"
        tipsContentLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        tipsContentLabel.font = .systemFont(ofSize: 13, weight: .regular)
        tipsContentLabel.numberOfLines = 2
        tipsContentLabel.lineBreakMode = .byTruncatingTail

        tipsStackView.axis = .vertical
        tipsStackView.alignment = .fill
        tipsStackView.distribution = .fill
        tipsStackView.spacing = kFitWidth(6)

        remainingCardView.backgroundColor = .COLOR_CARD_BG_WHITE
        remainingCardView.layer.cornerRadius = kFitWidth(12)
        remainingCardView.clipsToBounds = true

        remainingTitleLabel.text = "本餐后剩余"
        remainingTitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        remainingTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)

        remainingMetricsStackView.axis = .horizontal
        remainingMetricsStackView.alignment = .fill
        remainingMetricsStackView.distribution = .fillEqually
        remainingMetricsStackView.spacing = kFitWidth(10)

        addToLogsButton.setTitle("添加到日志", for: .normal)
        addToLogsButton.setTitleColor(.white, for: .normal)
        addToLogsButton.setTitleColor(.white, for: .disabled)
        addToLogsButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        addToLogsButton.backgroundColor = .THEME
        addToLogsButton.layer.cornerRadius = kFitWidth(27)
        addToLogsButton.clipsToBounds = true
        addToLogsButton.enablePressEffect()
        addToLogsButton.addTarget(self, action: #selector(addToLogsAction), for: .touchUpInside)

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = kFitWidth(12)

        let topMetricViewsLocal = metricColors.map { _ in MealAdviceNextTopMetricView() }
        let ringMetricViewsLocal = metricColors.map { _ in MealAdviceNextRingMetricView() }
        topMetricViews = topMetricViewsLocal
        ringMetricViews = ringMetricViewsLocal
        topMetricViewsLocal.forEach { topMetricsStackView.addArrangedSubview($0) }
        ringMetricViewsLocal.forEach { remainingMetricsStackView.addArrangedSubview($0) }

        contentStackView.addArrangedSubview(foodListCardView)
        contentStackView.addArrangedSubview(tipsCardView)
        contentStackView.addArrangedSubview(remainingCardView)
        headlineView.addSubview(titleLabel)
        headlineView.addSubview(topMetricsStackView)
        foodListCardView.addSubview(foodTableView)
        tipsCardView.addSubview(tipsIcon)
        tipsCardView.addSubview(tipsStackView)
        tipsStackView.addArrangedSubview(tipsTitleLabel)
        tipsStackView.addArrangedSubview(tipsContentLabel)
        remainingCardView.addSubview(remainingTitleLabel)
        remainingCardView.addSubview(remainingMetricsStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never

        closeButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(statusBarHeight + kFitWidth(8))
            make.width.height.equalTo(kFitWidth(36))
        }
        headlineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(closeButton.snp.bottom)//.offset(kFitWidth(10))
            make.height.equalTo(kFitWidth(115))
        }
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headlineView.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalTo(addToLogsButton.snp.top).offset(kFitWidth(-16))
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
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: kFitWidth(35), left: kFitWidth(16), bottom: 0, right: kFitWidth(16)))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kFitWidth(16))
        }
        topMetricsStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(30))
            make.bottom.equalToSuperview()
        }
        foodListCardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
        foodTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            foodTableHeightConstraint = make.height.equalTo(kFitWidth(1)).constraint
        }
        tipsCardView.snp.makeConstraints { make in
            make.height.equalTo(kFitWidth(89))
        }
        tipsIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(21))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        tipsStackView.snp.makeConstraints { make in
            make.left.equalTo(tipsIcon.snp.right).offset(kFitWidth(17))
            make.right.equalTo(kFitWidth(-21))
            make.centerY.equalToSuperview()
        }
        remainingCardView.snp.makeConstraints { make in
            make.height.equalTo(kFitWidth(168))
        }
        remainingTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(6))
        }
        remainingMetricsStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(remainingTitleLabel.snp.bottom)//.offset(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-26))
        }
        addToLogsButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
            make.height.equalTo(kFitWidth(54))
        }
    }

    /// 刷新页面数据。
    private func reloadData() {
        foodTableView.reloadData()
        reloadFoodListHeight()
        updateMetricViews(animated: false, animateTopMetrics: false)
        updateAddButtonState()
    }

    /// 刷新食物列表高度。
    private func reloadFoodListHeight() {
        let contentHeight = max(foodRowHeight * CGFloat(viewModel.foodItems.count), kFitWidth(1))
        foodTableHeightConstraint?.update(offset: contentHeight)
        view.layoutIfNeeded()
    }

    /// 刷新顶部和底部营养视图。
    private func updateMetricViews(animated: Bool) {
        updateMetricViews(animated: animated, animateTopMetrics: animated)
    }

    /// 刷新顶部和底部营养视图。
    /// - Parameters:
    ///   - animated: 底部圆环是否动画。
    ///   - animateTopMetrics: 顶部数值是否动画。
    private func updateMetricViews(animated: Bool, animateTopMetrics: Bool) {
        let states = viewModel.coreMetricStates
        let showRemainingValue = UserInfoModel.shared.showRemainCalories
        remainingTitleLabel.text = showRemainingValue ? "本餐后剩余" : "本餐后摄入"
        for (index, state) in states.enumerated() {
            guard index < topMetricViews.count, index < ringMetricViews.count else { continue }
            let color = metricColors[index]
            let postMealRemainingValue = state.targetValue - state.postMealConsumedValue
            let displayValue = showRemainingValue ? postMealRemainingValue : state.postMealConsumedValue
            topMetricViews[index].update(title: state.title, unit: state.unit, value: state.selectedValue, color: color, animated: animateTopMetrics)
            ringMetricViews[index].update(title: state.title,
                                          unit: state.unit,
                                          displayValue: displayValue,
                                          shouldHighlightNegativeValue: showRemainingValue,
                                          consumedValue: state.postMealConsumedValue,
                                          target: state.targetValue,
                                          color: color,
                                          overflowColor: metricOverflowColors[index],
                                          animated: animated)
        }
    }

    /// 刷新按钮可点击状态。
    private func updateAddButtonState() {
        addToLogsButton.isEnabled = viewModel.hasSelectedFoods
        addToLogsButton.alpha = viewModel.hasSelectedFoods ? 1 : 0.5
    }

    /// 切换某一行的勾选状态。
    /// - Parameter index: 食物索引。
    private func toggleSelection(at index: Int) {
        viewModel.toggleSelection(at: index)
        refreshVisibleFoodCell(at: index)
        updateMetricViews(animated: true)
        updateAddButtonState()
    }

    /// 更新某一行的数量。
    /// - Parameters:
    ///   - index: 食物索引。
    ///   - text: 输入框中的文本。
    private func updateQuantity(at index: Int, text: String) {
        viewModel.updateQuantity(at: index, text: text)
        refreshVisibleFoodCell(at: index)
        updateMetricViews(animated: true, animateTopMetrics: false)
        updateAddButtonState()
    }

    /// 结束编辑时恢复非法数量。
    /// - Parameters:
    ///   - index: 食物索引。
    ///   - text: 当前输入框文本。
    private func endEditingQuantity(at index: Int, text: String) {
        let normalizedText = text.replacingOccurrences(of: ",", with: ".")
        guard let quantity = Double(normalizedText), quantity > 0 else {
            viewModel.restoreQuantity(at: index)
            refreshVisibleFoodCell(at: index)
            updateMetricViews(animated: true, animateTopMetrics: false)
            updateAddButtonState()
            return
        }
        viewModel.updateQuantity(at: index, text: text)
        refreshVisibleFoodCell(at: index)
        updateMetricViews(animated: true, animateTopMetrics: false)
        updateAddButtonState()
    }

    /// 刷新某一行的可见 UI。
    /// - Parameter index: 食物索引。
    private func refreshVisibleFoodCell(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = foodTableView.cellForRow(at: indexPath) as? MealAdviceNextFoodCell else { return }
        cell.sync(with: viewModel.foodItems[index], keepQuantityText: true)
    }

    /// 添加到日志。
    @objc private func addToLogsAction() {
        let payloads = viewModel.selectedFoodPayloads()
        guard payloads.count > 0 else {
            MCToast.mc_text("请先勾选食物")
            return
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dietPlanFoodsAddToLogs"),
                                        object: nil,
                                        userInfo: ["sdate": sDate, "mealIndex": mealIndex, "fromMealAdvice": true])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForLogs"),
                                            object: payloads,
                                            userInfo: ["sdate": sDate, "mealIndex": mealIndex, "fromMealAdvice": true])
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    /// 关闭当前页面。
    @objc private func closeAction() {
        navigationController?.popViewController(animated: true)
    }

    /// 点击建议份量提示卡片。
    @objc private func tipsCardTapAction() {
        view.endEditing(true)
        view.bringSubviewToFront(tipsAlertVm)
        tipsAlertVm.showView()
    }

    /// 切换当前页面对应的三方输入法开关。
    /// - Parameter allowed: 是否允许键盘扩展。
    private func setKeyboardExtensionAllowed(_ allowed: Bool) {
        (UIApplication.shared.delegate as? AppDelegate)?.setKeyboardExtensionAllowed(allowed)
    }
}

extension MealAdviceNextVC: UITableViewDelegate, UITableViewDataSource {
    /// 返回食物列表行数。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.foodItems.count
    }

    /// 创建食物列表行。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealAdviceNextFoodCell") as? MealAdviceNextFoodCell
        let item = viewModel.foodItems[indexPath.row]
        cell?.sync(with: item)
        cell?.onSelectionTap = { [weak self] in
            self?.toggleSelection(at: indexPath.row)
        }
        cell?.onQuantityChanged = { [weak self] text in
            self?.updateQuantity(at: indexPath.row, text: text)
        }
        cell?.onQuantityEditingEnded = { [weak self] text in
            self?.endEditingQuantity(at: indexPath.row, text: text)
        }
        return cell ?? MealAdviceNextFoodCell()
    }

    /// 点击行时切换选中状态。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleSelection(at: indexPath.row)
    }

    /// 返回固定行高。
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        foodRowHeight
    }
}
