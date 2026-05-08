//
//  HabitExchangeTipsAlertVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/6.
//


import UIKit
import SnapKit

class HabitExchangeTipsAlertVM: UIView {
    
    // MARK: - Layout constants
    var whiteViewHeight: CGFloat = kFitWidth(650) //+ WHUtils().getBottomSafeAreaHeight()
    let whiteViewTopRadius: CGFloat = kFitWidth(50)
    private var topImgTopConstraint: Constraint?
    private var topImgHeightConstraint: Constraint?
    private var originalTopImageHeight: CGFloat = 0
    
    /// 蒙层目标透明度：浅色 0.15，深色 0.85
    private var targetDimAlpha: CGFloat {
        return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
    }
    // 主题变更时（例如从浅色切到深色）同步调整蒙层透明度
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
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
    lazy var bottomGapView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-kFitWidth(40), width: SCREEN_WIDHT, height: kFitWidth(40)))
        vi.backgroundColor = .black
        
        return vi
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
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.backgroundColor = .black
//        scro.bounces = false
        scro.alwaysBounceVertical = true
        scro.contentInsetAdjustmentBehavior = .never
        scro.delegate = self
        
        return scro
    }()
    lazy var topImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_exchange_tips_bg")
//        img.contentMode = .scaleAspectFit
        
        return img
    }()
    lazy var bottomImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_exchange_tips_ela_bg")
        img.contentMode = .scaleAspectFit
        return img
    }()
    lazy var elaImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_exchange_tips_title")
        return img
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
    lazy var tipsContentLabel: KeywordHighlightLabel = {
        let lab = KeywordHighlightLabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.preferredMaxLayoutWidth = lab.bounds.width
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = UIColor.white.withAlphaComponent(0.8)
        lab.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: kFitWidth(4), right: 0)
        lab.config.textColor = UIColor.white
        lab.config.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        
        return lab
    }()
    lazy var tipsContent2Label: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.preferredMaxLayoutWidth = lab.bounds.width
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = UIColor.white
        lab.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: kFitWidth(4), right: 0)
        
        return lab
    }()
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(12), y: kFitWidth(55), width: SCREEN_WIDHT-kFitWidth(56), height: kFitHeight(1)))
        vi.lineColor = UIColor.white.withAlphaComponent(0.2)
        return vi
    }()
    lazy var tipsDesLabel: UILabel = {
        let lab = UILabel()
        lab.text = "关于中国社会福利基金会免费午餐基金"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 13, weight: .semibold)
        return lab
    }()
    lazy var tipsDescriptLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .white.withAlphaComponent(0.8)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
}
// MARK: - Public API
extension HabitExchangeTipsAlertVM {
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
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: kFitWidth(0))
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

extension HabitExchangeTipsAlertVM{
    func updateUI() {
        tipsContentLabel.setText("2021年监测结果显示，仅在农村义务教育营养改善计划重点监测范围内，6至15岁学生消瘦率仍为9.8%，贫血率为12.0%，营养缺口依然真实存在，针对性的支持仍有必要。\n\nElavatine 关注运动与健康，也相信“健康不是从第一次训练开始，而是从每一天的饮食开始”。对儿童而言，一份更均衡的午餐能帮助他们更好地长身体，打基础，养成更稳定的生活方式与健康习惯。我们希望把“健身行业倡导的健康理念”向更早的成长阶段延伸，把资源投向真正需要的地方。",
                                    keywords: ["仅在农村义务教育营养改善计划重点监测范围内，6至15岁学生消瘦率仍为9.8%，贫血率为12.0%，",
                                              "健康不是从第一次训练开始，而是从每一天的饮食开始"])
        tipsDescriptLabel.setLineHeight(textString: "免费午餐基金是中国社会福利基金会下设专项基金，2011年4月2日发起，倡议公众捐赠，帮助乡村孩子免于课间饥饿。\n该项目累计在全国26个省市自治区1830所学校开餐，累计帮助超过44万人，目前开餐学校748所，每个开餐日有超过14万人在校用餐，并以师生同食，就地取材，透明公开，村校联合等原则执行与监督。",lineHeight: kFitWidth(20))
        
        let attr = NSMutableAttributedString(string: "每当你在「自律习惯养成」中兑换一餐", attributes: [.font : UIFont.systemFont(ofSize: 16, weight: .medium)])
        attr.append(NSAttributedString(string: "\n我们将代表你通过中国社会福利基金会免费午餐基金，向乡村困境学童捐出一份营养午餐。", attributes: [.font : UIFont.systemFont(ofSize: 13, weight: .regular)]))
//        tipsContent2Label.setLineHeight(attr: attr, lineHeight: kFitWidth(23))
        tipsContent2Label.attributedText = attr
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        dottedLineView.frame = CGRect.init(x: kFitWidth(29), y: tipsContent2Label.frame.maxY+kFitWidth(25), width: SCREEN_WIDHT-kFitWidth(58), height: kFitWidth(1))
        scrollView.contentSize = CGSize.init(width: 0, height: tipsDescriptLabel.frame.maxY+kFitWidth(90))
    }
}

