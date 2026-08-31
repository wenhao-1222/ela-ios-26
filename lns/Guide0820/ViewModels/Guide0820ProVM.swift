//
//  Guide0820ProVM.swift
//  lns
//
//  MasterGo 3:11500 - 收费墙-月-年付费
//

import UIKit
import SnapKit

/// 0820 引导流程使用的 ELA PRO 收费墙。
///
/// 页面展示完全由本视图负责；商品加载、套餐选中和购买仍复用
/// `ElaProPriceVM`，因此视觉改版不会绕开既有 StoreKit 流程。
final class Guide0820ProVM: UIView {
    private struct Benefit {
        let title: String
        let detail: String
    }

    private struct Review {
        let title: String
        let author: String
        let detail: String
    }

    private let benefits: [Benefit] = [
        Benefit(
            title: "持续营养指导",
            detail: "结合你的饮食执行和体重变化，告诉你下一步怎么做，并在需要时调整营养目标。"
        ),
        Benefit(
            title: "智能饮食规划",
            detail: "根据当天剩余目标和所选食物，给出每种食物的建议克重。"
        ),
        Benefit(
            title: "快速记录与完整分析",
            detail: "通过快速添加、AI 识别和详细营养分析，随时看清各项营养距离目标还差多少。"
        )
    ]

    private let reviews: [Review] = [
        Review(
            title: "最好的饮食管理工具",
            author: "rexyang96",
            detail: "最开始用是教练推荐，从24年11月用到现在，从91公斤减到73 再到现在开始增肌一直没断过，现在吃啥基本都会记录到elavatine里面，很喜欢那种进度一目了然的感觉，看到自己有变化就有更多的动力去坚持"
        ),
        Review(
            title: "改变了我的饮食方式",
            author: "早起困难户",
            detail: "用ela之前只会一味地压热量 后来试着跟着软件给的目标走了一段时间 虽然一开始掉得没那么快（也有可能是我之前断食导致代谢受损了），但是掉得很持续 不会说减完第二周就反弹回来 再就是配餐功能 节省了我很多计算的功夫 更像是传统食谱和自由饮食中间的折中方案 真的很不错！"
        )
    ]

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let planContainer = UIView()
    private let bottomFadeView = Guide0820ProBottomFadeView()
    private weak var priceVM: ElaProPriceVM?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        buildInterface()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 将既有价格 VM 的可交互套餐卡和购买栏嵌入新设计。
    func configure(priceVM: ElaProPriceVM) {
        guard self.priceVM !== priceVM else { return }
        self.priceVM = priceVM

        priceVM.usesExternalPlanCardLayout = true
        priceVM.scrollView.isHidden = true
        priceVM.lifeCard.isHidden = true

        installPlanCard(
            priceVM.yearCard,
            title: "每年",
            period: "/年",
            weeklyPrice: "¥3.23/周",
            savingsText: "节省 50%"
        )
        installPlanCard(
            priceVM.monthCard,
            title: "每月",
            period: "/月",
            weeklyPrice: "¥6.54/周",
            savingsText: nil
        )

        priceVM.bottomBar.removeFromSuperview()
        addSubview(bottomFadeView)
        addSubview(priceVM.bottomBar)

        priceVM.bottomBar.backgroundColor = .clear
        priceVM.labelBgImgView.removeFromSuperview()
        priceVM.confirmButton.setTitle("开始第一阶段", for: .normal)
        priceVM.confirmButton.titleLabel?.font = .systemFont(ofSize: kFitWidth(17), weight: .medium)
        priceVM.confirmButton.layer.cornerRadius = kFitWidth(25)
        priceVM.confirmButton.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(11.5))
            make.height.equalTo(kFitWidth(50))
        }
        priceVM.agreementLabel.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(priceVM.confirmButton.snp.bottom).offset(kFitWidth(10))
        }

        bottomFadeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(158) + WHUtils().getBottomSafeAreaHeight())
        }
        priceVM.bottomBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(82) + WHUtils().getBottomSafeAreaHeight())
        }

        scrollView.contentInset.bottom = kFitWidth(118) + WHUtils().getBottomSafeAreaHeight()
        scrollView.verticalScrollIndicatorInsets.bottom = scrollView.contentInset.bottom
        bringSubviewToFront(bottomFadeView)
        bringSubviewToFront(priceVM.bottomBar)
    }
}

