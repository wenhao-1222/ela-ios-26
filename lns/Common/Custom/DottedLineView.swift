//
//  DottedLineView.swift
//  lns
//
//  Created by Elavatine on 2025/4/22.
//

import UIKit

class DottedLineView: UIView {
    
    
    
    // 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // 设置虚线样式
    private func commonInit() {
        // 配置视图的背景色为透明，确保能看到虚线
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 创建CAShapeLayer来绘制虚线
        let shapeLayer = CAShapeLayer()
        
        // 设置线的颜色
        shapeLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor
        
        // 设置线宽
        shapeLayer.lineWidth = kFitWidth(1)
        
        // 设置虚线的模式：每10个点绘制10个像素的虚线，再留空5个像素
        shapeLayer.lineDashPattern = [3, 3]  // [6, 3]表示虚线长度为6个点，空隙为3个点
        
        // 创建虚线路径
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.height / 2)) // 起始点
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2)) // 终止点（根据宽度动态改变）
        
        // 将路径赋给CAShapeLayer
        shapeLayer.path = path.cgPath
        
        // 清除之前的子图层
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // 添加新的CAShapeLayer
        self.layer.addSublayer(shapeLayer)
    }
}
