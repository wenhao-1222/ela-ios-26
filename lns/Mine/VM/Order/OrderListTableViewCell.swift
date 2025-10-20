//
//  OrderListTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/7/22.
//

import UIKit
import SnapKit

class OrderListTableViewCell: UITableViewCell {

    private var countdownTimer: Timer?
    private var remainingSeconds: Int = 0
    private var deadlineTime: Date?

    var timeOutBlock:(()->())?
    var payBlock:(()->())?
    var closeBlock:(()->())?
    var changeBlock:(()->())?

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

    lazy var orderIdLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
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
        lab.textInsets = UIEdgeInsets(top: kFitWidth(3), left: 0, bottom: kFitWidth(3), right: 0)
        return lab
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
        lab.lineBreakMode = .byTruncatingTail
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
        lab.isHidden = true
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

    lazy var changeDeviceButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .COLOR_BG_WHITE
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(15)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.isHidden = true
        btn.setTitle("更换设备", for: .normal)
        btn.layer.borderWidth = kFitWidth(1)
        btn.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_30.cgColor
        btn.addTarget(self, action: #selector(changeBtnAction), for: .touchUpInside)
        return btn
    }()
}

// MARK: - Actions
extension OrderListTableViewCell{
    @objc func payTapAction() { self.payBlock?() }
    @objc func deleteAction() { self.closeBlock?() }
    @objc func changeBtnAction() { self.changeBlock?() }
}

// MARK: - Public
extension OrderListTableViewCell {
    func updateUI(dict: NSDictionary) {
        moneyLabel.isHidden = true
        
        if dict.stringValueForKey(key: "title").isEmpty {
            imgView.image = nil
            orderIdLabel.text = nil
            titleLab.text = nil
            subTitleLab.text = nil
            bindDeviceLabel.text = nil
            orderTimeLabel.text = nil
            moneyLabel.text = nil
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            imgView.showSkeleton(cfg)
            orderIdLabel.showSkeleton(cfg)
            titleLab.showSkeleton(cfg)
            bindDeviceLabel.showSkeleton(cfg)
            orderTimeLabel.showSkeleton(cfg)
            moneyLabel.showSkeleton(cfg)
            payButton.showSkeleton(cfg)
            changeDeviceButton.showSkeleton(cfg)
            
            return
        }
        if dict.stringValueForKey(key: "title").count > 0 {
            let coverInfo = dict["coverInfo"] as? NSDictionary ?? [:]
            imgView.setImgUrl(urlString: coverInfo.stringValueForKey(key: "orderListImageOssUrl"))
            orderIdLabel.text = "订单号 \(dict.stringValueForKey(key: "id"))"
            titleLab.text = dict.stringValueForKey(key: "title")
            subTitleLab.text = dict.stringValueForKey(key: "subtitle")

            updateCtime(cTime: dict.stringValueForKey(key: "ctime"))
            updateMoney(dict: dict)

            timeoutButton.isHidden = true
            payButton.isHidden = true
            changeDeviceButton.isHidden = true
            deleteIcon.isHidden = true
            deleteTapView.isHidden = true
            bindDeviceLabel.isHidden = true

            // 待支付
            if dict.stringValueForKey(key: "status") == "1" {
                payButton.isHidden = false
                moneyLabel.isHidden = false
                deleteIcon.isHidden = false
                deleteTapView.isHidden = false
                updatePayTimeCountDown(time: dict.stringValueForKey(key: "timeExpire"))
                lineView.snp.remakeConstraints { make in
                    make.left.equalTo(kFitWidth(16))
                    make.right.equalTo(kFitWidth(-16))
                    make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(16))
                    make.height.equalTo(kFitWidth(1))
                    make.bottom.equalTo(kFitWidth(-50))
                }
            } else if dict.stringValueForKey(key: "status") == "3" { // 已支付
                subTitleLab.isHidden = true
                orderTimeLabel.isHidden = false
                updateDevice(phoneName: dict.stringValueForKey(key: "phoneName"))
                if dict.doubleValueForKey(key: "rebindingQuota") > 0 && dict.stringValueForKey(key: "phoneName").count > 0 {
                    changeDeviceButton.isHidden = false
                    lineView.snp.remakeConstraints { make in
                        make.left.equalTo(kFitWidth(16))
                        make.right.equalTo(kFitWidth(-16))
                        make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(16))
                        make.height.equalTo(kFitWidth(1))
                        make.bottom.equalTo(kFitWidth(-50))
                    }
                } else {
                    lineView.snp.remakeConstraints { make in
                        make.left.equalTo(kFitWidth(16))
                        make.right.equalTo(kFitWidth(-16))
                        make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(16))
                        make.height.equalTo(kFitWidth(1))
                        make.bottom.equalToSuperview()
                    }
                }
            } else if dict.stringValueForKey(key: "status") == "2" { // 已取消
                moneyLabel.isHidden = false
                timeoutButton.isHidden = false
                lineView.snp.remakeConstraints { make in
                    make.left.equalTo(kFitWidth(16))
                    make.right.equalTo(kFitWidth(-16))
                    make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(16))
                    make.height.equalTo(kFitWidth(1))
                    make.bottom.equalTo(kFitWidth(-50))
                }
            }
            
            // 3) 最后统一把骨架优雅淡出 + 内容淡入
            [imgView, orderIdLabel, titleLab,subTitleLab,bindDeviceLabel,orderTimeLabel,moneyLabel,payButton,timeoutButton,changeDeviceButton].forEach { $0.hideSkeletonWithCrossfade() }
        }
    }

    func updateCtime(cTime: String) {
        let attr = NSMutableAttributedString(string: "下单时间：")
        let attrTime = NSMutableAttributedString(string: cTime.replacingOccurrences(of: "T", with: " "))
        attr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        attrTime.yy_color = .COLOR_TEXT_TITLE_0f1214
        attr.append(attrTime)
        orderTimeLabel.attributedText = attr
        orderTimeLabel.isHidden = true
    }

    func updateDevice(phoneName: String) {
        let attr = NSMutableAttributedString(string: "绑定设备：")
        let attrTime = NSMutableAttributedString(string: phoneName.count > 0 ? phoneName : "-")
        attr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        attrTime.yy_color = .COLOR_TEXT_TITLE_0f1214
        attr.append(attrTime)
        bindDeviceLabel.attributedText = attr
        bindDeviceLabel.isHidden = false
    }

    func updateMoney(dict: NSDictionary) {
        let priceAttrUnit = NSMutableAttributedString(string: "¥ ")
        let priceAttrPrice = NSMutableAttributedString(string: dict.stringValueForKey(key: "payAmount"))
        priceAttrUnit.yy_color = .COLOR_TEXT_TITLE_0f1214
        priceAttrUnit.yy_font  = .systemFont(ofSize: 13, weight: .semibold)
        priceAttrPrice.yy_color = .COLOR_TEXT_TITLE_0f1214
        priceAttrPrice.yy_font  = .systemFont(ofSize: 16, weight: .semibold)
        priceAttrUnit.append(priceAttrPrice)
        if dict.doubleValueForKey(key: "discountAmount") > 0 {
            let priceAttrDiscount = NSMutableAttributedString(string: "已优惠¥\(dict.stringValueForKey(key: "discountAmount"))")
            priceAttrDiscount.yy_color = .THEME
            priceAttrDiscount.yy_font  = .systemFont(ofSize: 11, weight: .regular)
            priceAttrUnit.append(priceAttrDiscount)
        }
        moneyLabel.attributedText = priceAttrUnit
        moneyLabel.isHidden = true
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
}