private extension Guide0820ProVM {
    func buildInterface() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        let logoView = UIImageView(image: UIImage(named: "ela_pro_expired_alert_icon"))
        logoView.contentMode = .scaleAspectFit
        contentView.addSubview(logoView)
        logoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kFitWidth(115))
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(103))
            make.height.equalTo(kFitWidth(28))
        }

        let titleLabel = makeLabel(
            text: "让ELA教练继续跟进你的计划",
            font: .systemFont(ofSize: kFitWidth(21), weight: .medium),
            color: .COLOR_TEXT_TITLE_0f1214,
            alignment: .center
        )
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(kFitWidth(15))
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
        }

        let benefitsStack = UIStackView()
        benefitsStack.axis = .vertical
        benefitsStack.spacing = kFitWidth(16)
        benefitsStack.alignment = .fill
        contentView.addSubview(benefitsStack)
        for benefit in benefits {
            benefitsStack.addArrangedSubview(makeBenefitView(benefit))
        }
        benefitsStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(28))
            make.left.equalTo(kFitWidth(18))
            make.right.equalTo(kFitWidth(-18))
        }

        contentView.addSubview(planContainer)
        planContainer.snp.makeConstraints { make in
            make.top.equalTo(benefitsStack.snp.bottom).offset(kFitWidth(25))
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.height.equalTo(kFitWidth(160))
        }

        let ratingView = makeRatingView()
        contentView.addSubview(ratingView)
        ratingView.snp.makeConstraints { make in
            make.top.equalTo(planContainer.snp.bottom).offset(kFitWidth(31))
            make.centerX.equalToSuperview()
        }

        let reviewScrollView = makeReviewsView()
        contentView.addSubview(reviewScrollView)
        reviewScrollView.snp.makeConstraints { make in
            make.top.equalTo(ratingView.snp.bottom).offset(kFitWidth(15))
            make.left.right.equalToSuperview()
            make.height.equalTo(kFitWidth(192))
        }

        let firstTransformation = makeTransformationCard(
            leftImage: "review_photo_4",
            rightImage: "review_photo_2",
            leftWeight: "74.6 kg",
            rightWeight: "74.6 kg",
            name: "Rich.L"
        )
        contentView.addSubview(firstTransformation)
        firstTransformation.snp.makeConstraints { make in
            make.top.equalTo(reviewScrollView.snp.bottom).offset(kFitWidth(20))
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.height.equalTo(kFitWidth(260))
        }

        let secondTransformation = makeTransformationCard(
            leftImage: "review_photo_3",
            rightImage: "review_photo_1",
            leftWeight: "58.6 kg",
            rightWeight: "65.6 kg",
            name: "Yi.D"
        )
        contentView.addSubview(secondTransformation)
        secondTransformation.snp.makeConstraints { make in
            make.top.equalTo(firstTransformation.snp.bottom).offset(kFitWidth(12))
            make.left.right.height.equalTo(firstTransformation)
            make.bottom.equalToSuperview().offset(kFitWidth(-30))
        }
    }

    private func makeBenefitView(_ benefit: Benefit) -> UIView {
        let container = UIView()

        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tintColor = .THEME
        checkmark.contentMode = .scaleAspectFit
        container.addSubview(checkmark)

        let title = makeLabel(
            text: benefit.title,
            font: .systemFont(ofSize: kFitWidth(14), weight: .medium),
            color: .COLOR_TEXT_TITLE_0f1214
        )
        container.addSubview(title)

        let detail = makeLabel(
            text: benefit.detail,
            font: .systemFont(ofSize: kFitWidth(12), weight: .regular),
            color: .COLOR_TEXT_TITLE_0f1214
        )
        detail.numberOfLines = 0
        detail.guide0820SetLineHeight(kFitWidth(18))
        container.addSubview(detail)

        checkmark.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(kFitWidth(2))
            make.width.equalTo(kFitWidth(13))
            make.height.equalTo(kFitWidth(10))
        }
        title.snp.makeConstraints { make in
            make.left.equalTo(checkmark.snp.right).offset(kFitWidth(6))
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        detail.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(title.snp.bottom).offset(kFitWidth(7))
            make.bottom.equalToSuperview()
        }
        return container
    }

    func installPlanCard(
        _ card: ElaProPriceCardView,
        title: String,
        period: String,
        weeklyPrice: String,
        savingsText: String?
    ) {
        card.removeFromSuperview()
        planContainer.addSubview(card)
        card.layer.cornerRadius = kFitWidth(12)
        card.titleLabel.removeFromSuperview()
        card.subTitleLabel.removeFromSuperview()
        card.originLabel.removeFromSuperview()
        card.tagLabel.removeFromSuperview()
        card.priceLabel.font = .systemFont(ofSize: kFitWidth(13), weight: .regular)
        card.priceLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        card.priceLabel.textAlignment = .left

        let titleLabel = makeLabel(
            text: title,
            font: .systemFont(ofSize: kFitWidth(16), weight: .medium),
            color: .COLOR_TEXT_TITLE_0f1214
        )
        card.addSubview(titleLabel)

        let periodLabel = makeLabel(
            text: period,
            font: .systemFont(ofSize: kFitWidth(13), weight: .regular),
            color: .COLOR_TEXT_TITLE_0f1214
        )
        card.addSubview(periodLabel)

        let weeklyLabel = makeLabel(
            text: weeklyPrice,
            font: .systemFont(ofSize: kFitWidth(12), weight: .regular),
            color: .COLOR_TEXT_TITLE_0f1214,
            alignment: .right
        )
        card.addSubview(weeklyLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(16))
        }
        card.priceLabel.snp.remakeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
            make.height.equalTo(kFitWidth(18))
        }
        periodLabel.snp.makeConstraints { make in
            make.left.equalTo(card.priceLabel.snp.right)
            make.centerY.equalTo(card.priceLabel)
        }
        weeklyLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.centerY.equalTo(card.priceLabel)
        }

        if let savingsText {
            let badge = makeLabel(
                text: savingsText,
                font: .systemFont(ofSize: kFitWidth(10), weight: .medium),
                color: .white,
                alignment: .center
            )
            badge.backgroundColor = .THEME
            badge.layer.cornerRadius = kFitWidth(12)
            badge.layer.maskedCorners = [.layerMinXMaxYCorner]
            badge.clipsToBounds = true
            card.addSubview(badge)
            badge.snp.makeConstraints { make in
                make.top.right.equalToSuperview()
                make.width.equalTo(kFitWidth(62))
                make.height.equalTo(kFitWidth(22))
            }
        }

        if title == "每年" {
            card.snp.makeConstraints {
                $0.left.top.right.equalToSuperview()
                $0.height.equalTo(kFitWidth(80))
            }
        } else {
            card.snp.makeConstraints {
                $0.left.right.bottom.equalToSuperview()
                $0.height.equalTo(kFitWidth(72))
            }
        }
    }

    func makeRatingView() -> UIView {
        let container = UIView()
        let stars = makeStars(size: kFitWidth(25), spacing: kFitWidth(3))
        container.addSubview(stars)

        let ratingLabel = makeLabel(
            text: "4.9分，10000+ 评价",
            font: .systemFont(ofSize: kFitWidth(12), weight: .regular),
            color: .COLOR_TEXT_TITLE_0f1214_50,
            alignment: .center
        )
        container.addSubview(ratingLabel)

        stars.snp.makeConstraints { $0.top.centerX.equalToSuperview() }
        ratingLabel.snp.makeConstraints {
            $0.top.equalTo(stars.snp.bottom).offset(kFitWidth(8))
            $0.left.right.bottom.equalToSuperview()
        }
        return container
    }

    func makeReviewsView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = kFitWidth(12)
        scrollView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        for review in reviews {
            let card = makeReviewCard(review)
            stack.addArrangedSubview(card)
            card.snp.makeConstraints { make in
                make.width.equalTo(kFitWidth(280))
                make.height.equalToSuperview()
            }
        }
        let leadingSpacer = UIView()
        leadingSpacer.snp.makeConstraints { $0.width.equalTo(0) }
        stack.insertArrangedSubview(leadingSpacer, at: 0)
        let trailingSpacer = UIView()
        trailingSpacer.snp.makeConstraints { $0.width.equalTo(0) }
        stack.addArrangedSubview(trailingSpacer)
        return scrollView
    }

    private func makeReviewCard(_ review: Review) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = kFitWidth(12)
        card.clipsToBounds = true

        let titleLabel = makeLabel(
            text: review.title,
            font: .systemFont(ofSize: kFitWidth(14), weight: .medium),
            color: .COLOR_TEXT_TITLE_0f1214
        )
        card.addSubview(titleLabel)

        let stars = makeStars(size: kFitWidth(15), spacing: kFitWidth(1.5))
        card.addSubview(stars)

        let authorLabel = makeLabel(
            text: review.author,
            font: .systemFont(ofSize: kFitWidth(11), weight: .regular),
            color: .COLOR_TEXT_TITLE_0f1214_50
        )
        card.addSubview(authorLabel)

        let detailLabel = makeLabel(
            text: review.detail,
            font: .systemFont(ofSize: kFitWidth(11), weight: .regular),
            color: .COLOR_TEXT_TITLE_0f1214_50
        )
        detailLabel.numberOfLines = 6
        detailLabel.lineBreakMode = .byTruncatingTail
        detailLabel.guide0820SetLineHeight(kFitWidth(17.5))
        card.addSubview(detailLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(14))
        }
        stars.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(9))
        }
        authorLabel.snp.makeConstraints { make in
            make.left.equalTo(stars.snp.right).offset(kFitWidth(7))
            make.centerY.equalTo(stars)
        }
        detailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(stars.snp.bottom).offset(kFitWidth(9))
            make.bottom.lessThanOrEqualToSuperview().offset(kFitWidth(-14))
        }
        return card
    }

    func makeStars(size: CGFloat, spacing: CGFloat) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = spacing
        for _ in 0..<5 {
            let star = UIImageView(image: UIImage(named: "review_star"))
            star.contentMode = .scaleAspectFit
            star.snp.makeConstraints { $0.width.height.equalTo(size) }
            stack.addArrangedSubview(star)
        }
        return stack
    }

    func makeTransformationCard(
        leftImage: String,
        rightImage: String,
        leftWeight: String,
        rightWeight: String,
        name: String
    ) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = kFitWidth(12)
        card.clipsToBounds = true

        let leftPhoto = makeTransformationPhoto(imageName: leftImage, weight: leftWeight, highlighted: false)
        let rightPhoto = makeTransformationPhoto(imageName: rightImage, weight: rightWeight, highlighted: true)
        card.addSubview(leftPhoto)
        card.addSubview(rightPhoto)

        let arrow = UIImageView(image: UIImage(named: "review_arrow"))
        arrow.contentMode = .scaleAspectFit
        card.addSubview(arrow)

        let nameLabel = makeLabel(
            text: name,
            font: .systemFont(ofSize: kFitWidth(12), weight: .medium),
            color: .COLOR_TEXT_TITLE_0f1214
        )
        card.addSubview(nameLabel)

        leftPhoto.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(12))
            make.bottom.equalTo(nameLabel.snp.top).offset(kFitWidth(-8))
        }
        rightPhoto.snp.makeConstraints { make in
            make.left.equalTo(leftPhoto.snp.right).offset(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.bottom.width.equalTo(leftPhoto)
        }
        leftPhoto.snp.makeConstraints { $0.width.equalTo(rightPhoto) }
        arrow.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(leftPhoto)
            make.width.height.equalTo(kFitWidth(36))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalToSuperview().offset(kFitWidth(232))
            make.height.equalTo(kFitWidth(20))
            make.bottom.equalTo(kFitWidth(-8))
        }
        card.bringSubviewToFront(nameLabel)
        return card
    }

    func makeTransformationPhoto(imageName: String, weight: String, highlighted: Bool) -> UIView {
        let container = UIView()
        container.backgroundColor = WHColor_16(colorStr: "505050")
        container.layer.cornerRadius = kFitWidth(12)
        container.clipsToBounds = true

        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        container.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        let weightLabel = makeLabel(
            text: weight,
            font: .systemFont(ofSize: kFitWidth(12), weight: .medium),
            color: .white,
            alignment: .center
        )
        weightLabel.backgroundColor = highlighted ? .THEME : .COLOR_TEXT_TITLE_0f1214
        weightLabel.layer.cornerRadius = kFitWidth(3)
        weightLabel.clipsToBounds = true
        container.addSubview(weightLabel)
        weightLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(9))
            make.right.equalTo(kFitWidth(-9))
            make.width.equalTo(kFitWidth(50))
            make.height.equalTo(kFitWidth(18))
        }
        return container
    }

    func makeLabel(
        text: String,
        font: UIFont,
        color: UIColor,
        alignment: NSTextAlignment = .left
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        return label
    }
}

private final class Guide0820ProBottomFadeView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        gradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
        gradientLayer.locations = [0, 0.45, 1]
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
