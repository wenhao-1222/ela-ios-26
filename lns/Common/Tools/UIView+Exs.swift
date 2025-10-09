//
//  UIView+Exs.swift
//  kxf
//
//  Created by 文 on 2023/7/6.
//

import Foundation
import UIKit


//private var pressGestureKey: UInt8 = 0
//private var pressGenerator = UIImpactFeedbackGenerator(style: .rigid)
//private var pressGeneratorWeight: CGFloat = 0.6


extension UIView {
    /**
     * 将一个UIView视图转为图片
     */
    public func mc_makeImage() -> UIImage {
        let size = self.bounds.size
        
        /**
         * 第一个参数表示区域大小。
         第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。
         第三个参数就是屏幕密度了
         */
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    func addShadow(color: UIColor = .COLOR_BG_BLACK, opacity: Float = 0.2, radius: CGFloat = 10, offset: CGSize = CGSize(width: 0, height: 5)) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
    }
    func addClipCorner(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    //Colors：渐变色色值数组
    func setLayerColors(_ colors:[CGColor])  {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.colors = colors
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        self.layer.addSublayer(layer)
    }
    func addDashedBorder(borderColor:UIColor,dashPattern:[NSNumber]) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = kFitWidth(1)
        shapeLayer.lineDashPattern = dashPattern//[6, 3] // 虚线的样式，6是实线长度，3是空格长度
        
        setNeedsLayout()
        layoutIfNeeded()
        let path = UIBezierPath(rect: self.bounds)
        shapeLayer.path = path.cgPath
        shapeLayer.frame = self.bounds
        
        self.layer.addSublayer(shapeLayer)
    }
    func blur(blurRadius blurRadius: CGFloat)
    {
        if self.superview == nil
        {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: frame.width, height: frame.height), false, 1)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
  
        UIGraphicsEndImageContext();
        
        guard let blur = CIFilter(name: "CIGaussianBlur"),
              let this = self as? UIView else
        {
            return
        }
  
        blur.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        blur.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let ciContext  = CIContext(options: nil)
        
        let result = (blur.value(forKey: kCIOutputImageKey) as! CIImage?)!
        
        let boundingRect = CGRect(x:0,
            y: 0,
            width: frame.width,
            height: frame.height)
        
        let cgImage = ciContext.createCGImage(result, from: boundingRect)

        let filteredImage = UIImage(cgImage: cgImage!)
        
        let blurOverlay = BlurOverlay()
        blurOverlay.frame = boundingRect
        
        blurOverlay.image = filteredImage
        blurOverlay.contentMode = UIView.ContentMode.left
     
        if let superview = superview as? UIStackView,
           let index = (superview as UIStackView).arrangedSubviews.firstIndex(of: this)
        {
            removeFromSuperview()
            superview.insertArrangedSubview(blurOverlay, at: index)
        }
        else
        {
            blurOverlay.frame.origin = frame.origin
            
            UIView.transition(from: this,
                              to: blurOverlay,
                duration: 0.2,
                              options: .curveEaseIn,
                completion: nil)
        }
        
        objc_setAssociatedObject(this,
            &BlurableKey.blurable,
            blurOverlay,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
