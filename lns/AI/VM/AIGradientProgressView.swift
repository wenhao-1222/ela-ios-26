//
//  AIGradientProgressView.swift
//  lns
//
//  Created by Elavatine on 2025/3/7.
//

import UIKit

class AIGradientProgressView: UIView {
    // MARK: - 属性
    private let backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return layer
    }()
    public var progressLast = 0.0
    private var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#06C1FF").cgColor,
            UIColor(hex: "#007AFF").cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()
    
    private let maskLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor
        layer.anchorPoint = CGPoint(x: 0, y: 0.5) // 关键修正：锚点设置在左边缘中心
        return layer
    }()
    func updateProgressColor(isFail:Bool) {
        if isFail{
            gradientLayer.colors = [
                UIColor(hex: "#BCBCBB").cgColor,
                UIColor(hex: "#727272").cgColor
            ]
            setProgress(self.progressLast, animated: false)
        }else{
            gradientLayer.colors = [
                UIColor(hex: "#06C1FF").cgColor,
                UIColor(hex: "#007AFF").cgColor
            ]
        }
    }
    @IBInspectable var progress: CGFloat = 0 {
        didSet { setProgress(progress, animated: true) }
    }

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    // MARK: - 图层配置
    private func setupLayers() {
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = maskLayer
        
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius = bounds.height / 2
        
        // 背景层设置
        backgroundLayer.frame = bounds
        backgroundLayer.cornerRadius = cornerRadius
        
        // 渐变层设置
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadius
        
        // 关键修正：maskLayer定位逻辑
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.position = CGPoint(x: 0, y: bounds.midY)
        maskLayer.bounds = CGRect(
            x: 0,
            y: 0,
            width: bounds.width * progress,
            height: bounds.height
        )
        maskLayer.cornerRadius = cornerRadius
        CATransaction.commit()
    }
    
    // MARK: - 核心动画
    func setProgress(_ progress: CGFloat, animated: Bool, duration: TimeInterval=0.3) {
        DLLog(message: "setProgress:\(progress)")
        self.progressLast = progress
//        DispatchQueue.main.asyncAfter(deadline: .now()+duration, execute: {
//            self.progressLabel.text = String(format: "%.0f%%", progress*100)
//        })
        
        let clampedProgress = min(max(progress, 0), 1)
        let targetWidth = bounds.width * clampedProgress
        
        if animated {
            let animation = CABasicAnimation(keyPath: "bounds.size.width")
            animation.fromValue = maskLayer.bounds.width
            animation.toValue = targetWidth
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // 关键修正：保持左侧固定
            let oldPosition = maskLayer.position
            maskLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
            maskLayer.position = oldPosition
            
            maskLayer.add(animation, forKey: "progressAnimation")
        }
        
        // 立即更新布局
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.bounds.size.width = targetWidth
        CATransaction.commit()
    }
}
