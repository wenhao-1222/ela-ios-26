//
//  DottedLabelView.swift
//  lns
//
//  Created by Elavatine on 2025/4/22.
//

import UIKit

class DottedLabelView: UIView {

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2  // 设置最多显示两行
        label.lineBreakMode = .byTruncatingTail  // 文本超出部分使用省略号
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // 设置视图的背景色为白色
        self.backgroundColor = .white

        // 添加UILabel到父视图
        addSubview(label)

        // 设置label的约束
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])

        // 绘制虚线边框
        drawDashedBorder()
    }

    private func drawDashedBorder() {
        // 创建CAShapeLayer来绘制虚线边框
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.lineDashPattern = [6, 3]  // 设置虚线模式（6个点的虚线，3个点的空隙）
        
        // 创建路径
        let path = UIBezierPath(rect: bounds)
        shapeLayer.path = path.cgPath

        // 将虚线边框添加到视图的图层中
        layer.addSublayer(shapeLayer)
    }

    // 设置文本
    func setLabelText(_ text: String) {
        label.text = text
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 重新绘制虚线边框
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        drawDashedBorder()
    }
}
