//
//  UIImage+Exs.swift
//  ttjx
//
//  Created by 文 on 2019/8/30.
//  Copyright © 2019 ttjx. All rights reserved.
//


import UIKit

extension UIImage {
    /// Compress image to keep data size below the given KB value.
    /// - Parameter maxKB: Maximum size in kilobytes.
    /// - Returns: Compressed UIImage.
    func compressTo(maxKB: Int) -> UIImage {
        let maxBytes = maxKB * 1024
        var compression: CGFloat = 1.0
        guard var data = self.jpegData(compressionQuality: compression) else { return self }
        if data.count <= maxBytes { return self }
        // Reduce JPEG quality
        while data.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            if let d = self.jpegData(compressionQuality: compression) {
                data = d
            }
        }
        // If still larger, scale image dimensions
        if data.count > maxBytes {
            var lastDataCount = 0
            var scaledImage = self
            while data.count > maxBytes && data.count != lastDataCount {
                lastDataCount = data.count
                let ratio = CGFloat(maxBytes) / CGFloat(data.count)
                let newSize = CGSize(width: scaledImage.size.width * sqrt(ratio),
                                     height: scaledImage.size.height * sqrt(ratio))
                UIGraphicsBeginImageContextWithOptions(newSize, false, scaledImage.scale)
                scaledImage.draw(in: CGRect(origin: .zero, size: newSize))
                scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? scaledImage
                UIGraphicsEndImageContext()
                if let d = scaledImage.jpegData(compressionQuality: compression) {
                    data = d
                }
            }
            return scaledImage
        }
        return UIImage(data: data) ?? self
    }
    /// 判断当前 UIImage 序列化为 JPEG 后是否小于指定的 maxKB（单位：KB）
    ///
    /// - Parameter maxKB: 目标最大体积（单位：KB）
    /// - Returns: 如果 JPEG Data 存在且大小 ≤ maxKB KB，返回 true；否则返回 false
    func isSizeLessThanKB(_ maxKB: Int) -> Bool {
        // 1. 将 UIImage 转为 JPEG Data（quality = 1.0，即最高质量）
        guard let data = self.jpegData(compressionQuality: 1.0) else {
            // 无法生成 Data 时，认为“不满足小于条件”
            return false
        }
        // 2. data.count 返回的是字节数，转为 KB 再比较
        DLLog(message: "图片大小：\(data.count/1024) kb")
        return data.count <= maxKB * 1024
    }
    /// 将当前 UIImage 压缩到不超过指定的最大 KB，返回 JPEG 格式的 Data
    ///
    /// - Parameter maxKB: 目标最大体积（单位：KB）
    /// - Returns: 如果压缩成功，则返回不超过 maxKB 的 JPEG Data；否则返回 nil
    func compressed(toMaxKB maxKB: Int) -> Data? {
        // 1. 先用最高质量（1.0）生成一次 JPEG Data
        guard var data = self.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        
        // 2. 如果当前已经小于等于 maxKB，直接返回
        if data.count <= maxKB * 1024 {
            return data
        }
        
        // 3. 否则，使用二分法在 [0.0, 1.0] 区间寻找合适的 compressionQuality
        var left: CGFloat = 0.0
        var right: CGFloat = 1.0
        var bestData: Data = data
        
        // 二分 6～8 次即可达到较好精度（视需求可调整循环次数）
        for _ in 0..<6 {
            let mid = (left + right) / 2
            // 用 mid 质量尝试一次
            if let compressed = self.jpegData(compressionQuality: mid) {
                if compressed.count > maxKB * 1024 {
                    // 如果仍然超出限制，则降低右边界（质量更低）
                    right = mid
                } else {
                    // 如果已经小于等于 maxKB，则记录当前结果，并尝试更高质量
                    bestData = compressed
                    left = mid
                }
            }
        }
        
        return bestData
    }
    //MARK 更改图片颜色
    public func WHImageWithTintColor(color : UIColor) -> UIImage{
        let drawRect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        color.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
    // 更改为主颜色
    public func WHImageWithTintMainColor() -> UIImage {
        return WHImageWithTintColor(color: UIColor.THEME)
    }
    
    // 通过rect，裁切图片
    func WHImageCrop(toRect:CGRect) -> UIImage {
        
        let imageRef = self.cgImage?.cropping(to: toRect)
        let image = UIImage.init(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
    
    public func CTRenderingByMainColor() -> UIImage {
        let drawRect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        UIColor.THEME.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    func fixOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}


//MARK -UIImage的处理
// 通过一个控件生成一张图片
func WHImage_createdWithView(view : UIView) -> UIImage {
    
    let size = view.bounds.size
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}

public func createImageWithColor(color:UIColor) -> UIImage {
    let rect = CGRect.init(x:0, y:0, width:1.0, height:1.0)

    UIGraphicsBeginImageContext(rect.size)

    let context = UIGraphicsGetCurrentContext()

    context!.setFillColor(color.cgColor)

    context!.fill(rect)

    let image = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return image!
}
