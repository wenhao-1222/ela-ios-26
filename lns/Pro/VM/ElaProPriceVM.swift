//
//  ElaProPriceVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//

import StoreKit
import MCToast
import UserNotifications
import WebKit

class ElaProPriceVM: UIView {
    enum PlanType {
        case month
        case annual
        case lifetime
    }
    
    private struct RemotePlanProduct {
        let type: Int
        let iosProductId: String
        let name: String
        let originalPrice: String
        let price: String
        let promotionDesc: String
        let promotionLabel: String
        let dayAvgPriceLabel: String
        let monthAvgPriceLabel: String
        
        init(dict: NSDictionary) {
            type = Int(dict.stringValueForKey(key: "type")) ?? 0
            iosProductId = dict.stringValueForKey(key: "iosProductId")
            name = dict.stringValueForKey(key: "name")
            originalPrice = dict.stringValueForKey(key: "originalPrice")
            price = dict.stringValueForKey(key: "price")
            promotionDesc = dict.stringValueForKey(key: "promotionDesc")
            promotionLabel = dict.stringValueForKey(key: "promotionLabel")
            dayAvgPriceLabel = dict.stringValueForKey(key: "dayAvgPriceLable")
            monthAvgPriceLabel = dict.stringValueForKey(key: "monthAvgPriceLable")
        }
        
        var displayPriceText: String? {
            guard !price.isEmpty else { return nil }
            if price.contains("¥") || price.contains("￥") || price.contains("$") {
                return price
            }
            return "¥\(price)"
        }
    }
    
    var purchaseSuccessBlock: (() -> ())?
    var protocalTapBlock: (() -> ())?
    
    private let selectedBlue = WHColor_16(colorStr: "1677F2")
    private let normalTextColor = UIColor.COLOR_TEXT_TITLE_0f1214
    private let subTextColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
    private let renewalDashLayer = CAShapeLayer()
    private var agreementConfirmSheetHeight: CGFloat {
        kFitWidth(254) + WHUtils().getBottomSafeAreaHeight()
    }
    
