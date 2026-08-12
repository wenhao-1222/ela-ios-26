//
//  ElaMealAdviceProIntroVM.swift
//  lns
//
//  Created by Codex on 2026/8/12.
//

import UIKit
import SnapKit

class ElaMealAdviceProIntroVM: UIView {
    private struct Feature {
        let title: String
        let desc: String
        let iconName: String?
    }

    private let features: [Feature] = [
        Feature(title: "提前规划", desc: "提前分配剩余目标，不再临时纠结每餐吃多少", iconName: nil),
        Feature(title: "合理分配", desc: "防止单餐摄入过多或不足，造成胃口波动", iconName: nil),
        Feature(title: "告别反复试算", desc: "热量、碳水、蛋白质和脂肪同步匹配目标", iconName: nil)
    ]

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()

    private lazy var contentView = UIView()
    private lazy var nextMealImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_next_meal_img"))
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = false
        return imageView
    }()

    private lazy var titleLabel: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_expired_alert_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = makeParagraphText("我们会根据你的剩余营养目标和所选食物，给出下一餐的推荐摄入克重，帮助你时刻贴近目标")
        return label
    }()

    private lazy var featureContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.24)
        view.layer.cornerRadius = kFitWidth(14)
        view.layer.borderWidth = kFitWidth(1.5)
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        view.clipsToBounds = true
        return view
    }()

    private lazy var featureStackView: UIStackView = {
        let rows = features.enumerated().map { index, feature in
            makeFeatureRow(feature, showsDivider: index < features.count - 1)
        }
        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
}

private extension ElaMealAdviceProIntroVM {
    func initUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(nextMealImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(featureContainer)
        featureContainer.addSubview(featureStackView)

        setConstraints()
    }

    func setConstraints() {
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(76)))
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        nextMealImageView.snp.makeConstraints { make in
            make.top.equalTo(statusBarHeight+kFitWidth(35))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(279))
            make.height.equalTo(kFitWidth(316))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(nextMealImageView.snp.bottom).offset(kFitWidth(-8))
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(20))
        }

        descLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
        }

        featureContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(descLabel.snp.bottom).offset(kFitWidth(34))
            make.height.equalTo(kFitWidth(204))
            make.bottom.equalToSuperview().offset(kFitWidth(-22))
        }

        featureStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func makeFeatureRow(_ feature: Feature, showsDivider: Bool) -> UIView {
        let row = UIView()

        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.image = feature.iconName.flatMap { UIImage(named: $0) }
        iconView.isHidden = iconView.image == nil

        let titleLabel = UILabel()
        titleLabel.text = feature.title
        titleLabel.textColor = UIColor.COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        let descLabel = UILabel()
        descLabel.text = feature.desc
        descLabel.textColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
        descLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descLabel.numberOfLines = 0

        let divider = UIView()
        divider.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_10
        divider.isHidden = !showsDivider

        row.addSubview(iconView)
        row.addSubview(titleLabel)
        row.addSubview(descLabel)
        row.addSubview(divider)

        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(22))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(28))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(64))
            make.right.equalTo(kFitWidth(-18))
            make.top.equalTo(kFitWidth(12))
        }

        descLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(5))
        }

        divider.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        return row
    }

    func makeParagraphText(_ text: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = kFitWidth(4)
        return NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
                .paragraphStyle: paragraph
            ]
        )
    }
}
