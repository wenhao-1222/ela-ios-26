//
//  SolidRippleView.swift
//  lns
//
//  Created by Elavatine on 2025/3/7.
//

class SolidRippleView: UIView {
    // 配置参数
    private let animationDuration: TimeInterval = 2.5
    private let rippleColor: UIColor = UIColor.white.withAlphaComponent(0.7)
    private let rippleCount = 3
    private let rippleDelay: TimeInterval = 0.8
    private let maxScale: CGFloat = 12.5
    private var rippleCenter = CGPoint()
    private let circleOriginWidth = kFitWidth(50)
    
    private var rippleLayers = [CALayer]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        rippleCenter = CGPoint(x: frame.midX, y: frame.midY)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    func refreshCenter(y:CGFloat) {
//        rippleCenter = CGPoint(x: SCREEN_WIDHT*0.5, y: y)
        setupLayers()
    }
    private func setupLayers() {
        for _ in 0..<rippleCount {
            let layer = CALayer()
            layer.backgroundColor = rippleColor.cgColor
//            layer.frame = CGRect.init(origin: rippleCenter, size: CGSize(width: circleOriginWidth, height: circleOriginWidth))
            layer.frame = CGRect.init(x: SCREEN_WIDHT*0.5-circleOriginWidth*0.5, y: bounds.height*0.5-circleOriginWidth*0.5, width: circleOriginWidth, height: circleOriginWidth)
            layer.cornerRadius = circleOriginWidth*0.5
            layer.opacity = 0
            self.layer.addSublayer(layer)
            rippleLayers.append(layer)
        }
    }
}

// 动画扩展
extension SolidRippleView {
    func startAnimation() {
        let baseScale = maxScale
        
        for (index, layer) in rippleLayers.enumerated() {
            // 重置状态
            layer.removeAllAnimations()
            layer.transform = CATransform3DIdentity
            layer.opacity = 0
            
            // 缩放动画
            let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
            scaleAnim.fromValue = 1.0
            scaleAnim.toValue = baseScale
            
            // 透明度动画
            let opacityAnim = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim.values = [0.8, 0.4, 0]
            
            // 组合动画
            let group = CAAnimationGroup()
            group.animations = [scaleAnim, opacityAnim]
            group.duration = animationDuration
            group.beginTime = CACurrentMediaTime() + Double(index) * rippleDelay
            group.timingFunction = CAMediaTimingFunction(name: .easeOut)
            group.repeatCount = .infinity
            
            layer.add(group, forKey: "solidRipple")
        }
    }
    
    func stopAnimation() {
        rippleLayers.forEach {
            $0.removeAllAnimations()
            $0.opacity = 0
        }
    }
}
