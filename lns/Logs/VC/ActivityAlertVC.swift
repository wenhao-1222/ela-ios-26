//
//  ActivityAlertVC.swift
//  lns
//
//  Created by LNS2 on 2025/12/8.
//
import Foundation
import UIKit
import Kingfisher
import SnapKit

class ActivityAlertVC: UIViewController {

    var whiteViewHeight = WHUtils().getBottomSafeAreaHeight()+kFitWidth(412)+kFitWidth(16)
    private var baseWhiteViewHeight: CGFloat = 0  // 👈 记录未拉伸时的高度

    var pushBlock:((String)->())?

    private var dictOne = NSDictionary()
    private var dictTwo = NSDictionary()
    private var pendingShow = false
    
    // 拖拽相关
    private var dragStartY: CGFloat = 0

    // imageView 相关约束
    private var imgTopConstraint: Constraint?
    private var imgBottomConstraint: Constraint?
    private var imgLeftConstraint: Constraint?
    private var imgRightConstraint: Constraint?

    private let maxStretchHeight: CGFloat = 80          // 手指往上最多拉多少
    private let maxImageTopLift: CGFloat = 6           // 图片顶部最多上移多少（控制“变长”）
    private let maxImageHorizontalInset: CGFloat = 5   // 图片左右最多收缩多少（控制“变窄”）

    private let dismissThreshold: CGFloat = 160         // 下滑多少关闭
    private let dismissVelocity: CGFloat = 900          // 下滑速度关闭
    
    /// 蒙层目标透明度：浅色 0.15，深色 0.85
    private var targetDimAlpha: CGFloat {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
        } else {
            return 0.25
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
           view.window != nil {
            UIView.animate(withDuration: 0.2) {
                self.bgView.alpha = self.targetDimAlpha
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = .clear
        initUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attemptShow()
    }

    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: view.bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK
        v.alpha = 0
        return v
    }()

    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        vi.alpha = 0

        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)

        // MARK: - Drag & Pan (关键)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        vi.addGestureRecognizer(pan)

        return vi
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(50)
        img.clipsToBounds = true
        img.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        img.layer.borderWidth = kFitWidth(1.5)
        img.contentMode = .scaleToFill   // 👈 保证图片完整显示，只是轻微变形
        return img
    }()


    lazy var confirmButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.backgroundColor = .COLOR_BG_WHITE
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(30)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()

    lazy var missButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.setTitleColor(WHColorWithAlpha(colorStr: "0F1214", alpha: 0.4), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return btn
    }()
}

// MARK: - Content Load
extension ActivityAlertVC {
    func updateUI(dict:NSDictionary) {
        let imgArr = dict["image"]as? NSArray ?? []
        if imgArr.count > 0 {
            self.dealButtonMsg(dict: dict)
            let imgUrl = imgArr[0]as? String ?? ""
            DSImageUploader().dealImgUrlSignForOss(urlStr: imgUrl) { signUrl in
                guard let resourceUrl = URL(string: signUrl) else { return }
                let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: imgUrl)

                self.imgView.kf.setImage(with: resource, options: [.transition(.fade(0.2))]) { [self] result in
                    let imgOriSize = imgView.image?.size
                    self.whiteViewHeight = SCREEN_WIDHT * ((imgOriSize?.height ?? 0) / (imgOriSize?.width ?? 1))
                    self.layoutWhiteViewFrame()
                    self.pendingShow = true
                    self.attemptShow()
                }
            }
        }
    }

    private func attemptShow() {
        guard pendingShow, isViewLoaded, view.window != nil else { return }
        pendingShow = false
        showView()
    }

    func dealButtonMsg(dict:NSDictionary) {
        let buttonArr = dict["button"]as? NSArray ?? []
        if buttonArr.count == 1 {
            dictOne = buttonArr[0]as? NSDictionary ?? [:]
            confirmButton.setTitle(dictOne.stringValueForKey(key: "text"), for: .normal)
            missButton.isHidden = true
            confirmButton.snp.remakeConstraints { make in
                make.width.equalTo(SCREEN_WIDHT-kFitWidth(40))
                make.height.equalTo(kFitWidth(60))
                make.centerX.lessThanOrEqualToSuperview()
                make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(37))
            }
        } else if buttonArr.count == 2 {
            dictOne = buttonArr[0]as? NSDictionary ?? [:]
            confirmButton.setTitle(dictOne.stringValueForKey(key: "text"), for: .normal)
            dictTwo = buttonArr[1]as? NSDictionary ?? [:]
            missButton.setTitle(dictTwo.stringValueForKey(key: "text"), for: .normal)
        }
    }
}

