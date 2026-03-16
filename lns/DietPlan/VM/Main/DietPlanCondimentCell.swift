//
//  DietPlanCondimentCell.swift
//  lns
//
//  Created by Codex on 2026/3/16.
//

class DietPlanCondimentCell: UICollectionViewCell {
    static let reuseId = "DietPlanCondimentCell"

    private let imageSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                     highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                     cornerRadius: kFitWidth(0),
                                                     shimmerWidth: 0.22,
                                                     shimmerDuration: 1.0,
                                                     skeletonFadeInDuration: 0.0,
                                                     contentFadeInDuration: 0.18)
    private let textSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                    highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                    cornerRadius: kFitWidth(2),
                                                    shimmerWidth: 0.2,
                                                    shimmerDuration: 1.0,
                                                    skeletonFadeInDuration: 0.0,
                                                    contentFadeInDuration: 0.18)
    private var imageLoadToken = ""

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(12)
        view.clipsToBounds = true
        return view
    }()

    private let condimentImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 10, weight: .regular)
        return label
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
        imageLoadToken = ""
        condimentImageView.image = nil
        [condimentImageView, titleLabel, detailLabel].forEach {
            $0.alpha = 1
        }
    }

    func updateUI(dict: NSDictionary?, isLoading: Bool) {
        if isLoading {
            imageLoadToken = ""
            condimentImageView.image = nil
            titleLabel.text = " "
            detailLabel.text = " "
            [condimentImageView].forEach { $0.showSkeleton(imageSkeletonConfig) }
            [titleLabel, detailLabel].forEach { $0.showSkeleton(textSkeletonConfig) }
            return
        }

        guard let dict = dict else {
            titleLabel.text = ""
            detailLabel.text = ""
            [titleLabel, detailLabel, condimentImageView].forEach { $0.hideSkeletonWithCrossfade() }
            return
        }

        prepareContentFadeInIfNeeded()
        titleLabel.text = dict.stringValueForKey(key: "name")
        detailLabel.text = buildDetailText(dict: dict)
        [titleLabel, detailLabel].forEach { $0.hideSkeletonWithCrossfade() }

        let imageUrl = dict.stringValueForKey(key: "image")
        let placeHolder = UIImage(named: "Image")
        guard !imageUrl.isEmpty else {
            condimentImageView.image = placeHolder
            condimentImageView.hideSkeletonWithCrossfade()
            return
        }

        imageLoadToken = UUID().uuidString
        let currentToken = imageLoadToken
        condimentImageView.showSkeleton(imageSkeletonConfig)
        condimentImageView.setImgUrlWithComplete(urlString: imageUrl, placeHolder: placeHolder) { [weak self] in
            guard let self = self else { return }
            guard self.imageLoadToken == currentToken else { return }
            self.condimentImageView.hideSkeletonWithCrossfade()
        }
    }
}

private extension DietPlanCondimentCell {
    func initUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(condimentImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(detailLabel)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        condimentImageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kFitWidth(125))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(condimentImageView.snp.bottom).offset(kFitWidth(9))
//            make.height.equalTo(kFitWidth(24))
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(kFitWidth(-12))
            make.bottom.equalTo(kFitWidth(-11))
//            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
        }
    }

    func prepareContentFadeInIfNeeded() {
        [titleLabel, detailLabel, condimentImageView].forEach { view in
            guard view.isSkeletonActive else { return }
            view.alpha = 0
        }
    }

    func buildDetailText(dict: NSDictionary) -> String {
        let qty = dict.stringValueForKey(key: "qty")
        let spec = dict.stringValueForKey(key: "spec")
        let caloriesText = formattedCalories(dict.stringValueForKey(key: "calories"))
        return "\(qty)\(spec) | \(caloriesText)kcal"
    }

    func formattedCalories(_ text: String) -> String {
        let value = text.doubleValue
        if abs(value - value.rounded()) < 0.001 {
            return "\(Int(value.rounded()))"
        }
        return String(format: "%.1f", value)
    }
}
