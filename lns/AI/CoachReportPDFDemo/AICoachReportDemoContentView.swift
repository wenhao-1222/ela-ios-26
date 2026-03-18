//
//  AICoachReportDemoContentView.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import SnapKit
import UIKit

final class AICoachReportDemoContentView: UIView {
    private let report: AICoachReportDemoData
    private let contentWidth: CGFloat
    private let mainStack = UIStackView()
    private var widthConstraint: Constraint?
    private var keepTogetherViews: [UIView] = []

    init(report: AICoachReportDemoData, contentWidth: CGFloat) {
        self.report = report
        self.contentWidth = contentWidth
        super.init(frame: CGRect(x: 0, y: 0, width: contentWidth, height: 100))
        backgroundColor = AICoachReportDemoPalette.background
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fittingHeight() -> CGFloat {
        snp.remakeConstraints { make in
            self.widthConstraint = make.width.equalTo(contentWidth).constraint
        }
        setNeedsLayout()
        layoutIfNeeded()
        let size = systemLayoutSizeFitting(
            CGSize(width: contentWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return ceil(size.height)
    }

    func pageStartOffsets(usableHeight: CGFloat) -> [CGFloat] {
        layoutIfNeeded()

        let blockFrames = keepTogetherViews
            .map { $0.convert($0.bounds, to: self).integral }
            .sorted { $0.minY < $1.minY }

        guard blockFrames.isEmpty == false else { return [0] }

        var pageStarts: [CGFloat] = [0]
        var currentPageStart: CGFloat = 0

        for frame in blockFrames {
            if frame.maxY - currentPageStart <= usableHeight {
                continue
            }

            if frame.height <= usableHeight {
                currentPageStart = frame.minY
                pageStarts.append(currentPageStart)
                continue
            }

            var splitStart = max(currentPageStart + usableHeight, frame.minY)
            while frame.maxY - splitStart > usableHeight {
                pageStarts.append(splitStart)
                splitStart += usableHeight
            }
            currentPageStart = splitStart
            if pageStarts.last != currentPageStart {
                pageStarts.append(currentPageStart)
            }
        }

        return pageStarts
    }
}

private extension AICoachReportDemoContentView {
    func setupUI() {
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20))
        }

        let headerCard = makeHeaderCard()
        let summaryCard = makeSummaryCard()
        let chartRows = makeChartRows()
        let actionCard = makeActionCard()

        [headerCard, summaryCard, chartRows, actionCard].forEach {
            mainStack.addArrangedSubview($0)
        }

        registerKeepTogetherView(headerCard)
        registerKeepTogetherView(summaryCard)
        registerKeepTogetherView(actionCard)
    }

    func makeHeaderCard() -> UIView {
        let card = AICoachReportDemoGradientCardView()

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = report.reportTitle

        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.92)
        dateLabel.text = report.dateRangeText

        let goalLabel = UILabel()
        goalLabel.font = .systemFont(ofSize: 13, weight: .medium)
        goalLabel.textColor = UIColor.white.withAlphaComponent(0.92)
        goalLabel.text = report.targetText

        let completenessLabel = UILabel()
        completenessLabel.font = .systemFont(ofSize: 13, weight: .medium)
        completenessLabel.textColor = UIColor.white.withAlphaComponent(0.92)
        completenessLabel.numberOfLines = 0
        completenessLabel.text = report.completenessText

        let logoLabel = UILabel()
        logoLabel.font = .systemFont(ofSize: 14, weight: .bold)
        logoLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        logoLabel.textAlignment = .right
        logoLabel.text = "elavatine"

