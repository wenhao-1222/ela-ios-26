//
//  PlayerSlider.swift
//  lns
//
//  Created by Elavatine on 2025/8/11.
//

class PlayerSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = rect.size.height / 2
        rect.origin.y = (bounds.size.height - rect.size.height) / 2
        return rect
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
