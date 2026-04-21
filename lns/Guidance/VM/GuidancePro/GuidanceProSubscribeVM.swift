//
//  GuidanceProSubscribeVM.swift
//  lns
//
//  Created by Codex on 2026/3/20.
//

import UIKit
import StoreKit
import SnapKit
import UserNotifications

class GuidanceProSubscribeVM: UIView {

    var startTrialTapBlock: (() -> Void)?
    var closeTapBlock: (() -> Void)?

    private var isSyncingReminderSwitchState = false
    private var hasFreeTrialPermission = true
    private var startTrialButtonNormalTitle = "0元 开启体验"
    private var annualPriceDescription = "168/年"
    private var dailyPriceDescription = "0.46元/天"

    private lazy var loadingOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.COLOR_BG_WHITE.withAlphaComponent(0.72)
        view.isHidden = true
        return view
    }()

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .THEME
        view.hidesWhenStopped = false
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()

    private lazy var contentView = UIView()
    private lazy var footerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.98)
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 18
        view.layer.shadowOffset = CGSize(width: 0, height: -8)
        return view
    }()

    private lazy var footerDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.withAlphaComponent(0.12)
        return view
    }()

    private lazy var footerTopFadeView: VerticalFadeView = {
        let view = VerticalFadeView()
        view.isUserInteractionEnabled = false
        view.startColor = UIColor.white.withAlphaComponent(0)
        view.endColor = UIColor.white.withAlphaComponent(0.98)
        return view
    }()

    private lazy var closeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_close_icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapAction))
        imageView.addGestureRecognizer(tap)
        
        return imageView
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_expired_alert_icon"))
        //ela_pro_expired_alert_icon
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var starsLeftImgView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "guidance_pro_promise_img")
        return img
    }()
    private lazy var starsLabel: UILabel = {
        let label = UILabel()
        label.text = "★★★★★"
        label.textColor = UIColor(hex: 0xFFC928)
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "超过1万+评价"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 8, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    lazy var starsRightImgView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "guidance_pro_subscribe_img")
        return img
    }()
    private lazy var faqStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = kFitWidth(18)
        return stack
    }()

    private lazy var reminderCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.84)
        view.layer.cornerRadius = kFitWidth(12)
        view.layer.borderWidth = kFitWidth(2)
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()

    private lazy var reminderLabel: UILabel = {
        let label = UILabel()
        label.text = "在试用期结束前提醒我"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private lazy var reminderSwitch: UISwitch = {
        let view = UISwitch()
        view.onTintColor = .THEME
        view.isOn = false
        view.addTarget(self, action: #selector(reminderSwitchValueChanged(_:)), for: .valueChanged)
        return view
    }()

    private lazy var trialDescLabel: UILabel = {
        let label = UILabel()
//        label.text = "免费试用3天，随后以186/年价格续费，仅0.51元/天。"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setLineHeight(textString: "免费试用3天，随后以168/年价格续费，仅0.46元/天。", lineHeight: label.font.lineHeight * 1.1)
        return label
    }()

    private lazy var renewalDescLabel: UILabel = {
        let label = UILabel()
//        label.text = "订阅计划会自动续订。请通过 App Store 取消订阅。\n除非你取消，否则免费试用结束后将开始收费。"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        label.setLineHeight(textString: "订阅计划会自动续订。请通过 App Store 取消订阅。\n除非你取消，否则免费试用结束后将开始收费。", lineHeight: label.font.lineHeight * 1.1)
        return label
    }()

    private lazy var startTrialButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("0元 开启体验", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        button.layer.cornerRadius = kFitWidth(22)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(startTrialTapAction), for: .touchUpInside)
        return button
    }()

    private lazy var noteIconLabel: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private lazy var noteLabel: UILabel = {
        let label = UILabel()
        label.text = "现在无需付费，你可以随时取消。"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private lazy var noteStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noteIconLabel, noteLabel])
        stack.axis = .horizontal
        stack.spacing = kFitWidth(6)
        stack.alignment = .center
        return stack
    }()

    private lazy var proTitleLabel = makeSectionTitle("ELA PRO 将帮助你：")
    private lazy var freeTitleLabel = makeSectionTitle("以及现有的免费功能：")
    private lazy var proFeatureContainer = makeFeatureContainer()
    private lazy var freeFeatureContainer = makeFeatureContainer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        initUI()
        observeAppBecomeActive()
        syncReminderSwitchStatusFromSystem(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension GuidanceProSubscribeVM {
    func updateFreeTrialPermission(_ hasPermission: Bool) {
        hasFreeTrialPermission = hasPermission
        startTrialButtonNormalTitle = hasPermission ? "0元 开启体验" : "开启体验"

//        reminderCardView.isHidden = !hasPermission
        noteStackView.isHidden = !hasPermission

        updateTrialDescription()
        renewalDescLabel.text = hasPermission
        ? "订阅计划会自动续订。请通过 App Store 取消订阅。\n除非你取消，否则免费试用结束后将开始收费。"
        : "订阅计划会自动续订。请通过 App Store 取消订阅。\n如果你不需要，可在当前订阅周期结束前取消。"
        startTrialButton.setTitle(startTrialButtonNormalTitle, for: .normal)

        rebuildFAQs()
        updateDynamicLayoutForTrialPermission()
    }

    func setLoading(_ isLoading: Bool) {
        loadingOverlayView.isHidden = !isLoading
        isUserInteractionEnabled = !isLoading

        if isLoading {
            bringSubviewToFront(loadingOverlayView)
            loadingIndicatorView.startAnimating()
        } else {
            loadingIndicatorView.stopAnimating()
        }

        startTrialButton.isEnabled = !isLoading
        startTrialButton.setTitle(isLoading ? "处理中..." : startTrialButtonNormalTitle, for: .normal)
    }

    func updateAnnualProduct(_ product: SKProduct) {
        annualPriceDescription = recurringPriceDescription(for: product)
        dailyPriceDescription = dailyPriceText(for: product)
        updateTrialDescription()
    }

    @objc func closeTapAction() {
        self.closeTapBlock?()
    }

    @objc func reminderSwitchValueChanged(_ sender: UISwitch) {
        guard !isSyncingReminderSwitchState else { return }
        guard sender.isOn else { return }

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.setReminderSwitchOn(true, animated: true)
                case .denied:
                    self.setReminderSwitchOn(false, animated: true)
                    self.presentNotificationPermissionAlert()
                case .notDetermined:
                    self.requestReminderNotificationAuthorization()
                @unknown default:
                    self.setReminderSwitchOn(false, animated: true)
                }
            }
        }
    }

    @objc func handleAppDidBecomeActive() {
        syncReminderSwitchStatusFromSystem(animated: true)
    }
}

