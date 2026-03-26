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
    private var keepTogetherViews: [UIView] = []

    init(report: AICoachReportDemoData, contentWidth: CGFloat) {
        self.report = report
        self.contentWidth = contentWidth
        super.init(frame: CGRect(x: 0, y: 0, width: contentWidth, height: 100))
        backgroundColor = AICoachReportDemoPalette.pageBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fittingHeight() -> CGFloat {
        frame.size.width = contentWidth
        setNeedsLayout()
        layoutIfNeeded()
        let targetSize = CGSize(width: contentWidth, height: UIView.layoutFittingCompressedSize.height)
        let size = systemLayoutSizeFitting(
            targetSize,
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
        addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 18, left: 10, bottom: 18, right: 10))
        }

        let headerCard = makeHeaderCard()
        let summaryCard = makeSummaryCard()
        let charts = makeChartRows()
        let actionSection = makeNextPageActionSection()

        [headerCard, summaryCard, charts, actionSection].forEach(mainStack.addArrangedSubview)
        keepTogetherViews = [headerCard, summaryCard, charts, actionSection]
    }

    func makeHeaderCard() -> UIView {
        let card = AICoachReportDemoGradientCardView()
        card.snp.makeConstraints { make in
            make.height.equalTo(146)
        }

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 19.5, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = report.reportTitle

        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.94)
        dateLabel.text = report.reportDateRange

        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = 22
        bottomRow.alignment = .center
        bottomRow.distribution = .fillProportionally

        let targetLabel = UILabel()
        targetLabel.font = .systemFont(ofSize: 12.5, weight: .medium)
        targetLabel.textColor = UIColor.white.withAlphaComponent(0.94)
        targetLabel.text = report.targetText

        let completenessLabel = UILabel()
        completenessLabel.font = .systemFont(ofSize: 12.5, weight: .medium)
        completenessLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        completenessLabel.text = report.completenessText

        let logoLabel = UILabel()
        logoLabel.font = .systemFont(ofSize: 11, weight: .bold)
        logoLabel.textColor = UIColor.white.withAlphaComponent(0.3)
        logoLabel.text = "elavatine"

        card.addSubview(titleLabel)
        card.addSubview(dateLabel)
        card.addSubview(bottomRow)
        card.addSubview(logoLabel)
        bottomRow.addArrangedSubview(targetLabel)
        bottomRow.addArrangedSubview(completenessLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23)
            make.left.equalToSuperview().offset(20)
            make.right.lessThanOrEqualTo(logoLabel.snp.left).offset(-16)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(13)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }
        bottomRow.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-21)
        }
        logoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26)
            make.right.equalToSuperview().offset(-19)
        }

        return card
    }

    func makeSummaryCard() -> UIView {
        let card = AICoachReportDemoCardView()
        card.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(152)
        }

        let titleLabel = makeCardTitleLabel(report.weeklySummaryTitle)

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 8

        report.weeklySummaryLines.forEach { line in
            let label = UILabel()
            label.font = .systemFont(ofSize: 12.5, weight: .regular)
            label.textColor = AICoachReportDemoPalette.textSecondary
            label.numberOfLines = 0
            label.text = line
            textStack.addArrangedSubview(label)
        }

        let confidenceLabel = UILabel()
        confidenceLabel.font = .systemFont(ofSize: 12.5, weight: .medium)
        confidenceLabel.textColor = AICoachReportDemoPalette.textSecondary
        confidenceLabel.numberOfLines = 0
        confidenceLabel.text = report.confidenceText
        textStack.addArrangedSubview(confidenceLabel)

        let sidePanel = UIView()
        sidePanel.backgroundColor = UIColor(hex: "F2F2F3")
        sidePanel.layer.cornerRadius = 13

        let potentialTitle = UILabel()
        potentialTitle.font = .systemFont(ofSize: 11.5, weight: .medium)
        potentialTitle.textColor = AICoachReportDemoPalette.textSecondary
        potentialTitle.text = report.weeklyPotentialTitle

        let potentialValue = UILabel()
        potentialValue.font = .systemFont(ofSize: 25, weight: .bold)
        potentialValue.textColor = AICoachReportDemoPalette.textPrimary
        potentialValue.text = report.weeklyPotentialValue

        let tipsStack = UIStackView()
        tipsStack.axis = .vertical
        tipsStack.spacing = 8
        tipsStack.addArrangedSubview(makeSummaryTipRow(report.riskTip))
        tipsStack.addArrangedSubview(makeSummaryTipRow(report.actionTip))

        card.addSubview(titleLabel)
        card.addSubview(textStack)
        card.addSubview(sidePanel)
        sidePanel.addSubview(potentialTitle)
        sidePanel.addSubview(potentialValue)
        sidePanel.addSubview(tipsStack)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.left.equalToSuperview().offset(19)
        }
        textStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-18)
            make.right.equalTo(sidePanel.snp.left).offset(-14)
        }
        sidePanel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(11)
            make.right.equalToSuperview().offset(-18)
            make.width.equalTo(248)
            make.bottom.equalToSuperview().offset(-18)
        }
        potentialTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(17)
        }
        potentialValue.snp.makeConstraints { make in
            make.left.equalTo(potentialTitle)
            make.top.equalTo(potentialTitle.snp.bottom).offset(2)
            make.bottom.lessThanOrEqualToSuperview().offset(-14)
        }
        tipsStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(potentialValue.snp.right).offset(18)
            make.right.equalToSuperview().offset(-13)
            make.bottom.equalToSuperview().offset(-14)
        }

        return card
    }

    func makeChartRows() -> UIView {
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.spacing = 16

        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 16
        row1.distribution = .fillEqually
        row1.addArrangedSubview(makeWeightCard())
        row1.addArrangedSubview(makeCalorieCard())

        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 16
        row2.distribution = .fillEqually
        row2.addArrangedSubview(makeNutrientCard())
        row2.addArrangedSubview(makeTrainingCard())

        wrapper.addArrangedSubview(row1)
        wrapper.addArrangedSubview(row2)
        return wrapper
    }

    func makeWeightCard() -> UIView {
        let chart = AICoachReportLineChartView(data: report.weightChart)
        let footer = makeFooterRows(report.weightChart.footerRows)
        return makeChartCard(title: "体重", chartView: chart, footerView: footer, chartHeight: 176)
    }

    func makeCalorieCard() -> UIView {
        let chart = AICoachReportBarChartView(data: report.calorieChart)
        let footer = makeFooterRows(report.calorieChart.footerRows)
        return makeChartCard(title: "热量", chartView: chart, footerView: footer, chartHeight: 176)
    }

    func makeNutrientCard() -> UIView {
        let chart = AICoachReportGroupedBarChartView(data: report.nutrientChart)

        let footer = UIView()
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = AICoachReportDemoPalette.textSecondary
        titleLabel.text = "本周营养素摄入均值及热量贡献"

        let legendStack = UIStackView()
        legendStack.axis = .horizontal
        legendStack.spacing = 8
        legendStack.distribution = .fillEqually
        report.nutrientChart.legendItems.forEach { item in
            legendStack.addArrangedSubview(makeLegendColumn(item))
        }

        footer.addSubview(titleLabel)
        footer.addSubview(legendStack)
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        legendStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }

        return makeChartCard(title: "营养素", chartView: chart, footerView: footer, chartHeight: 158)
    }

    func makeTrainingCard() -> UIView {
        let card = AICoachReportDemoCardView()

        let titleLabel = makeCardTitleLabel("力量训练部分")
        let columnStack = UIStackView()
        columnStack.axis = .horizontal
        columnStack.spacing = 18
        columnStack.distribution = .fillEqually

        let leftColumn = makeTrainingColumn(report.trainingChart.leftItems)
        let rightColumn = makeTrainingColumn(report.trainingChart.rightItems)
        columnStack.addArrangedSubview(leftColumn)
        columnStack.addArrangedSubview(rightColumn)

        let bottomLeft = UILabel()
        bottomLeft.font = .systemFont(ofSize: 12.5, weight: .medium)
        bottomLeft.textColor = AICoachReportDemoPalette.textSecondary
        bottomLeft.text = report.trainingChart.bottomLeftText

        let bottomRight = UILabel()
        bottomRight.font = .systemFont(ofSize: 12.5, weight: .medium)
        bottomRight.textColor = AICoachReportDemoPalette.textSecondary
        bottomRight.textAlignment = .right
        bottomRight.text = report.trainingChart.bottomRightText

        card.addSubview(titleLabel)
        card.addSubview(columnStack)
        card.addSubview(bottomLeft)
        card.addSubview(bottomRight)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(18)
        }
        columnStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(17)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
        }
        bottomLeft.snp.makeConstraints { make in
            make.left.equalTo(columnStack)
            make.top.equalTo(columnStack.snp.bottom).offset(18)
            make.bottom.equalToSuperview().offset(-18)
        }
        bottomRight.snp.makeConstraints { make in
            make.right.equalTo(columnStack)
            make.centerY.equalTo(bottomLeft)
        }

        return card
    }

    func makeNextPageActionSection() -> UIView {
        let section = UIView()

        let header = UIView()
        header.backgroundColor = AICoachReportDemoPalette.themeBlue
        header.layer.cornerRadius = 18

        let headerTitle = UILabel()
        headerTitle.font = .systemFont(ofSize: 17, weight: .semibold)
        headerTitle.textColor = .white
        headerTitle.text = report.nextPageTitle

        let body = AICoachReportDemoCardView()
        body.layer.cornerRadius = 18
        body.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        let bodyStack = UIStackView()
        bodyStack.axis = .vertical
        bodyStack.spacing = 12

        report.nextPageItems.forEach { item in
            let row = makeBlueBulletRow(item, textColor: AICoachReportDemoPalette.textSecondary)
            bodyStack.addArrangedSubview(row)
        }

        section.addSubview(header)
        section.addSubview(body)
        header.addSubview(headerTitle)
        body.addSubview(bodyStack)

        header.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(58)
        }
        headerTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        body.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(-4)
            make.left.right.bottom.equalToSuperview()
        }
        bodyStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 26, left: 20, bottom: 24, right: 20))
        }

        return section
    }

    func makeChartCard(title: String, chartView: UIView, footerView: UIView, chartHeight: CGFloat) -> UIView {
        let card = AICoachReportDemoCardView()
        let titleLabel = makeCardTitleLabel(title)

        card.addSubview(titleLabel)
        card.addSubview(chartView)
        card.addSubview(footerView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(18)
        }
        chartView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(chartHeight)
        }
        footerView.snp.makeConstraints { make in
            make.top.equalTo(chartView.snp.bottom).offset(11)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-18)
        }

        return card
    }

    func makeFooterRows(_ rows: [AICoachReportFooterRow]) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6

        rows.forEach { row in
            let line = UIView()
            let leftLabel = UILabel()
            leftLabel.font = .systemFont(ofSize: 12, weight: .medium)
            leftLabel.textColor = AICoachReportDemoPalette.textSecondary
            leftLabel.text = row.leftText

            line.addSubview(leftLabel)
            leftLabel.snp.makeConstraints { make in
                make.left.top.bottom.equalToSuperview()
            }

            if let rightText = row.rightText {
                let rightLabel = UILabel()
                rightLabel.font = .systemFont(ofSize: 12, weight: .medium)
                rightLabel.textColor = AICoachReportDemoPalette.textSecondary
                rightLabel.textAlignment = .right
                rightLabel.text = rightText
                line.addSubview(rightLabel)
                rightLabel.snp.makeConstraints { make in
                    make.right.top.bottom.equalToSuperview()
                    make.left.greaterThanOrEqualTo(leftLabel.snp.right).offset(12)
                }
            } else {
                leftLabel.snp.makeConstraints { make in
                    make.right.equalToSuperview()
                }
            }

            stack.addArrangedSubview(line)
        }

        return stack
    }

    func makeTrainingColumn(_ items: [AICoachReportTrainingItem]) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 11
        items.forEach { stack.addArrangedSubview(makeTrainingRow($0)) }
        return stack
    }

    func makeTrainingRow(_ item: AICoachReportTrainingItem) -> UIView {
        let row = UIView()

        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 12.5, weight: .semibold)
        nameLabel.textColor = AICoachReportDemoPalette.textSecondary
        nameLabel.text = item.title

        let barTrack = UIView()
        barTrack.backgroundColor = .clear

        let barFill = UIView()
        barFill.backgroundColor = AICoachReportDemoPalette.themeBlue
        barFill.layer.cornerRadius = 2

        let countLabel = UILabel()
        countLabel.font = .systemFont(ofSize: 12.5, weight: .medium)
        countLabel.textColor = AICoachReportDemoPalette.textSecondary
        countLabel.text = "\(item.count)"

        row.addSubview(nameLabel)
        row.addSubview(barTrack)
        barTrack.addSubview(barFill)
        row.addSubview(countLabel)

        nameLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(14)
        }
        countLabel.snp.makeConstraints { make in
            make.left.equalTo(barTrack.snp.right).offset(9)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        barTrack.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.width.equalTo(76)
            make.centerY.equalToSuperview()
            make.height.equalTo(4)
        }
        barFill.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(barTrack.snp.width).multipliedBy(CGFloat(item.count) / CGFloat(max(item.maxCount, 1)))
        }

        return row
    }

    func makeLegendColumn(_ item: AICoachReportLegendItem) -> UIView {
        let container = UIView()

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.spacing = 4
        topRow.alignment = .center

        let dot = UIView()
        dot.backgroundColor = item.color
        dot.layer.cornerRadius = 3
        dot.snp.makeConstraints { make in
            make.width.height.equalTo(6)
        }

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 11.5, weight: .medium)
        titleLabel.textColor = AICoachReportDemoPalette.textSecondary
        titleLabel.text = item.title

        let percentLabel = UILabel()
        percentLabel.font = .systemFont(ofSize: 11.5, weight: .regular)
        percentLabel.textColor = AICoachReportDemoPalette.textSecondary
        percentLabel.text = item.percentText

        container.addSubview(topRow)
        container.addSubview(percentLabel)
        topRow.addArrangedSubview(dot)
        topRow.addArrangedSubview(titleLabel)

        topRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        percentLabel.snp.makeConstraints { make in
            make.top.equalTo(topRow.snp.bottom).offset(6)
            make.left.right.bottom.equalToSuperview()
        }

        return container
    }

    func makeBlueBulletRow(_ text: String, textColor: UIColor = AICoachReportDemoPalette.textSecondary) -> UIView {
        let row = UIView()

        let dot = UIView()
        dot.backgroundColor = AICoachReportDemoPalette.bulletBlue
        dot.layer.cornerRadius = 2

        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = textColor
        label.numberOfLines = 0
        label.text = text

        row.addSubview(dot)
        row.addSubview(label)
        dot.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.width.height.equalTo(4)
        }
        label.snp.makeConstraints { make in
            make.left.equalTo(dot.snp.right).offset(8)
            make.top.right.bottom.equalToSuperview()
        }

        return row
    }

    func makeSummaryTipRow(_ text: String) -> UIView {
        let row = UIView()

        let dot = UIView()
        dot.backgroundColor = AICoachReportDemoPalette.bulletBlue
        dot.layer.cornerRadius = 2

        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AICoachReportDemoPalette.textSecondary
        label.numberOfLines = 0
        label.text = text

        row.addSubview(dot)
        row.addSubview(label)

        dot.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(4)
        }
        label.snp.makeConstraints { make in
            make.left.equalTo(dot.snp.right).offset(7)
            make.top.right.bottom.equalToSuperview()
        }

        return row
    }

    func makeCardTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = AICoachReportDemoPalette.textPrimary
        label.text = text
        return label
    }
}

class AICoachReportDemoCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AICoachReportDemoPalette.cardBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = AICoachReportDemoPalette.border.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.02
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4
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
        layer.shadowOpacity = 0
        gradientLayer.colors = [
            UIColor(hex: "1F81F2").cgColor,
            UIColor(hex: "1677EF").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.45)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.55)
        gradientLayer.cornerRadius = 14
        layer.cornerRadius = 14
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
