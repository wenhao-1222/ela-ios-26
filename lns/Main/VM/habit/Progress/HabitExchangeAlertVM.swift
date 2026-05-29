//
//  HabitExchangeAlertVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/25.
//

import UIKit
import MCToast

class HabitExchangeAlertVM: UIView {
    
    // MARK: - Layout constants
    var whiteViewHeight: CGFloat = kFitWidth(385) + WHUtils().getBottomSafeAreaHeight()
    let whiteViewTopRadius: CGFloat = kFitWidth(50)
    
    var exchangeBlock:(()->())?
    
    var msgDict = NSDictionary()
    ///兑换多少餐
    var num = 1
    ///兑换一餐所需积分
    var pointCostPerDonate = 1
    ///当前总剩余积分
    var pointBalance = 1
    /// 积分兑换额度是否用尽
    var isDonateLimitExceeded = false
    /// 积分兑换额度用尽提示文案
    var donateLimitExceededText = ""
    
    /// 蒙层目标透明度：浅色 0.15，深色 0.85
    private var targetDimAlpha: CGFloat {
        return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
    }
    // 主题变更时（例如从浅色切到深色）同步调整蒙层透明度
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupWhiteViewBorder()
        UIView.animate(withDuration: 0.2) {
            self.bgView.alpha = self.targetDimAlpha
        }
    }
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isHidden = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateWhiteViewBorderFrame()
    }

    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK//WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    private lazy var whiteView: UIView = {
        // 先用默认高度创建，后面 dealData() 会重算高度并设置 frame
        let vi = UIView(frame: CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight))
//        vi.backgroundColor = .COLOR_CARD_BG_WHITE_ALERT
        vi.backgroundColor = .clear
//        vi.layer.cornerRadius = whiteViewTopRadius
        vi.addClipCorner(corners: [.topLeft,.topRight], radius: whiteViewTopRadius)
        if #available(iOS 13.0, *) { vi.layer.cornerCurve = .continuous }
        vi.layer.masksToBounds = true
        
        // 吞掉点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)

        // 下拉关闭
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        vi.addGestureRecognizer(pan)
        
        return vi
    }()
    
    private lazy var whiteBlurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.contentView.backgroundColor = UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0.05)
        return view
    }()
    private let whiteBorderGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.locations = [0, 1]
        return layer
    }()
    private let whiteBorderMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 1
        return layer
    }()
    
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        btn.setTitle("确认兑换", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(exchangeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "选择兑换数量"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        
        return lab
    }()
    lazy var closeIconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "alert_close_icon")
        return img
    }()
    lazy var closeTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var numberBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(22.5)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var numerLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.text = "\(num)"
        
        return lab
    }()
    lazy var subImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_number_sub_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var addImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_number_add_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var subTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(subAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var addTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(addAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(32), y: kFitWidth(188), width: SCREEN_WIDHT-kFitWidth(64), height: kFitHeight(1)))
        
        return vi
    }()
    lazy var needPointLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "需要积分"
        
        return lab
    }()
    lazy var needPointLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "900"
        
        return lab
    }()
    lazy var pointLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "兑换后剩余"
        
        return lab
    }()
    lazy var pointLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "600"
        
        return lab
    }()
    lazy var dailyDonateLimitExceededLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.isHidden = true

        return lab
    }()
}
// MARK: - Public API
extension HabitExchangeAlertVM {
    func showSelf() {
        isHidden = false

        bgView.isUserInteractionEnabled = false
        
        // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0

        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.bgView.alpha = self.targetDimAlpha
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
    }

    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
    @objc func exchangeAction() {
        if isDonateLimitExceeded {
            return
        }
        if pointBalance - pointCostPerDonate * num < 0{
            MCToast.mc_text("积分不足")
            return
        }
        self.hiddenSelf()
        self.exchangeBlock?()
    }
}

extension HabitExchangeAlertVM{
    func updateUI(dict:NSDictionary,num:Int=1) {
        msgDict = dict
        pointBalance = msgDict.stringValueForKey(key: "pointBalance").intValue
        pointCostPerDonate = dict.stringValueForKey(key: "pointCostPerDonate").intValue
        isDonateLimitExceeded = dict.stringValueForKey(key: "isDonateLimitExceeded").intValue == 1
        donateLimitExceededText = dict.stringValueForKey(key: "donateLimitExceededText")
        dailyDonateLimitExceededLab.text = donateLimitExceededText
        dailyDonateLimitExceededLab.isHidden = !isDonateLimitExceeded//!isDonateLimitExceeded || donateLimitExceededText.isEmpty
        calculatePoint()
        updateConfirmButtonState()
    }
    func calculatePoint() {
        needPointLabel.text = "\(pointCostPerDonate * num)"
        var pointBalanceAfter = pointBalance - pointCostPerDonate * num
        if pointBalanceAfter < 0{
            pointBalanceAfter = 0
        }
        pointLabel.text = "\(pointBalanceAfter)"
        numerLabel.text = "\(num)"
    }
    func updateConfirmButtonState() {
        let isPointEnough = pointBalance >= pointCostPerDonate * num
        let isEnabled : Bool
        
        if isPointEnough{
            if isDonateLimitExceeded{
                isEnabled = false
            }else{
                isEnabled = true
            }
        }else{
            isEnabled = false
        }
        
//        let isEnabled = isPointEnough && !isDonateLimitExceeded
        confirmButton.backgroundColor = isEnabled ? .THEME : .COLOR_BUTTON_DISABLE_BG_THEME
        confirmButton.isEnabled = isEnabled
    }
    @objc func addAction() {
        if num >= 99 {
            num = 99
            return
        }
        if pointBalance - pointCostPerDonate * (num + 1) < 0{
            return
        }
        num += 1
        calculatePoint()
        updateConfirmButtonState()
    }
    @objc func subAction() {
        if num <= 1{
            num = 1
            return
        }
        num -= 1
        calculatePoint()
        updateConfirmButtonState()
    }
}

