//
//  GuidanceProSubscribeTimelineVM.swift
//  lns
//
//  Created by Codex on 2026/7/2.
//

import UIKit
import StoreKit
import SnapKit

class GuidanceProSubscribeTimelineVM: UIView {

    var startTrialTapBlock: (() -> Void)?
    var closeTapBlock: (() -> Void)?

    private var hasFreeTrialPermission = true
    private var startTrialButtonNormalTitle = "0元 开始体验"
    private var annualPriceDescription = "168/年"
    private var dailyPriceDescription = "0.46元/天"

    private lazy var loadingOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        view.isHidden = true
        return view
    }()

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .COLOR_TEXT_WHITE
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
        view.backgroundColor = .clear
        return view
    }()

    private lazy var footerTopFadeView: VerticalFadeView = {
        let view = VerticalFadeView()
        view.isUserInteractionEnabled = false
        view.startColor = UIColor.COLOR_BG_F2.withAlphaComponent(0)
        view.endColor = UIColor.COLOR_BG_F2.withAlphaComponent(1)
        return view
    }()

    private lazy var closeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setImgLocal(imgName: "ela_pro_close_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapAction))
        imageView.addGestureRecognizer(tap)

        return imageView
    }()

    private lazy var brandTitleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_expired_alert_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var ratingIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.setImgLocal(imgName: "guidance_pro_star_icon")
        return imageView
    }()

    private lazy var ratingScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "4.9   10,000+评价"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ratingIconView, ratingScoreLabel])
        stack.axis = .horizontal
        stack.spacing = kFitWidth(4.5)
        stack.alignment = .center
        return stack
    }()

    private lazy var timelineContainerView = UIView()

    private lazy var firstStepView = makeTimelineStep(
        iconName: "guidance_pro_timeline_check_icon",
        dayText: "今日",
        titleText: "解锁全部功能",
        subtitleText: nil
    )

    private lazy var secondStepView = makeTimelineStep(
        iconName: "guidance_pro_timeline_bell_icon",
        dayText: "2 天后",
        titleText: "收到提醒",
        subtitleText: nil
    )

    private lazy var thirdStepView = makeTimelineStep(
        iconName: "guidance_pro_timeline_lock_icon",
        dayText: "3 天后",
        titleText: "开始自动续费",
        subtitleText: "在此之前可随时取消"
    )

    private lazy var firstLineView = makeTimelineLineView()
    private lazy var secondLineView = makeTimelineLineView()

    private lazy var planCardShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = kFitWidth(12)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = kFitWidth(16)
        view.layer.shadowOffset = .zero
        view.layer.masksToBounds = false
        return view
    }()

    private lazy var planCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear//UIColor.COLOR_CARD_BG_WHITE//.withAlphaComponent(0.78)
        view.layer.cornerRadius = kFitWidth(12)
//        view.layer.borderWidth = kFitWidth(2)
//        view.layer.borderColor = UIColor.COLOR_CARD_BG_WHITE.cgColor
        view.clipsToBounds = true
        return view
    }()

    private lazy var planHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .THEME
        return view
    }()

    private lazy var planHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "免费试用"
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private lazy var planBodyView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.5)
        return view
    }()

    private lazy var planBodyBlurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        view.alpha = 0.4
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var radioOuterView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = kFitWidth(7.5)
        view.layer.borderWidth = kFitWidth(1.2)
        view.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor
        return view
    }()

    private lazy var radioInnerView: UIView = {
        let view = UIView()
        view.backgroundColor = .THEME
        view.layer.cornerRadius = kFitWidth(3)
        return view
    }()

    private lazy var planTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "立即免费试用"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var planDailyLabel: UILabel = {
        let label = UILabel()
        label.text = "每天仅¥0.46"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()

    private lazy var planPriceLabel: UILabel = {
        let label = UILabel()
        label.text = "¥ 168/年"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    private lazy var trialDescLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setLineHeight(textString: "现在无需付费，试用期内可随时取消", lineHeight: label.font.lineHeight * 1.1)
        return label
    }()

    private lazy var startTrialButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(startTrialButtonNormalTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        button.layer.cornerRadius = kFitWidth(25)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(startTrialTapAction), for: .touchUpInside)
        return button
    }()

    private lazy var renewalDescLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        label.isHidden = true
        return label
    }()

    private lazy var proTitleLabel = makeSectionTitle("ELA PRO 将帮助你：")
    private lazy var freeTitleLabel = makeSectionTitle("以及现有的免费功能：")
    private lazy var proFeatureContainer = makeFeatureContainer()
    private lazy var freeFeatureContainer = makeFeatureContainer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        planCardShadowView.layer.shadowPath = UIBezierPath(
            roundedRect: planCardShadowView.bounds,
            cornerRadius: kFitWidth(12)
        ).cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        planCardView.layer.borderColor = UIColor.COLOR_CARD_BG_WHITE.cgColor
        radioOuterView.layer.borderColor = UIColor.THEME.cgColor
        footerTopFadeView.startColor = UIColor.COLOR_BG_F2.withAlphaComponent(0)
        footerTopFadeView.endColor = UIColor.COLOR_BG_F2.withAlphaComponent(1)
        proFeatureContainer.layer.borderColor = UIColor.COLOR_CARD_BG_WHITE.cgColor
        freeFeatureContainer.layer.borderColor = UIColor.COLOR_CARD_BG_WHITE.cgColor
    }
}

