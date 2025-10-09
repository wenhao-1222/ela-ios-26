//
//  ProgressChartView.swift
//  lns
//
//  Created by Elavatine on 2025/6/10.
//

import UIKit
import QuartzCore

class ProgressChartView: UIView {

    // MARK: — 配置项 —
    var axisColor: UIColor = .COLOR_GRAY_BE
//    var axisTextColor: UIColor = WHColor_16(colorStr: "BEBEBE")
    var axisTextColor: UIColor = WHColor_16(colorStr: "BEBEBE") {
        didSet {
            monthLabel.textColor = axisTextColor
        }
    }
    var recordedLineColor: UIColor = WHColor_16(colorStr: "003CFF")
    var unrecordedLineColor: UIColor = WHColor_16(colorStr: "FF8C3B")
    var axisArrowSize: CGFloat = 4

    /// 渐变线条颜色, 默认蓝色渐变
   private var recordedLineGradientColors: [UIColor] = [
        UIColor(red: 155/255, green: 193/255, blue: 255/255, alpha: 1),
        UIColor(red: 238/255, green: 247/255, blue: 255/255, alpha: 1)
   ]
    private var unrecordedLineGradientColors: [UIColor] = [
        UIColor(red: 252/255, green: 142/255, blue: 83/255, alpha: 1),
         UIColor(red: 251/255, green: 242/255, blue: 228/255, alpha: 1)
    ]
        
    private let recordedLineLayer = CAShapeLayer()
    private let recordedGradientLayer = CAGradientLayer()
    private let unrecordedLineLayer = CAShapeLayer()
    
    private let monthLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "6个月"
        lbl.font = .systemFont(ofSize: 12)
        return lbl
    }()
    var animationProgress: CGFloat = 0.0
    var displayLink: CADisplayLink?
    
   /// 设置记录折线的渐变色
   func setRecordedLineGradient(start: UIColor, end: UIColor) {
       recordedLineGradientColors = [start, end]
       setNeedsDisplay()
   }
    private var gradientStartTime: CFTimeInterval = 0
    private var gradientDuration: CFTimeInterval = 1

    func startGradientAnimation(duration: CFTimeInterval = 1.2) {
        gradientDuration = duration
        gradientStartTime = CACurrentMediaTime()
        animationProgress = 0.0
        displayLink?.invalidate()
        animationProgress = 0.0
        displayLink = CADisplayLink(target: self, selector: #selector(updateGradientProgress))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateGradientProgress() {
//        animationProgress += 0.02
        guard gradientDuration > 0 else { return }
                let elapsed = CACurrentMediaTime() - gradientStartTime
                animationProgress = min(CGFloat(elapsed / gradientDuration), 1.0)
        if animationProgress >= 1.0 {
//            animationProgress = 1.0
            displayLink?.invalidate()
            displayLink = nil
        }
        setNeedsDisplay() // 触发 draw(_:)
    }
    private var progress: CGFloat = 0 {
//        didSet { setNeedsDisplay() }
        didSet {
            setNeedsDisplay()
            recordedLineLayer.strokeEnd = progress
            unrecordedLineLayer.strokeEnd = progress
        }
    }

    // 图例标签
    private lazy var recordedLabel: UILabel = makeLegendLabel(text: "记录饮食", bgColor: UIColor.THEME)
    private lazy var unrecordedLabel: UILabel = makeLegendLabel(text: "未记录", bgColor: unrecordedLineColor)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear

        // 虚线边框
        let dashBorder = CAShapeLayer()
        dashBorder.strokeColor = UIColor.label.withAlphaComponent(0.2).cgColor
        dashBorder.lineDashPattern = [4, 2]
        dashBorder.fillColor = nil
        layer.addSublayer(dashBorder)
        dashBorder.frame = bounds
        dashBorder.path = UIBezierPath(rect: bounds.insetBy(dx: 4, dy: 4)).cgPath
        dashBorder.lineWidth = 1

        // 折线图层
        for line in [recordedLineLayer, unrecordedLineLayer] {
            line.fillColor = nil
            line.lineWidth = 2
            line.lineCap = .round
            line.lineJoin = .round
            line.strokeEnd = 0
            layer.addSublayer(line)
        }
        recordedLineLayer.strokeColor = UIColor.THEME.cgColor//recordedLineColor.cgColor
        unrecordedLineLayer.strokeColor = unrecordedLineColor.cgColor

        // 添加图例
        addSubview(recordedLabel)
        addSubview(unrecordedLabel)
        addSubview(monthLabel)
        monthLabel.textColor = axisTextColor
        recordedLabel.alpha = 0
        unrecordedLabel.alpha = 0

        // 动画
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.animateLines()
        UIView.animate(withDuration: 1.2, delay: 0.02, options: .curveLinear) {
                self.progress = 1
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.recordedLabel.alpha = 1
                    self.unrecordedLabel.alpha = 1
                }
            }