extension HabitExchangeAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        
        whiteView.addSubview(whiteBlurView)
        whiteBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        whiteView.addSubview(confirmButton)
        
        whiteView.addSubview(titleLab)
        whiteView.addSubview(closeIconImgView)
        whiteView.addSubview(closeTapView)
        
        whiteView.addSubview(numberBgView)
        numberBgView.addSubview(numerLabel)
        numberBgView.addSubview(subImgView)
        numberBgView.addSubview(addImgView)
        
        whiteView.addSubview(subTapView)
        whiteView.addSubview(addTapView)
        
        whiteView.addSubview(dottedLineView)
        
        whiteView.addSubview(needPointLab)
        whiteView.addSubview(needPointLabel)
        whiteView.addSubview(pointLab)
        whiteView.addSubview(pointLabel)
        whiteView.addSubview(dailyDonateLimitExceededLab)
        
        setConstrait()
        setupWhiteViewBorder()
    }
    func setConstrait() {
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(kFitWidth(-5)-WHUtils().getBottomSafeAreaHeight())
        }
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(25))
            make.height.equalTo(kFitWidth(25))
        }
        closeIconImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-25))
            make.width.height.equalTo(kFitWidth(25))
            make.centerY.lessThanOrEqualTo(titleLab)
        }
        closeTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(closeIconImgView)
            make.width.height.equalTo(kFitWidth(75))
        }
        numberBgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(170))
            make.height.equalTo(kFitWidth(45))
            make.top.equalTo(kFitWidth(103))
        }
        subImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(14))
            make.height.equalTo(kFitWidth(3))
        }
        addImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-15))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(14))
        }
        subTapView.snp.makeConstraints { make in
            make.left.top.equalTo(numberBgView).offset(kFitWidth(-10))
            make.bottom.equalTo(numberBgView).offset(kFitWidth(10))
            make.width.equalTo(kFitWidth(65))
        }
        addTapView.snp.makeConstraints { make in
            make.right.bottom.equalTo(numberBgView).offset(kFitWidth(10))
            make.top.equalTo(kFitWidth(-10))
            make.width.equalTo(kFitWidth(65))
        }
        numerLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
        }
        needPointLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(208))
            make.height.equalTo(kFitWidth(20))
        }
        needPointLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-32))
            make.centerY.lessThanOrEqualTo(needPointLab)
        }
        pointLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(needPointLab.snp.bottom).offset(kFitWidth(10))
            make.height.equalTo(kFitWidth(20))
        }
        pointLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-32))
            make.centerY.lessThanOrEqualTo(pointLab)
        }
        dailyDonateLimitExceededLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.bottom.equalTo(confirmButton.snp.top).offset(kFitWidth(-18))
        }
    }
    private func setupWhiteViewBorder() {
        //color_text_white_d234_50
        if traitCollection.userInterfaceStyle == .dark{
            whiteBorderGradientLayer.colors = [WHColorWithAlpha(colorStr: "D2D3D4", alpha: 0.5).cgColor,
                                               WHColorWithAlpha(colorStr: "D2D3D4", alpha: 0).cgColor]
        }else{
            whiteBorderGradientLayer.colors = [WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5).cgColor,
                                               WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5).cgColor]
        }
        
        whiteBorderGradientLayer.mask = whiteBorderMaskLayer
        whiteView.layer.addSublayer(whiteBorderGradientLayer)
        updateWhiteViewBorderFrame()
    }

    private func updateWhiteViewBorderFrame() {
        whiteBorderGradientLayer.frame = whiteView.bounds

        let inset = whiteBorderMaskLayer.lineWidth / 2
        let pathRect = whiteView.bounds.insetBy(dx: inset, dy: inset)
        whiteBorderMaskLayer.path = UIBezierPath(roundedRect: pathRect,
                                                 cornerRadius: whiteViewTopRadius - inset).cgPath
    }
}

extension HabitExchangeAlertVM{
    @objc func nothingToDo() { /* 吞点击 */ }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        guard gesture.view === whiteView else { return }

        let translation = gesture.translation(in: whiteView)
        gesture.setTranslation(.zero, in: whiteView)

        switch gesture.state {
        case .changed:
            // 只允许向下拖动（ty >= 0）
            let currentTy = whiteView.transform.ty
            var newTy = currentTy + translation.y
            newTy = max(0, min(whiteViewHeight, newTy))
            whiteView.transform = CGAffineTransform(translationX: 0, y: newTy)

            // 同步调低蒙层
            let progress = min(1, max(0, newTy / whiteViewHeight))
            bgView.alpha = self.targetDimAlpha * (1 - progress)

        case .ended, .cancelled, .failed:
            let ty = whiteView.transform.ty
            let velocity = gesture.velocity(in: whiteView).y
            let threshold = kFitWidth(50)

            // 根据拖动距离或下滑速度决定收起
            if ty >= threshold || velocity > 800 {
                hiddenSelf()
            } else {
                // 回弹
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self.whiteView.transform = .identity
                    self.bgView.alpha = self.targetDimAlpha
                }
            }
        default:
            break
        }
    }
}
