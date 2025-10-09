//
//  RippleView.swift
//  lns
//
//  Created by Elavatine on 2025/6/9.
//

import UIKit

class RippleView: UIView {
    
    private let replicator = CAReplicatorLayer()
    private let rippleLayer = CALayer()
    
    /// 配置 replicator & 单个圆圈
    private func setupLayers() {
        // 动画参数
        let animationDuration: CFTimeInterval = 2.0
        let initialRadius: CGFloat = 11.0
        let finalRadius: CGFloat = 22//19.0
        
        // 1. 配置 replicator
        replicator.frame = bounds
        replicator.instanceCount = 2
        replicator.instanceDelay = animationDuration / CFTimeInterval(replicator.instanceCount)
        layer.addSublayer(replicator)
        
        // 2. 配置单个圆圈 layer
        let diameter = initialRadius * 2
        rippleLayer.bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        rippleLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        rippleLayer.cornerRadius = initialRadius
        rippleLayer.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1).cgColor
        rippleLayer.opacity = 0
        
        // 把圆圈 layer 加到 replicator 上
        replicator.addSublayer(rippleLayer)
        
        // 3. 配置动画
        // 缩放动画：从 0（隐藏）→ 目标半径比
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0
        scaleAnim.toValue = finalRadius / initialRadius
        
        // 透明度动画：1 → 0.2 → 0
        let opacityAnim = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnim.values = [0.0, 1.0, 0.2, 0.0]
        opacityAnim.keyTimes = [0, 0.1, 0.9, 1]
        
        // 组合动画
        let group = CAAnimationGroup()
        group.animations = [scaleAnim, opacityAnim]
        group.duration = animationDuration
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.repeatCount = .infinity
        group.isRemovedOnCompletion = false
        
        rippleLayer.add(group, forKey: "ripple")
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 更新 replicator 和圆心位置
        replicator.frame = bounds
        rippleLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
