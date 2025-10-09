//
//  DottedRectView.swift
//  lns
//
//  Created by Elavatine on 2025/4/22.
//


class DottedRectView: FeedBackView {
    
    var cornerRadius = kFitWidth(12)
    
    var dashColor = UIColor.COLOR_TEXT_TITLE_0f1214_20
    
    // 在视图大小改变时重新绘制虚线边框
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
        // 重新绘制虚线边框
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        drawDashedBorder()
    }
    
   // 绘制虚线边框
   private func drawDashedBorder() {
       // 创建CAShapeLayer来绘制虚线边框
       let shapeLayer = CAShapeLayer()
       shapeLayer.strokeColor = dashColor.cgColor
       shapeLayer.fillColor = nil
       shapeLayer.lineWidth = 1.0
       shapeLayer.lineDashPattern = [3, 3]  // 设置虚线模式（3个点的虚线，3个点的空隙）
       
       // 创建路径，确保虚线路径适应圆角
       let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)  // 设置圆角半径与视图一致
       shapeLayer.path = path.cgPath

       // 将虚线边框添加到视图的图层中
       layer.addSublayer(shapeLayer)
   }
}