    private var selectedPlan: PlanType = .annual
    private var monthProduct: SKProduct?
    private var annualProduct: SKProduct?
    private var lifetimeProduct: SKProduct?
    private var monthRemoteProduct: RemotePlanProduct?
    private var annualRemoteProduct: RemotePlanProduct?
    private var lifetimeRemoteProduct: RemotePlanProduct?
    private var monthTitleText = "连续包月"
    private var monthTagText: String?
    private var monthPriceText = "--"
    private var monthSubTitleText: String?
    private var monthOriginPriceText: String?
    private var annualTitleText = "连续包年"
    private var annualTagText: String?
    private var annualPriceText = "--"
    private var annualSubTitleText: String?
    private var annualOriginPriceText: String?
    private var lifetimeTitleText = "终身会员"
    private var lifetimePriceText = "--"
    private var isPurchasing = false
    private var shouldSyncRenewalSwitchAfterSettings = false
    private var isAgreementConfirmVisible = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
        observeAppBecomeActive()
        refreshPlanCards()
        sendProProductListRequest()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_bg")
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        
        return img
    }()
    lazy var scrollView: UIScrollView = {
        let vi = UIScrollView()
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        return vi
    }()
    lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()
    lazy var logoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_icon")
        img.contentMode = .scaleAspectFit
        return img
    }()
    lazy var subTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "专业健身饮食，助你精准达成目标"
        lab.textColor = subTextColor
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()
    lazy var cardContainer: UIView = {
        let vi = UIView()
        return vi
    }()
    lazy var monthCard: ElaProPriceCardView = {
        let vm = ElaProPriceCardView()
        vm.configure(tag: monthTagText,
                     title: "连续包月",
                     subTitle: monthSubTitleText,
                     price: monthPriceText,
                     originPrice: monthOriginPriceText,
                     selected: false)
        return vm
    }()
    lazy var yearCard: ElaProPriceCardView = {
        let vm = ElaProPriceCardView()
        vm.configure(tag: annualTagText,
                     title: "连续包年",
                     subTitle: annualSubTitleText,
                     price: annualPriceText,
                     originPrice: annualOriginPriceText,
                     selected: true)
        return vm
    }()
    lazy var lifeCard: ElaProPriceCardView = {
        let vm = ElaProPriceCardView()
        vm.configure(tag: nil,
                     title: "终身会员",
                     subTitle: nil,
                     price: lifetimePriceText,
                     originPrice: nil,
                     selected: false)
        return vm
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "价格加载中..."
        lab.textColor = subTextColor
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()
    lazy var renewalDashView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        return vi
    }()
    lazy var renewalNoticeLabel: UILabel = {
        let lab = UILabel()
        lab.text = "讨厌不知不觉扣费？我们也是。开启提醒，每次续费前5天我们会通过推送通知你，把选择权交还给你。"
        lab.textColor = subTextColor
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 0
        return lab
    }()
    lazy var renewalSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.onTintColor = selectedBlue
        sw.addTarget(self, action: #selector(renewalSwitchValueChanged(_:)), for: .valueChanged)
        return sw
    }()
    lazy var benefitTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "ELA PRO 将帮助你："
        lab.textColor = normalTextColor
        lab.font = .systemFont(ofSize: 14, weight: .semibold)
        return lab
    }()
    lazy var benefitContainer: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor(named: "color_white_20_pro")//UIColor.white.withAlphaComponent(0.2)
        vi.layer.cornerRadius = kFitWidth(12)
        vi.layer.borderWidth = kFitWidth(1.5)
        vi.layer.borderColor = UIColor(named: "color_white_20_pro_border")?.cgColor
        vi.clipsToBounds = true
        return vi
    }()
    lazy var benefitOne = makeBenefitRow(title: "定制每周食谱", desc: "每天不重样，照着吃就行")
    lazy var benefitTwo = makeBenefitRow(title: "消除选择困难", desc: "不用每天纠结吃什么")
    lazy var benefitThree = makeBenefitRow(title: "平衡家庭与健康饮食", desc: "和家人同桌，也能精准对齐目标")
    lazy var benefitFour = makeBenefitRow(title: "节省外卖支出", desc: "每月省下上千元外卖费用")
    lazy var benefitFive = makeBenefitRow(title: "整理购物清单", desc: "提前列好未来一周所需食材")
    lazy var benefitSix = makeBenefitRow(title: "快速记录", desc: "无需手动搜索，一键把每餐加入日志")
    lazy var dividerOne = makeDivider()
    lazy var dividerTwo = makeDivider()
    lazy var dividerThree = makeDivider()
    lazy var dividerFour = makeDivider()
    lazy var dividerFive = makeDivider()
    lazy var aiTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "解锁ELA AI教练："
        lab.textColor = normalTextColor
        lab.font = .systemFont(ofSize: 22, weight: .semibold)
        return lab
    }()
    lazy var aiContainer: UIView = {
        let vi = UIView()
        return vi
    }()
    lazy var aiOne = makeBenefitRow(title: "每周复盘", desc: "结合饮食训练变化，系统复盘进度")
    lazy var aiTwo = makeBenefitRow(title: "卡点预警", desc: "多维数据早发现，瓶颈前先介入")
    lazy var aiThree = makeBenefitRow(title: "体重去噪", desc: "分清真实进度，减少结果焦虑")
    lazy var aiFour = makeBenefitRow(title: "持续微调", desc: "越用越懂你，你只需照做")
    lazy var aiDividerOne = makeDivider()
    lazy var aiDividerTwo = makeDivider()
    lazy var aiDividerThree = makeDivider()
    lazy var moreTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "和更多："
        lab.textColor = normalTextColor
        lab.font = .systemFont(ofSize: 22, weight: .semibold)
        return lab
    }()
    lazy var moreContainer: UIView = {
        let vi = UIView()
        return vi
    }()
    lazy var moreOne = makeSimpleRow(title: "无广告")
    lazy var moreTwo = makeSimpleRow(title: "解锁AI识图上限")
    lazy var moreDividerOne = makeDivider()
    lazy var bottomBar: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE//UIColor.white.withAlphaComponent(0.94)
        return vi
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("确认", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = selectedBlue
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        return btn
    }()
    lazy var labelBgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_price_per_bg")
        img.contentMode = .scaleToFill
        return img
    }()
    lazy var dailyPriceLabel: UILabel = {
        let lab = UILabel()
        lab.text = "--元/天"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
//        lab.backgroundColor = WHColor_16(colorStr: "FF8F29")
//        lab.layer.cornerRadius = kFitWidth(13)
        lab.clipsToBounds = true
        return lab
    }()
    lazy var agreeButton: ElaExpandedTapButton = {
        let btn = ElaExpandedTapButton(type: .custom)
        btn.setImage(makeCircleImage(color: WHColor_16(colorStr: "BFC3CA")), for: .normal)
        btn.setImage(makeCheckedImage(), for: .selected)
        btn.isSelected = false
        btn.addTarget(self, action: #selector(toggleAgreeAction), for: .touchUpInside)
        return btn
    }()
    lazy var agreementLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 1
        lab.isUserInteractionEnabled = true
        let allText = "已阅读并同意《ELA PRO条款》（含自动续费条款）"
        let attr = NSMutableAttributedString(string: allText)
        attr.addAttributes([
            .foregroundColor: subTextColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .regular)
        ], range: NSRange(location: 0, length: allText.count))
        if let range = allText.range(of: "《ELA PRO条款》") {
            let nsRange = NSRange(range, in: allText)
            attr.addAttributes([
                .foregroundColor: selectedBlue
            ], range: nsRange)
        }
        lab.attributedText = attr
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAgreementLabelTap(_:)))
        lab.addGestureRecognizer(tap)
        return lab
    }()
    lazy var agreementConfirmDimView: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.COLOR_ALERT_BG_BLACK
        vi.alpha = 0
        vi.isHidden = true
        vi.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideAgreementConfirmSheetAction)))
        return vi
    }()
    lazy var agreementConfirmSheet: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(28)
        vi.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        vi.clipsToBounds = true
        vi.isHidden = true
        return vi
    }()
    lazy var agreementConfirmCloseButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "alert_close_icon"), for: .normal)
        btn.addTarget(self, action: #selector(hideAgreementConfirmSheetAction), for: .touchUpInside)
        return btn
    }()
    lazy var agreementConfirmTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "阅读并同意以下条款"
        lab.textColor = normalTextColor
        lab.font = .systemFont(ofSize: 20, weight: .semibold)
        lab.textAlignment = .center
        return lab
    }()
    lazy var agreementConfirmLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 1
        lab.textAlignment = .center
        lab.isUserInteractionEnabled = true
        let allText = "我已阅读并同意《ELA PRO条款》"
        let attr = NSMutableAttributedString(string: allText)
        attr.addAttributes([
            .foregroundColor: subTextColor,
            .font: UIFont.systemFont(ofSize: 15, weight: .regular)
        ], range: NSRange(location: 0, length: allText.count))
        if let range = allText.range(of: "《ELA PRO条款》") {
            let nsRange = NSRange(range, in: allText)
            attr.addAttributes([
                .foregroundColor: selectedBlue
            ], range: nsRange)
        }
        lab.attributedText = attr
        lab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAgreementConfirmLabelTap(_:))))
        return lab
    }()
    lazy var agreementConfirmContinueButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("同意并继续", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        btn.backgroundColor = selectedBlue
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(agreeAndContinueAction), for: .touchUpInside)
        return btn
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        renewalDashLayer.frame = renewalDashView.bounds
        let path = UIBezierPath()
        let y = renewalDashView.bounds.height * 0.5
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: renewalDashView.bounds.width, y: y))
        renewalDashLayer.path = path.cgPath
    }
}

