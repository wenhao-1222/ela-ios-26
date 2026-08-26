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
    private var currentIndex = 0
    private var isProgressPersistenceSuppressed = false
    private var hasInstalledPages = false

    private lazy var backButton: ElaLiquidGlassCloseButton = {
        let button = ElaLiquidGlassCloseButton()
        button.iconImage = UIImage(named: "guide_back_button")
        button.iconColor = .COLOR_TEXT_TITLE_0f1214
        button.iconSize = kFitWidth(20)
        button.showsOuterStroke = true
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return button
    }()

    private let navTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "了解你的生活"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: kFitWidth(17), weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.1)
        view.layer.cornerRadius = kFitWidth(2)
        view.clipsToBounds = true
        return view
    }()

    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_TEXT_TITLE_0f1214
        view.layer.cornerRadius = kFitWidth(2)
        view.clipsToBounds = true
        return view
    }()

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

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        return stack
    }()

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

    private lazy var bottomGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.layer.addSublayer(bottomGradientLayer)
        return view
    }()

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

    private lazy var takeoutFrequencyVm: Guide0820LifeProfileTakeoutFrequencyVM = {
        let vm = Guide0820LifeProfileTakeoutFrequencyVM()
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

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

    private lazy var mealsAdjustVm: Guide0820LifeProfileMealsAdjustVM = {
        let vm = Guide0820LifeProfileMealsAdjustVM(frame: .zero)
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    private lazy var exerciseCaloriesRecordVm: Guide0820LifeProfileExerciseCaloriesRecordVM = {
        let vm = Guide0820LifeProfileExerciseCaloriesRecordVM()
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    private lazy var cardioFrequencyVm: Guide0820LifeProfileCardioFrequencyVM = {
        let vm = Guide0820LifeProfileCardioFrequencyVM()
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    private lazy var strengthTrainingFrequencyVm: Guide0820LifeProfileStrengthTrainingFrequencyVM = {
        let vm = Guide0820LifeProfileStrengthTrainingFrequencyVM()
        vm.validityChanged = { [weak self] _ in
            self?.syncNextButtonState()
        }
        return vm
    }()

    private lazy var caloriesResultVm = Guide0820LifeProfileCaloriesResultVM(frame: .zero)

    private lazy var reminderVm: Guide0820LifeProfileReminderVM = {
        let vm = Guide0820LifeProfileReminderVM(frame: .zero)
        vm.enableReminderBlock = { [weak self] in
            self?.finishLifeProfile(requestReminderPermission: true)
        }
        vm.skipReminderBlock = { [weak self] in
            self?.finishLifeProfile(requestReminderPermission: false)
        }
        return vm
    }()

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

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        restoreSavedProgress()
        updatePage(animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomGradientLayer.frame = bottomGradientView.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension Guide0820LifeProfileVC {
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

    func updatePage(animated: Bool) {
        guard hasInstalledPages, pages.isEmpty == false else { return }
        currentIndex = clampedCurrentIndex()
        view.layoutIfNeeded()
        scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(currentIndex), y: 0), animated: animated)
        updateProgress()
        syncNextButtonState()
        (pages[currentIndex] as? Guide0820LifeProfilePageVM)?.pageWillAppear()
    }

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

    func syncNextButtonState() {
        guard let currentPage = safeCurrentPage() else { return }
        let isReminderPage = currentPage === reminderVm
        nextButton.isHidden = isReminderPage
        bottomGradientView.isHidden = isReminderPage

        let valid = (currentPage as? Guide0820LifeProfilePageVM)?.isStepValid ?? true
        nextButton.isEnabled = valid
        nextButton.backgroundColor = valid ? .THEME : .COLOR_BUTTON_DISABLE_BG_THEME
    }

    @objc func backButtonAction() {
        if currentIndex > 0 {
            currentIndex -= 1
            updatePage(animated: true)
            return
        }
        navigationController?.popViewController(animated: true)
    }

    @objc func nextButtonAction() {
        commitCurrentPage()
        if currentIndex == pages.count - 1 {
            finishLifeProfile(requestReminderPermission: false)
            return
        }
        currentIndex += 1
        updatePage(animated: true)
    }

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

    func persistCompletedLifeProfile() {
        guard isProgressPersistenceSuppressed == false else { return }
        pages.forEach { ($0 as? Guide0820LifeProfilePageVM)?.commitCurrentValue() }
        Guide0820ProgressStorage.saveLifeProfileFromGuide0820Model()
    }

    /// 完成当前页时先把页面状态同步到 Guide0820Model。
    func commitCurrentPage() {
        (pages[currentIndex] as? Guide0820LifeProfilePageVM)?.commitCurrentValue()
    }

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

    func performWithoutProgressPersistence(_ action: () -> Void) {
        let previousValue = isProgressPersistenceSuppressed
        isProgressPersistenceSuppressed = true
        action()
        isProgressPersistenceSuppressed = previousValue
    }

    func clampedCurrentIndex() -> Int {
        guard pages.isEmpty == false else { return 0 }
        return min(max(currentIndex, 0), pages.count - 1)
    }

    func safeCurrentPage() -> UIView? {
        guard hasInstalledPages, pages.isEmpty == false else { return nil }
        currentIndex = clampedCurrentIndex()
        return pages[currentIndex]
    }
}
