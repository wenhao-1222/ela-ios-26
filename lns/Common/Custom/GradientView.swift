//
//  GradientView.swift
//  lns
//
//  Created by Elavatine on 2025/4/14.
//

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // 更新渐变层尺寸（在布局变化时调用）
    override open func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
    }
}
// MARK: - 为 UIView 添加渐变背景
extension GradientView {
    func addGradientBackground(startColor: UIColor, endColor: UIColor) {
        // 移除旧的渐变层
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        // 创建渐变层
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 1] // 颜色分布位置
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0) // 垂直渐变起点（顶部）
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)   // 垂直渐变终点（底部）
        gradientLayer.frame = bounds
        
        // 插入到最底层作为背景
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