extension HabitExchangeTipsAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(bottomGapView)
        addSubview(whiteView)
        whiteView.addSubview(scrollView)
        scrollView.addSubview(topImgView)
        scrollView.addSubview(elaImgView)
        scrollView.addSubview(bottomImgView)
        
        whiteView.addSubview(closeIconImgView)
        whiteView.addSubview(closeTapView)
        
        scrollView.addSubview(tipsContentLabel)
        scrollView.addSubview(tipsContent2Label)
        scrollView.addSubview(dottedLineView)
        scrollView.addSubview(tipsDesLabel)
        scrollView.addSubview(tipsDescriptLabel)
        
        setConstrait()
        updateUI()
    }
    func setConstrait() {
        scrollView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        topImgView.snp.makeConstraints { make in
//            make.left.top.width.equalToSuperview()
            make.left.equalToSuperview()
            topImgTopConstraint = make.top.equalToSuperview().constraint
            make.width.equalToSuperview()
            topImgHeightConstraint = make.height.equalTo(kFitWidth(300)).constraint
        }
        elaImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(29))
            make.top.equalTo(kFitWidth(77))
        }
        closeIconImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-25))
            make.width.height.equalTo(kFitWidth(25))
            make.top.equalTo(kFitWidth(25))
        }
        closeTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(closeIconImgView)
            make.width.height.equalTo(kFitWidth(75))
        }
        tipsContentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(29))
//            make.right.equalTo(kFitWidth(-29))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(58))
            make.top.equalTo(kFitWidth(203))
        }
        tipsContent2Label.snp.makeConstraints { make in
            make.left.width.equalTo(tipsContentLabel)
            make.top.equalTo(tipsContentLabel.snp.bottom).offset(kFitWidth(20))
        }
//        dottedLineView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(29))
//            make.right.equalTo(kFitWidth(-29))
//            make.top.equalTo(tipsContentLabel.snp.bottom).offset(kFitWidth(24))
//            make.height.equalTo(kFitWidth(2))
//        }
        tipsDesLabel.snp.makeConstraints { make in
            make.left.right.equalTo(tipsContent2Label)
            make.top.equalTo(tipsContent2Label.snp.bottom).offset(kFitWidth(50))
        }
        tipsDescriptLabel.snp.makeConstraints { make in
            make.left.right.equalTo(tipsContentLabel)
            make.top.equalTo(tipsDesLabel.snp.bottom).offset(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-90))
        }
        bottomImgView.snp.makeConstraints { make in
            make.left.equalToSuperview()
//            make.bottom.equalTo(tipsDescriptLabel).offset(kFitWidth(90))
            make.width.equalTo(SCREEN_WIDHT)
            make.top.equalTo(tipsContent2Label.snp.bottom).offset(kFitWidth(81))
        }
    }
}

extension HabitExchangeTipsAlertVM{
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

extension HabitExchangeTipsAlertVM: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === self.scrollView else { return }

        if originalTopImageHeight == 0 {
            originalTopImageHeight = topImgView.frame.height
//            topImgHeightConstraint?.update(offset: originalTopImageHeight)
        }

        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            topImgTopConstraint?.update(offset: offsetY)
//            topImgHeightConstraint?.update(offset: originalTopImageHeight - offsetY)
        } else {
            topImgTopConstraint?.update(offset: 0)
//            topImgHeightConstraint?.update(offset: originalTopImageHeight)
        }
    }
}
