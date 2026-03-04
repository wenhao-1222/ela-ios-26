//
//  ElaProPriceVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//

import StoreKit
import MCToast

class ElaProPriceVM: UIView {
    enum PlanType {
        case month
        case annual
        case lifetime
    }
    
    var purchaseSuccessBlock: (() -> ())?
    
    private let selectedBlue = WHColor_16(colorStr: "1677F2")
    private let normalTextColor = UIColor.COLOR_TEXT_TITLE_0f1214
    private let subTextColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
    private let renewalDashLayer = CAShapeLayer()
    
    private var selectedPlan: PlanType = .annual
    private var monthProduct: SKProduct?
    private var annualProduct: SKProduct?
    private var lifetimeProduct: SKProduct?
    private var monthTagText: String?
    private var monthPriceText = "--"
    private var monthSubTitleText: String?
    private var monthOriginPriceText: String?
    private var annualTagText: String?
    private var annualPriceText = "--"
    private var annualSubTitleText: String?
    private var annualOriginPriceText: String?
    private var lifetimePriceText = "--"
    private var isPurchasing = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
        refreshPlanCards()
        fetchProProductsIfNeeded()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        lab.text = "订阅不知不觉扣费？我们也是。开启提醒，每次续费前5天我们会通过推送通知你。把选择权交还给你。"
        lab.textColor = subTextColor
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 0
        return lab
    }()
    lazy var renewalSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = true
        sw.onTintColor = selectedBlue
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
        vi.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        vi.layer.cornerRadius = kFitWidth(12)
        vi.layer.borderWidth = kFitWidth(1.5)
        vi.layer.borderColor = UIColor.white.cgColor
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
        vi.backgroundColor = UIColor.white.withAlphaComponent(0.94)
        return vi
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("确认", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = selectedBlue
        btn.layer.cornerRadius = kFitWidth(28)
        btn.clipsToBounds = true
        return btn
    }()
    lazy var dailyPriceLabel: UILabel = {
        let lab = UILabel()
        lab.text = "--元/天"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = WHColor_16(colorStr: "FF8F29")
        lab.layer.cornerRadius = kFitWidth(13)
        lab.clipsToBounds = true
        return lab
    }()
    lazy var agreeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(makeCircleImage(color: WHColor_16(colorStr: "BFC3CA")), for: .normal)
        btn.setImage(makeCheckedImage(), for: .selected)
        btn.isSelected = false
        btn.addTarget(self, action: #selector(toggleAgreeAction), for: .touchUpInside)
        return btn
    }()
    lazy var agreementLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 1
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
        return lab
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
    @objc func toggleAgreeAction() {
        agreeButton.isSelected.toggle()
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
            MCToast.mc_text("请先勾选并同意协议")
            return
        }
        
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
                    self.purchaseSuccessBlock?()
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
                        self.monthTagText = self.promoTagText(for: month)
                        self.monthSubTitleText = nil
                        if let intro = month.introductoryPrice {
                            self.monthPriceText = self.localizedPriceString(decimal: intro.price, locale: intro.priceLocale)
                            self.monthOriginPriceText = self.recurringPriceText(for: month)
                        } else {
                            self.monthPriceText = ElaProIAPManager.shared.localizedPriceString(for: month)
                            self.monthOriginPriceText = nil
                        }
                    }
                    
                    if let annual = products.first(where: { $0.productIdentifier == ElaProIAPConfig.annualProductID }) {
                        self.annualProduct = annual
                        self.annualTagText = self.promoTagText(for: annual)
                        self.annualSubTitleText = self.buildMonthlyText(for: annual)
                        if let intro = annual.introductoryPrice {
                            self.annualPriceText = self.localizedPriceString(decimal: intro.price, locale: intro.priceLocale)
                            self.annualOriginPriceText = self.recurringPriceText(for: annual)
                        } else {
                            self.annualPriceText = ElaProIAPManager.shared.localizedPriceString(for: annual)
                            self.annualOriginPriceText = nil
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
                            title: "连续包月",
                            subTitle: monthSubTitleText,
                            price: monthPriceText,
                            originPrice: monthOriginPriceText,
                            selected: selectedPlan == .month)
        
        yearCard.configure(tag: annualTagText,
                           title: "连续包年",
                           subTitle: annualSubTitleText,
                           price: annualPriceText,
                           originPrice: annualOriginPriceText,
                           selected: selectedPlan == .annual)
        
        lifeCard.configure(tag: nil,
                           title: "终身会员",
                           subTitle: nil,
                           price: lifetimePriceText,
                           originPrice: nil,
                           selected: selectedPlan == .lifetime)
        
        switch selectedPlan {
        case .month:
            if let monthProduct = monthProduct {
                dailyPriceLabel.text = buildDailyText(for: monthProduct)
                tipsLabel.text = buildSubscriptionTips(for: monthProduct,
                                                       currentPriceText: monthPriceText,
                                                       originPriceText: monthOriginPriceText)
            } else {
                dailyPriceLabel.text = "--元/天"
                tipsLabel.text = "价格加载中..."
            }
        case .annual:
            if let annualProduct = annualProduct {
                dailyPriceLabel.text = buildDailyText(for: annualProduct)
                tipsLabel.text = buildSubscriptionTips(for: annualProduct,
                                                       currentPriceText: annualPriceText,
                                                       originPriceText: annualOriginPriceText)
            } else {
                dailyPriceLabel.text = "--元/天"
                tipsLabel.text = "价格加载中..."
            }
        case .lifetime:
            if let lifetimeProduct = lifetimeProduct {
                dailyPriceLabel.text = buildDailyText(for: lifetimeProduct, days: 365)
                tipsLabel.text = "买断价\(lifetimePriceText)，一次购买长期可用"
            } else {
                dailyPriceLabel.text = "--元/天"
                tipsLabel.text = "价格加载中..."
            }
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
            return "首期\(currentPriceText)，随后\(renewText)，可随时取消"
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
        
        bottomBar.addSubview(confirmButton)
        bottomBar.addSubview(dailyPriceLabel)
        bottomBar.addSubview(agreeButton)
        bottomBar.addSubview(agreementLabel)
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapAction), for: .touchUpInside)
        
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(145) + WHUtils().getBottomSafeAreaHeight())
        }
        
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(56))
        }
        
        dailyPriceLabel.snp.makeConstraints { make in
            make.right.equalTo(confirmButton.snp.right)
            make.bottom.equalTo(confirmButton.snp.top).offset(kFitWidth(5))
            make.width.equalTo(kFitWidth(70))
            make.height.equalTo(kFitWidth(26))
        }
        
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
            make.top.equalTo(cardContainer.snp.bottom).offset(kFitWidth(30))
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
            make.top.equalTo(renewalDashView.snp.bottom).offset(kFitWidth(16))
        }
        
        benefitTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(renewalNoticeLabel.snp.bottom).offset(kFitWidth(24))
        }
        
        benefitContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(benefitTitleLabel.snp.bottom).offset(kFitWidth(14))
        }
        
        benefitOne.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(82))
        }
        dividerOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(benefitOne.snp.bottom)
            make.height.equalTo(1)
        }
        
        benefitTwo.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerOne.snp.bottom)
            make.height.equalTo(kFitWidth(82))
        }
        dividerTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(benefitTwo.snp.bottom)
            make.height.equalTo(1)
        }
        
        benefitThree.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerTwo.snp.bottom)
            make.height.equalTo(kFitWidth(82))
        }
        dividerThree.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(benefitThree.snp.bottom)
            make.height.equalTo(1)
        }
        
        benefitFour.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerThree.snp.bottom)
            make.height.equalTo(kFitWidth(82))
        }
        dividerFour.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(benefitFour.snp.bottom)
            make.height.equalTo(1)
        }
        
        benefitFive.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerFour.snp.bottom)
            make.height.equalTo(kFitWidth(82))
        }
        dividerFive.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(benefitFive.snp.bottom)
            make.height.equalTo(1)
        }
        
        benefitSix.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerFive.snp.bottom)
            make.height.equalTo(kFitWidth(82))
            make.bottom.equalToSuperview()
        }
        
        aiTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(benefitContainer.snp.bottom).offset(kFitWidth(24))
        }
        
        aiContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(aiTitleLabel.snp.bottom).offset(kFitWidth(10))
        }
        
        aiOne.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(78))
        }
        aiDividerOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(aiOne.snp.bottom)
            make.height.equalTo(1)
        }
        
        aiTwo.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(aiDividerOne.snp.bottom)
            make.height.equalTo(kFitWidth(78))
        }
        aiDividerTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(aiTwo.snp.bottom)
            make.height.equalTo(1)
        }
        
        aiThree.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(aiDividerTwo.snp.bottom)
            make.height.equalTo(kFitWidth(78))
        }
        aiDividerThree.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(aiThree.snp.bottom)
            make.height.equalTo(1)
        }
        
        aiFour.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(aiDividerThree.snp.bottom)
            make.height.equalTo(kFitWidth(78))
            make.bottom.equalToSuperview()
        }
        
        moreTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(aiContainer.snp.bottom).offset(kFitWidth(24))
        }
        
        moreContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(moreTitleLabel.snp.bottom).offset(kFitWidth(10))
            make.bottom.equalToSuperview().offset(kFitWidth(-20))
        }
        
        moreOne.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(64))
        }
        moreDividerOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(moreOne.snp.bottom)
            make.height.equalTo(1)
        }
        
        moreTwo.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(moreDividerOne.snp.bottom)
            make.height.equalTo(kFitWidth(64))
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
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(6))
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
        vi.backgroundColor = WHColor_16(colorStr: "E7EAF0")
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
