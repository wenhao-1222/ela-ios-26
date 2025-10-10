//
//  WHTabBar.swift
//  lns
//
//  Created by LNS2 on 2024/5/6.
//
import UIKit

/// 自定义 TabBar：最底层铺 “LiquidGlassView”，并屏蔽系统 UITabBarButton
class WHTabBar: UITabBar {

    var tabbar = LLMyTabbar()
    private let glassView = LiquidGlassView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isTranslucent = true

        insertSubview(glassView, at: 0)

        // 顶部分割线（极轻）
        layer.shadowColor = UIColor.label.withAlphaComponent(0.08).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: -0.5)
        layer.shadowRadius = 0
        layer.masksToBounds = false
        if #available(iOS 13.0, *) { layer.cornerCurve = .continuous }
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        clearTabBarWrapperBackground()   // [Fix-W2]
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
//        glassView.frame = bounds
        if glassView.superview != nil { glassView.frame = bounds }
        glassView.frame = bounds
        // 中和系统按钮/铺满背景/置顶自定义层等...

        clearTabBarWrapperBackground()   // [Fix-W2] 再兜底一次
        // ⛔️ 关键：隐藏/移除系统 UITabBarButton，避免与自定义重叠
        for sub in subviews {
            if let control = sub as? UIControl, String(describing: type(of: control)).contains("UITabBarButton") {
                control.removeFromSuperview() // 也可用 control.isHidden = true
            }
        }
    }
    private func clearTabBarWrapperBackground() {
        // 从当前 UITabBar 开始，逐级向上找
        var v: UIView? = self
        while let s = v?.superview {
            let name = String(describing: type(of: s))

            // 命中 iOS 18/26 的两种容器命名
            if name.contains("UITabBarContainerWrapperView") || name.contains("UITabBarContainerView") {
                // 置透明 & 非不透明
                s.backgroundColor = .clear
                s.isOpaque = false

                // 一些机型上 wrapper 里还会塞分隔线/阴影/背景视图，统统隐藏
                for sub in s.subviews {
                    let subName = String(describing: type(of: sub))
                    if subName.contains("Shadow") ||
                       subName.contains("Separator") ||
                       subName.contains("Background") {
                        sub.isHidden = true
                        sub.alpha = 0.0
                        sub.isUserInteractionEnabled = false
                    }
                }
                // 找到了就可以退出
                break
            }
            v = s
        }
    }

}
