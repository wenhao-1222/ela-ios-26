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
    private let firstPageUsableHeight: CGFloat
    private let mainStack = UIStackView()
    private var keepTogetherViews: [UIView] = []
    private let mainStackInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
    private let mainStackSpacing = CGFloat(18)
    private let chartRowSpacing = CGFloat(16)
    private let defaultTopRowChartHeight = PDFWidth(913)

    init(report: AICoachReportDemoData, contentWidth: CGFloat, firstPageUsableHeight: CGFloat) {
        self.report = report
        self.contentWidth = contentWidth
        self.firstPageUsableHeight = firstPageUsableHeight
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
        mainStack.spacing = mainStackSpacing
        addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(mainStackInsets)
        }

        let headerCard = makeHeaderCard()
        let summaryCard = makeSummaryCard()
        let topRowChartHeight = calculateTopRowChartHeight(
            headerCard: headerCard,
            summaryCard: summaryCard
        )
        let row1 = makeTopChartRow(chartHeight: topRowChartHeight)
        let row2 = makeBottomChartRow()
        let actionSection = makeNextPageActionSection()

        [headerCard, summaryCard, row1, row2, actionSection].forEach(mainStack.addArrangedSubview)
        mainStack.setCustomSpacing(chartRowSpacing, after: row1)
        keepTogetherViews = [headerCard, summaryCard, row1, row2, actionSection]
    }

    func makeHeaderCard() -> UIView {
        let card = AICoachReportDemoGradientCardView()
        card.snp.makeConstraints { make in
            make.height.equalTo(PDFWidth(362))
        }

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: PDFWidth(64), weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.text = report.reportTitle

        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: PDFWidth(38), weight: .regular)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.94)
        dateLabel.text = report.reportDateRange

        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = PDFWidth(55)
        bottomRow.alignment = .center
        bottomRow.distribution = .fillProportionally

        let targetLabel = UILabel()
        targetLabel.font = .systemFont(ofSize: PDFWidth(38), weight: .regular)
        targetLabel.textColor = UIColor.white.withAlphaComponent(0.94)
        targetLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        targetLabel.text = report.targetText

        let completenessLabel = UILabel()
        completenessLabel.font = .systemFont(ofSize: PDFWidth(38), weight: .regular)
        completenessLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        completenessLabel.numberOfLines = 1
        completenessLabel.text = report.completenessText

//        let logoLabel = UILabel()
//        logoLabel.font = .systemFont(ofSize: 11.5, weight: .bold)
//        logoLabel.textColor = UIColor.white.withAlphaComponent(0.3)
//        logoLabel.text = "elavatine"
        
        let bgIconImg = UIImageView()
        bgIconImg.setImgLocal(imgName: "ela_pro_ai_bg_icon")
        bgIconImg.contentMode = .scaleAspectFit
        
        let logoImg = UIImageView()
        logoImg.image = UIImage(named: "ela_icon_img")?.withTintColor(.white.withAlphaComponent(0.4))
        
        card.addSubview(titleLabel)
        card.addSubview(dateLabel)
        card.addSubview(bottomRow)
//        card.addSubview(logoLabel)
        card.addSubview(bgIconImg)
        card.addSubview(logoImg)
        bottomRow.addArrangedSubview(targetLabel)
        bottomRow.addArrangedSubview(completenessLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(PDFWidth(50))
            make.left.equalToSuperview().offset(PDFWidth(50))
            make.right.lessThanOrEqualTo(logoImg.snp.left).offset(-18)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(PDFWidth(24))
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualToSuperview().offset(-24)
        }
        bottomRow.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-PDFWidth(50))
        }
