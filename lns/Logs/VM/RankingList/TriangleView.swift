//
//  TriangleView.swift
//  lns
//
//  Created by Elavatine on 2025/7/3.
//

class TriangleView: UIView {

    enum Direction {
        case up
        case down
    }

    var direction: Direction = .up {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        switch direction {
        case .up:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        case .down:
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }
        path.close()

        UIColor.white.setFill()
        path.fill()
    }
}
