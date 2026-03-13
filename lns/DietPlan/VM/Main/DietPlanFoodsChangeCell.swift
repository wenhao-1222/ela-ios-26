//
//  DietPlanFoodsChangeCell.swift
//  lns
//
//  Created by LNS2 on 2026/3/13.
//

class DietPlanFoodsChangeCell: UICollectionViewCell {
    static let reuseId = "DietPlanFoodsChangeCell"
    
    var chooseTapBlock: (() -> Void)?
    
    private let imageSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                     highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                     cornerRadius: kFitWidth(12),
                                                     shimmerWidth: 0.22,
                                                     shimmerDuration: 1.0,
                                                     skeletonFadeInDuration: 0.0,
                                                     contentFadeInDuration: 0.18)
    private let textSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                    highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                    cornerRadius: kFitWidth(8),
                                                    shimmerWidth: 0.2,
                                                    shimmerDuration: 1.0,
                                                    skeletonFadeInDuration: 0.0,
                                                    contentFadeInDuration: 0.18)
    private var imageLoadToken = ""
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(14)
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var mealImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var chooseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("选择", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.backgroundColor = .THEME
        button.layer.cornerRadius = kFitWidth(13)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(chooseButtonTapAction), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chooseTapBlock = nil
        imageLoadToken = ""
        mealImageView.image = nil
        nameLabel.alpha = 1
        chooseButton.alpha = 1
//        [mealImageView, nameLabel, chooseButton].forEach { $0.removeSkeletonImmediately() }
    }
    
    func updateUI(item: DietPlanFoodsChangeItem?, isLoading: Bool) {
        chooseButton.isUserInteractionEnabled = !isLoading
        
        if isLoading {
            imageLoadToken = ""
            mealImageView.image = nil
            nameLabel.alpha = 1
            chooseButton.alpha = 1
            nameLabel.text = " "
            chooseButton.setTitle("选择", for: .normal)
            [mealImageView].forEach { $0.showSkeleton(imageSkeletonConfig) }
            [nameLabel, chooseButton].forEach { $0.showSkeleton(textSkeletonConfig) }
            return
        }

        guard let item = item else {
            nameLabel.text = ""
            chooseButton.setTitle("选择", for: .normal)
            prepareTextContentFadeInIfNeeded()
            [nameLabel, chooseButton].forEach { $0.hideSkeletonWithCrossfade() }
//            mealImageView.removeSkeletonImmediately()
            return
        }
        
        prepareTextContentFadeInIfNeeded()
        nameLabel.text = item.mealName
        chooseButton.setTitle("选择", for: .normal)
        [nameLabel, chooseButton].forEach { $0.hideSkeletonWithCrossfade() }
        
        let placeHolder = UIImage(named: "Image")
        guard !item.mealImage.isEmpty else {
//            mealImageView.removeSkeletonImmediately()
            mealImageView.image = placeHolder
            return
        }
        
        imageLoadToken = UUID().uuidString
        let currentToken = imageLoadToken
        mealImageView.showSkeleton(imageSkeletonConfig)
        mealImageView.setImgUrlWithComplete(urlString: item.mealImage, placeHolder: placeHolder) { [weak self] in
            guard let self = self else { return }
            guard self.imageLoadToken == currentToken else { return }
            self.mealImageView.hideSkeletonWithCrossfade()
        }
    }
}

private extension DietPlanFoodsChangeCell {
    func initUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(mealImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(chooseButton)
        
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mealImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(93))
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(mealImageView.snp.bottom).offset(kFitWidth(9))
            make.height.equalTo(kFitWidth(42))
        }
        
        chooseButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.bottom.equalTo(kFitWidth(-11))
            make.height.equalTo(kFitWidth(26))
        }
    }
    
    @objc func chooseButtonTapAction() {
        chooseTapBlock?()
    }
    
    func prepareTextContentFadeInIfNeeded() {
        [nameLabel, chooseButton].forEach { view in
            guard view.isSkeletonActive else { return }
            view.alpha = 0
        }
    }
}