//        logoLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(27)
//            make.right.equalToSuperview().offset(-24)
//        }
        bgIconImg.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(PDFWidth(550))
        }
        logoImg.snp.makeConstraints { make in
            make.right.equalTo(PDFWidth(-48))
            make.width.equalTo(PDFWidth(233))
            make.height.equalTo(PDFWidth(42))
            make.top.equalTo(PDFWidth(70))
        }

        return card
    }

    func makeSummaryCard() -> UIView {
        let card = AICoachReportDemoCardView()
        card.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(PDFWidth(421))
        }

        let titleLabel = makeCardTitleLabel(report.weeklySummaryTitle)
        
        let summaryLabel = UILabel()
        summaryLabel.font = .systemFont(ofSize: PDFWidth(32), weight: .regular)
        summaryLabel.textColor = AICoachReportDemoPalette.textPrimary
        summaryLabel.numberOfLines = 0
        summaryLabel.text = makeSummaryBodyText()

        let sidePanel = UIView()
        sidePanel.backgroundColor = UIColor(hex: "F2F2F2")
        sidePanel.layer.cornerRadius = PDFWidth(30)

        let panelStack = UIStackView()
        panelStack.axis = .horizontal
        panelStack.alignment = .center
        panelStack.spacing = 18

        let potentialColumn = UIView()

        let potentialTitle = UILabel()
        potentialTitle.font = .systemFont(ofSize: PDFWidth(28), weight: .regular)
        potentialTitle.textColor = AICoachReportDemoPalette.textSecondary
        potentialTitle.textAlignment = .right
        potentialTitle.text = report.weeklyPotentialTitle

        let potentialValue = UILabel()
        potentialValue.attributedText = makePotentialValueText(report.weeklyPotentialValue)
        potentialValue.textAlignment = .right

        let riskView = makeSummaryPanelTipItem(report.riskTip)
        let actionView = makeSummaryPanelTipItem(report.actionTip)

        card.addSubview(titleLabel)
        card.addSubview(summaryLabel)
        card.addSubview(sidePanel)
        sidePanel.addSubview(panelStack)
        panelStack.addArrangedSubview(potentialColumn)
        panelStack.addArrangedSubview(riskView)
        panelStack.addArrangedSubview(actionView)
        potentialColumn.addSubview(potentialTitle)
        potentialColumn.addSubview(potentialValue)
