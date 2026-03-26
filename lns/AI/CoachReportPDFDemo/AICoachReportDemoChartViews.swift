//
//  AICoachReportDemoChartViews.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit

private let chartXAxisLabelFont = UIFont.systemFont(ofSize: 8.5, weight: .regular)
private let chartYAxisLabelFont = UIFont.systemFont(ofSize: 8, weight: .regular)
private let chartXAxisLabelAngle = -CGFloat.pi / 5

final class AICoachReportLineChartView: UIView {
    private let data: AICoachReportLineChartData

    init(data: AICoachReportLineChartData) {
        self.data = data
        super.init(frame: .zero)
        backgroundColor = .clear
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), data.entries.isEmpty == false else { return }

        let yAxisWidth = yAxisReservedWidth(for: data.yAxisTexts)
        let chartInsets = UIEdgeInsets(top: 14, left: yAxisWidth + 14, bottom: 36, right: 8)
        let chartRect = rect.inset(by: chartInsets)
        let xAxisInset = xAxisEdgeInset(for: data.entries.map(\.axisLabel), availableWidth: chartRect.width)
        let plottingRect = chartRect.insetBy(dx: xAxisInset, dy: 0)
        let stepX = plottingRect.width / CGFloat(max(data.entries.count - 1, 1))

        drawYAxis(in: context, rect: chartRect, labels: data.yAxisTexts)

        let points = data.entries.enumerated().compactMap { index, entry -> (index: Int, point: CGPoint)? in
            guard let plottedValue = entry.plottedValue else { return nil }
            let x = plottingRect.minX + CGFloat(index) * stepX
            let ratio = (plottedValue - data.minValue) / max(data.maxValue - data.minValue, 1)
            let y = chartRect.maxY - ratio * chartRect.height
            return (index, CGPoint(x: x, y: y))
        }

        if points.count > 1 {
            let fillPath = UIBezierPath()
            fillPath.move(to: CGPoint(x: points.first?.point.x ?? chartRect.minX, y: chartRect.maxY))
            points.forEach { fillPath.addLine(to: $0.point) }
            fillPath.addLine(to: CGPoint(x: points.last?.point.x ?? chartRect.maxX, y: chartRect.maxY))
            fillPath.close()

            context.saveGState()
            fillPath.addClip()
            let colors = [
                AICoachReportDemoPalette.chartFillBlue.withAlphaComponent(0.72).cgColor,
                AICoachReportDemoPalette.chartFillBlue.withAlphaComponent(0.12).cgColor
            ] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: chartRect.midX, y: chartRect.minY),
                end: CGPoint(x: chartRect.midX, y: chartRect.maxY),
                options: []
            )
            context.restoreGState()

            let linePath = UIBezierPath()
            linePath.lineWidth = 2
            linePath.lineJoinStyle = .round
            linePath.lineCapStyle = .round
            if let firstPoint = points.first {
                linePath.move(to: firstPoint.point)
            }
            points.forEach { linePath.addLine(to: $0.point) }
            AICoachReportDemoPalette.themeBlue.setStroke()
            linePath.stroke()
        }

        for (index, entry) in data.entries.enumerated() {
            let x = plottingRect.minX + CGFloat(index) * stepX
            if entry.axisLabel.isEmpty == false {
                drawXAxisLabel(
                    entry.axisLabel,
                    center: CGPoint(x: x, y: chartRect.maxY + 10),
                    minX: rect.minX + 4,
                    maxX: rect.maxX - 4
                )
            }
        }

        for pointItem in points {
            let entry = data.entries[pointItem.index]
            let point = pointItem.point
            let pointRect = CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)
            let circle = UIBezierPath(ovalIn: pointRect)
            UIColor.white.setFill()
            circle.fill()
            AICoachReportDemoPalette.themeBlue.setStroke()
            circle.lineWidth = 1.5
            circle.stroke()

            if entry.valueText.isEmpty == false {
                let valueText = entry.valueText as NSString
                valueText.draw(
                    in: CGRect(x: point.x - 12, y: point.y - 18, width: 24, height: 12),
                    withAttributes: [
                        .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
                        .foregroundColor: AICoachReportDemoPalette.themeBlue
                    ]
                )
            }

        }
    }
}

final class AICoachReportBarChartView: UIView {
    private let data: AICoachReportBarChartData

    init(data: AICoachReportBarChartData) {
        self.data = data
        super.init(frame: .zero)
        backgroundColor = .clear
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard data.entries.isEmpty == false else { return }

        let yAxisWidth = yAxisReservedWidth(for: data.yAxisTexts)
        let chartInsets = UIEdgeInsets(top: 14, left: yAxisWidth + 14, bottom: 36, right: 8)
        let chartRect = rect.inset(by: chartInsets)
        let step = chartRect.width / CGFloat(data.entries.count)
        let barWidth = min(17, step * 0.46)

        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawYAxis(in: context, rect: chartRect, labels: data.yAxisTexts)

        for (index, entry) in data.entries.enumerated() {
            let x = chartRect.minX + CGFloat(index) * step + (step - barWidth) / 2
            let labelCenterX = chartRect.minX + CGFloat(index) * step + step / 2
            if let value = entry.value {
                let barHeight = (value / max(data.maxValue, 1)) * chartRect.height
                let y = chartRect.maxY - barHeight
                let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                let barPath = UIBezierPath(rect: barRect)
                AICoachReportDemoPalette.themeBlue.setFill()
                barPath.fill()
            }

            drawXAxisLabel(
                entry.axisLabel,
                center: CGPoint(x: labelCenterX, y: chartRect.maxY + 10),
                minX: rect.minX + 4,
                maxX: rect.maxX - 4
            )
        }
    }
}