private extension GuidanceProSubscribeVM {
    func requestReminderNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted {
                    self.syncReminderSwitchStatusFromSystem(animated: true)
                } else {
                    self.setReminderSwitchOn(false, animated: true)
                }
            }
        }
    }

    func observeAppBecomeActive() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    func syncReminderSwitchStatusFromSystem(animated: Bool) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            let isEnabled: Bool
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                isEnabled = true
            default:
                isEnabled = false
            }

            DispatchQueue.main.async {
                self?.setReminderSwitchOn(isEnabled, animated: animated)
            }
        }
    }

    func setReminderSwitchOn(_ isOn: Bool, animated: Bool) {
        isSyncingReminderSwitchState = true
        reminderSwitch.setOn(isOn, animated: animated)
        isSyncingReminderSwitchState = false
    }

    func updateTrialDescription() {
        let text = hasFreeTrialPermission
        ? "免费试用3天，随后以\(annualPriceDescription)价格续费，仅\(dailyPriceDescription)。"
        : "订阅价格为\(annualPriceDescription)，仅\(dailyPriceDescription)。"
        trialDescLabel.text = text
        trialDescLabel.setLineHeight(textString: text, lineHeight: trialDescLabel.font.lineHeight * 1.1)
    }

    func recurringPriceDescription(for product: SKProduct) -> String {
        let period = periodText(from: product.subscriptionPeriod)
        if isChineseYuanLocale(product.priceLocale) {
            return "\(decimalText(for: product.price))/\(period)"
        }
        return ElaProIAPManager.shared.localizedPriceString(for: product) + "/\(period)"
    }

    func dailyPriceText(for product: SKProduct) -> String {
        let days = max(daysCount(from: product.subscriptionPeriod), 1)
        let daily = product.price.dividing(by: NSDecimalNumber(value: days))
        if isChineseYuanLocale(product.priceLocale) {
            return "\(decimalText(for: daily))元/天"
        }
        return "\(localizedPriceString(decimal: daily, locale: product.priceLocale))/天"
    }

    func localizedPriceString(decimal: NSDecimalNumber, locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = max(2, formatter.maximumFractionDigits)
        return formatter.string(from: decimal) ?? "\(decimal)"
    }

    func decimalText(for value: NSDecimalNumber) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value) ?? "\(value)"
    }

    func periodText(from period: SKProductSubscriptionPeriod?) -> String {
        guard let period = period else { return "年" }
        let unitText: String
        switch period.unit {
        case .day:
            unitText = "天"
        case .week:
            unitText = "周"
        case .month:
            unitText = "月"
        case .year:
            unitText = "年"
        @unknown default:
            unitText = "期"
        }

        if period.numberOfUnits <= 1 {
            return unitText
        }
        return "\(period.numberOfUnits)\(unitText)"
    }

    func daysCount(from period: SKProductSubscriptionPeriod?) -> Int {
        guard let period = period else { return 365 }
        let units = max(period.numberOfUnits, 1)
        switch period.unit {
        case .day:
            return units
        case .week:
            return units * 7
        case .month:
            return units * 30
        case .year:
            return units * 365
        @unknown default:
            return 365
        }
    }

    func isChineseYuanLocale(_ locale: Locale) -> Bool {
        guard let currencyCode = locale.currencyCode?.uppercased() else { return false }
        return currencyCode == "CNY" || currencyCode == "CNH" || currencyCode == "RMB"
    }

    func presentNotificationPermissionAlert() {
        guard let topVC = UIApplication.topViewController() else {
            return
        }
        guard !(topVC.presentedViewController is UIAlertController) else { return }

        let alert = UIAlertController(title: "通知权限未开启",
                                      message: "请在系统设置中允许通知，便于你在试用结束前收到提醒。",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        let settingsAction = UIAlertAction(title: "去设置", style: .default) { _ in
            self.openSystemSettings()
        }
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        topVC.present(alert, animated: true)
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func initUI() {
        addSubview(scrollView)
        addSubview(footerContainerView)
        addSubview(closeImageView)
        addSubview(loadingOverlayView)
        scrollView.addSubview(contentView)
        loadingOverlayView.addSubview(loadingIndicatorView)
        addSubview(footerTopFadeView)

        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(footerContainerView.snp.top)
        }

        footerContainerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }

        footerTopFadeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(footerContainerView.snp.top)
            make.height.equalTo(kFitWidth(34))
        }

        loadingOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        contentView.addSubview(logoImageView)
        contentView.addSubview(starsLeftImgView)
        contentView.addSubview(starsLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(starsRightImgView)
        contentView.addSubview(faqStackView)
        contentView.addSubview(reminderCardView)
        contentView.addSubview(proTitleLabel)
        contentView.addSubview(proFeatureContainer)
        contentView.addSubview(freeTitleLabel)
        contentView.addSubview(freeFeatureContainer)
        contentView.addSubview(renewalDescLabel)
        
        freeFeatureContainer.layer.borderColor = UIColor.clear.cgColor

//        footerContainerView.addSubview(footerDividerView)
        footerContainerView.addSubview(trialDescLabel)
        footerContainerView.addSubview(startTrialButton)
        footerContainerView.addSubview(noteStackView)

        reminderCardView.addSubview(reminderLabel)
        reminderCardView.addSubview(reminderSwitch)

        logoImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(28))
            make.top.equalTo(statusBarHeight + kFitWidth(110))
            make.width.equalTo(kFitWidth(165))
            make.height.equalTo(kFitWidth(29))
        }
        closeImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-15))
            make.top.equalTo(statusBarHeight + kFitWidth(10))
            make.width.height.equalTo(kFitWidth(30))
        }
        starsRightImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-29))
            make.centerY.lessThanOrEqualTo(logoImageView)
            make.width.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(38))
        }
        starsLabel.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-24))
            make.right.equalTo(starsRightImgView.snp.left).offset(kFitWidth(-3))
