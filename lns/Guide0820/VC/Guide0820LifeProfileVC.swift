//
//  Guide0820LifeProfileVC.swift
//  lns
//
//  Created by Codex on 2026/8/25.
//

import UIKit
import SnapKit
import UserNotifications

/// Guide0820 第二步“了解你的生活”流程页。
final class Guide0820LifeProfileVC: WHBaseViewVC {
    // `currentIndex` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var currentIndex = 0
    // `isProgressPersistenceSuppressed` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var isProgressPersistenceSuppressed = false

    /// 非首步时接管右滑手势，用于返回流程内的上一步。
    private lazy var stepBackSwipeGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleStepBackSwipe))
        gesture.direction = .right
        gesture.isEnabled = false
        return gesture
    }()
    // `hasInstalledPages` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var hasInstalledPages = false
    // 防止热量结果页重复发起相同的基础消耗请求。
    private var isRequestingBasicConsumption = false
    private var lastRequestedBasicConsumptionSignature: String?

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
        label.text = "了解你的生活"
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

    // `takeoutFrequencyVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var takeoutFrequencyVm: Guide0820LifeProfileTakeoutFrequencyVM = {
        let vm = Guide0820LifeProfileTakeoutFrequencyVM()
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    // `mealsPerDayVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var mealsPerDayVm: Guide0820LifeProfileMealsPerDayVM = {
        let vm = Guide0820LifeProfileMealsPerDayVM()
        vm.validityChanged = { [weak self, weak vm] _ in
            if let selectedValue = vm?.selectedAnswerValue {
                Guide0820Model.shared.guidanceMealsAdjustType = selectedValue
            }
            self?.mealsAdjustVm.refreshSelectionFromModel()
            self?.syncNextButtonState()
        }
        return vm
    }()

    // `mealsAdjustVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var mealsAdjustVm: Guide0820LifeProfileMealsAdjustVM = {
        let vm = Guide0820LifeProfileMealsAdjustVM(frame: .zero)
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    // `exerciseCaloriesRecordVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var exerciseCaloriesRecordVm: Guide0820LifeProfileExerciseCaloriesRecordVM = {
        let vm = Guide0820LifeProfileExerciseCaloriesRecordVM()
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    // `cardioFrequencyVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var cardioFrequencyVm: Guide0820LifeProfileCardioFrequencyVM = {
        let vm = Guide0820LifeProfileCardioFrequencyVM()
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    // `strengthTrainingFrequencyVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var strengthTrainingFrequencyVm: Guide0820LifeProfileStrengthTrainingFrequencyVM = {
        let vm = Guide0820LifeProfileStrengthTrainingFrequencyVM()
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    // `caloriesResultVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var caloriesResultVm = Guide0820LifeProfileCaloriesResultVM(frame: .zero)

    // `reminderVm` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var reminderVm: Guide0820LifeProfileReminderVM = {
        let vm = Guide0820LifeProfileReminderVM(frame: .zero)
        vm.enableReminderBlock = { [weak self] in
            self?.handleReminderSelection(requestPermission: true)
        }
        vm.skipReminderBlock = { [weak self] in
            self?.handleReminderSelection(requestPermission: false)
        }
        return vm
    }()

    // `pages` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var pages: [UIView] = [
        takeoutFrequencyVm,
        mealsPerDayVm,
        mealsAdjustVm,
        exerciseCaloriesRecordVm,
        cardioFrequencyVm,
        strengthTrainingFrequencyVm,
        reminderVm,
        caloriesResultVm,        
    ]

    /// 执行 `viewDidLoad` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        restoreSavedProgress()
        updatePage(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBackGestureAvailability()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateBackGestureAvailability()
    }

    /// 执行 `viewDidLayoutSubviews` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomGradientLayer.frame = bottomGradientView.bounds
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        restoreFullscreenInteractivePopGesture()
    }

    /// 释放当前类型实例持有的资源。
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// Guide0820LifeProfileVC 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820LifeProfileVC {
    /// 首步交给导航控制器执行交互式 pop，其余步骤由页面内右滑返回上一步。
    func updateBackGestureAvailability() {
        let isFirstStep = currentIndex == 0
        stepBackSwipeGesture.isEnabled = !isFirstStep

        if isFirstStep {
            restoreFullscreenInteractivePopGesture()
        } else {
            canEdgeBack = false
            fd_forceDisableInteractivePopGesture = true
            fd_interactivePopDisabled = true
            navigationController?.fd_interactivePopDisabled = true
            navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }

    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    func initUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .COLOR_BG_F2
        view.addGestureRecognizer(stepBackSwipeGesture)

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
            make.edges.equalToSuperview()
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
        hasInstalledPages = true

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
    }

    // 执行 `updatePage` 操作，完成当前引导页面的状态更新或交互处理。
    func updatePage(animated: Bool) {
        guard hasInstalledPages, pages.isEmpty == false else { return }
        currentIndex = clampedCurrentIndex()
        updateBackGestureAvailability()
        view.layoutIfNeeded()
        scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(currentIndex), y: 0), animated: animated)
        updateProgress()
        syncNextButtonState()
        (pages[currentIndex] as? Guide0820LifeProfilePageVM)?.pageWillAppear()
    }

    // 执行 `updateProgress` 操作，完成当前引导页面的状态更新或交互处理。
    func updateProgress() {
        guard hasInstalledPages, pages.isEmpty == false else { return }
        currentIndex = clampedCurrentIndex()
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
        guard let currentPage = safeCurrentPage() else { return }
        let isReminderPage = currentPage === reminderVm
        nextButton.isHidden = isReminderPage
        bottomGradientView.isHidden = isReminderPage

        let valid = (currentPage as? Guide0820LifeProfilePageVM)?.isStepValid ?? true
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

    @objc func handleStepBackSwipe() {
        guard currentIndex > 0 else { return }
        backButtonAction()
    }

    // 执行 `nextButtonAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc func nextButtonAction() {
        if currentIndex == pages.count - 1,
           caloriesResultVm.hasReasonableCaloriesInput == false {
            presentAlertVcNoAction(title: "请输入合理的热量摄入值", viewController: self)
            return
        }
        commitCurrentPage()
        if pages[currentIndex] === cardioFrequencyVm {
            requestBasicConsumptionIfNeeded()
        }
        if currentIndex == pages.count - 1 {
            finishLifeProfile(requestReminderPermission: false)
            return
        }
        currentIndex += 1
        updatePage(animated: true)
    }

    // 执行 `restoreSavedProgress` 操作，完成当前引导页面的状态更新或交互处理。
    func restoreSavedProgress() {
        performWithoutProgressPersistence {
            Guide0820ProgressStorage.restoreBodyProfileToGuide0820Model()
            Guide0820ProgressStorage.restoreLifeProfileToGuide0820Model()
            takeoutFrequencyVm.restore(selectedValue: Guide0820ProgressStorage.lifeProfileTakeoutFrequency)
            mealsPerDayVm.restore(selectedValue: Guide0820ProgressStorage.lifeProfileMealsPerDay)
            mealsAdjustVm.refreshSelectionFromModel()
            exerciseCaloriesRecordVm.restore(selectedValue: Guide0820ProgressStorage.lifeProfileExerciseCaloriesRecord)
            cardioFrequencyVm.restore(selectedValue: Guide0820ProgressStorage.lifeProfileCardioFrequency)
            strengthTrainingFrequencyVm.restore(selectedValue: Guide0820ProgressStorage.lifeProfileStrengthTrainingFrequency)
            currentIndex = clampedCurrentIndex()
        }
        syncNextButtonState()
    }

    // 执行 `persistCompletedLifeProfile` 操作，完成当前引导页面的状态更新或交互处理。
    func persistCompletedLifeProfile() {
        guard isProgressPersistenceSuppressed == false else { return }
        pages.forEach { ($0 as? Guide0820LifeProfilePageVM)?.commitCurrentValue() }
        Guide0820ProgressStorage.saveLifeProfileFromGuide0820Model()
    }

    /// 完成当前页时先把页面状态同步到 Guide0820Model。
    func commitCurrentPage() {
        (pages[currentIndex] as? Guide0820LifeProfilePageVM)?.commitCurrentValue()
    }

    // 执行 `finishLifeProfile` 操作，完成当前引导页面的状态更新或交互处理。
    func finishLifeProfile(requestReminderPermission: Bool) {
        persistCompletedLifeProfile()
        Guide0820ProgressStorage.markStepCompleted(.lifeProfile)
        Guide0820Model.shared.printModelMsg()

        guard requestReminderPermission else {
            navigationController?.popViewController(animated: true)
            return
        }

        UserInfoModel.shared.showNotifiAuthoriAlertVM = false
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            switch settings.authorizationStatus {
            case .denied:
                DispatchQueue.main.async {
                    self.openUrl(urlString: UIApplication.openSettingsURLString)
                    self.navigationController?.popViewController(animated: true)
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            default:
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    /// 处理提醒页操作。提醒授权完成后继续进入最后的基础消耗结果页。
    func handleReminderSelection(requestPermission: Bool) {
        guard requestPermission else {
            showCaloriesResultPage()
            return
        }

        UserInfoModel.shared.showNotifiAuthoriAlertVM = false
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            let continueToCalories = {
                DispatchQueue.main.async {
                    self.showCaloriesResultPage()
                }
            }
            switch settings.authorizationStatus {
            case .denied:
                DispatchQueue.main.async {
                    self.openUrl(urlString: UIApplication.openSettingsURLString)
                    continueToCalories()
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                    continueToCalories()
                }
            default:
                continueToCalories()
            }
        }
    }

    /// 跳转到生活资料流程的最后一步。
    func showCaloriesResultPage() {
        guard pages.isEmpty == false else { return }
        currentIndex = pages.count - 1
        updatePage(animated: true)
    }

    /// 在有氧频率页离开时请求基础消耗；参数变化后再次离开该页会重新请求。
    func requestBasicConsumptionIfNeeded() {
        guard let request = basicConsumptionRequest(),
              request.signature != lastRequestedBasicConsumptionSignature,
              isRequestingBasicConsumption == false else {
            return
        }
        requestBasicConsumption(request.parameters, signature: request.signature)
    }

    /// 生成基础消耗接口参数及其签名；四项参数全部具备后才允许请求。
    func basicConsumptionRequest() -> (parameters: [String: AnyObject], signature: String)? {
        let model = Guide0820Model.shared
        let values = [model.sex, model.events, model.bodyFat, model.weight]
        guard values.allSatisfy({ $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }) else {
            return nil
        }
        let parameters: [String: AnyObject] = [
            "gender": model.sex as NSString,
            "dailyact": model.events as NSString,
            "bodyfat": model.bodyFat as NSString,
            "weight": model.weight as NSString
        ]
        return (parameters, values.joined(separator: "|"))
    }

    /// 请求基础消耗并将服务端结果回填到热量结果页。
    func requestBasicConsumption(_ parameters: [String: AnyObject], signature: String) {
        guard isRequestingBasicConsumption == false else { return }
        isRequestingBasicConsumption = true
        lastRequestedBasicConsumptionSignature = signature
        DLLog(message: "Guide0820 requestBasicConsumption: \(parameters)")

        WHNetworkUtil.shareManager().POST(
            urlString: URL_question_basic_consumption,
            parameters: parameters,
            isNeedToast: true,
            vc: self
        ) { [weak self] responseObject in
            guard let self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "") ?? ""
            let caloriesText = dataString.trimmingCharacters(in: .whitespacesAndNewlines)
            DispatchQueue.main.async {
                self.isRequestingBasicConsumption = false
                guard let calories = Int(caloriesText), calories > 0 else {
                    DLLog(message: "Guide0820 requestBasicConsumption invalid calories: \(caloriesText)")
                    if self.basicConsumptionRequest()?.signature != signature {
                        self.lastRequestedBasicConsumptionSignature = nil
                        self.requestBasicConsumptionIfNeeded()
                    }
                    return
                }

                guard self.basicConsumptionRequest()?.signature == signature else {
                    self.lastRequestedBasicConsumptionSignature = nil
                    self.requestBasicConsumptionIfNeeded()
                    return
                }
                self.caloriesResultVm.updateCaloriesFromServer("\(calories)")
            }
        } failure: { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isRequestingBasicConsumption = false
                if self.basicConsumptionRequest()?.signature != signature {
                    self.lastRequestedBasicConsumptionSignature = nil
                    self.requestBasicConsumptionIfNeeded()
                }
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

    // 执行 `clampedCurrentIndex` 操作，完成当前引导页面的状态更新或交互处理。
    func clampedCurrentIndex() -> Int {
        guard pages.isEmpty == false else { return 0 }
        return min(max(currentIndex, 0), pages.count - 1)
    }

    // 执行 `safeCurrentPage` 操作，完成当前引导页面的状态更新或交互处理。
    func safeCurrentPage() -> UIView? {
        guard hasInstalledPages, pages.isEmpty == false else { return nil }
        currentIndex = clampedCurrentIndex()
        return pages[currentIndex]
    }
}
