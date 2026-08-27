//
//  Guide0820BodyProfileVC.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// Guide0820BodyProfileVC 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820BodyProfileVC: WHBaseViewVC {
    // `currentIndex` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var currentIndex = 0
    // `isProgressPersistenceSuppressed` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var isProgressPersistenceSuppressed = false

    // `backButton` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var backButton: ElaLiquidGlassCloseButton = {
        let button = ElaLiquidGlassCloseButton()
        button.iconImage = UIImage(named: "guide_back_button")
        button.iconColor = .COLOR_TEXT_TITLE_0f1214
        button.iconSize = kFitWidth(20)
        button.showsOuterStroke = true
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return button
    }()

    // `navTitleLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let navTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "了解你的身体"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: kFitWidth(17), weight: .medium)
        label.textAlignment = .center
        return label
    }()

    // `progressTrackView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.1)
        view.layer.cornerRadius = kFitWidth(2)
        view.clipsToBounds = true
        return view
    }()

    // `progressView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_TEXT_TITLE_0f1214
        view.layer.cornerRadius = kFitWidth(2)
        view.clipsToBounds = true
        return view
    }()

    // `scrollView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
        view.isScrollEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.bounces = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()

    // `stackView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        return stack
    }()

    // `nextButton` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: guide0820Design(34), weight: .medium)
        button.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        button.layer.cornerRadius = guide0820Design(24)
        button.layer.cornerCurve = .continuous
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return button
    }()

    // `bottomGradientView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var bottomGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.layer.addSublayer(bottomGradientLayer)
        return view
    }()

    // `bottomGradientLayer` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
        return layer
    }()

    // `sexVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var sexVm: Guide0820BodyProfileSexVM = {
        let vm = Guide0820BodyProfileSexVM(frame: .zero)
        vm.sexChangedBlock = { [weak self] sex in
            guard let self else { return }
            switch sex {
            case "1":
                self.heightVm.applyDefaultHeight(170)
                self.weightVm.applyDefaultWeight(integer: 70)
            case "2":
                self.heightVm.applyDefaultHeight(160)
                self.weightVm.applyDefaultWeight(integer: 50)
            default:
                break
            }
            self.bodyfatVm.updateScrollView()
        }
        vm.showTipsBlock = { [weak self] in
            self?.sexIntroVm.show()
        }
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    // `yearVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var yearVm: Guide0820BodyProfileYearVM = {
        let vm = Guide0820BodyProfileYearVM(frame: .zero)
        return vm
    }()

    // `heightVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var heightVm: Guide0820BodyProfileHeightVM = {
        let vm = Guide0820BodyProfileHeightVM(frame: .zero)
        return vm
    }()

    // `weightVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var weightVm: Guide0820BodyProfileWeightVM = {
        let vm = Guide0820BodyProfileWeightVM(frame: .zero)
        vm.showTipsBlock = { [weak self] in
            self?.weightIntroVm.show()
        }
        vm.weightChangedBlock = { [weak self] value in
            self?.weightExceededVm.updateCurrentWeight(value)
        }
        return vm
    }()

    // `weightExceededVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var weightExceededVm: Guide0820BodyProfileWeightExceededVM = {
        let vm = Guide0820BodyProfileWeightExceededVM(frame: .zero)
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    // `weightTrendVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var weightTrendVm: Guide0820BodyProfileWeightTrendVM = {
        let vm = Guide0820BodyProfileWeightTrendVM(frame: .zero)
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    // `bodyfatVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var bodyfatVm: Guide0820BodyProfileBodyfatVM = {
        let vm = Guide0820BodyProfileBodyfatVM(frame: .zero)
        vm.showTipsBlock = { [weak self] in
            self?.bodyFatAlertVm.showView()
        }
        vm.selectStateChangeBlock = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    // `bodyFatAlertVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var bodyFatAlertVm: QuestionnaireBodyFatAlertVM = {
        QuestionnaireBodyFatAlertVM(frame: .zero)
    }()

    // `pages` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var pages: [UIView] = [
        sexVm,
        yearVm,
        heightVm,
        weightVm,
        weightExceededVm,
        weightTrendVm,
        bodyfatVm
    ]

    // `sexIntroVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var sexIntroVm = Guide0820BodyProfileIntroOverlayVM(
        title: "荷尔蒙：无法被忽略的变量",
        bodyItems: [
            (nil, "在营养与运动生理学中，生理性别并非形式项，而是初始估算的重要变量。"),
            ("·男性的代谢模型相对线性", "更高的骨骼肌比例和雄性激素水平，赋予了男性更高的基础代谢率，这也决定了其在增肌或减脂期，对碳水化合物与蛋白质具备更大的消耗与利用空间。[1]"),
            ("·女性绝不仅仅是“缩小版的男性”", "在整个生理周期中，雌激素与孕激素的交替波动，会直接影响身体的储水状态与食欲倾向。研究显示，在中等强度有氧运动中，女性平均比男性更依赖脂肪氧化；而黄体期也常伴随短期的代谢与体重波动，平均约0.5kg的体重起伏主要与细胞外液潴留有关。[2][3][4]"),
            (nil, "了解你的生理性别，是为了帮助 Elavatine 摒弃粗暴的“一刀切”公式，为你构建真正符合你生理规律的初始基准线。")
        ],
        references: "[1] Hunter et al. (2023), Med Sci Sports Exerc\n[2] Cano et al. (2022), Eur J Appl Physiol\n[3] Kanellakis et al. (2023), Am J Hum Biol\n[4] Benton et al. (2020), PLOS One",
        dismissAction: {}
    )

    // `weightIntroVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var weightIntroVm = Guide0820BodyProfileIntroOverlayVM(
        title: "什么时候称更准？",
        bodyItems: [
            (nil, "建议固定在早上起床排空后、进食饮水前称重。食物、水分和排便情况都会让体重短期波动，影响判断。")
        ],
        dismissAction: {}
    )

    /// 执行 `viewDidLoad` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        restoreSavedProgress()
        updatePage(animated: false)
    }

    /// 执行 `viewWillAppear` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enforceInteractivePopGestureDisabled()
    }

    /// 执行 `viewDidAppear` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enforceInteractivePopGestureDisabled()
    }

    /// 执行 `viewDidLayoutSubviews` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomGradientLayer.frame = bottomGradientView.bounds
    }

    /// 执行 `viewDidDisappear` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        restoreFullscreenInteractivePopGesture()
    }

    /// 释放当前类型实例持有的资源。
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// Guide0820BodyProfileVC 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820BodyProfileVC {
    // 执行 `enforceInteractivePopGestureDisabled` 操作，完成当前引导页面的状态更新或交互处理。
    func enforceInteractivePopGestureDisabled() {
        updateInteractivePopGestureBlocked(true)
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.navigationController?.topViewController === self else {
                return
            }
            self.updateInteractivePopGestureBlocked(true)
        }
    }

    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    func initUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .COLOR_BG_F2

        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(6))
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(kFitWidth(4.5))
            make.width.height.equalTo(kFitWidth(35))
        }

        view.addSubview(navTitleLabel)
        navTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }

        view.addSubview(progressTrackView)
        progressTrackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(guide0820Design(96))
            make.height.equalTo(guide0820Design(8))
        }

        progressTrackView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide)
        }

        pages.forEach { page in
            stackView.addArrangedSubview(page)
            page.snp.makeConstraints { make in
                make.width.equalTo(scrollView.frameLayoutGuide)
            }
        }

        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(navTitleLabel)
        view.bringSubviewToFront(progressTrackView)

        view.addSubview(bottomGradientView)
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(158) + WHUtils().getBottomSafeAreaHeight())
        }

        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(32))
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(guide0820Design(104))
        }

        view.addSubview(sexIntroVm)
        sexIntroVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(weightIntroVm)
        weightIntroVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(bodyFatAlertVm)
        bodyFatAlertVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // 执行 `updatePage` 操作，完成当前引导页面的状态更新或交互处理。
    func updatePage(animated: Bool) {
        currentIndex = min(max(currentIndex, 0), pages.count - 1)
        view.layoutIfNeeded()
        let offset = CGPoint(x: SCREEN_WIDHT * CGFloat(currentIndex), y: 0)
        scrollView.setContentOffset(offset, animated: animated)
        updateProgress()
        syncNextButtonState()
        if currentIndex == pages.count - 1 {
            restoreBodyFatSelectionFromStorage(shouldCenterSelectedItem: false)
        }
        if let page = pages[currentIndex] as? Guide0820BodyProfilePageVM {
            page.pageWillAppear()
        } else if let page = pages[currentIndex] as? Guide0820BodyProfileYearVM {
            page.pageWillAppear()
        }
    }

    // 执行 `updateProgress` 操作，完成当前引导页面的状态更新或交互处理。
    func updateProgress() {
        let ratio = CGFloat(currentIndex + 1) / CGFloat(max(pages.count, 1))
        progressView.snp.remakeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(progressTrackView.snp.width).multipliedBy(ratio)
        }
        UIView.animate(withDuration: 0.2) {
            self.progressTrackView.layoutIfNeeded()
        }
    }

    // 执行 `syncNextButtonState` 操作，完成当前引导页面的状态更新或交互处理。
    func syncNextButtonState() {
        let valid: Bool
        if let vm = pages[currentIndex] as? Guide0820BodyProfilePageVM {
            valid = vm.isStepValid
        } else if let vm = pages[currentIndex] as? Guide0820BodyProfileYearVM {
            valid = vm.isStepValid
        } else if let vm = pages[currentIndex] as? Guide0820BodyProfileBodyfatVM {
            valid = vm.selectIndex >= 0
        } else {
            valid = true
        }
        nextButton.isEnabled = valid
        nextButton.backgroundColor = valid ? .THEME : .COLOR_BUTTON_DISABLE_BG_THEME
    }

    // 执行 `backButtonAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc func backButtonAction() {
        if currentIndex > 0 {
            currentIndex -= 1
            updatePage(animated: true)
            return
        }
        navigationController?.popViewController(animated: true)
    }

    // 执行 `nextButtonAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc func nextButtonAction() {
        commitCurrentPage()
        if currentIndex == pages.count - 1 {
            persistCompletedBodyProfile()
            Guide0820ProgressStorage.markStepCompleted(.bodyProfile)
            Guide0820Model.shared.printModelMsg()
            navigationController?.popViewController(animated: true)
            return
        }
        currentIndex += 1
        updatePage(animated: true)
    }

    /// 恢复本地保存的身体资料进度。
    func restoreSavedProgress() {
        performWithoutProgressPersistence {
            Guide0820ProgressStorage.restoreBodyProfileToGuide0820Model()
            sexVm.restore(selectedSex: Guide0820ProgressStorage.bodyProfileSex)
            yearVm.restore(birthYear: Guide0820ProgressStorage.bodyProfileBirthYear)
            heightVm.restore(height: Guide0820ProgressStorage.bodyProfileHeight)
            weightVm.restore(weight: Guide0820ProgressStorage.bodyProfileWeight)
            weightExceededVm.restore(selectedValue: Guide0820ProgressStorage.bodyProfileWeightExceeded)
            weightTrendVm.restore(selectedValue: Guide0820ProgressStorage.bodyProfileWeightTrend)
            restoreBodyFatSelectionFromStorage(shouldCenterSelectedItem: false)
            currentIndex = min(max(currentIndex, 0), pages.count - 1)
        }

        syncNextButtonState()
    }

    /// 身体问卷整段完成后，一次性保存全部答案。
    func persistCompletedBodyProfile() {
        guard isProgressPersistenceSuppressed == false else { return }

        pages.forEach { page in
            if let pageVM = page as? Guide0820BodyProfilePageVM {
                pageVM.commitCurrentValue()
            } else if let pageVM = page as? Guide0820BodyProfileYearVM {
                pageVM.commitCurrentValue()
            } else if let pageVM = page as? Guide0820BodyProfileBodyfatVM {
                pageVM.commitCurrentValue()
            }
        }
        Guide0820ProgressStorage.saveBodyProfileFromGuide0820Model()
    }

    /// 完成当前页时先把页面状态同步到 Guide0820Model。
    func commitCurrentPage() {
        if let pageVM = pages[currentIndex] as? Guide0820BodyProfilePageVM {
            pageVM.commitCurrentValue()
        } else if let pageVM = pages[currentIndex] as? Guide0820BodyProfileYearVM {
            pageVM.commitCurrentValue()
        } else if let pageVM = pages[currentIndex] as? Guide0820BodyProfileBodyfatVM {
            pageVM.commitCurrentValue()
        }
    }

    // 执行 `restoreBodyFatSelectionFromStorage` 操作，完成当前引导页面的状态更新或交互处理。
    func restoreBodyFatSelectionFromStorage(shouldCenterSelectedItem: Bool) {
        performWithoutProgressPersistence {
            bodyfatVm.updateScrollView()
            if let bodyFat = Guide0820ProgressStorage.bodyProfileBodyFat {
                bodyfatVm.restoreSelection(modelValue: bodyFat, shouldCenterSelectedItem: shouldCenterSelectedItem)
            }
        }
    }

    // 执行 `performWithoutProgressPersistence` 操作，完成当前引导页面的状态更新或交互处理。
    func performWithoutProgressPersistence(_ action: () -> Void) {
        let previousValue = isProgressPersistenceSuppressed
        isProgressPersistenceSuppressed = true
        action()
        isProgressPersistenceSuppressed = previousValue
    }
}