extension ElaProPriceVM{
    @objc func renewalSwitchValueChanged(_ sender: UISwitch) {
        guard sender.isOn else {
            shouldSyncRenewalSwitchAfterSettings = false
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self.shouldSyncRenewalSwitchAfterSettings = false
                    return
                }
                sender.setOn(false, animated: true)
                self.shouldSyncRenewalSwitchAfterSettings = true
                self.presentNotificationPermissionAlert()
            }
        }
    }
    
    private func observeAppBecomeActive() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc private func handleAppDidBecomeActive() {
        guard shouldSyncRenewalSwitchAfterSettings else { return }
        syncRenewalSwitchStatusFromSystem(animated: true) { [weak self] _ in
            self?.shouldSyncRenewalSwitchAfterSettings = false
        }
    }
    
    private func syncRenewalSwitchStatusFromSystem(animated: Bool,
                                                   completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            let enabled: Bool
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                enabled = true
            default:
                enabled = false
            }
            DispatchQueue.main.async {
                self?.renewalSwitch.setOn(enabled, animated: animated)
                completion?(enabled)
            }
        }
    }
    
    private func presentNotificationPermissionAlert() {
        guard let topVC = UIApplication.topViewController() else {
            MCToast.mc_text("通知权限未开启，请在系统设置中允许通知")
            return
        }
        guard !(topVC.presentedViewController is UIAlertController) else { return }
        
        let alert = UIAlertController(title: "通知权限未开启",
                                      message: "请在系统设置中允许通知，便于你在续费前收到提醒。",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        let settingsAction = UIAlertAction(title: "去设置", style: .default) { _ in
            self.openSystemSettings()
        }
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        topVC.present(alert, animated: true)
    }
    
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc func toggleAgreeAction() {
        agreeButton.isSelected.toggle()
    }
    
    @objc func handleAgreementLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        guard didTapAgreementKeyword(in: label, gesture: gesture) else { return }
        openProAgreementAction()
    }

    @objc func handleAgreementConfirmLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        guard didTapAgreementKeyword(in: label, gesture: gesture) else { return }
        openProAgreementAction()
    }

    @objc func openProAgreementAction() {
        self.protocalTapBlock?()
    }

    private func didTapAgreementKeyword(in label: UILabel, gesture: UITapGestureRecognizer) -> Bool {
        guard let attributedText = label.attributedText, !attributedText.string.isEmpty else { return false }
        let keyword = "《ELA PRO条款》"
        let keywordRange = (attributedText.string as NSString).range(of: keyword)
        guard keywordRange.location != NSNotFound else { return false }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let tapLocation = gesture.location(in: label)
        let textRect = label.textRect(forBounds: label.bounds, limitedToNumberOfLines: label.numberOfLines)
        guard textRect.contains(tapLocation) else { return false }

        let locationInTextContainer = CGPoint(x: tapLocation.x - textRect.origin.x,
                                              y: tapLocation.y - textRect.origin.y)
        let glyphIndex = layoutManager.glyphIndex(for: locationInTextContainer, in: textContainer)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1),
                                                   in: textContainer)
        guard glyphRect.contains(locationInTextContainer) else { return false }

        let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        return NSLocationInRange(characterIndex, keywordRange)
    }
    
    @objc func selectMonthCardAction() {
        selectedPlan = .month
        refreshPlanCards()
    }
    
    @objc func selectYearCardAction() {
        selectedPlan = .annual
        refreshPlanCards()
    }
    
    @objc func selectLifeCardAction() {
        selectedPlan = .lifetime
        refreshPlanCards()
    }
    
    @objc func confirmButtonTapAction() {
        guard agreeButton.isSelected else {
            showAgreementConfirmSheet()
            return
        }
        startPurchaseFlow()
    }

    @objc func hideAgreementConfirmSheetAction() {
        hideAgreementConfirmSheet(animated: true)
    }

    @objc func agreeAndContinueAction() {
        agreeButton.isSelected = true
        hideAgreementConfirmSheet(animated: true) { [weak self] in
            self?.startPurchaseFlow()
        }
    }

    func showAgreementConfirmSheet() {
        guard !isAgreementConfirmVisible else { return }
        isAgreementConfirmVisible = true
        agreementConfirmDimView.isHidden = false
        agreementConfirmSheet.isHidden = false
        agreementConfirmDimView.alpha = 0
        agreementConfirmSheet.transform = CGAffineTransform(translationX: 0, y: agreementConfirmSheetHeight)

        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.agreementConfirmDimView.alpha = 0.2
            self.agreementConfirmSheet.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.agreementConfirmSheet.transform = .identity
            }
        }
    }

    func hideAgreementConfirmSheet(animated: Bool, completion: (() -> Void)? = nil) {
        guard isAgreementConfirmVisible || !agreementConfirmSheet.isHidden else {
            completion?()
            return
        }
        isAgreementConfirmVisible = false
        let animations = {
            self.agreementConfirmDimView.alpha = 0
            self.agreementConfirmSheet.transform = CGAffineTransform(translationX: 0, y: self.agreementConfirmSheetHeight)
        }
        let finish = {
            self.agreementConfirmDimView.isHidden = true
            self.agreementConfirmSheet.isHidden = true
            completion?()
        }
        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn, .allowUserInteraction]) {
                animations()
            } completion: { _ in
                finish()
            }
        } else {
            animations()
            finish()
        }
    }

    func startPurchaseFlow() {
        
        guard !isPurchasing else { return }
        
        let purchasingPlan = selectedPlan
        isPurchasing = true
        confirmButton.isEnabled = false
        confirmButton.setTitle("处理中...", for: .normal)
        let completion: (Result<SKPaymentTransaction, Error>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isPurchasing = false
                self.confirmButton.isEnabled = true
                self.confirmButton.setTitle("确认", for: .normal)
                
                switch result {
                case .success(let transaction):
                    ElaProIAPManager.shared.handlePurchaseSuccessPostAction(transaction: transaction)
                    MCToast.mc_text(purchasingPlan == .lifetime ? "购买成功" : "订阅成功")
//                    self.purchaseSuccessBlock?()
                case .failure(let error):
                    if let iapError = error as? ElaProIAPError {
                        MCToast.mc_text(iapError.localizedDescription)
                    } else {
                        MCToast.mc_text(error.localizedDescription)
                    }
                }
            }
        }
        
        switch selectedPlan {
        case .month:
            ElaProIAPManager.shared.purchaseMonth(completion: completion)
        case .annual:
            ElaProIAPManager.shared.purchaseAnnual(completion: completion)
        case .lifetime:
            ElaProIAPManager.shared.purchaseLifetime(completion: completion)
        }
    }
    
    func fetchProProductsIfNeeded() {
        ElaProIAPManager.shared.fetchProProducts { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if case .success(let products) = result {
                    if let month = products.first(where: { $0.productIdentifier == ElaProIAPConfig.monthProductID }) {
                        self.monthProduct = month
                        self.monthTagText = self.preferredRemoteText(self.monthRemoteProduct?.promotionLabel) ?? self.promoTagText(for: month)
                        self.monthSubTitleText = self.preferredRemoteText(self.monthRemoteProduct?.monthAvgPriceLabel)
                        if let intro = month.introductoryPrice {
                            self.monthPriceText = self.localizedPriceString(decimal: intro.price, locale: intro.priceLocale)
                            self.monthOriginPriceText = self.preferredRemoteText(self.monthRemoteProduct?.originalPrice) ?? self.recurringPriceText(for: month)
                        } else {
                            self.monthPriceText = ElaProIAPManager.shared.localizedPriceString(for: month)
                            self.monthOriginPriceText = self.preferredRemoteText(self.monthRemoteProduct?.originalPrice)
                        }
                    }
                    
                    if let annual = products.first(where: { $0.productIdentifier == ElaProIAPConfig.annualProductID }) {
                        self.annualProduct = annual
                        self.annualTagText = self.preferredRemoteText(self.annualRemoteProduct?.promotionLabel) ?? self.promoTagText(for: annual)
                        self.annualSubTitleText = self.preferredRemoteText(self.annualRemoteProduct?.monthAvgPriceLabel) ?? self.buildMonthlyText(for: annual)
                        if let intro = annual.introductoryPrice {
                            self.annualPriceText = self.localizedPriceString(decimal: intro.price, locale: intro.priceLocale)
                            self.annualOriginPriceText = self.preferredRemoteText(self.annualRemoteProduct?.originalPrice) ?? self.recurringPriceText(for: annual)
                        } else {
                            self.annualPriceText = ElaProIAPManager.shared.localizedPriceString(for: annual)
                            self.annualOriginPriceText = self.preferredRemoteText(self.annualRemoteProduct?.originalPrice)
                        }
                    }
                    
                    if let lifetime = products.first(where: { $0.productIdentifier == ElaProIAPConfig.lifetimeProductID }) {
                        self.lifetimeProduct = lifetime
                        self.lifetimePriceText = ElaProIAPManager.shared.localizedPriceString(for: lifetime)
                    }
                    
                    self.refreshPlanCards()
                }
            }
        }
    }
    
    func refreshPlanCards() {
        monthCard.configure(tag: monthTagText,
                            title: monthTitleText,
                            subTitle: monthSubTitleText,
                            price: monthPriceText,
                            originPrice: monthOriginPriceText,
                            selected: selectedPlan == .month)
        
        yearCard.configure(tag: annualTagText,
                           title: annualTitleText,
                           subTitle: annualSubTitleText,
                           price: annualPriceText,
                           originPrice: annualOriginPriceText,
                           selected: selectedPlan == .annual)
        
        lifeCard.configure(tag: nil,
                           title: lifetimeTitleText,
                           subTitle: nil,
                           price: lifetimePriceText,
                           originPrice: nil,
                           selected: selectedPlan == .lifetime)
        
        switch selectedPlan {
        case .month:
            labelBgImgView.isHidden = true
            if let monthProduct = monthProduct {
                dailyPriceLabel.text = preferredRemoteText(monthRemoteProduct?.dayAvgPriceLabel) ?? buildDailyText(for: monthProduct)
                tipsLabel.text = preferredRemoteText(monthRemoteProduct?.promotionDesc) ?? buildSubscriptionTips(for: monthProduct,
                                                                                                                  currentPriceText: monthPriceText,
                                                                                                                  originPriceText: monthOriginPriceText)
            } else {
                dailyPriceLabel.text = preferredRemoteText(monthRemoteProduct?.dayAvgPriceLabel) ?? "--元/天"
                tipsLabel.text = preferredRemoteText(monthRemoteProduct?.promotionDesc) ?? "价格加载中..."
            }
        case .annual:
            let annualDailyText = preferredRemoteText(annualRemoteProduct?.dayAvgPriceLabel) ?? annualProduct.map { buildDailyText(for: $0) }
            labelBgImgView.isHidden = (annualDailyText?.isEmpty ?? true)
            dailyPriceLabel.text = annualDailyText ?? "--元/天"
            if let annualProduct = annualProduct {
                tipsLabel.text = preferredRemoteText(annualRemoteProduct?.promotionDesc) ?? buildSubscriptionTips(for: annualProduct,
                                                                                                                   currentPriceText: annualPriceText,
                                                                                                                   originPriceText: annualOriginPriceText)
            } else {
                tipsLabel.text = preferredRemoteText(annualRemoteProduct?.promotionDesc) ?? "价格加载中..."
            }
        case .lifetime:
            labelBgImgView.isHidden = true
            if let lifetimeProduct = lifetimeProduct {
                dailyPriceLabel.text = buildDailyText(for: lifetimeProduct, days: 365)
                tipsLabel.text = preferredRemoteText(lifetimeRemoteProduct?.promotionDesc) ?? "买断价\(lifetimePriceText)，一次购买长期可用"
            } else {
                dailyPriceLabel.text = "--元/天"
                tipsLabel.text = preferredRemoteText(lifetimeRemoteProduct?.promotionDesc) ?? "价格加载中..."
            }
        }
    }

    private func preferredRemoteText(_ text: String?) -> String? {
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return nil
        }
        return text
    }

    private func applyRemoteProducts(_ products: [RemotePlanProduct]) {
        monthRemoteProduct = remoteProduct(from: products, type: .month)
        annualRemoteProduct = remoteProduct(from: products, type: .annual)
        lifetimeRemoteProduct = remoteProduct(from: products, type: .lifetime)
        
        monthTitleText = preferredRemoteText(monthRemoteProduct?.name) ?? "连续包月"
        annualTitleText = preferredRemoteText(annualRemoteProduct?.name) ?? "连续包年"
        lifetimeTitleText = preferredRemoteText(lifetimeRemoteProduct?.name) ?? "终身会员"
        
        monthTagText = preferredRemoteText(monthRemoteProduct?.promotionLabel)
        annualTagText = preferredRemoteText(annualRemoteProduct?.promotionLabel)
        monthSubTitleText = preferredRemoteText(monthRemoteProduct?.monthAvgPriceLabel)
        annualSubTitleText = preferredRemoteText(annualRemoteProduct?.monthAvgPriceLabel)
        monthOriginPriceText = preferredRemoteText(monthRemoteProduct?.originalPrice)
        annualOriginPriceText = preferredRemoteText(annualRemoteProduct?.originalPrice)
        monthPriceText = preferredRemoteText(monthRemoteProduct?.displayPriceText) ?? monthPriceText
        annualPriceText = preferredRemoteText(annualRemoteProduct?.displayPriceText) ?? annualPriceText
        lifetimePriceText = preferredRemoteText(lifetimeRemoteProduct?.displayPriceText) ?? lifetimePriceText
    }

    private func remoteProduct(from products: [RemotePlanProduct], type: PlanType) -> RemotePlanProduct? {
        if let matchedByType = products.first(where: { remotePlanType(for: $0) == type }) {
            return matchedByType
        }
        
        switch type {
        case .month:
            return products.first(where: {
                $0.iosProductId.lowercased().contains("month") || $0.name.contains("月")
            })
        case .annual:
            return products.first(where: {
                $0.iosProductId.lowercased().contains("annual") || $0.name.contains("年")
            })
        case .lifetime:
            return products.first(where: {
                $0.iosProductId.lowercased().contains("life") || $0.name.contains("终身")
            })
        }
    }

    private func remotePlanType(for product: RemotePlanProduct) -> PlanType? {
        switch product.type {
        case 1:
            return .month
        case 2:
            return .annual
        case 3:
            return .lifetime
        default:
            return nil
        }
    }
    
    func buildMonthlyText(for product: SKProduct) -> String {
        guard let period = product.subscriptionPeriod else { return "" }
        let months = monthCount(from: period)
        guard months > 1 else { return "" }
        
        let monthly = product.price.dividing(by: NSDecimalNumber(value: months))
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = max(2, formatter.maximumFractionDigits)
        let price = formatter.string(from: monthly) ?? "\(monthly)"
        return "每月仅需\(price)"
    }
    
    func buildDailyText(for product: SKProduct, days: Int) -> String {
        let safeDays = max(days, 1)
        let daily = product.price.dividing(by: NSDecimalNumber(value: safeDays))
        return buildDailyText(decimal: daily)
    }
    
    func buildDailyText(for product: SKProduct) -> String {
        if let intro = product.introductoryPrice {
            let days = daysCount(from: intro.subscriptionPeriod)
            let daily = intro.price.dividing(by: NSDecimalNumber(value: max(days, 1)))
            return buildDailyText(decimal: daily)
        }
        
        let days = daysCount(from: product.subscriptionPeriod)
        return buildDailyText(for: product, days: days)
    }
    
    func buildDailyText(decimal: NSDecimalNumber) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let value = formatter.string(from: decimal) ?? "\(decimal)"
        return "\(value)元/天"
    }
    
    func localizedPriceString(decimal: NSDecimalNumber, locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = max(2, formatter.maximumFractionDigits)
        return formatter.string(from: decimal) ?? "\(decimal)"
    }
    
    func recurringPriceText(for product: SKProduct) -> String {
        return ElaProIAPManager.shared.localizedPriceString(for: product) + periodSuffix(period: product.subscriptionPeriod)
    }
    
    func buildSubscriptionTips(for product: SKProduct,
                               currentPriceText: String,
                               originPriceText: String?) -> String {
        if let renewText = originPriceText {
            return "首期\(currentPriceText)，随后以\(renewText)，可随时取消"
        }
        
        return "\(currentPriceText)\(periodSuffix(period: product.subscriptionPeriod))，可随时取消"
    }
    
    func promoTagText(for product: SKProduct) -> String? {
        guard let intro = product.introductoryPrice else { return nil }
        let periodText = periodText(period: intro.subscriptionPeriod)
        switch periodText {
        case "月":
            return "首月特惠"
        case "年":
            return "首年特惠"
        default:
            return "首期特惠"
        }
    }
    
    func periodSuffix(period: SKProductSubscriptionPeriod?) -> String {
        let text = periodText(period: period)
        if text.isEmpty { return "" }
        return "/\(text)"
    }
    
    func periodText(period: SKProductSubscriptionPeriod?) -> String {
        guard let period = period else { return "" }
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
        guard let period = period else { return 30 }
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
            return 30
        }
    }
    
    func monthCount(from period: SKProductSubscriptionPeriod) -> Double {
        let units = Double(max(period.numberOfUnits, 1))
        switch period.unit {
        case .day:
            return units / 30.0
        case .week:
            return units * 7.0 / 30.0
        case .month:
            return units
        case .year:
            return units * 12.0
        @unknown default:
            return units
        }
    }
    
    func initUI() {
        addSubview(bgImgView)
        addSubview(scrollView)
        addSubview(bottomBar)
        addSubview(agreementConfirmDimView)
        addSubview(agreementConfirmSheet)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(logoImgView)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(cardContainer)
        contentView.addSubview(tipsLabel)
        contentView.addSubview(renewalDashView)
        contentView.addSubview(renewalNoticeLabel)
        contentView.addSubview(renewalSwitch)
        contentView.addSubview(benefitTitleLabel)
        contentView.addSubview(benefitContainer)
        contentView.addSubview(aiTitleLabel)
        contentView.addSubview(aiContainer)
        contentView.addSubview(moreTitleLabel)
        contentView.addSubview(moreContainer)
        
        cardContainer.addSubview(monthCard)
        cardContainer.addSubview(yearCard)
        cardContainer.addSubview(lifeCard)
        
        monthCard.isUserInteractionEnabled = true
        yearCard.isUserInteractionEnabled = true
        lifeCard.isUserInteractionEnabled = true
        monthCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectMonthCardAction)))
        yearCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectYearCardAction)))
        lifeCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectLifeCardAction)))
        
        benefitContainer.addSubview(benefitOne)
        benefitContainer.addSubview(benefitTwo)
        benefitContainer.addSubview(benefitThree)
        benefitContainer.addSubview(benefitFour)
        benefitContainer.addSubview(benefitFive)
        benefitContainer.addSubview(benefitSix)
        benefitContainer.addSubview(dividerOne)
        benefitContainer.addSubview(dividerTwo)
        benefitContainer.addSubview(dividerThree)
        benefitContainer.addSubview(dividerFour)
        benefitContainer.addSubview(dividerFive)
        
        aiContainer.addSubview(aiOne)
        aiContainer.addSubview(aiTwo)
        aiContainer.addSubview(aiThree)
        aiContainer.addSubview(aiFour)
        aiContainer.addSubview(aiDividerOne)
        aiContainer.addSubview(aiDividerTwo)
        aiContainer.addSubview(aiDividerThree)
        
        moreContainer.addSubview(moreOne)
        moreContainer.addSubview(moreTwo)
        moreContainer.addSubview(moreDividerOne)
        
        renewalDashLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor
        renewalDashLayer.lineWidth = 1
        renewalDashLayer.lineDashPattern = [4, 3]
        renewalDashLayer.fillColor = UIColor.clear.cgColor
        renewalDashView.layer.addSublayer(renewalDashLayer)
        
        bottomBar.addSubview(labelBgImgView)
        labelBgImgView.addSubview(dailyPriceLabel)
        bottomBar.addSubview(confirmButton)
        bottomBar.addSubview(agreeButton)
        bottomBar.addSubview(agreementLabel)
        agreementConfirmSheet.addSubview(agreementConfirmCloseButton)
        agreementConfirmSheet.addSubview(agreementConfirmTitleLabel)
        agreementConfirmSheet.addSubview(agreementConfirmLabel)
        agreementConfirmSheet.addSubview(agreementConfirmContinueButton)
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapAction), for: .touchUpInside)
        
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(100) + WHUtils().getBottomSafeAreaHeight())
        }

        agreementConfirmDimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        agreementConfirmSheet.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(agreementConfirmSheetHeight)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(22))
            make.height.equalTo(kFitWidth(44))
        }
        labelBgImgView.snp.makeConstraints { make in
            make.right.equalTo(confirmButton)
            make.top.equalTo(confirmButton).offset(kFitWidth(-16))
            make.width.equalTo(kFitWidth(64.5))
            make.height.equalTo(kFitWidth(43.5))
        }
        dailyPriceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kFitWidth(4))
            make.left.equalToSuperview().offset(kFitWidth(9.5))
            make.right.equalToSuperview().offset(kFitWidth(-9))
        }
