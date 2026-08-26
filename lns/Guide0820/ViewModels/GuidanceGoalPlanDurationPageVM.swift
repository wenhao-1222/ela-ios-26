//
//  GuidanceGoalPlanDurationPageVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit
import SnapKit

class GuidanceGoalPlanDurationPageVM: UIView, GuidanceGoalPlanPageVM {
    var selectionChanged: (() -> Void)?
    var weeksChanged: ((Int) -> Void)?

    private let titleText: String
    private let accentColor: UIColor
    private var recommendedWeeks: Int
    private var recommendationTitle: String
    private var recommendationDetail: String
    private let weekLabel = UILabel()
    private let recommendationTitleLabel = UILabel()
    private let recommendationDetailLabel = UILabel()

    var weeks: Int {
        didSet {
            weeks = min(max(weeks, 1), 52)
            weekLabel.text = "\(weeks)"
            weeksChanged?(weeks)
            selectionChanged?()
        }
    }

    var hasSelection: Bool {
        weeks > 0
    }

    init(title: String, accentColor: UIColor, defaultWeeks: Int, recommendationTitle: String, recommendationDetail: String) {
        self.titleText = title
        self.accentColor = accentColor
        self.recommendedWeeks = defaultWeeks
        self.recommendationTitle = recommendationTitle
        self.recommendationDetail = recommendationDetail
        self.weeks = defaultWeeks
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateRecommendation(defaultWeeks: Int, title: String, detail: String) {
        recommendedWeeks = defaultWeeks
        recommendationTitle = title
        recommendationDetail = detail
        weeks = defaultWeeks
        recommendationTitleLabel.text = title
        recommendationDetailLabel.text = detail
    }

    func pageWillAppear() {
        weekLabel.text = "\(weeks)"
        recommendationTitleLabel.text = recommendationTitle
        recommendationDetailLabel.text = recommendationDetail
    }
}

private extension GuidanceGoalPlanDurationPageVM {
    func initUI() {
        backgroundColor = GuidanceGoalPlanStyle.pageBackgroundColor

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.textColor = GuidanceGoalPlanStyle.titleColor
        titleLabel.font = .systemFont(ofSize: 24, weight: .medium)
        titleLabel.numberOfLines = 0

        let cardView = UIView()
        cardView.backgroundColor = GuidanceGoalPlanStyle.cardBackgroundColor
        cardView.layer.cornerRadius = kFitWidth(16)

        let minusButton = makeRoundButton(title: "-", fontSize: 28)
        let plusButton = makeRoundButton(title: "+", fontSize: 24)
        minusButton.addTarget(self, action: #selector(minusTapAction), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapAction), for: .touchUpInside)

        weekLabel.text = "\(weeks)"
        weekLabel.textAlignment = .center
        weekLabel.textColor = accentColor
        weekLabel.font = UIFont().DDInFontMedium(fontSize: 46)

        let unitLabel = UILabel()
        unitLabel.text = "周"
        unitLabel.textColor = GuidanceGoalPlanStyle.detailColor
        unitLabel.font = .systemFont(ofSize: 16, weight: .regular)

        recommendationTitleLabel.text = recommendationTitle
        recommendationTitleLabel.textColor = GuidanceGoalPlanStyle.titleColor
        recommendationTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        recommendationTitleLabel.numberOfLines = 0

        recommendationDetailLabel.text = recommendationDetail
        recommendationDetailLabel.textColor = GuidanceGoalPlanStyle.detailColor
        recommendationDetailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        recommendationDetailLabel.numberOfLines = 0

        addSubview(titleLabel)
        addSubview(cardView)
        cardView.addSubview(minusButton)
        cardView.addSubview(plusButton)
        cardView.addSubview(weekLabel)
        cardView.addSubview(unitLabel)
        cardView.addSubview(recommendationTitleLabel)
        cardView.addSubview(recommendationDetailLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(kFitWidth(22))
        }

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(42))
        }

        weekLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kFitWidth(28))
        }

        unitLabel.snp.makeConstraints { make in
            make.left.equalTo(weekLabel.snp.right).offset(kFitWidth(4))
            make.lastBaseline.equalTo(weekLabel.snp.lastBaseline).offset(kFitWidth(-6))
        }

        minusButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(28))
            make.centerY.equalTo(weekLabel)
            make.width.height.equalTo(kFitWidth(44))
        }

        plusButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-28))
            make.centerY.equalTo(weekLabel)
            make.width.height.equalTo(kFitWidth(44))
        }

        recommendationTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(weekLabel.snp.bottom).offset(kFitWidth(30))
        }

        recommendationDetailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(recommendationTitleLabel)
            make.top.equalTo(recommendationTitleLabel.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalTo(kFitWidth(-24))
        }
    }

    func makeRoundButton(title: String, fontSize: CGFloat) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(accentColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: fontSize, weight: .medium)
        button.backgroundColor = accentColor.withAlphaComponent(0.12)
        button.layer.cornerRadius = kFitWidth(22)
        button.enablePressEffect()
        return button
    }

    @objc func minusTapAction() {
        weeks -= 1
    }

    @objc func plusTapAction() {
        weeks += 1
    }
}

