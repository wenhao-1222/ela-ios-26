//
//  RippleAnimationView.swift
//  lns
//
//  Created by Elavatine on 2025/3/7.
//
class RippleAnimationView: UIView {
    // 配置参数
    private let animationDuration: TimeInterval = 1.2
    private let rippleColor: UIColor = UIColor.white.withAlphaComponent(0.7)
    private let rippleCount = 3
    private let rippleInterval: TimeInterval = 0.3
    
    // 图层容器
    private var rippleLayers = [CAShapeLayer]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        for _ in 0..<rippleCount {
            let layer = CAShapeLayer()
            layer.strokeColor = rippleColor.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 2
            layer.opacity = 0
            self.layer.addSublayer(layer)
            rippleLayers.append(layer)
        }
    }
//    // 可配置参数
//    var rippleColor: UIColor = UIColor.white.withAlphaComponent(0.7) {
//        didSet { updateLayerColors() }
//    }
//    
//    var lineWidth: CGFloat = 2 {
//        didSet { updateLineWidth() }
//    }
//    
//    // 更新图层颜色
//    private func updateLayerColors() {
//        rippleLayers.forEach { $0.strokeColor = rippleColor.cgColor }
//    }
//    
//    // 更新线条宽度
//    private func updateLineWidth() {
//        rippleLayers.forEach { $0.lineWidth = lineWidth }
//    }
}

extension RippleAnimationView {
    func startAnimation() {
        let baseRect = bounds.insetBy(dx: 10, dy: 10)
        
        for (index, layer) in rippleLayers.enumerated() {
            // 计算每个圆形的路径
            let inset = CGFloat(index) * (baseRect.width/2)/CGFloat(rippleCount)
            let rect = baseRect.insetBy(dx: inset, dy: inset)
            layer.path = UIBezierPath(ovalIn: rect).cgPath
            
            // 配置动画组
            let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
            scaleAnim.fromValue = 0.0
            scaleAnim.toValue = 1.2
            
            let opacityAnim = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim.values = [0.8, 0.4, 0]
            
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [scaleAnim, opacityAnim]
            animationGroup.duration = animationDuration
            animationGroup.beginTime = CACurrentMediaTime() + Double(index) * rippleInterval
            animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animationGroup.repeatCount = .infinity
            
            layer.add(animationGroup, forKey: "rippleGroup")
        }
    }
    
    func stopAnimation() {
        rippleLayers.forEach { $0.removeAllAnimations() }
    }
}
