//
//  DataMainLineExtendView.swift
//  lns
//
//  Created by Elavatine on 2025/8/27.
//

import UIKit

class DataMainLineExtendView: UIView {
    var yXaisNum: Int = 0
    var chartGap: CGFloat = 0

    override init(frame: CGRect) {
        let newFrame = CGRect(x: frame.origin.x - 200,
                              y: frame.origin.y,
                              width: frame.size.width + 400,
                              height: frame.size.height)
        super.init(frame: newFrame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let topGap = kfitWidth(0)
        for i in 0..<yXaisNum {
            let originY = topGap + chartGap * CGFloat(i)
            drawLine(context: context,
                     startPoint: CGPoint(x: 0, y: originY),
                     endPoint: CGPoint(x: frame.size.width, y: originY),
                     lineColor: UIColor.black.withAlphaComponent(0.15),
                     lineWidth: 1)
        }
    }

    private func drawLine(context: CGContext,
                          startPoint: CGPoint,
                          endPoint: CGPoint,
                          lineColor: UIColor,
                          lineWidth: CGFloat) {
        context.setShouldAntialias(true)
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(lineWidth)
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.strokePath()
    }

    private func kfitWidth(_ width: CGFloat) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return width * min(UIScreen.main.bounds.size.width / 375,
                               UIScreen.main.bounds.size.height / 812)
        } else {
            return width * UIScreen.main.bounds.size.width / 375
        }
    }
}
