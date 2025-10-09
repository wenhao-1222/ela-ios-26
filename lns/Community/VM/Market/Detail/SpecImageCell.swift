//
//  SpecImageCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/9.
//

import UIKit

// MARK: - 模型：后台给的是图片链接；本 Demo 用颜色占位
struct SpecImageOption {
    let id: String
    /// 图片链接（你后续替换：用 SDWebImage/Kingfisher 设置到 imageView）
    let imageURL: String?
    /// Demo 中用背景色代替图片
    let placeholderColor: UIColor
}

// MARK: - 色块的 collection cell
final class SpecImageCell: UICollectionViewCell {
    static let reuseID = "SpecImageCell"
    
    let imageView = UIImageView()
    private let borderLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = kFitWidth(3)
        imageView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // 选中描边
        borderLayer.lineWidth = kFitWidth(1)
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.systemBlue.cgColor
        layer.addSublayer(borderLayer)
        
        // 阴影更有“按钮块”的感觉
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 4
        layer.shadowOffset = .init(width: 0, height: 1)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: kFitWidth(3)).cgPath
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: kFitWidth(3)).cgPath
    }
    
    func setSelectedUI(_ selected: Bool, animated: Bool) {
        let apply: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.borderLayer.opacity = selected ? 1 : 0
//            self.layer.transform = CATransform3DIdentity
            self.imageView.transform = selected ? CGAffineTransform(scaleX: 0.8, y: 0.8) : .identity
        }
        if animated {
            // 轻微弹簧缩放
            let anim = CASpringAnimation(keyPath: "transform.scale")
            anim.fromValue = 0.92
            anim.toValue = 1.0
            anim.damping = 10
            anim.stiffness = 180
            anim.mass = 1
            anim.initialVelocity = 6
            anim.duration = anim.settlingDuration
            layer.add(anim, forKey: "spring")
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            apply()
            CATransaction.commit()
        } else {
            apply()
        }
    }
}
