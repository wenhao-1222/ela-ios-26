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

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        glassView.frame = bounds

        // ⛔️ 关键：隐藏/移除系统 UITabBarButton，避免与自定义重叠
        for sub in subviews {
            if let control = sub as? UIControl, String(describing: type(of: control)).contains("UITabBarButton") {
                control.removeFromSuperview() // 也可用 control.isHidden = true
            }
        }
    }
}
