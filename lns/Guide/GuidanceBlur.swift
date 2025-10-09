//
//  GuidanceBlur.swift
//  lns
//
//  Created by Elavatine on 2025/2/10.
//

import CoreImage

class GuidanceBlur{
    func lnsGuidanceBlur(
        on view: UIView,
        isShowGuidance: Bool,
        blurRadius: CGFloat = 10
    ) {
        // 相当于 “if (isShowGuidance && Build.VERSION.SDK_INT >= 31)”
        // 这里用系统版本判断模拟一下；你也可以按自己需要改动
        if isShowGuidance, #available(iOS 14.0, *) {
            // 给 layer 加一个自定义模糊滤镜
            let blurFilter = CIFilter(name: "CIGaussianBlur")!
            blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)

            // iOS 对于 layer 的 filters 数组，每个元素可以是一个 CIFilter。
            // 真正渲染时系统会把这个滤镜应用到 view.layer 的内容上。
            view.layer.filters = [blurFilter]
        } else {
            // 不符合条件，则去掉滤镜
            view.layer.filters = nil
        }
    }
}
