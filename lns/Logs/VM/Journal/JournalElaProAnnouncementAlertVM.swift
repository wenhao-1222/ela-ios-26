//
//  JournalElaProAnnouncementAlertVM.swift
//  lns
//
//  Created by Codex on 2026/4/16.
//


class JournalElaProAnnouncementAlertVM: UIView {
    
    // MARK: - Layout constants
    var whiteViewHeight: CGFloat = kFitWidth(566) + WHUtils().getBottomSafeAreaHeight()
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
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "journal_ela_pro_announcement_bg")
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        return img
    }()
    lazy var titleImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_expired_alert_icon")
        return img
    }()
    lazy var closeIconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "alert_close_icon")
        return img
    }()
    lazy var titleImgIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_tips_label_icon")
        img.contentMode = .scaleAspectFit
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
    lazy var contentLabelOne: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .light)
        lab.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
//        paragraphStyle.alignment = .center
        let text = "为了让 Elavatine 能够持续探索更极致、更能帮助高效增肌减脂的功能，同时为了支撑最新的「自律习惯养成 x Elavatine捐赠计划」，我们推出了 ELA PRO。\n\n这里面包含了研发和算力投入最大的「AI教练」与「智能饮食计划2.0」，同时会持续加入那些我们一直想加入、却因过去商业模式不允许而搁置的功能。\n\n用户规模的扩大确实带来了更高的服务器与维护成本，"

        let textBold = "但这不影响我们最初的决定：原本所有的免费功能，都将继续无条件免费。"
        var attr = NSMutableAttributedString(string: text, attributes: [
            .font: lab.font as Any,
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
            .paragraphStyle: paragraphStyle
        ])
        attr.append(NSAttributedString(string: textBold,attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
            .paragraphStyle: paragraphStyle
        ]))
        lab.attributedText = attr
        
        return lab
    }()
    lazy var dottLineView: DottedLineView = {
        let vi = DottedLineView()
        return vi
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "感谢大家一直以来的见证与支持。\n\nElavatine团队"
        lab.font = .systemFont(ofSize: 12, weight: .light)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.numberOfLines = 0
        
        return lab
    }()
}

extension JournalElaProAnnouncementAlertVM {
    @objc func nothingToDo() { /* 吞点击 */ }
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
extension JournalElaProAnnouncementAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(whiteBlurView)
        whiteView.addSubview(bgImgView)
        whiteView.addSubview(titleImgView)
        whiteView.addSubview(titleImgIcon)
        whiteView.addSubview(closeIconImgView)
        whiteView.addSubview(closeTapView)
        whiteView.addSubview(contentLabelOne)
        whiteView.addSubview(dottLineView)
        whiteView.addSubview(tipsLabel)
        
        setConstrait()
    }
    func setConstrait() {
        whiteBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        titleImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(29))
            make.top.equalTo(kFitWidth(78))
            make.width.equalTo(kFitWidth(137))
            make.height.equalTo(kFitWidth(24))
        }
        titleImgIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(30))
            make.top.equalTo(titleImgView.snp.bottom).offset(kFitWidth(15))
            make.width.equalTo(kFitWidth(85))
            make.height.equalTo(kFitWidth(20))
        }
        closeIconImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-25))
            make.top.width.height.equalTo(kFitWidth(25))
//            make.centerY.lessThanOrEqualTo(titleImgView)
        }
        closeTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(closeIconImgView)
            make.width.height.equalTo(kFitWidth(75))
        }
        contentLabelOne.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(29))
            make.right.equalTo(kFitWidth(-29))
            make.top.equalTo(kFitWidth(203))
        }
        dottLineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(29))
            make.right.equalTo(kFitWidth(-29))
            make.height.equalTo(kFitWidth(1))
            make.top.equalTo(contentLabelOne.snp.bottom).offset(kFitWidth(20))
        }
        tipsLabel.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
            make.left.right.equalTo(dottLineView)
            make.top.equalTo(dottLineView.snp.bottom).offset(kFitWidth(25))
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
