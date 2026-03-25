//
//  AICoachPreInfoVM.swift
//  lns
//
//  Created by Codex on 2026/3/25.
//

import UIKit
import SnapKit

class AICoachPreInfoVM: UIView {

    let selfHeight = kFitHeight(110)

    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(16)
        view.layer.cornerCurve = .continuous
        return view
    }()

    private lazy var goalRowView = AICoachPreInfoRowView(title: "目标")
    private lazy var intensityRowView = AICoachPreInfoRowView(title: "强度")

    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        initUI()
        configure(userGoal: 0, aiCoachIntensityPreference: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AICoachPreInfoVM {
    func configure(userGoal: Int, aiCoachIntensityPreference: Int) {
        goalRowView.updateValue(text: goalText(for: userGoal))
        intensityRowView.updateValue(text: intensityText(for: aiCoachIntensityPreference))
    }
}

private extension AICoachPreInfoVM {
    func initUI() {
        addSubview(cardView)
        cardView.addSubview(goalRowView)
        cardView.addSubview(separatorLine)
        cardView.addSubview(intensityRowView)

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.bottom.equalToSuperview()
        }

        goalRowView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(54))
        }

        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(goalRowView.snp.bottom)
            make.height.equalTo(1)
        }

        intensityRowView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(54))
        }
    }

    func goalText(for userGoal: Int) -> String {
        switch userGoal {
        case 1: return "减脂"
        case 2: return "增肌"
        default: return "--"
        }
    }

    func intensityText(for preference: Int) -> String {
        switch preference {
        case 1: return "非常放松"
        case 2: return "放松"
        case 3: return "正常"
        case 4: return "健身爱好者"
        case 5: return "职业运动员"
        default: return "--"
        }
    }
}

private final class AICoachPreInfoRowView: UIView {

    private let title: String

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .COLOR_TEXT_TITLE_0f1214
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    func updateValue(text: String) {
        valueLabel.text = text
    }
}

private extension AICoachPreInfoRowView {
    func setupUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(arrowImageView)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.equalToSuperview()
        }

        arrowImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalToSuperview()
            make.width.equalTo(kFitWidth(8))
            make.height.equalTo(kFitWidth(13))
        }

        valueLabel.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(kFitWidth(12))
            make.right.equalTo(arrowImageView.snp.left).offset(kFitWidth(-10))
            make.centerY.equalToSuperview()
        }
    }
}
