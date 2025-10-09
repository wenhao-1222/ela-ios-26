//
//  OrderListMallTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/16.
//


import UIKit
import SnapKit

class OrderListMallTableViewCell: UITableViewCell {

    private var countdownTimer: Timer?
    private var remainingSeconds: Int = 0
    private var deadlineTime: Date?

    var tapBlock:(()->())?
    var timeOutBlock:(()->())?
    var payBlock:(()->())?
    var closeBlock:(()->())?
    var saleAfterBlock:(()->())?
    var disableSaleAfterBlock:(()->())?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .COLOR_BG_F5
        selectionStyle = .none
        
        initUI()
    }

    // MARK: - UI
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        return vi
    }()

    lazy var tapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var orderIdLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var afterSaleStatusLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "FF8725")
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.isHidden = true
        return lab
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(6)
        img.clipsToBounds = true
        return img
    }()

    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.numberOfLines = 1
        lab.lineBreakMode = .byTruncatingTail//.byTruncatingMiddle
        lab.textInsets = UIEdgeInsets(top: kFitWidth(3), left: 0, bottom: kFitWidth(3), right: 0)
        lab.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        lab.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return lab
    }()
    lazy var titleQuantityLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.setContentCompressionResistancePriority(.required, for: .horizontal)
        lab.setContentHuggingPriority(.required, for: .horizontal)
        lab.isHidden = true
        return lab
    }()

    lazy var titleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLab, titleQuantityLabel])
        stack.axis = .horizontal
        stack.spacing = kFitWidth(4)
        stack.alignment = .center
        return stack
    }()
    lazy var subTitleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.textInsets = UIEdgeInsets(top: kFitWidth(3), left: 0, bottom: kFitWidth(3), right: 0)
        return lab
    }()

    lazy var bindDeviceLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
//        lab.isHidden = true
        return lab
    }()

    lazy var orderTimeLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
//        lab.isHidden = true
        return lab
    }()

    lazy var moneyLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.isHidden = true
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()

    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()

    lazy var deleteIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_order_delete_icon")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        return img
    }()

    lazy var deleteTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        vi.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()

    lazy var payButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(15)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.isHidden = true
        btn.addTarget(self, action: #selector(payTapAction), for: .touchUpInside)
        return btn
    }()

    lazy var timeoutButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.backgroundColor = WHColor_16(colorStr: "C4C4C4")
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(15)
        btn.clipsToBounds = true
        btn.isHidden = true
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    lazy var saleAfterButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.setTitle("售后", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_30, for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(15)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saleAfterAction), for: .touchUpInside)
        return btn
    }()
}

// MARK: - Actions
extension OrderListMallTableViewCell{
    @objc func tapAction() { self.tapBlock?() }
    @objc func payTapAction() { self.payBlock?() }
    @objc func deleteAction() { self.closeBlock?() }
    @objc func saleAfterAction() { self.saleAfterBlock?() }
    @objc func afterSaleDisableAction() {
        self.disableSaleAfterBlock?()
    }
}

