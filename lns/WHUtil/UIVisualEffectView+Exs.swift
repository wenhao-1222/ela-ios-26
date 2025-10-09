//
//  UIVisualEffectView+Exs.swift
//  lns
//
//  Created by Elavatine on 2025/2/8.
//

extension UIVisualEffectView {
    /// 根据模糊程度生成 UIVisualEffectView
    public convenience init(blurRadius: CGFloat) {
        let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
        blurEffect.setValue(blurRadius, forKeyPath: "blurRadius")

        self.init(effect: blurEffect)
    }
}