// MARK: - Show / Hide Animation
extension ActivityAlertVC {

    private func showView() {
        bgView.isUserInteractionEnabled = false
        
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0
        whiteView.alpha = 1

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

    @objc func hiddenView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}
extension ActivityAlertVC {
    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: whiteView)
        let velocity = pan.velocity(in: whiteView)

        switch pan.state {

        case .began:
            dragStartY = whiteView.transform.ty

        case .changed:
            let offsetY = dragStartY + translation.y

            if offsetY >= 0 {
                // =========👇 往下拖：整体跟手下移，准备关闭 =========
                whiteView.transform = CGAffineTransform(translationX: 0, y: offsetY)

                let progress = min(1, max(0, offsetY / baseWhiteViewHeight))
                bgView.alpha = targetDimAlpha * (1 - progress)

                // 下拉时：恢复到没有拉伸的状态（高度 & 约束）
                updateWhiteViewHeight(extraStretch: 0)
                resetImageStretch()
                view.layoutIfNeeded()

            } else {
                // =========👇 往上拖：whiteView 从顶部“长高”，图片变窄变长，底部不动 =========

                whiteView.transform = .identity
                bgView.alpha = targetDimAlpha

                let pullDistance = min(maxStretchHeight, -offsetY)     // 0 ~ maxStretchHeight
                let progress = pullDistance / maxStretchHeight         // 0 ~ 1

                // 1）whiteView 高度从顶部增加，底部位置不变
                let extraHeight = pullDistance * 0.6                   // 手感可以调：0.4~0.8 之间
                updateWhiteViewHeight(extraStretch: extraHeight)

                // 2）图片：top/bottom 固定，左右轻微收缩 => 视觉上更“瘦高”
                let horizontalInset = maxImageHorizontalInset * progress
                imgTopConstraint?.update(offset: 0)                    // 👈 不再往上拉出父视图
                imgBottomConstraint?.update(offset: kFitWidth(-13))    // 👈 底部永远在原来的位置
                imgLeftConstraint?.update(offset: horizontalInset)
                imgRightConstraint?.update(offset: -horizontalInset)

                view.layoutIfNeeded()
            }

        case .ended, .cancelled:

            // =====👇 检查是否需要下滑关闭 =====
            if translation.y > dismissThreshold || velocity.y > dismissVelocity {
                hiddenView()
                return
            }

            // =====👇 否则回弹到初始状态 =====
            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.8,
                options: [.curveEaseOut]
            ) {
                self.whiteView.transform = .identity
                self.bgView.alpha = self.targetDimAlpha

                self.updateWhiteViewHeight(extraStretch: 0)  // whiteView 高度复原
                self.resetImageStretch()                     // 图片约束复原

                self.view.layoutIfNeeded()
            }

        default:
            break
        }
    }
}

// MARK: - Drag & Pan Interaction（上下拖动效果）
extension ActivityAlertVC {
    @objc private func handlePandd(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: whiteView)
        let velocity = pan.velocity(in: whiteView)