//        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let chartW = bounds.width - 30
        let chartH = bounds.height - 44
        let frame = CGRect(x: 26, y: 20, width: chartW, height: chartH)
        recordedLineLayer.frame = frame
        unrecordedLineLayer.frame = frame
        // 设置渐变层属性
        recordedGradientLayer.colors = recordedLineGradientColors.map { $0.cgColor }
        recordedGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        recordedGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        recordedGradientLayer.frame = frame
        recordedGradientLayer.mask = recordedLineLayer
        if recordedGradientLayer.superlayer == nil {
            layer.addSublayer(recordedGradientLayer)
        }
        
        // 布局图例
        let inset: CGFloat = 30
        let w: CGFloat = 80, h: CGFloat = 24
        recordedLabel.frame = CGRect(
            x: bounds.width - w - inset,
            y: bounds.height * 0.2 - h/2,
            width: w, height: h
        )
        let unrecordedLabelGap = CGFloat(20)
        unrecordedLabel.frame = CGRect(
            x: bounds.width - w + unrecordedLabelGap - inset,
//            x: bounds.width - w - inset,
            y: bounds.height * 0.5 - h/2,
            width: w-unrecordedLabelGap, height: h
        )
        
        monthLabel.sizeToFit()
        monthLabel.frame.origin = CGPoint(
            x: bounds.width - monthLabel.bounds.width - 20,
            y: bounds.height - monthLabel.bounds.height - 10
        )
        
        // Layout changes may occur before the animation starts.
        // Trigger a redraw so the chart uses the latest bounds.
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
//        let w = rect.width - 30  // 留出左侧 26 + 少量空间
//        let h = rect.height - 44 // 留出上下各 20/24
//
//        ctx.translateBy(x: 26, y: 20)  // 避开 Y 轴标签 & 上边距
        let left: CGFloat = 26
        let right: CGFloat = axisArrowSize + 14
        let top: CGFloat = 20 + axisArrowSize
        let bottom: CGFloat = 24 + axisArrowSize
        let w = rect.width - left - right
        let h = rect.height - top - bottom

        ctx.translateBy(x: left, y: top)  // 避开文字与箭头
        ctx.saveGState()

        // ——— 坐标轴 & 箭头 & 分割线 ———
        drawAxes(in: ctx, width: w, height: h)

        // ——— 渐变填充 & 折线 & 圆点 ———
        drawCurves(in: ctx, width: w, height: h)
        
        // X 轴
        ctx.setStrokeColor(axisColor.cgColor)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: 0, y: h))
        ctx.addLine(to: CGPoint(x: w, y: h))
        ctx.strokePath()
        // X 箭头
        drawArrow(in: ctx, at: CGPoint(x: w, y: h), pointing: .right)
        if progress > 0 {
//            drawCircle(at: CGPoint(x: 0, y: h), radius: 4, in: ctx, fill: .white, stroke: WHColor_16(colorStr: "00D0FF"), lineWidth: 3)
            drawCircle(at: CGPoint(x: 0, y: h), radius: 4, in: ctx, fill: .white, stroke: UIColor.THEME, lineWidth: 3)
           
        }
        ctx.restoreGState()

        // ——— 坐标轴文字 ———
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: axisTextColor
        ]
        ("体重变化" as NSString).draw(at: CGPoint(x: -24, y: -16), withAttributes: attrs)
    }

    // MARK: — 绘制子方法 —

    private func drawAxes(in ctx: CGContext, width w: CGFloat, height h: CGFloat) {
        ctx.setStrokeColor(axisColor.cgColor)
        ctx.setLineWidth(1)

        // Y 轴
        ctx.move(to: CGPoint(x: 0, y: h))
        ctx.addLine(to: CGPoint(x: 0, y: 0))
        ctx.strokePath()
        // Y 箭头
        drawArrow(in: ctx, at: CGPoint(x: 0, y: 0), pointing: .up)
        
        // 水平分割线 25%,50%,75%
        ctx.setStrokeColor(axisColor.withAlphaComponent(0.25).cgColor)
        for frac in [0.25, 0.5, 0.75] {
            let y = h * CGFloat(frac)
            ctx.move(to: CGPoint(x: 0, y: y))
            ctx.addLine(to: CGPoint(x: w - axisArrowSize, y: y))
            ctx.strokePath()
        }
    }

    private enum ArrowDirection { case up, right }

    private func drawArrow(in ctx: CGContext, at point: CGPoint, pointing dir: ArrowDirection) {
        let s = axisArrowSize
        ctx.beginPath()
//        let path = UIBezierPath()
        switch dir {
        case .up:
            
            ctx.move(to: CGPoint(x: point.x - s, y: point.y + s))
            ctx.addLine(to: point)
            ctx.addLine(to: CGPoint(x: point.x + s, y: point.y + s))
        case .right:
            
            ctx.move(to: CGPoint(x: point.x - s, y: point.y - s))
            ctx.addLine(to: point)
            ctx.addLine(to: CGPoint(x: point.x - s, y: point.y + s))
        }
        
        ctx.closePath()
        ctx.setFillColor(axisColor.cgColor)
        ctx.fillPath()
    }
    private func drawCurves(in ctx: CGContext, width w: CGFloat, height h: CGFloat) {
        let steps = 100
        
//        func blueY(_ t: CGFloat) -> CGFloat { 0.78 * pow(t, 0.5) + 0.1 * t * (1 - t) }
//        func blueY(_ t: CGFloat) -> CGFloat {
//            let base = 0.78 * pow(t, 0.7) // 原始顺滑曲线
//            let bumpCenter: CGFloat = 0.5 //凸起中心点
//            let bumpWidth: CGFloat = 0.39// 调整凸起范围
//            let bumpHeight: CGFloat = 0.045// 调整凸起高度
//
//            // 使用高斯函数制造局部提升
//            let bump = bumpHeight * exp(-pow((t - bumpCenter) / bumpWidth, 2))
//            
//            return base + bump
//        }
        func cubicBezier(_ t: CGFloat,
                         _ p0: CGFloat,
                         _ p1: CGFloat,
                         _ p2: CGFloat,
                         _ p3: CGFloat) -> CGFloat {
            let u = 1 - t
            return pow(u, 3) * p0 +
                   3 * pow(u, 2) * t * p1 +
                   3 * u * pow(t, 2) * p2 +
                   pow(t, 3) * p3
        }
        let blueY: (CGFloat) -> CGFloat = { t in
            cubicBezier(t, 0.0, 0.7*0.78, 0.95*0.78, 1.0*0.78)
        }

        let orangeY: (CGFloat) -> CGFloat = { t in
            0.5 * blueY(t)
        }
//        func orangeY(_ t: CGFloat) -> CGFloat { 0.42 * pow(t, 0.6) }

        // 记录填充
        let recPath = CGMutablePath()
        recPath.move(to: CGPoint(x: 0, y: h))
        let recLinePath = CGMutablePath()
        for i in 0...steps {
            let t = min(progress, CGFloat(i) / CGFloat(steps))
            let x = t * w
            let y = h * (1 - blueY(t))
            recPath.addLine(to: CGPoint(x: x, y: y))
            let point = CGPoint(x: x, y: y)
            if i == 0 { recLinePath.move(to: point) } else { recLinePath.addLine(to: point) }
        }
        recPath.addLine(to: CGPoint(x: progress * w, y: h))
        recPath.closeSubpath()
        ctx.saveGState()
        ctx.addPath(recPath)
        ctx.clip()
        drawLinearGradient(
            in: ctx,
            rect: CGRect(x: 0, y: 0, width: w, height: h),
            colors: recordedLineGradientColors.map { $0.cgColor },
            progress: animationProgress
        )
        ctx.restoreGState()
        // 未记录填充
        let unrecPath = CGMutablePath()
        unrecPath.move(to: CGPoint(x: 0, y: h))
        for i in 0...steps {
            let t = min(progress, CGFloat(i) / CGFloat(steps))
            let x = t * w
            let y = h * (1 - orangeY(t))
            unrecPath.addLine(to: CGPoint(x: x, y: y))
        }
        unrecPath.addLine(to: CGPoint(x: progress * w, y: h))
        unrecPath.closeSubpath()
        ctx.saveGState()
        ctx.addPath(unrecPath)
        ctx.clip()
        drawLinearGradient(
            in: ctx,
            rect: CGRect(x: 0, y: 0, width: w, height: h),
            colors: [UIColor(red: 252/255, green: 142/255, blue: 83/255, alpha: 1).cgColor,
                     UIColor(red: 251/255, green: 242/255, blue: 228/255, alpha: 1).cgColor],
            progress: animationProgress
        )
        ctx.restoreGState()

//         折线描边
        ctx.setLineCap(.round)
        var last: CGPoint?
//        ctx.setStrokeColor(recordedLineColor.cgColor)
        ctx.setStrokeColor(UIColor.THEME.cgColor)
        ctx.setLineWidth(2)
        for i in 0...steps {
            let t = min(progress, CGFloat(i) / CGFloat(steps))
            let p = CGPoint(x: t * w, y: h * (1 - blueY(t)))
            if let prev = last {
                ctx.move(to: prev); ctx.addLine(to: p); ctx.strokePath()
            }
            last = p
        }
        last = nil
        ctx.setStrokeColor(unrecordedLineColor.cgColor)
        ctx.setLineWidth(2)
        for i in 0...steps {
            let t = min(progress, CGFloat(i) / CGFloat(steps))
            let p = CGPoint(x: t * w, y: h * (1 - orangeY(t)))
            if let prev = last {
                ctx.move(to: prev); ctx.addLine(to: p); ctx.strokePath()
            }
            last = p
        }

        // 原点圆点
//        if progress > 0 {
//            drawCircle(at: CGPoint(x: 0, y: h), radius: 4, in: ctx, fill: .white, stroke: WHColor_16(colorStr: "00D0FF"), lineWidth: 3)
//        }
        // 末端圆点
        if progress >= 0.98 {
            let endX = w
            let y1 = h * (1 - blueY(1))
//            drawCircle(at: CGPoint(x: endX, y: y1), radius: 4, in: ctx, fill: .white, stroke: recordedLineColor, lineWidth: 3)
            drawCircle(at: CGPoint(x: endX, y: y1), radius: 4, in: ctx, fill: .white, stroke: UIColor.THEME, lineWidth: 3)
//            let y2 = h * (1 - orangeY(1))
//            drawCircle(at: CGPoint(x: endX, y: y2), radius: 4, in: ctx, fill: .white, stroke: unrecordedLineColor, lineWidth: 3)
        }
    }

    // 画圆 helper
    private func drawCircle(at center: CGPoint, radius: CGFloat, in ctx: CGContext,
                            fill: UIColor, stroke: UIColor, lineWidth: CGFloat) {
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.setStrokeColor(stroke.cgColor)
        ctx.setLineWidth(lineWidth)
        let rect = CGRect(x: center.x - radius, y: center.y - radius,
                          width: radius*2, height: radius*2)
        ctx.addEllipse(in: rect)
        ctx.drawPath(using: .fillStroke)
    }

    // 画渐变 helper
    private func drawLinearGradient(in ctx: CGContext, rect: CGRect, colors: [CGColor]) {
        guard let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0,1]) else { return }
        ctx.drawLinearGradient(grad, start: rect.origin, end: CGPoint(x: rect.minX, y: rect.maxY), options: [])
    }
    private func drawLinearGradient(in ctx: CGContext, rect: CGRect, colors: [CGColor], progress: CGFloat) {
        let clippedRect = CGRect(x: rect.origin.x,
                                 y: rect.origin.y,
                                 width: rect.width * progress,
                                 height: rect.height)
        ctx.saveGState()
        ctx.clip(to: clippedRect) // 限制渐变区域
        guard let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0,1]) else {
            ctx.restoreGState()
            return
        }
        ctx.drawLinearGradient(grad,
                               start: CGPoint(x: clippedRect.minX, y: clippedRect.minY),
//                               end: CGPoint(x: clippedRect.maxX, y: clippedRect.minY),
                               end: CGPoint(x: clippedRect.minX, y: clippedRect.maxY),
                               options: [])
        ctx.restoreGState()
    }

    private func makeLegendLabel(text: String, bgColor: UIColor) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.backgroundColor = bgColor
        lbl.layer.cornerRadius = 4
        lbl.layer.masksToBounds = true
        return lbl
    }
    /// 从外部触发的折线加载动画
    func startProgressAnimation() {
        progress = 0
        recordedLabel.alpha = 0
        unrecordedLabel.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
            self.progress = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.recordedLabel.alpha = 1
                self.unrecordedLabel.alpha = 1
            }
        }
    }
    private func animateLines() {
        for layer in [recordedLineLayer, unrecordedLineLayer] {
            layer.removeAllAnimations()
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = 0
            anim.toValue = 1
            anim.duration = 1.5
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(anim, forKey: "draw")
            layer.strokeEnd = 1
        }
    }
}
