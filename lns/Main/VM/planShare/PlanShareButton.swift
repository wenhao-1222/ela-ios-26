//
//  PlanShareButton.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation


class PlanShareButton : UIButton{
    
    var tapBlock:(()->())?
    
    var labelColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let feedbackWeight: CGFloat = 0.6
    private var lastFeedbackTime: TimeInterval = 0
    private let minimumFeedbackInterval: TimeInterval = 0.1
    
    override init(frame: CGRect) {
       super.init(frame: frame)
       setupButton()
   }

   required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       setupButton()
   }
    
    lazy var imgView : UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: kFitWidth(10), y: 0, width: kFitWidth(40), height: kFitWidth(40)))
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var contenLab : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(-10), y: kFitWidth(48), width: kFitWidth(80), height: kFitWidth(14)))
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.isUserInteractionEnabled = true
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
    lazy var coverVi : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(9), y: 0, width: kFitWidth(40), height: kFitWidth(40)))
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.04)
        vi.isHidden = true
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        return vi
    }()

    func updateImgFrame() {
        
    }
   private func setupButton() {
       // 设置按钮的其他属性，如颜色、字体等
       
       addSubview(imgView)
       addSubview(contenLab)
       addSubview(coverVi)
       
//       let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
//       self.addGestureRecognizer(tap)
   }
    
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
        contenLab.textColor = labelColor
        coverVi.isHidden = true
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        TouchGenerator.shared.touchGenerator()
//        contenLab.textColor = .COLOR_HIGHTLIGHT_GRAY
//        coverVi.isHidden = false
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        contenLab.textColor = labelColor
//        coverVi.isHidden = true
//    }
//    override var isHighlighted: Bool {
//       didSet {
//           if isHighlighted {
//               // 当按钮被高亮时，更改按钮的状态，如颜色等
//               contenLab.textColor = .COLOR_HIGHTLIGHT_GRAY
//               coverVi.isHidden = false
//           } else {
//               // 当按钮高亮状态结束时，恢复按钮的原始状态
//               contenLab.textColor = labelColor
//               coverVi.isHidden = true
//           }
//       }
//   }
    
}


extension PlanShareButton{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let scale: CGFloat = 0.95
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
//        showPressRippleEffect()
//        feedbackGenerator.impactOccurred(intensity: feedbackWeight)
        triggerImpact(feedbackGenerator, intensity: feedbackWeight)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
        if let touch = touches.first, self.bounds.contains(touch.location(in: self)) {
//            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.9)
            triggerImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
            tapAction()
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
        guard now - lastFeedbackTime > minimumFeedbackInterval else { return }
        generator.impactOccurred(intensity: intensity)
        lastFeedbackTime = now
    }
}