extension GuidanceProSubscribeTimelineVM {
    func updateFreeTrialPermission(_ hasPermission: Bool) {
        hasFreeTrialPermission = hasPermission
        startTrialButtonNormalTitle = hasPermission ? "0元 开始体验" : "开启体验"

        planHeaderLabel.text = hasPermission ? "免费试用" : "年度订阅"
        planTitleLabel.text = hasPermission ? "立即免费试用" : "立即订阅"
        startTrialButton.setTitle(startTrialButtonNormalTitle, for: .normal)
        renewalDescLabel.text = hasPermission
        ? "订阅计划会自动续订。请通过 App Store 取消订阅。\n除非你取消，否则免费试用结束后将开始收费。"
        : "订阅计划会自动续订。请通过 App Store 取消订阅。\n如果你不需要，可在当前订阅周期结束前取消。"
        updateTrialDescription()
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

    func updateAnnualProduct(_ product: Product) {
        annualPriceDescription = recurringPriceDescription(for: product)
        dailyPriceDescription = dailyPriceText(for: product)
        planPriceLabel.text = annualPlanPriceText(for: product)
        planDailyLabel.text = dailyPlanText(for: product)
    }

    func updateAnnualProductInfo(_ dict: NSDictionary) {
        let remoteProductName = dict.stringValueForKey(key: "productName")
        let productName = remoteProductName.isEmpty ? dict.stringValueForKey(key: "name") : remoteProductName
        if !productName.isEmpty {
            planTitleLabel.text = productName
        }

        let period = remotePeriodText(from: dict)
        let priceText = remotePriceNumberText(from: dict.stringValueForKey(key: "price"))
        if !priceText.isEmpty {
            annualPriceDescription = "\(priceText)/\(period)"
            planPriceLabel.text = "¥ \(priceText)/\(period)"
        }

        let remoteDayAvgText = dict.stringValueForKey(key: "dayAvgPriceLabel")
        let dayAvgText = remoteDayAvgText.isEmpty ? dict.stringValueForKey(key: "dayAvgPriceLable") : remoteDayAvgText
        if !dayAvgText.isEmpty {
            dailyPriceDescription = dayAvgText
            planDailyLabel.text = remoteDailyPlanText(from: dayAvgText)
        } else if let priceDecimal = remotePriceDecimal(from: dict.stringValueForKey(key: "price")) {
            let daily = priceDecimal.dividing(by: NSDecimalNumber(value: remoteDaysCount(from: dict)))
            let dailyText = decimalText(for: daily)
            dailyPriceDescription = "\(dailyText)元/天"
            planDailyLabel.text = "每天仅¥\(dailyText)"
        }
    }

    @objc func closeTapAction() {
        closeTapBlock?()
    }

    @objc func startTrialTapAction() {
        startTrialTapBlock?()
    }
}

private extension GuidanceProSubscribeTimelineVM {
    func initUI() {
        addSubview(scrollView)
        addSubview(footerTopFadeView)
        addSubview(footerContainerView)
        addSubview(closeImageView)
        addSubview(loadingOverlayView)
        scrollView.addSubview(contentView)
        loadingOverlayView.addSubview(loadingIndicatorView)

        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(footerContainerView.snp.top)
        }

        footerContainerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }

        footerTopFadeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(footerContainerView).offset(kFitWidth(-30))
            make.bottom.equalToSuperview()
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