//        potentialColumn.backgroundColor = WHColor_ARC()

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }
        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-20)
        }
        sidePanel.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel.snp.bottom).offset(PDFWidth(40))
            make.left.equalToSuperview().offset(PDFWidth(50))
            make.right.equalToSuperview().offset(PDFWidth(-50))
            make.bottom.equalToSuperview().offset(PDFWidth(-50))
        }
        panelStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18))
        }
        potentialColumn.snp.makeConstraints { make in
            make.width.equalTo(108)
            make.left.equalTo(PDFWidth(-50))
        }
        potentialTitle.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        potentialValue.snp.makeConstraints { make in
            make.top.equalTo(potentialTitle.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        riskView.snp.makeConstraints { make in
            make.width.equalTo(actionView)
        }
        actionView.snp.makeConstraints { make in
            make.width.equalTo(riskView)
        }

        return card
    }

    func makeSummaryBodyText() -> String {
        let summaryLines = report.weeklySummaryLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
        let summaryText = summaryLines.joined(separator: " ")
        let confidenceText = report.confidenceText.trimmingCharacters(in: .whitespacesAndNewlines)

        if confidenceText.isEmpty {
            return summaryText
        }
        if summaryText.isEmpty {
            return appendFullStopIfNeeded(confidenceText)
        }
        if summaryText.contains(confidenceText) {
            return appendFullStopIfNeeded(summaryText)
        }
        return appendFullStopIfNeeded(summaryText) + " " + appendFullStopIfNeeded(confidenceText)
    }

    func appendFullStopIfNeeded(_ text: String) -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.isEmpty == false else { return "" }
        if let lastCharacter = trimmedText.last,
           "。！？.!?".contains(lastCharacter) {
            return trimmedText
        }
        return trimmedText + "。"
    }

    func makePotentialValueText(_ text: String) -> NSAttributedString {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let percentSuffix = trimmedText.hasSuffix("%") ? "%" : ""
        let numberText = percentSuffix.isEmpty ? trimmedText : String(trimmedText.dropLast())
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: PDFWidth(48), weight: .medium),
            .foregroundColor: AICoachReportDemoPalette.textPrimary
        ]
        let percentAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: PDFWidth(24), weight: .medium),
            .baselineOffset: PDFWidth(-2),
            .foregroundColor: AICoachReportDemoPalette.textPrimary
        ]

        let attributedText = NSMutableAttributedString(string: numberText, attributes: numberAttributes)
        if percentSuffix.isEmpty == false {
            attributedText.append(NSAttributedString(string: percentSuffix, attributes: percentAttributes))
        }
        return attributedText
    }

    func makeSummaryPanelTipItem(_ text: String) -> UIView {
        let row = UIView()

        let dot = UIView()
        dot.backgroundColor = AICoachReportDemoPalette.bulletBlue
        dot.layer.cornerRadius = PDFWidth(5)

        let label = UILabel()
        label.font = .systemFont(ofSize: PDFWidth(32), weight: .regular)
        label.textColor = AICoachReportDemoPalette.textPrimary
        label.numberOfLines = 0
        label.text = text

        row.addSubview(dot)
        row.addSubview(label)

        dot.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(label.snp.top).offset(PDFWidth(16))
            make.width.height.equalTo(PDFWidth(10))
        }
        label.snp.makeConstraints { make in
            make.left.equalTo(dot.snp.right).offset(PDFWidth(12))
            make.top.bottom.right.equalToSuperview()
        }

        return row
    }

    func makeTopChartRow(chartHeight: CGFloat) -> UIView {
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = chartRowSpacing
        row1.distribution = .fillEqually
        row1.addArrangedSubview(makeWeightCard(chartHeight: chartHeight))
        row1.addArrangedSubview(makeCalorieCard(chartHeight: chartHeight))
        return row1
    }

    func makeBottomChartRow() -> UIView {
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = chartRowSpacing
        row2.distribution = .fillEqually
        row2.addArrangedSubview(makeNutrientCard())
        row2.addArrangedSubview(makeTrainingCard())
        return row2
    }

    func makeWeightCard(chartHeight: CGFloat) -> UIView {
        let chart = AICoachReportLineChartView(data: report.weightChart)
        let footer = makeFooterRows(report.weightChart.footerRows)
        return makeChartCard(title: "体重", chartView: chart, footerView: footer, chartHeight: chartHeight)
    }

    func makeCalorieCard(chartHeight: CGFloat) -> UIView {
        let chart = AICoachReportBarChartView(data: report.calorieChart)
        let footer = makeFooterRows(report.calorieChart.footerRows)
        return makeChartCard(title: "热量", chartView: chart, footerView: footer, chartHeight: chartHeight)
    }

    func calculateTopRowChartHeight(headerCard: UIView, summaryCard: UIView) -> CGFloat {
        let stackWidth = contentWidth - mainStackInsets.left - mainStackInsets.right
        let chartCardWidth = (stackWidth - chartRowSpacing) / 2

        let headerHeight = fittedHeight(for: headerCard, width: stackWidth)
        let summaryHeight = fittedHeight(for: summaryCard, width: stackWidth)

        let weightFixedHeight = fittedHeight(
            for: makeWeightCard(chartHeight: 1),
            width: chartCardWidth
        ) - 1
        let calorieFixedHeight = fittedHeight(
            for: makeCalorieCard(chartHeight: 1),
            width: chartCardWidth
        ) - 1
        let topRowFixedHeight = max(weightFixedHeight, calorieFixedHeight)

        let availableTopRowHeight = firstPageUsableHeight
            - mainStackInsets.top
            - headerHeight
            - mainStackSpacing
            - summaryHeight
            - mainStackSpacing

        let preferredHeight = min(defaultTopRowChartHeight, availableTopRowHeight - topRowFixedHeight)
        return max(1, floor(preferredHeight))
    }

    func fittedHeight(for view: UIView, width: CGFloat) -> CGFloat {
        view.frame = CGRect(x: 0, y: 0, width: width, height: 10)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let size = view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return ceil(size.height)
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

    func makeCardTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: PDFWidth(42), weight: .semibold)
        label.textColor = AICoachReportDemoPalette.textPrimary
        label.text = text
        return label
    }
}

class AICoachReportDemoCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AICoachReportDemoPalette.cardBackground
        layer.cornerRadius = PDFWidth(30)
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
