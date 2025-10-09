//
//  RoundedShadowImageView.swift
//  lns
//
//  Created by Elavatine on 2025/9/26.
//

final class RoundedShadowImageView: UIView {

    let imageView = UIImageView()
    var isCircle = true              // 圆形：true；圆角矩形：false
    var cornerRadius: CGFloat = kFitWidth(33)   // isCircle = false 时生效

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // 外层：阴影容器（不裁剪）
        self.clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.26
        layer.shadowRadius  = cornerRadius
//        layer.shadowOffset  = CGSize(width: kFitWidth(0), height: kFitWidth(0))

        // 内层：图片（裁剪圆角）
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true                // 或 imageView.layer.masksToBounds = true
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 计算圆角
        let r = isCircle ? min(bounds.width, bounds.height) * 0.5 : cornerRadius
        layer.cornerRadius     = r     // 外层用于匹配形状
        imageView.layer.cornerRadius = r

        // 指定阴影路径（不然系统按模糊边计算，性能差且形状不准）
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: r).cgPath
    }
}
