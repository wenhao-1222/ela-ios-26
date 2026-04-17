//
//  AICoachPreDayStatusRowView.swift
//  lns
//
//  Created by LNS2 on 2026/4/17.
//

class AICoachPreDayStatusRowView: UIView {

    private let title: String
    private let selectedColor: UIColor

    init(title: String, selectedColor: UIColor) {
        self.title = title
        self.selectedColor = selectedColor
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = kFitWidth(4)
        view.clipsToBounds = true
        return view
    }()

    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ai_progress_complete_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    func update(isSelected: Bool) {
        iconContainerView.backgroundColor = isSelected ? selectedColor : .COLOR_TEXT_TITLE_0f1214_50
//        checkImageView.isHidden = isSelected == false
//        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
    }
}

private extension AICoachPreDayStatusRowView {
    func setupUI() {
        addSubview(iconContainerView)
        addSubview(titleLabel)
        iconContainerView.addSubview(checkImageView)

        iconContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(3))
            make.width.height.equalTo(AICoachPrePopupLayout.rowIconSize)
            make.bottom.lessThanOrEqualToSuperview().offset(-kFitWidth(3))
        }

        checkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(10))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconContainerView.snp.right).offset(AICoachPrePopupLayout.rowLabelSpacing)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }

        update(isSelected: false)
    }
}
