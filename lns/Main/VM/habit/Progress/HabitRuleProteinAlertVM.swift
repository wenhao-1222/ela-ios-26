//
//  HabitRuleProteinAlertVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//


import UIKit

class HabitRuleProteinAlertVM: UIView {
    
    // MARK: - Layout constants
    var whiteViewHeight: CGFloat = kFitWidth(690) + WHUtils().getBottomSafeAreaHeight()
    let whiteViewTopRadius: CGFloat = kFitWidth(50)
    
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
        if SCREEN_HEIGHT < kFitWidth(680){
            whiteViewHeight = kFitWidth(616) + WHUtils().getBottomSafeAreaHeight()
        }
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
        vi.isUserInteractionEnabled = true
        
        // 吞掉点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)

        // 下拉关闭
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        vi.addGestureRecognizer(pan)
        
        return vi
    }()
    
    private lazy var whiteBlurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemChromeMaterial)
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

    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.showsVerticalScrollIndicator = false
        return scro
    }()
    lazy var ruleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.adjustsFontSizeToFitWidth = true
        let attr = NSMutableAttributedString(string: "规则：",
                                             attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
                                                                        .font:UIFont.systemFont(ofSize: 16, weight: .semibold)])
        let attr1 = NSMutableAttributedString(string: "在当日完整饮食记录后，本日蛋白质摄入≥蛋白质目标",
                                             attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
                                                                        .font:UIFont.systemFont(ofSize: 16, weight: .regular)])
        
        attr.append(attr1)
        lab.attributedText = attr
        
        return lab
    }()
    lazy var dottlineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(32), y: kFitWidth(110), width: SCREEN_WIDHT-kFitWidth(64), height: kFitHeight(1)))
        return vi
    }()
    lazy var tipsLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "无论增肌还是减脂\n摄入足够的蛋白质都十分关键"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.numberOfLines = 2
        lab.font = .systemFont(ofSize: 17, weight: .semibold)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var tipsLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "生活中难免外食或聚餐，脂肪和碳水可能会临时上下浮动，而蛋白质需求相对稳定。\n我们选择蛋白质作为每日目标，因为这更符合日常饮食习惯。"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.numberOfLines = 4
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "rule_journal_alert_img_protein")
        
        return img
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        btn.setTitle("知道了", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        
        return btn
    }()
}
// MARK: - Public API
extension HabitRuleProteinAlertVM {
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
}

extension HabitRuleProteinAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        
        whiteView.addSubview(whiteBlurView)
        whiteBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        whiteView.addSubview(scrollView)
        scrollView.addSubview(ruleLab)
        scrollView.addSubview(dottlineView)
        scrollView.addSubview(tipsLab)
        scrollView.addSubview(tipsLabel)
        scrollView.addSubview(imgView)
        whiteView.addSubview(confirmButton)
        
        setConstrait()
        setupWhiteViewBorder()
        
        setNeedsLayout()
        layoutIfNeeded()
        scrollView.contentSize = CGSizeMake(0, imgView.frame.maxY+kFitWidth(5))
//        scrollView.contentSize = CGSize.init(width: 0, height: kFitWidth(650))
    }
    func setConstrait() {
        scrollView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
//            make.width.equalTo(SCREEN_WIDHT)
            make.bottom.equalTo(confirmButton.snp.top).offset(kFitWidth(-10))
        }
        ruleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
//            make.right.equalTo(kFitWidth(-32))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(64))
            make.top.equalTo(kFitWidth(30))
            make.height.equalTo(kFitWidth(55))
        }
        tipsLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
//            make.right.equalTo(kFitWidth(-30))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(64))
            make.top.equalTo(kFitWidth(135))
            make.height.equalTo(kFitWidth(52))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
//            make.right.equalTo(kFitWidth(-32))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(64))
            make.top.equalTo(kFitWidth(202))
        }
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
//            make.top.equalTo(kFitWidth(317))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(20))
            make.width.equalTo(kFitWidth(311))
            make.height.equalTo(kFitWidth(319))
        }
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(kFitWidth(-5)-WHUtils().getBottomSafeAreaHeight())
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

extension HabitRuleProteinAlertVM{
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