// MARK: - Public
extension OrderListMallTableViewCell {
    func updateUI(dict: NSDictionary) {
        if dict.stringValueForKey(key: "skuName").isEmpty {
            imgView.image = nil
            orderIdLabel.text = nil
            titleLab.text = nil
            subTitleLab.text = nil
            bindDeviceLabel.text = nil
            orderTimeLabel.text = nil
            afterSaleStatusLabel.text = nil
            moneyLabel.text = nil
            titleQuantityLabel.text = nil
            titleQuantityLabel.isHidden = true
            payButton.isHidden = true
            saleAfterButton.isHidden = false
            saleAfterButton.setTitle("", for: .normal)
            saleAfterButton.layer.borderColor = UIColor.clear.cgColor
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            imgView.showSkeleton(cfg)
            orderIdLabel.showSkeleton(cfg)
            titleStackView.showSkeleton(cfg)
            bindDeviceLabel.showSkeleton(cfg)
            orderTimeLabel.showSkeleton(cfg)
            titleQuantityLabel.showSkeleton(cfg)
            moneyLabel.showSkeleton(cfg)
            payButton.showSkeleton(cfg)
            afterSaleStatusLabel.showSkeleton(cfg)
            saleAfterButton.showSkeleton(cfg)
            
            return
        }
        saleAfterButton.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_30.cgColor
        saleAfterButton.setTitle("售后", for: .normal)
//        if dict.stringValueForKey(key: "skuName").count > 0 {
            let coverInfo = dict["image"] as? NSArray ?? []
            if coverInfo.count > 0 {
                imgView.setImgUrl(urlString: coverInfo[0]as? String ?? "")
            }else{
                imgView.image = nil
            }
            
            orderIdLabel.text = "订单号 \(dict.stringValueForKey(key: "id"))"
//            titleLab.text = "\(dict.stringValueForKey(key: "skuName"))"
//            let skuName = dict.stringValueForKey(key: "skuName")
//            contentView.layoutIfNeeded()
//            titleLab.text = formattedTitleText(skuName: skuName, dict: dict)
        
            let skuName = dict.stringValueForKey(key: "skuName")
            titleLab.text = skuName
            if let quantityText = resolvedQuantityText(from: dict) {
                titleQuantityLabel.text = "x\(quantityText)"
                titleQuantityLabel.isHidden = false
            } else {
                titleQuantityLabel.text = nil
                titleQuantityLabel.isHidden = true
            }

            updateCtime(cTime: dict.stringValueForKey(key: "ctime"))
            updateMoney(dict: dict)

            timeoutButton.isHidden = true
            payButton.isHidden = true
            deleteIcon.isHidden = true
            deleteTapView.isHidden = true
            saleAfterButton.isHidden = true
            bindDeviceLabel.isHidden = true

            let specList = dict["specValueList"]as? NSArray ?? []
            var spec = ""
            for i in 0..<specList.count{
                let s = specList[i]as? String ?? ""
                spec += s
                if i < specList.count - 1{
                    spec += " | "
                }
            }
            updateDevice(phoneName: spec)
            // 待支付
            if dict.stringValueForKey(key: "status") == "1" {
                payButton.isHidden = false
                moneyLabel.isHidden = false
                deleteIcon.isHidden = false
                deleteTapView.isHidden = false
                updatePayTimeCountDown(time: dict.stringValueForKey(key: "timeExpire"))
            }  else if dict.stringValueForKey(key: "status") == "2" { // 已取消
                moneyLabel.isHidden = false
                timeoutButton.isHidden = false
                deleteIcon.isHidden = false
                deleteTapView.isHidden = false
            } else if dict.stringValueForKey(key: "status") == "3" { // 已支付
                subTitleLab.isHidden = true
                saleAfterButton.isHidden = false
                orderTimeLabel.isHidden = false
                updateExpress(expressStatus: "待发货")
            } else if dict.stringValueForKey(key: "status") == "4" { // 运输中
                saleAfterButton.isHidden = false
                updateExpress(expressStatus: "运输中")
            }else if dict.stringValueForKey(key: "status") == "5" { // 已签收
                saleAfterButton.isHidden = false
                updateExpress(expressStatus: "已签收")
                deleteIcon.isHidden = false
                deleteTapView.isHidden = false
            }else if dict.stringValueForKey(key: "status") == "6" { // 已退款
                saleAfterButton.isHidden = false
                updateExpress(expressStatus: "已签收")
            }else if dict.stringValueForKey(key: "status") == "7" { // 已换货
                saleAfterButton.isHidden = false
                updateExpress(expressStatus: "已签收")
            }
            
        updateAfterSaleStatus(afterSaleStatus: dict.stringValueForKey(key: "afterSaleStatus"),
                              status: dict.stringValueForKey(key: "status"))
        updateAfterSaleEnableStatus(returnable: dict.stringValueForKey(key: "returnable") == "1")
            // 3) 最后统一把骨架优雅淡出 + 内容淡入
            [imgView, orderIdLabel,titleQuantityLabel, titleStackView,subTitleLab,bindDeviceLabel,orderTimeLabel,moneyLabel,payButton,timeoutButton,saleAfterButton,afterSaleStatusLabel].forEach { $0.hideSkeletonWithCrossfade() }
//        }
    }
    //是否支持售后
    func updateAfterSaleEnableStatus(returnable:Bool) {
        if returnable == false{
            tapView.snp.remakeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.bottom.equalTo(lineView)
            }
            saleAfterButton.isEnabled = true
            saleAfterButton.setTitleColor(.COLOR_TEXT_TITLE_0f1214_30, for: .normal)
            saleAfterButton.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_30.cgColor
            saleAfterButton.removeTarget(self, action: #selector(saleAfterAction), for: .touchUpInside)
            saleAfterButton.addTarget(self, action: #selector(afterSaleDisableAction), for: .touchUpInside)
        }else{
            tapView.snp.remakeConstraints { make in
                make.left.top.right.bottom.equalToSuperview()
            }
            saleAfterButton.removeTarget(self, action: #selector(afterSaleDisableAction), for: .touchUpInside)
            saleAfterButton.addTarget(self, action: #selector(saleAfterAction), for: .touchUpInside)
        }
    }
    //刷新售后状态
    func updateAfterSaleStatus(afterSaleStatus:String,status:String) {
        tapView.snp.remakeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        if afterSaleStatus == "0"{//未申请售后
            afterSaleStatusLabel.isHidden = true
            afterSaleStatusLabel.text = ""
            tapView.snp.remakeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.bottom.equalTo(lineView)
            }
        }else if afterSaleStatus == "1"{//售后中
            afterSaleStatusLabel.isHidden = false
            afterSaleStatusLabel.text = "售后服务中"
            saleAfterButton.isEnabled = false
            deleteIcon.isHidden = true
            deleteTapView.isHidden = true
            afterSaleStatusLabel.textColor = WHColor_16(colorStr: "FF8725")
            afterSaleStatusLabel.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-16))
                make.centerY.lessThanOrEqualTo(orderIdLabel)
            }
        }else if afterSaleStatus == "2"{//售后完成
            afterSaleStatusLabel.isHidden = false
            deleteIcon.isHidden = false
            saleAfterButton.isEnabled = false
            deleteTapView.isHidden = false
            afterSaleStatusLabel.textColor = WHColor_16(colorStr: "FF8725")
            afterSaleStatusLabel.snp.remakeConstraints { make in
                make.right.equalTo(deleteIcon.snp.left).offset(kFitWidth(-8))
                make.centerY.lessThanOrEqualTo(orderIdLabel)
            }
            if status == "6"{
                afterSaleStatusLabel.text = "已退款"
            }else if status == "7"{
                afterSaleStatusLabel.text = "已换货"
            }else{
                afterSaleStatusLabel.text = "售后完成"
            }
        }else if afterSaleStatus == "3"{//拒绝售后
            afterSaleStatusLabel.isHidden = false
            if status == "4"{
                deleteIcon.isHidden = true
                saleAfterButton.isEnabled = true
                deleteTapView.isHidden = true
                afterSaleStatusLabel.snp.remakeConstraints { make in
                    make.right.equalTo(deleteIcon)
                    make.centerY.lessThanOrEqualTo(orderIdLabel)
                }
            }else{
                deleteIcon.isHidden = false
                saleAfterButton.isEnabled = false
                deleteTapView.isHidden = false
                afterSaleStatusLabel.snp.remakeConstraints { make in
                    make.right.equalTo(deleteIcon.snp.left).offset(kFitWidth(-8))
                    make.centerY.lessThanOrEqualTo(orderIdLabel)
                }
            }
            
            afterSaleStatusLabel.text = "不符合退/换货"
            afterSaleStatusLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        }
    }
    //更新物流状态
    func updateExpress(expressStatus:String) {
        let attr = NSMutableAttributedString(string: "物流状态：")
        let attrTime = NSMutableAttributedString(string: expressStatus)
        attr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        attrTime.yy_color = .COLOR_TEXT_TITLE_0f1214
        attr.append(attrTime)
        moneyLabel.attributedText = attr
        moneyLabel.isHidden = false
    }
    
    func updateCtime(cTime: String) {
        let attr = NSMutableAttributedString(string: "下单时间：")
        let attrTime = NSMutableAttributedString(string: cTime.replacingOccurrences(of: "T", with: " "))
        attr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        attrTime.yy_color = .COLOR_TEXT_TITLE_0f1214
        attr.append(attrTime)
        orderTimeLabel.attributedText = attr
//        orderTimeLabel.isHidden = false
    }

    func updateDevice(phoneName: String) {
        let attr = NSMutableAttributedString(string: "型号：")
        let attrTime = NSMutableAttributedString(string: phoneName.count > 0 ? phoneName : "-")
        attr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        attrTime.yy_color = .COLOR_TEXT_TITLE_0f1214
        attr.append(attrTime)
        bindDeviceLabel.attributedText = attr
        bindDeviceLabel.isHidden = false
    }
    
    func updateMoney(dict: NSDictionary) {
        let attr = NSMutableAttributedString(string: "订单金额：")
        let attrTime = NSMutableAttributedString(string: "¥\(dict.stringValueForKey(key: "payAmount"))")
        attr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        attrTime.yy_color = .COLOR_TEXT_TITLE_0f1214
        attr.append(attrTime)
        
        if dict.doubleValueForKey(key: "discountAmount") > 0 {
            let priceAttrDiscount = NSMutableAttributedString(string: "已优惠¥\(dict.stringValueForKey(key: "discountAmount"))")
            priceAttrDiscount.yy_color = .THEME
            priceAttrDiscount.yy_font  = .systemFont(ofSize: 11, weight: .regular)
            attr.append(priceAttrDiscount)
        }
        
        moneyLabel.attributedText = attr
        moneyLabel.isHidden = false
    }

    func updatePayTimeCountDown(time: String) {
        countdownTimer?.invalidate()
        countdownTimer = nil

        guard let timestamp = TimeInterval(time) else {
            payButton.setTitle("去支付 00:00", for: .normal)
            return
        }

        let serverDeadline = Date(timeIntervalSince1970: timestamp)
        let now = Date()
        remainingSeconds = Int(serverDeadline.timeIntervalSince(now))
        deadlineTime = serverDeadline

        if remainingSeconds <= 0 {
            payButton.setTitle("去支付 00:00", for: .normal)
            self.timeOutBlock?()
            return
        }

        payButton.isHidden = false
        updateCountdownLabel()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickCountdown()
        }
        RunLoop.main.add(countdownTimer!, forMode: .common)
    }
    

    private func tickCountdown() {
        remainingSeconds -= 1
        if remainingSeconds <= 0 {
            countdownTimer?.invalidate()
            payButton.setTitle("去支付 00:00", for: .normal)
            self.timeOutBlock?()
            return
        }
        updateCountdownLabel()
    }

    private func updateCountdownLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        let timeStr = String(format: "去支付 %02d:%02d", minutes, seconds)
        payButton.setTitle(timeStr, for: .normal)
    }
    
    
    private func resolvedQuantityText(from dict: NSDictionary) -> String? {
        if let number = dict["quantity"] as? NSNumber {
            let formatted = formatQuantityNumber(number)
            return formatted.isEmpty ? nil : formatted
        }

        let quantityString = dict.stringValueForKey(key: "quantity").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !quantityString.isEmpty else { return nil }

        if let doubleValue = Double(quantityString) {
            let formatted = formatQuantityNumber(NSNumber(value: doubleValue))
            return formatted.isEmpty ? nil : formatted
        }

        return quantityString
    }

    private func formatQuantityNumber(_ number: NSNumber) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = number.doubleValue.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 3
        return formatter.string(from: number) ?? number.stringValue
    }
}

