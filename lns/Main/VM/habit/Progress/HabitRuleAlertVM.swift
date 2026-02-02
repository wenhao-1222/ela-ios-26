//
//  HabitRuleAlertVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//


class RuleTextModel: NSObject {
    var contentStr : String = ""
    var isTitle    : Bool = false
    var bottomGap  : CGFloat = kFitWidth(-2)
    var contentType : String = "0"
    var imgString  : String = ""
    
    ///contentType  0   纯文字    1  纯图片   2  图 + 文
    func initModel(content:String,
                   isTitle:Bool=false,
                   bottomGap:CGFloat=kFitWidth(-2),
                   contentType:String="0",
                   imgString:String="") -> RuleTextModel {
        let model = RuleTextModel()
        model.contentStr = content
        model.isTitle = isTitle
        model.bottomGap = bottomGap
        model.contentType = contentType
        model.imgString = imgString
        
        return model
    }
}

import UIKit

class HabitRuleAlertVM: UIView {
    
    // MARK: - Layout constants
    var whiteViewHeight: CGFloat = kFitWidth(616) + WHUtils().getBottomSafeAreaHeight()
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
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "周末记录双倍积分"
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
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: kFitWidth(80), width: SCREEN_WIDHT, height: kFitWidth(470)), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(HabitRuleTableViewCell.classForCoder(), forCellReuseIdentifier: "HabitRuleTableViewCell")
        vi.register(HabitRuleTableViewImgCell.classForCoder(), forCellReuseIdentifier: "HabitRuleTableViewImgCell")
        vi.register(HabitRuleTableViewImgTextCell.classForCoder(), forCellReuseIdentifier: "HabitRuleTableViewImgTextCell")
        
        return vi
    }()
    lazy var dataSourceArray: [RuleTextModel] = {
        return [RuleTextModel().initModel(content: "根据elavatine数据显示，活跃用户中能做到周末记录，养成长期记录习惯（持续记录30天及以上）高达53.8%（无周末记录时：21.0%）",bottomGap: kFitWidth(-15)),
                RuleTextModel().initModel(content: "",bottomGap: kFitWidth(-15),contentType: "1",imgString: "habit_rule_img_1"),
                RuleTextModel().initModel(content: "缺失记录扣分", isTitle: true),
                RuleTextModel().initModel(content: "和养成习惯一样，短期记录缺失影响不大，但负面习惯累计越多，对坚持的影响就越大，所以当你连续未记录饮食时，积分的减少也是阶梯式的。"),
                RuleTextModel().initModel(content: "缺失记录1天扣1分，缺失2天在此基础上再扣2分，3天再扣3分，以此类推叠加。(7分封顶)",contentType: "2",imgString: "habit_rule_img_2")]  }()
}
// MARK: - Public API
extension HabitRuleAlertVM {
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

extension HabitRuleAlertVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSourceArray[indexPath.row]
        
        if model.contentType == "1"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "HabitRuleTableViewImgCell") as? HabitRuleTableViewImgCell
            cell?.updateUI(imgString: model.imgString,
                           bottomGap: model.bottomGap)
            
            return cell ?? HabitRuleTableViewImgCell()
        }else if model.contentType == "2"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "HabitRuleTableViewImgTextCell") as? HabitRuleTableViewImgTextCell
            cell?.updateUI(contentStr: model.contentStr,
                           imgString: model.imgString,
                           bottomGap: model.bottomGap)
            
            return cell ?? HabitRuleTableViewImgTextCell()
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "HabitRuleTableViewCell") as? HabitRuleTableViewCell
            cell?.updateUI(contentStr: model.contentStr, isTitle: model.isTitle, bottomGap: model.bottomGap)
            
            return cell ?? HabitRuleTableViewCell()
        }
    }
}

extension HabitRuleAlertVM{
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
        whiteView.addSubview(tableView)
        
        setConstrait()
        setupWhiteViewBorder()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
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

extension HabitRuleAlertVM{
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
