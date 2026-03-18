//
//  AICoachReportDemoChartViews.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit

final class AICoachReportLineChartView: UIView {
    private let entries: [AICoachReportPoint]
    private let lineColor: UIColor
    private let fillColor: UIColor

    init(entries: [AICoachReportPoint],
         lineColor: UIColor = AICoachReportDemoPalette.themeBlue,
         fillColor: UIColor = AICoachReportDemoPalette.themeBlueLight) {
        self.entries = entries
        self.lineColor = lineColor
        self.fillColor = fillColor
        super.init(frame: .zero)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), entries.count > 1 else { return }

        let chartInsets = UIEdgeInsets(top: 24, left: 18, bottom: 26, right: 10)
        let chartRect = rect.inset(by: chartInsets)
        let maxValue = max(entries.map(\.value).max() ?? 1, 1)
        let minValue = min(entries.map(\.value).min() ?? 0, 0)
        let range = max(maxValue - minValue, 1)
        let stepX = chartRect.width / CGFloat(max(entries.count - 1, 1))

        context.setStrokeColor(AICoachReportDemoPalette.border.cgColor)
        context.setLineWidth(1)
        for index in 0...3 {
            let y = chartRect.minY + CGFloat(index) * (chartRect.height / 3)
            context.move(to: CGPoint(x: chartRect.minX, y: y))
            context.addLine(to: CGPoint(x: chartRect.maxX, y: y))
            context.strokePath()
        }

        let points: [CGPoint] = entries.enumerated().map { index, entry in
            let x = chartRect.minX + CGFloat(index) * stepX
            let ratio = (entry.value - minValue) / range
            let y = chartRect.maxY - CGFloat(ratio) * chartRect.height
            return CGPoint(x: x, y: y)
        }

        let fillPath = UIBezierPath()
        fillPath.move(to: CGPoint(x: points.first?.x ?? chartRect.minX, y: chartRect.maxY))
        points.forEach { fillPath.addLine(to: $0) }
        fillPath.addLine(to: CGPoint(x: points.last?.x ?? chartRect.maxX, y: chartRect.maxY))
        fillPath.close()
        fillColor.withAlphaComponent(0.65).setFill()
        fillPath.fill()

        let linePath = UIBezierPath()
        linePath.lineWidth = 2
        linePath.lineJoinStyle = .round
        linePath.lineCapStyle = .round
        if let firstPoint = points.first {
            linePath.move(to: firstPoint)
        }
        points.forEach { linePath.addLine(to: $0) }
        lineColor.setStroke()
        linePath.stroke()

        let pointRadius: CGFloat = 3.5
        for (index, point) in points.enumerated() {
            let pointRect = CGRect(x: point.x - pointRadius, y: point.y - pointRadius, width: pointRadius * 2, height: pointRadius * 2)
            let pointPath = UIBezierPath(ovalIn: pointRect)
            UIColor.white.setFill()
            pointPath.fill()
            lineColor.setStroke()
            pointPath.lineWidth = 1.5
            pointPath.stroke()

            let value = Int(entries[index].value)
            let valueText = "\(value)" as NSString
            valueText.draw(in: CGRect(x: point.x - 12, y: point.y - 20, width: 24, height: 14), withAttributes: [
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                .foregroundColor: lineColor
            ])

            let labelText = entries[index].label as NSString
            labelText.draw(in: CGRect(x: point.x - 16, y: chartRect.maxY + 8, width: 32, height: 12), withAttributes: [
                .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                .foregroundColor: AICoachReportDemoPalette.textSecondary
            ])
        }
    }
}

final class AICoachReportBarChartView: UIView {
    private let entries: [AICoachReportPoint]
    private let barColor: UIColor

    init(entries: [AICoachReportPoint], barColor: UIColor = AICoachReportDemoPalette.themeBlue) {
        self.entries = entries
        self.barColor = barColor
        super.init(frame: .zero)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), entries.isEmpty == false else { return }

        let chartInsets = UIEdgeInsets(top: 24, left: 18, bottom: 26, right: 10)
        let chartRect = rect.inset(by: chartInsets)
        let maxValue = max(entries.map(\.value).max() ?? 1, 1)
        let step = chartRect.width / CGFloat(entries.count)
        let barWidth = min(20, step * 0.5)

        context.setStrokeColor(AICoachReportDemoPalette.border.cgColor)
        context.setLineWidth(1)
        for index in 0...3 {
            let y = chartRect.minY + CGFloat(index) * (chartRect.height / 3)
            context.move(to: CGPoint(x: chartRect.minX, y: y))
            context.addLine(to: CGPoint(x: chartRect.maxX, y: y))
            context.strokePath()
        }

        for (index, entry) in entries.enumerated() {
            let barHeight = CGFloat(entry.value / maxValue) * chartRect.height
            let x = chartRect.minX + CGFloat(index) * step + (step - barWidth) / 2
            let y = chartRect.maxY - barHeight
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let barPath = UIBezierPath(roundedRect: barRect, cornerRadius: 4)
            barColor.setFill()
            barPath.fill()

            let labelText = entry.label as NSString
            labelText.draw(in: CGRect(x: x - 6, y: chartRect.maxY + 8, width: barWidth + 12, height: 12), withAttributes: [
                .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                .foregroundColor: AICoachReportDemoPalette.textSecondary
            ])
        }
    }
}

final class AICoachReportGroupedBarChartView: UIView {
    private let entries: [AICoachReportGroupedPoint]

    init(entries: [AICoachReportGroupedPoint]) {
        self.entries = entries
        super.init(frame: .zero)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), entries.isEmpty == false else { return }

        let chartInsets = UIEdgeInsets(top: 24, left: 18, bottom: 26, right: 10)
        let chartRect = rect.inset(by: chartInsets)
        let maxValue = max(
            entries.map { max($0.firstValue, max($0.secondValue, $0.thirdValue)) }.max() ?? 1,
            1
        )
        let step = chartRect.width / CGFloat(entries.count)
        let groupWidth = step * 0.72
        let barWidth = groupWidth / 3.6
        let colors = [
            AICoachReportDemoPalette.nutrientPurple,
            AICoachReportDemoPalette.nutrientYellow,
            AICoachReportDemoPalette.nutrientOrange
        ]

        context.setStrokeColor(AICoachReportDemoPalette.border.cgColor)
        context.setLineWidth(1)
        for index in 0...3 {
            let y = chartRect.minY + CGFloat(index) * (chartRect.height / 3)
            context.move(to: CGPoint(x: chartRect.minX, y: y))
            context.addLine(to: CGPoint(x: chartRect.maxX, y: y))
            context.strokePath()
        }

        for (index, entry) in entries.enumerated() {
            let groupX = chartRect.minX + CGFloat(index) * step + (step - groupWidth) / 2
            let values = [entry.firstValue, entry.secondValue, entry.thirdValue]
            for valueIndex in 0..<values.count {
                let barHeight = CGFloat(values[valueIndex] / maxValue) * chartRect.height
                let x = groupX + CGFloat(valueIndex) * (barWidth + 3)
                let y = chartRect.maxY - barHeight
                let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                let barPath = UIBezierPath(roundedRect: barRect, cornerRadius: 3)
                colors[valueIndex].setFill()
                barPath.fill()
            }

            let labelText = entry.label as NSString
            labelText.draw(in: CGRect(x: groupX - 4, y: chartRect.maxY + 8, width: groupWidth + 8, height: 12), withAttributes: [
                .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                .foregroundColor: AICoachReportDemoPalette.textSecondary
            ])
        }
    }
}