        contentView.addSubview(ratingStackView)
        contentView.addSubview(brandTitleImageView)
        contentView.addSubview(timelineContainerView)
        contentView.addSubview(planCardShadowView)
        contentView.addSubview(renewalDescLabel)
        contentView.addSubview(proTitleLabel)
        contentView.addSubview(proFeatureContainer)
        contentView.addSubview(freeTitleLabel)
        contentView.addSubview(freeFeatureContainer)
        timelineContainerView.addSubview(firstStepView)
        timelineContainerView.addSubview(secondStepView)
        timelineContainerView.addSubview(thirdStepView)
        timelineContainerView.addSubview(firstLineView)
        timelineContainerView.addSubview(secondLineView)
        planCardShadowView.addSubview(planCardView)
        planCardView.addSubview(planHeaderView)
        planHeaderView.addSubview(planHeaderLabel)
        planCardView.addSubview(planBodyView)
//        planBodyView.addSubview(planBodyBlurView)
        planBodyView.addSubview(radioOuterView)
        radioOuterView.addSubview(radioInnerView)
        planBodyView.addSubview(planTitleLabel)
        planBodyView.addSubview(planDailyLabel)
        planBodyView.addSubview(planPriceLabel)
        footerContainerView.addSubview(trialDescLabel)
        footerContainerView.addSubview(startTrialButton)

        closeImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(statusBarHeight + kFitWidth(6))
            make.width.height.equalTo(kFitWidth(30))
        }

        ratingIconView.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(11))
        }
        
        ratingStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(21))
        }

        brandTitleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ratingStackView.snp.bottom).offset(kFitWidth(15))
            make.width.equalTo(kFitWidth(165))
            make.height.equalTo(kFitWidth(29))
        }

        timelineContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(brandTitleImageView.snp.bottom).offset(kFitWidth(68))
            make.height.equalTo(kFitWidth(240))
        }

        firstStepView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(126))
            make.right.equalTo(kFitWidth(-48))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(42))
        }

        secondStepView.snp.makeConstraints { make in
            make.left.right.height.equalTo(firstStepView)
            make.top.equalTo(firstStepView.snp.bottom).offset(kFitWidth(57))
        }

        thirdStepView.snp.makeConstraints { make in
            make.left.right.height.equalTo(firstStepView)
            make.top.equalTo(secondStepView.snp.bottom).offset(kFitWidth(57))
        }

        firstLineView.snp.makeConstraints { make in
            make.centerX.equalTo(firstStepView.snp.left).offset(kFitWidth(17.5))
            make.top.equalTo(firstStepView.snp.bottom).offset(kFitWidth(9))
            make.bottom.equalTo(secondStepView.snp.top).offset(kFitWidth(-9))
            make.width.equalTo(kFitWidth(2))
        }

        secondLineView.snp.makeConstraints { make in
            make.centerX.equalTo(firstLineView)
            make.top.equalTo(secondStepView.snp.bottom).offset(kFitWidth(9))
            make.bottom.equalTo(thirdStepView.snp.top).offset(kFitWidth(-9))
            make.width.equalTo(kFitWidth(2))
        }

        planCardShadowView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(23))
            make.right.equalTo(kFitWidth(-23))
            make.top.equalTo(timelineContainerView.snp.bottom).offset(kFitWidth(37))
            make.height.equalTo(kFitWidth(109))
        }

        planCardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        renewalDescLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(planCardShadowView.snp.bottom).offset(kFitWidth(18))
        }

        proTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(renewalDescLabel.snp.bottom).offset(kFitWidth(48))
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

        planHeaderView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(30))
        }

        planHeaderLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        planBodyView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(planHeaderView.snp.bottom)
        }

//        planBodyBlurView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }

        radioOuterView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15.5))
            make.top.equalTo(kFitWidth(17))
            make.width.height.equalTo(kFitWidth(15))
        }

        radioInnerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(6))
        }

        planTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(radioOuterView.snp.right).offset(kFitWidth(10))
//            make.top.equalTo(kFitWidth(19))
            make.centerY.lessThanOrEqualTo(radioOuterView)
            make.right.lessThanOrEqualTo(planPriceLabel.snp.left).offset(kFitWidth(-10))
        }

        planDailyLabel.snp.makeConstraints { make in
            make.left.equalTo(planTitleLabel)
            make.top.equalTo(planTitleLabel.snp.bottom).offset(kFitWidth(8))
            make.right.lessThanOrEqualTo(planPriceLabel.snp.left).offset(kFitWidth(-10))
        }

        planPriceLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalTo(planTitleLabel)
            make.width.greaterThanOrEqualTo(kFitWidth(86))
        }

        trialDescLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(kFitWidth(8))
        }

        startTrialButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(trialDescLabel.snp.bottom).offset(kFitWidth(16))
            make.height.equalTo(kFitWidth(50))
