//
//  DietPlanBuyListFoodsCell.swift
//  lns
//
//  Created by LNS2 on 2026/3/12.
//


class DietPlanBuyListFoodsCell: UITableViewCell {
    static let reuseId = "DietPlanBuyListFoodsCell"
    
    private let checkedImageName = "circle_today_select_icon"
    private let uncheckedImageName = "question_foods_normal_icon"
    private let textSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                    highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                    cornerRadius: kFitWidth(6),
                                                    shimmerWidth: 0.2,
                                                    shimmerDuration: 1.0,
                                                    skeletonFadeInDuration: 0.0,
                                                    contentFadeInDuration: 0.18)
    private let checkSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                     highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                     cornerRadius: kFitWidth(10.5),
                                                     shimmerWidth: 0.2,
                                                     shimmerDuration: 1.0,
                                                     skeletonFadeInDuration: 0.0,
                                                     contentFadeInDuration: 0.18)
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(12)
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(weightLabel)
        cardView.addSubview(checkImageView)
        
        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(4.5))
            make.bottom.equalTo(kFitWidth(-4.5))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(8))
            make.height.equalTo(kFitWidth(21))
            make.right.lessThanOrEqualTo(checkImageView.snp.left).offset(kFitWidth(-10))
        }
        weightLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(2))
            make.height.equalTo(kFitWidth(18))
        }
        checkImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(21))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        weightLabel.text = nil
        [titleLabel, weightLabel, checkImageView].forEach {
            $0.alpha = 1
        }
        checkImageView.layer.removeAllAnimations()
        checkImageView.transform = .identity
        checkImageView.alpha = 1
        checkImageView.setCheckState(false,
                                     checkedImageName: checkedImageName,
                                     uncheckedImageName: uncheckedImageName,
                                     animated: false)
    }
    
    func updateUI(title: String,weight: String, isSelected: Bool, isLoading: Bool) {
        if isLoading {
            titleLabel.text = "                                    "
            weightLabel.text = "                      "
            checkImageView.image = nil
            [titleLabel, weightLabel].forEach { $0.showSkeleton(textSkeletonConfig) }
            checkImageView.showSkeleton(checkSkeletonConfig)
            return
        }

        prepareContentFadeInIfNeeded()
        titleLabel.text = title
        weightLabel.text = weight
        checkImageView.setCheckState(isSelected,
                                     checkedImageName: checkedImageName,
                                     uncheckedImageName: uncheckedImageName,
                                     animated: false)
        [titleLabel, weightLabel, checkImageView].forEach { $0.hideSkeletonWithCrossfade() }
    }
}

private extension DietPlanBuyListFoodsCell {
    func prepareContentFadeInIfNeeded() {
        [titleLabel, weightLabel, checkImageView].forEach { view in
            guard view.isSkeletonActive else { return }
            view.alpha = 0
        }
    }
}