//            make.centerY.lessThanOrEqualTo(starsRightImgView)
            make.top.equalTo(starsRightImgView).offset(kFitWidth(5))
        }

        ratingLabel.snp.makeConstraints { make in
            make.centerX.equalTo(starsLabel)
            make.bottom.equalTo(starsRightImgView).offset(kFitWidth(-5))
//            make.top.equalTo(starsLabel.snp.bottom).offset(kFitWidth(8))
        }
        starsLeftImgView.snp.makeConstraints { make in
            make.right.equalTo(starsLabel.snp.left).offset(kFitWidth(-3))
            make.width.height.equalTo(starsRightImgView)
            make.centerY.lessThanOrEqualTo(starsRightImgView)
        }

        faqStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(logoImageView.snp.bottom).offset(kFitWidth(34))
        }

        reminderCardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(faqStackView.snp.bottom).offset(kFitWidth(30))
            make.height.equalTo(kFitWidth(60))
        }

        reminderLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.centerY.equalToSuperview()
        }

        reminderSwitch.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-18))
            make.centerY.equalToSuperview()
        }

        proTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(renewalDescLabel.snp.bottom).offset(kFitWidth(28))
        }

        proFeatureContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(proTitleLabel.snp.bottom).offset(kFitWidth(14))
        }

        freeTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(proFeatureContainer.snp.bottom).offset(kFitWidth(26))
        }

        freeFeatureContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(freeTitleLabel.snp.bottom).offset(kFitWidth(14))
            make.bottom.equalToSuperview().offset(-kFitWidth(24))
        }

        renewalDescLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(reminderCardView.snp.bottom).offset(kFitWidth(18))
        }