// MARK: - Layout
extension OrderListMallTableViewCell {
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(tapView)
        bgView.addSubview(orderIdLabel)
        bgView.addSubview(afterSaleStatusLabel)
        bgView.addSubview(imgView)
//        bgView.addSubview(titleLab)
        bgView.addSubview(titleStackView)
        bgView.addSubview(deleteIcon)
        bgView.addSubview(deleteTapView)
        bgView.addSubview(subTitleLab)
        bgView.addSubview(bindDeviceLabel)
        bgView.addSubview(orderTimeLabel)
        bgView.addSubview(moneyLabel)
        bgView.addSubview(lineView)
        bgView.addSubview(payButton)
        bgView.addSubview(timeoutButton)
        bgView.addSubview(saleAfterButton)

        setConstrait()
    }

    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-12))
            make.top.equalToSuperview()
        }
        tapView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(lineView)
        }
        orderIdLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(4))
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-80))
            make.height.equalTo(kFitWidth(27))
        }
        afterSaleStatusLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(orderIdLabel)
        }
        deleteIcon.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(orderIdLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        deleteTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(deleteIcon)
            make.width.height.equalTo(kFitWidth(48))
        }
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(43))
            make.width.height.equalTo(kFitWidth(90))
        }
        titleStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(121))
            make.top.equalTo(imgView)
            make.height.equalTo(kFitWidth(21))
            make.right.equalTo(kFitWidth(-16))
        }
        subTitleLab.snp.makeConstraints { make in
            make.left.right.equalTo(titleStackView)
            make.top.equalTo(titleStackView.snp.bottom).offset(kFitWidth(3))
        }
        bindDeviceLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleStackView)
            make.top.equalTo(titleStackView.snp.bottom).offset(kFitWidth(3))
            make.height.equalTo(kFitWidth(18))
        }
        orderTimeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleStackView)
            make.top.equalTo(bindDeviceLabel.snp.bottom).offset(kFitWidth(3))
            make.height.equalTo(kFitWidth(18))
        }
        moneyLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleStackView)
            make.top.equalTo(orderTimeLabel.snp.bottom).offset(kFitWidth(3))
            make.height.equalTo(kFitWidth(18))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
//            make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(16))
            make.top.equalTo(kFitWidth(150))
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(kFitWidth(-50))
        }
        payButton.snp.makeConstraints { make in
            make.bottom.equalTo(kFitWidth(-10))
            make.width.equalTo(kFitWidth(102))
            make.height.equalTo(kFitWidth(30))
            make.right.equalTo(kFitWidth(-16))
        }
        timeoutButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-10))
            make.width.equalTo(kFitWidth(80))
            make.height.equalTo(kFitWidth(30))
        }
        saleAfterButton.snp.makeConstraints { make in
            make.bottom.equalTo(kFitWidth(-10))
            make.width.equalTo(kFitWidth(80))
            make.height.equalTo(kFitWidth(30))
            make.right.equalTo(kFitWidth(-16))
        }
    }
}

