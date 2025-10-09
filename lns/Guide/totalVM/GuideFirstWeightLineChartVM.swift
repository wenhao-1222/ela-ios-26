//
//  GuideFirstWeightLineChartVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/9.
//
import UIKit

/// 自定义一个 UIView，用来绘制折线图
class GuideFirstWeightLineChartVM: UIView {
    // MARK: — 数据
    private let recValues: [CGFloat]    = [0, 3, 5, 6.5, 7.5, 8.2, 9]
    private let notRecValues: [CGFloat] = [0, 2, 4, 5,   6,   6.8, 7.5]
    private lazy var maxValue: CGFloat = max(recValues.max() ?? 0, notRecValues.max() ?? 0)
    
    // MARK: — 绘制
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        // 边距
        let marginX: CGFloat = 40
        let marginY: CGFloat = 40
        let chartRect = rect.insetBy(dx: marginX, dy: marginY)
        
        // 1. 画网格线 + 坐标轴
        drawGridAndAxes(in: chartRect, context: ctx)
        
        // 2. 计算点坐标
        let recPoints    = computePoints(values: recValues,    in: chartRect)
        let notRecPoints = computePoints(values: notRecValues, in: chartRect)
        
        // 3. 渐变填充 + 折线（先“未记录”，再“记录饮食”，保证遮盖顺序）
        drawSeries(points: notRecPoints,
                   lineColor: .orange,
                   gradientColors: [UIColor.orange.withAlphaComponent(0.6), UIColor.orange.withAlphaComponent(0.1)],
                   in: chartRect,
                   context: ctx)
        
        drawSeries(points: recPoints,
                   lineColor: .blue,
                   gradientColors: [UIColor.blue.withAlphaComponent(0.6), UIColor.blue.withAlphaComponent(0.1)],
                   in: chartRect,
                   context: ctx)
        
        // 4. 起点/终点标记
        drawEndpoints(points: recPoints,    color: .blue,   context: ctx)
        drawEndpoints(points: notRecPoints, color: .orange, context: ctx)
        
        // 5. 坐标轴文字
        drawLabels(in: rect, chartRect: chartRect)
    }
    
    /// 计算 [0...6] 的 X 坐标和归一化后的 Y 坐标
    private func computePoints(values: [CGFloat], in r: CGRect) -> [CGPoint] {
        return values.enumerated().map { (i, v) in
            let x = r.minX + (r.width / CGFloat(values.count - 1)) * CGFloat(i)
            let y = r.maxY - (v / maxValue) * r.height
            return CGPoint(x: x, y: y)
        }
    }
    
    /// 画网格线和坐标轴
    private func drawGridAndAxes(in r: CGRect, context ctx: CGContext) {
        ctx.saveGState()
        ctx.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.4).cgColor)
        ctx.setLineWidth(1)
        
        // 3 条水平网格线
        for i in 0...3 {
            let y = r.minY + (r.height / 3) * CGFloat(i)
            ctx.move(to: CGPoint(x: r.minX, y: y))
            ctx.addLine(to: CGPoint(x: r.maxX, y: y))
        }
        ctx.strokePath()
        
        // 坐标轴
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(1.5)
        // Y 轴
        ctx.move(to: CGPoint(x: r.minX, y: r.minY))
        ctx.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        // X 轴
        ctx.move(to: CGPoint(x: r.minX, y: r.maxY))
        ctx.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        ctx.strokePath()
        ctx.restoreGState()
    }
    
    /// 对一系列点：先填充渐变，再描边平滑折线
    private func drawSeries(points: [CGPoint],
                            lineColor: UIColor,
                            gradientColors: [UIColor],
                            in r: CGRect,
                            context ctx: CGContext)
    {
        // 1) 构造平滑曲线（Catmull–Rom 样条的近似，用 quad curve）
        let path = UIBezierPath()
        path.move(to: points[0])
        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            let mid  = CGPoint(x: (prev.x + curr.x) / 2,
                               y: (prev.y + curr.y) / 2)
            path.addQuadCurve(to: mid, controlPoint: prev)
        }
        // 收尾
        if let last = points.last, let penult = points.dropLast().last {
            path.addQuadCurve(to: last, controlPoint: penult)
        }
        
        // 2) 填充渐变
        ctx.saveGState()
        let fillPath = path.cgPath.mutableCopy()!
        // 延伸到底部
        fillPath.addLines(between: [
            points.last!,
            CGPoint(x: points.last!.x, y: r.maxY),
            CGPoint(x: points[0].x, y: r.maxY),
            points[0]
        ])
        fillPath.closeSubpath()
        ctx.addPath(fillPath)
        ctx.clip()
        
        let cgColors = gradientColors.map { $0.cgColor } as CFArray
        let locations: [CGFloat] = [0, 1]
        let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: cgColors,
                              locations: locations)!
        ctx.drawLinearGradient(grad,
                               start: CGPoint(x: 0, y: r.minY),
                               end:   CGPoint(x: 0, y: r.maxY),
                               options: [])
        ctx.restoreGState()
        
        // 3) 描边折线
        ctx.saveGState()
        ctx.setStrokeColor(lineColor.cgColor)
        ctx.setLineWidth(3)
        ctx.addPath(path.cgPath)
        ctx.setLineJoin(.round)
        ctx.setLineCap(.round)
        ctx.strokePath()
        ctx.restoreGState()
    }
    
    /// 在首尾两个点画圆点标记
    private func drawEndpoints(points: [CGPoint], color: UIColor, context ctx: CGContext) {
        guard let first = points.first, let last = points.last else { return }
        [first, last].forEach { p in
            ctx.saveGState()
            // 外圈
            let outer = UIBezierPath(arcCenter: p, radius: 8, startAngle: 0, endAngle: .pi*2, clockwise: true)
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(2)
            ctx.addPath(outer.cgPath)
            ctx.strokePath()
            // 填充
            let inner = UIBezierPath(arcCenter: p, radius: 5, startAngle: 0, endAngle: .pi*2, clockwise: true)
            ctx.setFillColor(color.cgColor)
            ctx.addPath(inner.cgPath)
            ctx.fillPath()
            ctx.restoreGState()
        }
    }
    
    /// 画 “体重变化” + “6个月” 标签
    private func drawLabels(in full: CGRect, chartRect r: CGRect) {
        let style: [NSAttributedString.Key:Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        // Y 轴标题（旋转 -90°）
        let ylabel = "体重变化"
        let ySize = ylabel.size(withAttributes: style)
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.saveGState()
            // 平移到左侧中间
            ctx.translateBy(x: r.minX - 20,
                            y: full.midY + ySize.width/2)
            ctx.rotate(by: -.pi/2)
            ylabel.draw(at: .zero, withAttributes: style)
            ctx.restoreGState()
        }
        // X 轴末尾
        let xlabel = "6个月"
        let xSize = xlabel.size(withAttributes: style)
        let xPos = CGPoint(x: r.maxX - xSize.width/2,
                           y: r.maxY + 5)
        xlabel.draw(at: xPos, withAttributes: style)
    }
}