//        dailyPriceLabel.snp.makeConstraints { make in
//            make.right.equalTo(confirmButton.snp.right)
//            make.bottom.equalTo(confirmButton.snp.top).offset(kFitWidth(5))
//            make.width.equalTo(kFitWidth(70))
//            make.height.equalTo(kFitWidth(26))
//        }
        
        agreeButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(84))
            make.top.equalTo(confirmButton.snp.bottom).offset(kFitWidth(17))
            make.width.height.equalTo(kFitWidth(16))
        }
        
        agreementLabel.snp.makeConstraints { make in
            make.centerY.equalTo(agreeButton)
            make.left.equalTo(agreeButton.snp.right).offset(kFitWidth(10))
            make.right.lessThanOrEqualTo(kFitWidth(-20))
        }

        agreementConfirmCloseButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(kFitWidth(-19))
            make.width.height.equalTo(kFitWidth(28))
        }

        agreementConfirmTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kFitWidth(53))
            make.centerX.equalToSuperview()
        }

        agreementConfirmLabel.snp.makeConstraints { make in
            make.top.equalTo(agreementConfirmTitleLabel.snp.bottom).offset(kFitWidth(27))
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(kFitWidth(24))
            make.right.lessThanOrEqualTo(kFitWidth(-24))
        }

        agreementConfirmContinueButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(19))
            make.right.equalTo(kFitWidth(-19))
            make.top.equalTo(agreementConfirmLabel.snp.bottom).offset(kFitWidth(28))
            make.height.equalTo(kFitWidth(48))
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomBar.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        logoImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(8))
            make.width.equalTo(kFitWidth(165))
            make.height.equalTo(kFitWidth(59))
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImgView.snp.bottom).offset(kFitWidth(2))
            make.centerX.equalToSuperview()
            make.height.equalTo(kFitWidth(22))
        }
        
        cardContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(subTitleLabel.snp.bottom).offset(kFitWidth(57))
            make.height.equalTo(kFitWidth(141))
        }
        
        let cardGap = kFitWidth(14)
        monthCard.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        yearCard.snp.makeConstraints { make in
            make.left.equalTo(monthCard.snp.right).offset(cardGap)
            make.top.bottom.width.equalTo(monthCard)
        }
        lifeCard.snp.makeConstraints { make in
            make.left.equalTo(yearCard.snp.right).offset(cardGap)
            make.right.equalToSuperview()
            make.top.bottom.width.equalTo(monthCard)
        }
        
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cardContainer.snp.bottom).offset(kFitWidth(20))
            make.height.equalTo(kFitWidth(22))
        }
        
        renewalDashView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(25))
            make.height.equalTo(1)
        }
        
        renewalSwitch.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalTo(renewalNoticeLabel)
        }
        
        renewalNoticeLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
