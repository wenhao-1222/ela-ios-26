//
//  ColorWheelView.swift
//  lns
//
//  Created by LNS2 on 2025/11/27.
//

import UIKit

protocol ColorWheelViewDelegate: AnyObject {
    func colorWheelDidChangeColor(_ color: UIColor)
}

class ColorWheelView: UIView {
    
    weak var delegate: ColorWheelViewDelegate?
    
    private var colorWheelImage: UIImage?
    private var indicator: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if colorWheelImage == nil || colorWheelImage?.size != bounds.size {
            colorWheelImage = generateColorWheelImage(size: bounds.size)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        colorWheelImage?.draw(in: rect)
        
        // Draw selection point
        let radius: CGFloat = 8
        let path = UIBezierPath(ovalIn: CGRect(x: indicator.x - radius,
                                               y: indicator.y - radius,
                                               width: radius * 2,
                                               height: radius * 2))
        UIColor.white.setStroke()
        UIColor.black.setFill()
        path.lineWidth = 2
        path.stroke()
        path.fill()
    }
    

    // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
    }

    private func handleTouch(_ touches: Set<UITouch>) {
        guard let point = touches.first?.location(in: self) else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let r = bounds.width / 2
        
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx*dx + dy*dy)
        
        if distance <= r {  // Inside the circle
            indicator = point
        } else {            // Outside, clamp to edge
            let scale = r / distance
            indicator = CGPoint(x: center.x + dx * scale,
                                y: center.y + dy * scale)
        }
        
        delegate?.colorWheelDidChangeColor(color(at: indicator))
        setNeedsDisplay()
    }


    // MARK: - Color Calculation
    private func color(at point: CGPoint) -> UIColor {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let dx = point.x - center.x
        let dy = point.y - center.y
        
        let angle = atan2(dy, dx)
        var hue = angle / (.pi * 2)
        if hue < 0 { hue += 1 }
        
        let distance = sqrt(dx*dx + dy*dy)
        let radius = bounds.width / 2
        let saturation = min(distance / radius, 1)
        
        return UIColor(hue: hue, saturation: saturation, brightness: 1, alpha: 1)
    }

    
    // MARK: - Create Image
    private func generateColorWheelImage(size: CGSize) -> UIImage? {
        let radius = size.width / 2
        let center = CGPoint(x: radius, y: radius)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        
        for y in 0 ..< Int(size.height) {
            for x in 0 ..< Int(size.width) {
                let dx = CGFloat(x) - center.x
                let dy = CGFloat(y) - center.y
                let distance = sqrt(dx*dx + dy*dy)
                
                if distance <= radius {
                    let angle = atan2(dy, dx)
                    var hue = angle / (.pi * 2)
                    if hue < 0 { hue += 1 }
                    let saturation = distance / radius
                    let color = UIColor(hue: hue, saturation: saturation, brightness: 1, alpha: 1)
                    
                    ctx.setFillColor(color.cgColor)
                    ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