        switch pan.state {

        case .began:
            dragStartY = whiteView.transform.ty

        case .changed:
            let offsetY = dragStartY + translation.y

            if offsetY >= 0 {
                // =========👇 往下拖：整体跟手下移，准备关闭 =========
                whiteView.transform = CGAffineTransform(translationX: 0, y: offsetY)

                let progress = min(1, max(0, offsetY / whiteViewHeight))
                bgView.alpha = targetDimAlpha * (1 - progress)

                // 下拉时把图片恢复成初始形态
                resetImageStretch()
                view.layoutIfNeeded()

            } else {
                // =========👇 往上拖：只做图片“轻微变窄变长”，底部不动 =========

                // whiteView 不整体上移，始终贴着底部
                whiteView.transform = .identity
                bgView.alpha = targetDimAlpha

                let pullDistance = min(maxStretchHeight, -offsetY)   // 0 ~ maxStretchHeight
                let progress = pullDistance / maxStretchHeight       // 0 ~ 1

                // 顶部轻微往上提一点（负值代表往上）
                let topLift = -maxImageTopLift * progress

                // 左右各往里收一点，图片看起来更“瘦高”
                let horizontalInset = maxImageHorizontalInset * progress

                imgTopConstraint?.update(offset: topLift)
                imgLeftConstraint?.update(offset: horizontalInset)
                imgRightConstraint?.update(offset: -horizontalInset)

                // 底部始终保持在 -13，不动
                imgBottomConstraint?.update(offset: kFitWidth(-13))

                view.layoutIfNeeded()
            }

        case .ended, .cancelled:

            // =====👇 检查是否需要下滑关闭 =====
            if translation.y > dismissThreshold || velocity.y > dismissVelocity {
                hiddenView()
                return
            }

            // =====👇 否则，回弹到初始状态（高度 & 位置）=====
            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.8,
                options: [.curveEaseOut]
            ) {
                self.whiteView.transform = .identity
                self.bgView.alpha = self.targetDimAlpha

                self.resetImageStretch()
                self.view.layoutIfNeeded()
            }

        default:
            break
        }
    }
    private func resetImageStretch() {
        imgTopConstraint?.update(offset: 0)
        imgLeftConstraint?.update(offset: 0)
        imgRightConstraint?.update(offset: 0)
        imgBottomConstraint?.update(offset: kFitWidth(-13))
        imgView.transform = .identity   // 理论上已经不用 transform，但留着兜底
    }
    /// 根据额外拉伸高度，实时调整 whiteView，高度从顶部变高，底部始终贴着屏幕
    private func updateWhiteViewHeight(extraStretch: CGFloat) {
        let height = baseWhiteViewHeight + extraStretch
        let bottomY = view.bounds.height
        whiteView.frame = CGRect(
            x: 0,
            y: bottomY - height,
            width: SCREEN_WIDHT,
            height: height
        )
    }
}

// MARK: - Actions
extension ActivityAlertVC {
    @objc func nothingAction() {}
    @objc func cancelAction() {
        if self.dictTwo.stringValueForKey(key: "iosTargetPage").count > 0 {
            self.pushBlock?(dictTwo.stringValueForKey(key: "iosTargetPage"))
        }
        self.hiddenView()
    }
    @objc func confirmAction() {
        if self.dictOne.stringValueForKey(key: "iosTargetPage").count > 0 {
            self.pushBlock?(dictOne.stringValueForKey(key: "iosTargetPage"))
        }
        self.hiddenView()
    }
}

// MARK: - Layout
extension ActivityAlertVC {
    func initUI() {
        view.addSubview(bgView)
        view.addSubview(whiteView)
        whiteView.addSubview(imgView)

        whiteView.addSubview(confirmButton)
        whiteView.addSubview(missButton)

        setConstrait()
        whiteView.transform = .identity
    }

    private func layoutWhiteViewFrame() {
        whiteView.transform = .identity
        whiteView.frame = CGRect(x: 0, y: view.bounds.height - whiteViewHeight,
                                 width: SCREEN_WIDHT,
                                 height: whiteViewHeight)
        baseWhiteViewHeight = whiteViewHeight   // 👈 记住“原始高度”，后面拉伸都基于这个算

        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            imgTopConstraint = make.top.equalToSuperview().constraint
            imgLeftConstraint = make.left.equalToSuperview().constraint
            imgRightConstraint = make.right.equalToSuperview().constraint
            imgBottomConstraint = make.bottom.equalTo(kFitWidth(-13)).constraint
        }

        confirmButton.snp.makeConstraints { make in
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(40))
            make.height.equalTo(kFitWidth(60))
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(imgView).offset(kFitWidth(-65))
        }

        missButton.snp.makeConstraints { make in
            make.width.equalTo(confirmButton)
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(confirmButton.snp.bottom).offset(kFitWidth(20))
            make.height.equalTo(kFitWidth(36))
        }
    }


}
