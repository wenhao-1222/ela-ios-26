//
//  PlayerSlider.swift
//  lns
//
//  Created by Elavatine on 2025/8/11.
//

class PlayerSlider: UISlider {
    /// 负值表示向外扩；建议至少 44pt 的可点尺寸
        var hitTestEdgeInsets = UIEdgeInsets(top: -12, left: -102, bottom: -12, right: -102)

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = rect.size.height / 2
        rect.origin.y = (bounds.size.height - rect.size.height) / 2
        return rect
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerBounds = bounds.inset(by: hitTestEdgeInsets)
        return largerBounds.contains(point)
    }
}

extension UIImage {
    func scaled(by scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
