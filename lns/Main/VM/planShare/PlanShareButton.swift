//
//  PlanShareButton.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation


/// MARK: - 统一封装的可点击分享按钮
class PlanShareButton : UIButton {
    
    var tapBlock:(()->())?
    
    var labelColor = UIColor.COLOR_TEXT_WHITE.withAlphaComponent(0.65)//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let feedbackWeight: CGFloat = 0.6
    private var lastFeedbackTime: TimeInterval = 0
    private let minimumFeedbackInterval: TimeInterval = 0.1

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton() // [修改] 在 setup 里统一 addTarget，确保所有 init 路径都生效
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton() // [修改]
    }
    
    lazy var imgView : UIImageView = {
        let img = UIImageView(frame: CGRect(x: kFitWidth(10), y: 0, width: kFitWidth(40), height: kFitWidth(40)))
        img.isUserInteractionEnabled = false // [修改] 子视图不参与交互，避免抢事件
        return img
    }()
    lazy var contenLab : UILabel = {
        let lab = UILabel(frame: CGRect(x: kFitWidth(-10), y: kFitWidth(48), width: kFitWidth(80), height: kFitWidth(14)))
        lab.textColor = .COLOR_TEXT_WHITE.withAlphaComponent(0.65)//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.isUserInteractionEnabled = false // [修改]
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
    lazy var coverVi : UIView = {
        let vi = UIView(frame: CGRect(x: kFitWidth(9), y: 0, width: kFitWidth(40), height: kFitWidth(40)))
        vi.backgroundColor = .COLOR_BG_WHITE.withAlphaComponent(0.04)//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.04)
        vi.isHidden = true
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = false // [修改]
        return vi
    }()

    func updateImgFrame() { }

    private func setupButton() {
        addSubview(imgView)
        addSubview(contenLab)
        addSubview(coverVi)

        // [修改] 使用 UIButton 标准点击事件，避免手势/坐标系带来的歧义
        addTarget(self, action: #selector(tapAction), for: .touchUpInside)
    }
    
    @objc func tapAction() {
        tapBlock?()
        contenLab.textColor = labelColor
        coverVi.isHidden = true
        
        // [可选] 点击成功时再给一次更强的触感反馈
        triggerImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
    }
}

// MARK: - 触摸动效与触感
extension PlanShareButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let scale: CGFloat = 0.95
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        triggerImpact(feedbackGenerator, intensity: feedbackWeight)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        // [保留] 只负责视觉还原；不在这里手动调用 tapAction（由 .touchUpInside 统一触发）
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }

    private func showPressRippleEffect() {
        let size = max(bounds.width, bounds.height)
        guard size > 0 else { return }
        let frame = CGRect(x: (bounds.width - size) / 2,
                           y: (bounds.height - size) / 2,
                           width: size,
                           height: size)

        let rippleLayer = CALayer()
        rippleLayer.frame = frame
        rippleLayer.cornerRadius = size / 2
        rippleLayer.backgroundColor = UIColor.THEME.withAlphaComponent(0.2).cgColor
        layer.insertSublayer(rippleLayer, at: 0)

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0.3
        scaleAnim.toValue = 1.4

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0.5
        opacityAnim.toValue = 0.0

        let group = CAAnimationGroup()
        group.animations = [scaleAnim, opacityAnim]
        group.duration = 0.5
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            rippleLayer.removeFromSuperlayer()
        }
        rippleLayer.add(group, forKey: "ripple")
        CATransaction.commit()
    }
    
    private func triggerImpact(_ generator: UIImpactFeedbackGenerator, intensity: CGFloat) {
        let now = Date().timeIntervalSince1970
        // 防抖，避免同一帧多次触发
        if now - lastFeedbackTime <= minimumFeedbackInterval { return }
        generator.impactOccurred(intensity: intensity)
        lastFeedbackTime = now
    }
}