//            make.right.equalTo(renewalSwitch.snp.left).offset(kFitWidth(-12))
            make.right.equalTo(kFitWidth(-69))
            make.top.equalTo(renewalDashView.snp.bottom).offset(kFitWidth(20))
        }
        
        benefitTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(renewalNoticeLabel.snp.bottom).offset(kFitWidth(35))
        }
        
        benefitContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(benefitTitleLabel.snp.bottom).offset(kFitWidth(14))
        }
        
        benefitOne.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(65))
        }
        dividerOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.right.equalToSuperview()
            make.top.equalTo(benefitOne.snp.bottom)
            make.height.equalTo(1)
        }
        
        benefitTwo.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerOne.snp.bottom)
            make.height.equalTo(benefitOne)
        }
        dividerTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.right.equalToSuperview()
            make.top.equalTo(benefitTwo.snp.bottom)
            make.height.equalTo(1)
        }
        
        benefitThree.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerTwo.snp.bottom)
            make.height.equalTo(benefitOne)
        }
        dividerThree.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.right.equalToSuperview()
            make.top.equalTo(benefitThree.snp.bottom)
            make.height.equalTo(1)
        }
        
        benefitFour.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerThree.snp.bottom)
            make.height.equalTo(benefitOne)
        }
        dividerFour.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.right.equalToSuperview()
            make.top.equalTo(benefitFour.snp.bottom)
            make.height.equalTo(1)
        }
        
        benefitFive.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerFour.snp.bottom)
            make.height.equalTo(benefitOne)
        }
        dividerFive.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.right.equalToSuperview()
            make.top.equalTo(benefitFive.snp.bottom)
            make.height.equalTo(1)
        }
        
        benefitSix.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerFive.snp.bottom)
            make.height.equalTo(benefitOne)
            make.bottom.equalToSuperview()
        }
        
        aiTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(benefitContainer.snp.bottom).offset(kFitWidth(24))
        }
        
        aiContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(aiTitleLabel.snp.bottom).offset(kFitWidth(20))
        }
        
        aiOne.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(65))
        }
        aiDividerOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.right.equalToSuperview()
            make.top.equalTo(aiOne.snp.bottom)
            make.height.equalTo(1)
        }
        
        aiTwo.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(aiDividerOne.snp.bottom)
            make.height.equalTo(kFitWidth(65))
        }
        aiDividerTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.right.equalToSuperview()
            make.top.equalTo(aiTwo.snp.bottom)
            make.height.equalTo(1)
        }
        
        aiThree.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(aiDividerTwo.snp.bottom)
            make.height.equalTo(kFitWidth(65))
        }
        aiDividerThree.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.right.equalToSuperview()
            make.top.equalTo(aiThree.snp.bottom)
            make.height.equalTo(1)
        }
        
        aiFour.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(aiDividerThree.snp.bottom)
            make.height.equalTo(kFitWidth(65))
            make.bottom.equalToSuperview()
        }
        
        moreTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(aiContainer.snp.bottom).offset(kFitWidth(25))
        }
        
        moreContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(moreTitleLabel.snp.bottom).offset(kFitWidth(20))
            make.bottom.equalToSuperview().offset(kFitWidth(-20))
        }
        
        moreOne.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(55))
        }
        moreDividerOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.right.equalToSuperview()
            make.top.equalTo(moreOne.snp.bottom)
            make.height.equalTo(1)
        }
        
        moreTwo.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(moreDividerOne.snp.bottom)
            make.height.equalTo(kFitWidth(55))
            make.bottom.equalToSuperview()
        }
    }
    
    func makeBenefitRow(title: String, desc: String) -> UIView {
        let row = UIView()
        let dot = UIImageView()
        dot.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        dot.layer.cornerRadius = kFitWidth(14)
        dot.clipsToBounds = true
        
        let titleLab = UILabel()
        titleLab.text = title
        titleLab.textColor = normalTextColor
        titleLab.font = .systemFont(ofSize: 15, weight: .medium)
        
        let descLab = UILabel()
        descLab.text = desc
        descLab.textColor = subTextColor
        descLab.font = .systemFont(ofSize: 12, weight: .regular)
        
        row.addSubview(dot)
        row.addSubview(titleLab)
        row.addSubview(descLab)
        
        dot.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.top.equalTo(kFitWidth(18))
            make.width.height.equalTo(kFitWidth(28))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.top.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(21))
        }
        descLab.snp.makeConstraints { make in
            make.left.right.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(2))
            make.height.equalTo(kFitWidth(18))
        }
        
        return row
    }
    
    func makeSimpleRow(title: String) -> UIView {
        let row = UIView()
        
        let dot = UIImageView()
        dot.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        dot.layer.cornerRadius = kFitWidth(14)
        dot.clipsToBounds = true
        
        let titleLab = UILabel()
        titleLab.text = title
        titleLab.textColor = normalTextColor
        titleLab.font = .systemFont(ofSize: 16, weight: .semibold)
        
        row.addSubview(dot)
        row.addSubview(titleLab)
        
        dot.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(28))
        }
        
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalTo(dot)
        }
        
        return row
    }
    
    func makeDivider() -> UIView {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10//WHColor_16(colorStr: "E7EAF0")
        return vi
    }
    
    func makeCircleImage(color: UIColor) -> UIImage {
        let size = CGSize(width: kFitWidth(24), height: kFitWidth(24))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(color.cgColor)
        context?.setLineWidth(2)
        context?.addEllipse(in: CGRect(x: 1, y: 1, width: size.width - 2, height: size.height - 2))
        context?.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    func makeCheckedImage() -> UIImage {
        let size = CGSize(width: kFitWidth(24), height: kFitWidth(24))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        context.setFillColor(selectedBlue.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2.4)
        context.setLineCap(.round)
        context.move(to: CGPoint(x: size.width * 0.28, y: size.height * 0.53))
        context.addLine(to: CGPoint(x: size.width * 0.45, y: size.height * 0.69))
        context.addLine(to: CGPoint(x: size.width * 0.72, y: size.height * 0.36))
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

extension ElaProPriceVM{
    func sendProProductListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_product,
                                          parameters: nil,
                                          success: { [weak self] responseObject in
            guard let self = self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendProProductListRequest:\(dataDict)")
            let rawProducts = (dataDict["products"] as? NSArray) ?? (dataDict["product"] as? NSArray) ?? []
            let products = rawProducts.compactMap { item -> RemotePlanProduct? in
                guard let dict = item as? NSDictionary else { return nil }
                return RemotePlanProduct(dict: dict)
            }
            
            self.applyRemoteProducts(products)
            let monthID = self.preferredRemoteText(self.monthRemoteProduct?.iosProductId) ?? ElaProIAPConfig.monthProductID
            let annualID = self.preferredRemoteText(self.annualRemoteProduct?.iosProductId) ?? ElaProIAPConfig.annualProductID
            let lifetimeID = self.preferredRemoteText(self.lifetimeRemoteProduct?.iosProductId) ?? ElaProIAPConfig.lifetimeProductID
            
            ElaProIAPManager.shared.updateProductIDs(month: monthID, annual: annualID, lifetime: lifetimeID)
            self.refreshPlanCards()
            self.fetchProProductsIfNeeded()
        }, failure: { [weak self] _ in
            self?.fetchProProductsIfNeeded()
        })
    }
}