//            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-kFitWidth(26))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }

        updateFreeTrialPermission(true)
        buildFeatureRows()
    }

    func makeTimelineStep(iconName: String, dayText: String, titleText: String, subtitleText: String?) -> UIView {
        let view = UIView()

        let iconImageView = UIImageView()
        iconImageView.setImgLocal(imgName: iconName)
        iconImageView.contentMode = .scaleAspectFit

        let dayLabel = UILabel()
        dayLabel.text = dayText
        dayLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        dayLabel.font = .systemFont(ofSize: 14, weight: .medium)

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitleText
        subtitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.isHidden = subtitleText == nil

        view.addSubview(iconImageView)
        view.addSubview(dayLabel)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        iconImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(35))
        }

        dayLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(kFitWidth(16))
            make.right.equalToSuperview()
            make.top.equalTo(kFitWidth(1))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(dayLabel)
            make.top.equalTo(dayLabel.snp.bottom).offset(kFitWidth(6))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(dayLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
        }

        return view
    }

    func makeTimelineLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_20
        view.layer.cornerRadius = kFitWidth(2)
        return view
    }

    func buildFeatureRows() {
        let proItems = [
            ("guidance_pro_ai_icon", "解锁AI教练", "结合饮食记录与体重变化调整目标"),
            ("survey_subscription_mealplan_ic_01", "定制饮食计划", "按你的目标与饮食模式定制，直接照着执行"),
            ("survey_subscription_mealplan_ic_05", "整理购物清单", "为你食谱提前列好未来一周所需食材"),
            ("survey_subscription_more_ic_01", "去除广告", "专心记录饮食，不被干扰"),
            ("survey_subscription_more_ic_02", "解锁AI识别上限", "放开使用AI食物与营养成分表识别"),
            ("pro_func_new_icon", "优先体验新功能", "新功能上线时第一时间体验")
        ]

        let freeItems: [(String, String, String?)] = [
            ("guidance_pro_fell_icon_1", "日常饮食记录", nil),
            ("guidance_pro_fell_icon_2", "身体数据记录", nil)
        ]

        addFeatureRows(proItems, to: proFeatureContainer, accentColor: UIColor(hex: 0xEAF3FF))
        addFeatureRows(freeItems, to: freeFeatureContainer, accentColor: UIColor(hex: 0xF2F4F7))
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
        view.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.5)
        view.layer.cornerRadius = kFitWidth(16)
        view.layer.borderWidth = kFitWidth(2)
        view.layer.borderColor = UIColor.COLOR_CARD_BG_WHITE.cgColor
        view.clipsToBounds = true
        return view
    }

    func addFeatureRows(_ items: [(String, String, String?)], to container: UIView, accentColor: UIColor) {
        var previousRow: UIView?

        for (index, item) in items.enumerated() {
            let row = makeFeatureRow(iconName: item.0,
                                     title: item.1,
                                     desc: item.2,
                                     accentColor: accentColor)
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
                        accentColor: UIColor) -> UIView {
        let view = UIView()

        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.setImgLocal(imgName: iconName)

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
        divider.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.withAlphaComponent(0.15)

        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(divider)

        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(kFitWidth(18))
            make.width.height.lessThanOrEqualTo(kFitWidth(30))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(kFitWidth(17))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(14))
        }

        if desc == nil {
            divider.snp.makeConstraints { make in
                make.left.equalTo(titleLabel)
                make.right.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(17))
                make.height.equalTo(1)
                make.bottom.equalToSuperview()
            }
            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(iconImageView.snp.right).offset(kFitWidth(17))
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

    func updateTrialDescription() {
        let text = hasFreeTrialPermission ? "现在无需付费，试用期内可随时取消" : "订阅计划可随时取消"
        trialDescLabel.text = text
        trialDescLabel.setLineHeight(textString: text, lineHeight: trialDescLabel.font.lineHeight * 1.1)
    }

    func remotePeriodText(from dict: NSDictionary) -> String {
        let productType = Int(dict.stringValueForKey(key: "productType")) ?? Int(dict.stringValueForKey(key: "type")) ?? 0
        switch productType {
        case 1:
            return "月"
        case 2:
            return "年"
        default:
            let membershipDays = Int(dict.stringValueForKey(key: "membershipDays")) ?? 0
            if membershipDays > 0, membershipDays < 365 {
                return "\(membershipDays)天"
            }
            return "年"
        }
    }

    func remoteDaysCount(from dict: NSDictionary) -> Int {
        let productType = Int(dict.stringValueForKey(key: "productType")) ?? Int(dict.stringValueForKey(key: "type")) ?? 0
        switch productType {
        case 1:
            return 30
        case 2:
            return 365
        default:
            let membershipDays = Int(dict.stringValueForKey(key: "membershipDays")) ?? 0
            return membershipDays > 0 ? membershipDays : 365
        }
    }

    func remotePriceDecimal(from priceText: String) -> NSDecimalNumber? {
        let cleanText = priceText
            .replacingOccurrences(of: "¥", with: "")
            .replacingOccurrences(of: "￥", with: "")
            .replacingOccurrences(of: "CNY", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return nil }
        let value = NSDecimalNumber(string: cleanText)
        guard !value.doubleValue.isNaN else { return nil }
        return value
    }

    func remotePriceNumberText(from priceText: String) -> String {
        guard let value = remotePriceDecimal(from: priceText) else {
            return priceText
                .replacingOccurrences(of: "¥", with: "")
                .replacingOccurrences(of: "￥", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return decimalText(for: value)
    }

    func remoteDailyPlanText(from dayAvgText: String) -> String {
        let cleanText = dayAvgText
            .replacingOccurrences(of: "元/天", with: "")
            .replacingOccurrences(of: "/天", with: "")
            .replacingOccurrences(of: "¥", with: "")
            .replacingOccurrences(of: "￥", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return "每天仅\(dayAvgText)" }
        return "每天仅¥\(cleanText)"
    }

    func recurringPriceDescription(for product: Product) -> String {
        let period = periodText(from: product.subscription?.subscriptionPeriod)
        if isChineseYuanPrice(product.displayPrice) {
            return "\(decimalText(for: NSDecimalNumber(decimal: product.price)))/\(period)"
        }
        return ElaProIAPManager.shared.localizedPriceString(for: product) + "/\(period)"
    }

    func annualPlanPriceText(for product: Product) -> String {
        let period = periodText(from: product.subscription?.subscriptionPeriod)
        if isChineseYuanPrice(product.displayPrice) {
            return "¥ \(decimalText(for: NSDecimalNumber(decimal: product.price)))/\(period)"
        }
        return ElaProIAPManager.shared.localizedPriceString(for: product) + "/\(period)"
    }

    func dailyPriceText(for product: Product) -> String {
        let days = max(daysCount(from: product.subscription?.subscriptionPeriod), 1)
        let daily = NSDecimalNumber(decimal: product.price).dividing(by: NSDecimalNumber(value: days))
        if isChineseYuanPrice(product.displayPrice) {
            return "\(decimalText(for: daily))元/天"
        }
        return "\(localizedPriceString(decimal: daily, fallbackPriceText: product.displayPrice))/天"
    }

    func dailyPlanText(for product: Product) -> String {
        let days = max(daysCount(from: product.subscription?.subscriptionPeriod), 1)
        let daily = NSDecimalNumber(decimal: product.price).dividing(by: NSDecimalNumber(value: days))
        if isChineseYuanPrice(product.displayPrice) {
            return "每天仅¥\(decimalText(for: daily))"
        }
        return "每天仅\(localizedPriceString(decimal: daily, fallbackPriceText: product.displayPrice))"
    }

    func localizedPriceString(decimal: NSDecimalNumber, fallbackPriceText: String) -> String {
        let symbol = fallbackPriceText.contains("€") ? "€" : fallbackPriceText.contains("£") ? "£" : fallbackPriceText.contains("$") ? "$" : "$"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: decimal) ?? fallbackPriceText
    }

    func decimalText(for value: NSDecimalNumber) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value) ?? "\(value)"
    }

    func periodText(from period: Product.SubscriptionPeriod?) -> String {
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

        if period.value <= 1 {
            return unitText
        }
        return "\(period.value)\(unitText)"
    }

    func daysCount(from period: Product.SubscriptionPeriod?) -> Int {
        guard let period = period else { return 365 }
        let units = max(period.value, 1)
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

    func isChineseYuanPrice(_ priceText: String) -> Bool {
        priceText.contains("¥") || priceText.contains("￥") || priceText.uppercased().contains("CNY")
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