//        footerDividerView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
//            make.top.equalToSuperview()
//            make.height.equalTo(1)
//        }

        trialDescLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(kFitWidth(8))
//            make.top.equalTo(footerDividerView.snp.bottom).offset(kFitWidth(14))
        }

        startTrialButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(trialDescLabel.snp.bottom).offset(kFitWidth(12))
            make.height.equalTo(kFitWidth(52))
        }

        noteStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(startTrialButton.snp.bottom).offset(kFitWidth(12))
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-kFitWidth(10))
        }

        rebuildFAQs()
        buildFeatureRows()
        updateFreeTrialPermission(true)
    }

    func updateDynamicLayoutForTrialPermission() {
        reminderCardView.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(faqStackView.snp.bottom).offset(kFitWidth(30))
            make.height.equalTo(kFitWidth(60))
        }

        renewalDescLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(reminderCardView.snp.bottom).offset(kFitWidth(18))
        }

        proTitleLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(renewalDescLabel.snp.bottom).offset(kFitWidth(28))
        }

        startTrialButton.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(trialDescLabel.snp.bottom).offset(kFitWidth(12))
            make.height.equalTo(kFitWidth(52))
            if hasFreeTrialPermission {
                make.bottom.equalTo(noteStackView.snp.top).offset(-kFitWidth(12))
            } else {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-kFitWidth(18))
            }
        }

        noteStackView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            if hasFreeTrialPermission {
                make.top.equalTo(startTrialButton.snp.bottom).offset(kFitWidth(12))
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-kFitWidth(10))
            } else {
                make.top.equalTo(startTrialButton.snp.bottom)
                make.height.equalTo(0)
                make.bottom.equalTo(startTrialButton.snp.bottom)
            }
        }

        layoutIfNeeded()
    }

    func rebuildFAQs() {
        faqStackView.arrangedSubviews.forEach { view in
            faqStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let faqItems = faqItemsForCurrentPermission()

        faqItems.forEach { title, answer in
            faqStackView.addArrangedSubview(makeFAQView(question: title, answer: answer))
        }
    }

    func faqItemsForCurrentPermission() -> [(String, String)] {
        if hasFreeTrialPermission {
            return [
                ("Q：试用期间会扣费吗？", "A：不会扣费。"),
                ("Q：开始体验后可以取消吗？", "A：当然可以。在试用期结束前随时可取消，不会扣除任何费用。"),
                ("Q：如何取消试用？", "A：非常简单！进入手机设置，随后点击你的头像，点击订阅后选择elavatine，再次点击“取消订阅”即可。")
            ]
        }

        return [
            ("Q：开始订阅后会立即扣费吗？", "A：会按照当前订阅价格收取费用。"),
            ("Q：开始体验后可以取消吗？", "A：当然可以。你可以在当前订阅周期结束前随时取消。"),
            ("Q：如何取消订阅？", "A：非常简单！进入手机设置，随后点击你的头像，点击订阅后选择elavatine，再次点击“取消订阅”即可。")
        ]
    }

    func buildFeatureRows() {
        let proItems = [
            ("list.bullet.clipboard", "定制饮食计划", "按你的目标与饮食模式定制，直接照着执行"),
            ("cart", "整理购物清单", "为你食谱提前列好未来一周所需食材"),
            ("slash.circle", "去除广告", "专心记录饮食，不被干扰"),
            ("viewfinder.circle", "解锁AI识别上限", "放开使用AI食物与营养成分表识别"),
            ("sparkles", "优先体验新功能", "新功能上线的第一时间体验")
        ]

        let freeItems: [(String, String, String?)] = [
            ("fork.knife.circle", "日常饮食记录", nil),
            ("figure.stand", "身体数据记录", nil),
            ("figure.walk.circle", "有氧训练记录", nil),
            ("dumbbell", "力量训练标签", nil),
            ("target", "目标打卡养成", nil)
        ]

        addFeatureRows(proItems, to: proFeatureContainer, accentColor: UIColor(hex: 0xEAF3FF))
        addFeatureRows(freeItems, to: freeFeatureContainer, accentColor: UIColor(hex: 0xF2F4F7))
    }

    func makeFAQView(question: String, answer: String) -> UIView {
        let view = UIView()

        let questionLabel = UILabel()
        questionLabel.text = question
        questionLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        questionLabel.font = .systemFont(ofSize: 11, weight: .regular)
        questionLabel.numberOfLines = 0

        let answerLabel = UILabel()
        answerLabel.text = answer
        answerLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        answerLabel.font = .systemFont(ofSize: 12, weight: .medium)
        answerLabel.numberOfLines = 0

        view.addSubview(questionLabel)
        view.addSubview(answerLabel)

        questionLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }

        answerLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(questionLabel.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalToSuperview()
        }

        return view
    }

    func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }

    func makeFeatureContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.84)
        view.layer.cornerRadius = kFitWidth(16)
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.withAlphaComponent(0.08).cgColor
        view.layer.borderWidth = kFitWidth(2)
        view.layer.borderColor = UIColor.white.cgColor
        view.clipsToBounds = true
        return view
    }

    func addFeatureRows(_ items: [(String, String, String?)], to container: UIView, accentColor: UIColor) {
        var previousRow: UIView?

        let hasLine = container == proFeatureContainer
        for (index, item) in items.enumerated() {
            let row = makeFeatureRow(iconName: item.0,
                                     title: item.1,
                                     desc: item.2,
                                     accentColor: accentColor,
                                     hasLine: hasLine)
            container.addSubview(row)

            row.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                if let previousRow {
                    make.top.equalTo(previousRow.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                if index == items.count - 1 {
                    make.bottom.equalToSuperview()
                }
            }

            previousRow = row
        }
    }

    func makeFeatureRow(iconName: String,
                        title: String,
                        desc: String?,
                        accentColor: UIColor,
                        hasLine:Bool=true) -> UIView {
        let view = UIView()

        let iconView = UIView()
        iconView.backgroundColor = accentColor
        iconView.layer.cornerRadius = kFitWidth(15)
//        iconView.layer.borderWidth = 1
//        iconView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let iconImageView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: symbolConfig))
        iconImageView.contentMode = .scaleAspectFit
//        iconImageView.tintColor = .COLOR_TEXT_TITLE_0f1214

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.numberOfLines = 0

        let descLabel = UILabel()
        descLabel.text = desc
        descLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        descLabel.font = .systemFont(ofSize: 12, weight: .regular)
        descLabel.numberOfLines = 0
        descLabel.isHidden = desc == nil

        let divider = UIView()
        if hasLine {
            divider.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.withAlphaComponent(0.15)
        }else{
            divider.backgroundColor = UIColor.clear        }
        

        view.addSubview(iconView)
        iconView.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(divider)

        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
//            make.top.equalTo(kFitWidth(18))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(30))
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.lessThanOrEqualTo(kFitWidth(15))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(kFitWidth(12))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(14))
        }

        if desc == nil {
            divider.isHidden = true
            
            divider.snp.makeConstraints { make in
                make.left.equalTo(titleLabel)
                make.right.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(14))
                make.height.equalTo(1)
                make.bottom.equalToSuperview()
            }
            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(iconView.snp.right).offset(kFitWidth(12))
                make.right.equalTo(kFitWidth(-16))
                make.top.equalTo(kFitWidth(17))
                make.bottom.equalTo(kFitWidth(-17))
            }
        } else {
            descLabel.snp.makeConstraints { make in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            }

            divider.snp.makeConstraints { make in
                make.left.equalTo(titleLabel)
                make.right.equalToSuperview()
                make.top.equalTo(descLabel.snp.bottom).offset(kFitWidth(14))
                make.height.equalTo(1)
                make.bottom.equalToSuperview()
            }
        }

        return view
    }

    @objc func startTrialTapAction() {
        startTrialTapBlock?()
    }
}

private extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

private final class VerticalFadeView: UIView {

    var startColor: UIColor = .clear {
        didSet { updateGradient() }
    }

    var endColor: UIColor = .white {
        didSet { updateGradient() }
    }

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
        updateGradient()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}