        card.addSubview(titleLabel)
        card.addSubview(dateLabel)
        card.addSubview(goalLabel)
        card.addSubview(completenessLabel)
        card.addSubview(logoLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(20)
            make.right.lessThanOrEqualTo(logoLabel.snp.left).offset(-12)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-20)
        }
        goalLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-20)
        }
        completenessLabel.snp.makeConstraints { make in
            make.top.equalTo(goalLabel.snp.bottom).offset(8)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-22)
        }
        logoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.right.equalToSuperview().offset(-20)
        }

        return card
    }

    func makeSummaryCard() -> UIView {
        let card = AICoachReportDemoCardView()

        let titleLabel = makeCardTitleLabel(report.weeklySummaryTitle)
        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = AICoachReportDemoPalette.textSecondary
        bodyLabel.numberOfLines = 0
        bodyLabel.text = report.weeklySummaryBody

        let sideBox = UIView()
        sideBox.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
        sideBox.layer.cornerRadius = 14

        let potentialTitle = UILabel()
        potentialTitle.font = .systemFont(ofSize: 11, weight: .medium)
        potentialTitle.textColor = AICoachReportDemoPalette.textSecondary
        potentialTitle.text = "本周潜力利用率"

        let potentialValue = UILabel()
        potentialValue.font = .systemFont(ofSize: 24, weight: .bold)
        potentialValue.textColor = AICoachReportDemoPalette.textPrimary
        potentialValue.text = report.weeklyPotentialValue

        let riskLabel = makeBulletLabel(report.riskTip)
        let actionLabel = makeBulletLabel(report.actionTip)

        card.addSubview(titleLabel)
        card.addSubview(bodyLabel)
        card.addSubview(sideBox)
        sideBox.addSubview(potentialTitle)
        sideBox.addSubview(potentialValue)
        sideBox.addSubview(riskLabel)
        sideBox.addSubview(actionLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-18)
            make.right.equalTo(sideBox.snp.left).offset(-14)
        }
        sideBox.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-18)
            make.width.equalTo(230)
            make.bottom.lessThanOrEqualToSuperview().offset(-18)
        }
        potentialTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(14)
        }
        potentialValue.snp.makeConstraints { make in
            make.top.equalTo(potentialTitle.snp.bottom).offset(4)
            make.left.equalTo(potentialTitle)
        }
        riskLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-14)
            make.left.equalTo(potentialValue.snp.right).offset(16)
        }
        actionLabel.snp.makeConstraints { make in
            make.top.equalTo(riskLabel.snp.bottom).offset(8)
            make.left.equalTo(riskLabel)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }

        return card
    }

    func makeChartRows() -> UIView {
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.spacing = 16

        let firstRow = UIStackView()
        firstRow.axis = .horizontal
        firstRow.spacing = 16
        firstRow.distribution = .fillEqually

        let secondRow = UIStackView()
        secondRow.axis = .horizontal
        secondRow.spacing = 16
        secondRow.distribution = .fillEqually

        firstRow.addArrangedSubview(makeWeightCard())
        firstRow.addArrangedSubview(makeCalorieCard())
        secondRow.addArrangedSubview(makeNutrientCard())
        secondRow.addArrangedSubview(makeTrainingCard())

        wrapper.addArrangedSubview(firstRow)
        wrapper.addArrangedSubview(secondRow)

        registerKeepTogetherView(firstRow)
        registerKeepTogetherView(secondRow)
        return wrapper
    }

    func registerKeepTogetherView(_ view: UIView) {
        keepTogetherViews.append(view)
    }

    func makeWeightCard() -> UIView {
        let chart = AICoachReportLineChartView(entries: report.weightEntries)
        return makeChartCard(
            title: "体重",
            chartView: chart,
            footerTexts: report.weightFootnotes
        )
    }

    func makeCalorieCard() -> UIView {
        let chart = AICoachReportBarChartView(entries: report.calorieEntries)
        return makeChartCard(
            title: "热量",
            chartView: chart,
            footerTexts: report.calorieFootnotes
        )
    }

    func makeNutrientCard() -> UIView {
        let chart = AICoachReportGroupedBarChartView(entries: report.nutrientEntries)
        let card = makeChartCard(
            title: "营养素",
            chartView: chart,
            footerTexts: report.nutrientFootnotes
        )

        let legend = UIStackView()
        legend.axis = .horizontal
        legend.spacing = 10
        legend.distribution = .fillEqually

        legend.addArrangedSubview(makeLegendItem(title: "碳水", color: AICoachReportDemoPalette.nutrientPurple))
        legend.addArrangedSubview(makeLegendItem(title: "蛋白质", color: AICoachReportDemoPalette.nutrientYellow))
        legend.addArrangedSubview(makeLegendItem(title: "脂肪", color: AICoachReportDemoPalette.nutrientOrange))

        if let stack = card.viewWithTag(9991) as? UIStackView {
            stack.insertArrangedSubview(legend, at: 1)
        }
        return card
    }

    func makeTrainingCard() -> UIView {
        let card = AICoachReportDemoCardView()

        let titleLabel = makeCardTitleLabel("力量训练部分")
        let bodyStack = UIStackView()
        bodyStack.axis = .vertical
        bodyStack.spacing = 10

        report.trainingEntries.forEach { item in
            bodyStack.addArrangedSubview(makeTrainingRow(item))
        }

        let footerStack = makeFootnoteStack(report.trainingFootnotes)

        card.addSubview(titleLabel)
        card.addSubview(bodyStack)
        card.addSubview(footerStack)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
        }
        bodyStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
        }
        footerStack.snp.makeConstraints { make in
            make.top.equalTo(bodyStack.snp.bottom).offset(16)
            make.left.equalTo(bodyStack)
            make.right.equalTo(bodyStack)
            make.bottom.equalToSuperview().offset(-18)
        }

        return card
    }

    func makeActionCard() -> UIView {
        let card = AICoachReportDemoCardView()

        let titleLabel = makeCardTitleLabel("下周行动建议")
        let bodyStack = UIStackView()
        bodyStack.axis = .vertical
        bodyStack.spacing = 12

        report.actionItems.forEach { item in
            bodyStack.addArrangedSubview(makeBulletLabel(item))
        }

        card.addSubview(titleLabel)
        card.addSubview(bodyStack)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
        }
        bodyStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-18)
        }

        return card
    }

    func makeChartCard(title: String, chartView: UIView, footerTexts: [String]) -> UIView {
        let card = AICoachReportDemoCardView()

        let titleLabel = makeCardTitleLabel(title)
        let footerStack = makeFootnoteStack(footerTexts)
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.tag = 9991

        chartView.snp.makeConstraints { make in
            make.height.equalTo(190)
        }

        contentStack.addArrangedSubview(chartView)
        contentStack.addArrangedSubview(footerStack)

        card.addSubview(titleLabel)
        card.addSubview(contentStack)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
        }
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-18)
        }

        return card
    }

    func makeFootnoteStack(_ texts: [String]) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        texts.forEach { text in
            let label = UILabel()
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = AICoachReportDemoPalette.textSecondary
            label.numberOfLines = 0
            label.text = text
            stack.addArrangedSubview(label)
        }
        return stack
    }

    func makeCardTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = AICoachReportDemoPalette.textPrimary
        label.text = text
        return label
    }

    func makeBulletLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AICoachReportDemoPalette.textSecondary
        label.numberOfLines = 0
        label.text = "•  \(text)"
        return label
    }

    func makeLegendItem(title: String, color: UIColor) -> UIView {
        let container = UIView()

        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 4

        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = AICoachReportDemoPalette.textSecondary
        label.text = title

        container.addSubview(dot)
        container.addSubview(label)
        dot.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        label.snp.makeConstraints { make in
            make.left.equalTo(dot.snp.right).offset(6)
            make.top.bottom.right.equalToSuperview()
        }

        return container
    }

    func makeTrainingRow(_ item: AICoachReportTrainingItem) -> UIView {
        let row = UIView()

        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = AICoachReportDemoPalette.textPrimary
        nameLabel.text = item.name

        let trackView = UIView()
        trackView.backgroundColor = AICoachReportDemoPalette.themeBlueLight
        trackView.layer.cornerRadius = 3

        let fillView = UIView()
        fillView.backgroundColor = AICoachReportDemoPalette.themeBlue
        fillView.layer.cornerRadius = 3

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 13, weight: .medium)
        valueLabel.textColor = AICoachReportDemoPalette.textSecondary
        valueLabel.text = "\(item.count)"

        row.addSubview(nameLabel)
        row.addSubview(trackView)
        trackView.addSubview(fillView)
        row.addSubview(valueLabel)

        let maxCount = max(report.trainingEntries.map(\.count).max() ?? 1, 1)
        let fillRatio = CGFloat(item.count) / CGFloat(maxCount)

        nameLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(24)
        }
        valueLabel.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
        }
        trackView.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.right.equalTo(valueLabel.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(6)
        }
        fillView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(trackView.snp.width).multipliedBy(fillRatio)
        }

        return row
    }
}

class AICoachReportDemoCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AICoachReportDemoPalette.cardBackground
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = AICoachReportDemoPalette.border.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 14
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class AICoachReportDemoGradientCardView: AICoachReportDemoCardView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 0
        gradientLayer.colors = [
            UIColor(red: 0.11, green: 0.52, blue: 0.98, alpha: 1).cgColor,
            UIColor(red: 0.02, green: 0.42, blue: 0.92, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 18
        layer.insertSublayer(gradientLayer, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
