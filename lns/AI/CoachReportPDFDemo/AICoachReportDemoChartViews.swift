//
//  AICoachReportDemoChartViews.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit

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
        guard let context = UIGraphicsGetCurrentContext(), data.entries.count > 1 else { return }

        let chartInsets = UIEdgeInsets(top: 14, left: 30, bottom: 24, right: 8)
        let chartRect = rect.inset(by: chartInsets)
        let stepX = chartRect.width / CGFloat(max(data.entries.count - 1, 1))

        drawYAxis(in: context, rect: chartRect, labels: data.yAxisTexts)

        let points = data.entries.enumerated().map { index, entry -> CGPoint in
            let x = chartRect.minX + CGFloat(index) * stepX
            let ratio = (entry.plottedValue - data.minValue) / max(data.maxValue - data.minValue, 1)
            let y = chartRect.maxY - ratio * chartRect.height
            return CGPoint(x: x, y: y)
        }

        let fillPath = UIBezierPath()
        fillPath.move(to: CGPoint(x: points.first?.x ?? chartRect.minX, y: chartRect.maxY))
        points.forEach { fillPath.addLine(to: $0) }
        fillPath.addLine(to: CGPoint(x: points.last?.x ?? chartRect.maxX, y: chartRect.maxY))
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
            linePath.move(to: firstPoint)
        }
        points.forEach { linePath.addLine(to: $0) }
        AICoachReportDemoPalette.themeBlue.setStroke()
        linePath.stroke()

        for (index, point) in points.enumerated() {
            let pointRect = CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)
            let circle = UIBezierPath(ovalIn: pointRect)
            UIColor.white.setFill()
            circle.fill()
            AICoachReportDemoPalette.themeBlue.setStroke()
            circle.lineWidth = 1.5
            circle.stroke()

            if data.entries[index].valueText.isEmpty == false {
                let valueText = data.entries[index].valueText as NSString
                valueText.draw(
                    in: CGRect(x: point.x - 12, y: point.y - 18, width: 24, height: 12),
                    withAttributes: [
                        .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
                        .foregroundColor: AICoachReportDemoPalette.themeBlue
                    ]
                )
            }

            if data.entries[index].axisLabel.isEmpty == false {
                let axisText = data.entries[index].axisLabel as NSString
                axisText.draw(
                    in: CGRect(x: point.x - 16, y: chartRect.maxY + 7, width: 32, height: 11),
                    withAttributes: [
                        .font: UIFont.systemFont(ofSize: 8.5, weight: .regular),
                        .foregroundColor: AICoachReportDemoPalette.textTertiary
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

        let chartInsets = UIEdgeInsets(top: 14, left: 31, bottom: 24, right: 8)
        let chartRect = rect.inset(by: chartInsets)
        let step = chartRect.width / CGFloat(data.entries.count)
        let barWidth = min(17, step * 0.46)

        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawYAxis(in: context, rect: chartRect, labels: data.yAxisTexts)

        for (index, entry) in data.entries.enumerated() {
            let barHeight = (entry.value / max(data.maxValue, 1)) * chartRect.height
            let x = chartRect.minX + CGFloat(index) * step + (step - barWidth) / 2
            let y = chartRect.maxY - barHeight
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let barPath = UIBezierPath(roundedRect: barRect, cornerRadius: 3)
            AICoachReportDemoPalette.themeBlue.setFill()
            barPath.fill()

            let axisText = entry.axisLabel as NSString
            axisText.draw(
                in: CGRect(x: x - 8, y: chartRect.maxY + 7, width: barWidth + 16, height: 11),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 8.5, weight: .regular),
                    .foregroundColor: AICoachReportDemoPalette.textTertiary
                ]
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

        let chartInsets = UIEdgeInsets(top: 13, left: 31, bottom: 24, right: 8)
        let chartRect = rect.inset(by: chartInsets)
        let step = chartRect.width / CGFloat(data.entries.count)
        let groupWidth = step * 0.66
        let barWidth = groupWidth / 3.45
        let colors = [
            AICoachReportDemoPalette.nutrientPurple,
            AICoachReportDemoPalette.nutrientYellow,
            AICoachReportDemoPalette.nutrientOrange
        ]

        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawYAxis(in: context, rect: chartRect, labels: data.yAxisTexts)

        for (index, entry) in data.entries.enumerated() {
            let startX = chartRect.minX + CGFloat(index) * step + (step - groupWidth) / 2
            for valueIndex in 0..<entry.values.count {
                let barHeight = (entry.values[valueIndex] / max(data.maxValue, 1)) * chartRect.height
                let x = startX + CGFloat(valueIndex) * (barWidth + 2.4)
                let y = chartRect.maxY - barHeight
                let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                let barPath = UIBezierPath(roundedRect: barRect, cornerRadius: 2.4)
                colors[valueIndex].setFill()
                barPath.fill()
            }

            let axisText = entry.axisLabel as NSString
            axisText.draw(
                in: CGRect(x: startX - 5, y: chartRect.maxY + 7, width: groupWidth + 10, height: 11),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 8.5, weight: .regular),
                    .foregroundColor: AICoachReportDemoPalette.textTertiary
                ]
            )
        }
    }
}

private func drawYAxis(in context: CGContext, rect: CGRect, labels: [String]) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .right

    for index in 0..<labels.count {
        let y = rect.minY + CGFloat(index) * (rect.height / CGFloat(max(labels.count - 1, 1)))
        context.setStrokeColor(AICoachReportDemoPalette.grid.cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: rect.minX, y: y))
        context.addLine(to: CGPoint(x: rect.maxX, y: y))
        context.strokePath()

        let label = labels[index] as NSString
        label.draw(
            in: CGRect(x: rect.minX - 24, y: y - 6, width: 16, height: 11),
            withAttributes: [
                .font: UIFont.systemFont(ofSize: 8, weight: .regular),
                .foregroundColor: AICoachReportDemoPalette.textTertiary,
                .paragraphStyle: paragraph
            ]
        )
    }
}