// MARK: - Layout
extension OrderListTableViewCell {
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(orderIdLabel)
        bgView.addSubview(imgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(deleteIcon)
        bgView.addSubview(deleteTapView)
        bgView.addSubview(subTitleLab)
        bgView.addSubview(bindDeviceLabel)
        bgView.addSubview(orderTimeLabel)
        bgView.addSubview(moneyLabel)
        bgView.addSubview(lineView)
        bgView.addSubview(payButton)
        bgView.addSubview(timeoutButton)
        bgView.addSubview(changeDeviceButton)

        setConstrait()
    }

    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-12))
            make.top.equalToSuperview()
        }
        orderIdLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(4))
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-80))
            make.height.equalTo(kFitWidth(27))
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
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(121))
            make.top.equalTo(imgView)
            make.height.equalTo(kFitWidth(21))
            make.right.equalTo(kFitWidth(-16))
        }
        subTitleLab.snp.makeConstraints { make in
            make.left.right.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(3))
        }
        moneyLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.top.equalTo(subTitleLab.snp.bottom).offset(kFitWidth(6))
            make.right.equalTo(kFitWidth(-16))
        }
        bindDeviceLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(3))
            make.height.equalTo(kFitWidth(18))
        }
        orderTimeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLab)
            make.top.equalTo(bindDeviceLabel.snp.bottom).offset(kFitWidth(3))
            make.height.equalTo(kFitWidth(18))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(16))
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalToSuperview()
        }
        payButton.snp.makeConstraints { make in
            make.bottom.equalTo(kFitWidth(-10))
            make.width.equalTo(kFitWidth(102))
            make.height.equalTo(kFitWidth(30))
            make.right.equalTo(kFitWidth(-16))
        }
        changeDeviceButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-10))
            make.height.equalTo(kFitWidth(30))
            make.width.equalTo(kFitWidth(80))
        }
        timeoutButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-10))
            make.width.equalTo(kFitWidth(80))
            make.height.equalTo(kFitWidth(30))
        }
    }
}

