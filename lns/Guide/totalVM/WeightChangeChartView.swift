//
//  WeightChangeChartView.swift
//  lns
//
//  Created by Elavatine on 2025/7/4.
//

import UIKit

// 数据模型
struct DataPoint {
    let month: CGFloat    // 0～6
    let noRecord: CGFloat // 归一化体重变化（未记录）
    let record: CGFloat   // 归一化体重变化（记录饮食）
}

class WeightChangeChartView: UIView {
    // 示例数据，可根据真实需求替换
    let data: [DataPoint] = [
        .init(month: 0, noRecord: 0.00, record: 0.00),
        .init(month: 1, noRecord: 0.12, record: 0.40),
        .init(month: 2, noRecord: 0.28, record: 0.65),
        .init(month: 3, noRecord: 0.38, record: 0.82),
        .init(month: 4, noRecord: 0.45, record: 0.92),
        .init(month: 6, noRecord: 0.55, record: 1.00)
    ]
    
    // 四周留白，用于画坐标轴文字
    let margin = UIEdgeInsets(top: 20, left: 40, bottom: 30, right: 20)
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), data.count > 1 else { return }
        
        // 计算实际绘图区域
        let chartRect = rect.inset(by: margin)
        let maxX: CGFloat = 6
        let maxY: CGFloat = 1.0
        
        // 坐标转换函数
        func point(forMonth m: CGFloat, value v: CGFloat) -> CGPoint {
            let x = chartRect.minX + (m / maxX) * chartRect.width
            let y = chartRect.maxY - (v / maxY) * chartRect.height
            return CGPoint(x: x, y: y)
        }
        
        // —— 1. 橙色区域：x 轴到未记录线 —— //
        let noRecPath = UIBezierPath()
        noRecPath.move(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
        for pt in data {
            noRecPath.addLine(to: point(forMonth: pt.month, value: pt.noRecord))
        }
        noRecPath.addLine(to: CGPoint(x: chartRect.maxX, y: chartRect.maxY))
        noRecPath.close()
        
        ctx.saveGState()
        noRecPath.addClip()
        let orangeColors = [UIColor.orange.withAlphaComponent(0.4).cgColor,
                            UIColor.orange.withAlphaComponent(0.05).cgColor] as CFArray
        let gradO = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: orangeColors, locations: [0,1])!
        ctx.drawLinearGradient(gradO,
                               start: CGPoint(x: chartRect.midX, y: chartRect.minY),
                               end: CGPoint(x: chartRect.midX, y: chartRect.maxY),
                               options: [])
        ctx.restoreGState()
        
        // —— 2. 蓝色区域：在两条线之间 —— //
        let blueAreaPath = UIBezierPath()
        // 从第一条“记录饮食”起点开始
        blueAreaPath.move(to: point(forMonth: data[0].month, value: data[0].record))
        // 沿蓝线到终点
        for pt in data { blueAreaPath.addLine(to: point(forMonth: pt.month, value: pt.record)) }
        // 再沿橙线逆序回到起点
        for pt in data.reversed() { blueAreaPath.addLine(to: point(forMonth: pt.month, value: pt.noRecord)) }
        blueAreaPath.close()
        
        ctx.saveGState()
        blueAreaPath.addClip()
        let blueColors = [UIColor.blue.withAlphaComponent(0.4).cgColor,
                          UIColor.blue.withAlphaComponent(0.05).cgColor] as CFArray
        let gradB = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: blueColors, locations: [0,1])!
        ctx.drawLinearGradient(gradB,
                               start: CGPoint(x: chartRect.midX, y: chartRect.minY),
                               end: CGPoint(x: chartRect.midX, y: chartRect.maxY),
                               options: [])
        ctx.restoreGState()
        
        // 公共样式
        ctx.setLineWidth(3)
        ctx.setLineCap(.round)
        
        // —— 3. 橙色平滑折线（未记录） —— //
        UIColor.orange.setStroke()
        let orangeLine = UIBezierPath()
        orangeLine.move(to: point(forMonth: data[0].month, value: data[0].noRecord))
        for i in 1..<data.count {
            let prev = data[i-1]
            let cur  = data[i]
            let p0 = point(forMonth: prev.month, value: prev.noRecord)
            let p1 = point(forMonth: cur.month,  value: cur.noRecord)
            let cp = CGPoint(x: (p0.x + p1.x)/2, y: p0.y)
            orangeLine.addQuadCurve(to: p1, controlPoint: cp)
        }
        orangeLine.stroke()
        
        // —— 4. 蓝色平滑折线（记录饮食） —— //
        UIColor.blue.setStroke()
        let blueLine = UIBezierPath()
        blueLine.move(to: point(forMonth: data[0].month, value: data[0].record))
        for i in 1..<data.count {
            let prev = data[i-1]
            let cur  = data[i]
            let p0 = point(forMonth: prev.month, value: prev.record)
            let p1 = point(forMonth: cur.month,  value: cur.record)
            let cp = CGPoint(x: (p0.x + p1.x)/2, y: p0.y)
            blueLine.addQuadCurve(to: p1, controlPoint: cp)
        }
        blueLine.stroke()
        
        // —— 5. 端点圆点 & 文本标注 —— //
        for (color, label, valueKey) in [
            (UIColor.orange, "未记录", \DataPoint.noRecord),
            (UIColor.blue,   "记录饮食", \DataPoint.record)
        ] {
            let last = data.last!
            let pt   = point(forMonth: last.month, value: last[keyPath: valueKey])
            
            // 圆点
            let dot = UIBezierPath(arcCenter: pt, radius: 4, startAngle: 0, endAngle: .pi*2, clockwise: true)
            color.setFill()
            dot.fill()
            
            // 文本
            let attrs: [NSAttributedString.Key:Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: color
            ]
            let textSize = (label as NSString).size(withAttributes: attrs)
            let textPoint = CGPoint(x: pt.x + 6, y: pt.y - textSize.height - 2)
            (label as NSString).draw(at: textPoint, withAttributes: attrs)
        }
        
        // —— 6. 坐标轴文字 —— //
        // Y 轴标题（旋转绘制）
        ctx.saveGState()
        let yTitle = "体重变化" as NSString
        let yAttrs: [NSAttributedString.Key:Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        ctx.translateBy(x: chartRect.minX - 30, y: chartRect.midY)
        ctx.rotate(by: -CGFloat.pi/2)
        yTitle.draw(at: CGPoint(x: -yTitle.size(withAttributes: yAttrs).width/2, y: 0), withAttributes: yAttrs)
        ctx.restoreGState()
        
        // X 轴末尾标注
        let xTitle = "6个月" as NSString
        let xAttrs: [NSAttributedString.Key:Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        let xPoint = CGPoint(
            x: chartRect.maxX - xTitle.size(withAttributes: xAttrs).width/2,
            y: chartRect.maxY + 4
        )
        xTitle.draw(at: xPoint, withAttributes: xAttrs)
    }
}

// 用法示例：在某个 UIViewController 里
class ChartViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let chart = WeightChangeChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chart)
        
        NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chart.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            chart.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
}