final class AICoachReportGroupedBarChartView: UIView {
    private let data: AICoachReportGroupedBarChartData

    init(data: AICoachReportGroupedBarChartData) {
        self.data = data
        super.init(frame: .zero)
        backgroundColor = .clear
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard data.entries.isEmpty == false else { return }

        let yAxisWidth = yAxisReservedWidth(for: data.yAxisTexts)
        let chartInsets = UIEdgeInsets(top: 13, left: yAxisWidth + 14, bottom: 36, right: 8)
        let chartRect = rect.inset(by: chartInsets)
        let step = chartRect.width / CGFloat(data.entries.count)
        let groupWidth = min(step * 0.78, step - 2)
        let barWidth = groupWidth / 3
        let colors = [
            AICoachReportDemoPalette.nutrientPurple,
            AICoachReportDemoPalette.nutrientYellow,
            AICoachReportDemoPalette.nutrientOrange
        ]

        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawYAxis(in: context, rect: chartRect, labels: data.yAxisTexts)

        for (index, entry) in data.entries.enumerated() {
            let startX = chartRect.minX + CGFloat(index) * step + (step - groupWidth) / 2
            let labelCenterX = chartRect.minX + CGFloat(index) * step + step / 2
            for valueIndex in 0..<entry.values.count {
                let barHeight = (entry.values[valueIndex] / max(data.maxValue, 1)) * chartRect.height
                let x = startX + CGFloat(valueIndex) * barWidth
                let y = chartRect.maxY - barHeight
                let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                let barPath = UIBezierPath(rect: barRect)
                colors[valueIndex].setFill()
                barPath.fill()
            }

            drawXAxisLabel(
                entry.axisLabel,
                center: CGPoint(x: labelCenterX, y: chartRect.maxY + 10),
                minX: rect.minX + 4,
                maxX: rect.maxX - 4
            )
        }
    }
}

private func drawYAxis(in context: CGContext, rect: CGRect, labels: [String]) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .right
    let labelWidth = yAxisReservedWidth(for: labels)

    for index in 0..<labels.count {
        let y = rect.minY + CGFloat(index) * (rect.height / CGFloat(max(labels.count - 1, 1)))
        context.setStrokeColor(AICoachReportDemoPalette.grid.cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: rect.minX, y: y))
        context.addLine(to: CGPoint(x: rect.maxX, y: y))
        context.strokePath()

        let label = labels[index] as NSString
        label.draw(
            in: CGRect(x: rect.minX - labelWidth - 8, y: y - 6, width: labelWidth, height: 11),
            withAttributes: [
                .font: chartYAxisLabelFont,
                .foregroundColor: AICoachReportDemoPalette.textTertiary,
                .paragraphStyle: paragraph
            ]
        )
    }
}

private func yAxisReservedWidth(for labels: [String]) -> CGFloat {
    let attributes: [NSAttributedString.Key: Any] = [.font: chartYAxisLabelFont]
    let maxWidth = labels
        .map { ($0 as NSString).size(withAttributes: attributes).width }
        .max() ?? 16
    return ceil(max(maxWidth, 16))
}

private func drawXAxisLabel(_ text: String, center: CGPoint, minX: CGFloat, maxX: CGFloat) {
    guard text.isEmpty == false, let context = UIGraphicsGetCurrentContext() else { return }

    let attributes: [NSAttributedString.Key: Any] = [
        .font: chartXAxisLabelFont,
        .foregroundColor: AICoachReportDemoPalette.textTertiary
    ]
    let labelSize = (text as NSString).size(withAttributes: attributes)
    let rotatedHalfWidth =
        abs(cos(chartXAxisLabelAngle)) * labelSize.width / 2 +
        abs(sin(chartXAxisLabelAngle)) * labelSize.height / 2
    let clampedCenterX = min(max(center.x, minX + rotatedHalfWidth), maxX - rotatedHalfWidth)

    context.saveGState()
    context.translateBy(x: clampedCenterX, y: center.y)
    context.rotate(by: chartXAxisLabelAngle)
    (text as NSString).draw(
        in: CGRect(x: -labelSize.width / 2, y: 0, width: labelSize.width, height: labelSize.height),
        withAttributes: attributes
    )
    context.restoreGState()
}

private func xAxisEdgeInset(for labels: [String], availableWidth: CGFloat) -> CGFloat {
    let maxHalfWidth = labels
        .filter { $0.isEmpty == false }
        .map(rotatedLabelHalfWidth(for:))
        .max() ?? 0
    return min(maxHalfWidth + 2, max(availableWidth * 0.12, 8))
}

private func rotatedLabelHalfWidth(for text: String) -> CGFloat {
    let attributes: [NSAttributedString.Key: Any] = [.font: chartXAxisLabelFont]
    let labelSize = (text as NSString).size(withAttributes: attributes)
    return
        abs(cos(chartXAxisLabelAngle)) * labelSize.width / 2 +
        abs(sin(chartXAxisLabelAngle)) * labelSize.height / 2
}
