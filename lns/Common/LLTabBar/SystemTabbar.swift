//
//  SystemTabbar.swift
//  lns
//
//  Created by LNS2 on 2025/10/10.
//

import UIKit

class SystemTabbar: UITabBarController {

    private weak var myTabItem: UITabBarItem?
    private var shouldShowDotAfterLayout = false
    private var pendingDotDiameter: CGFloat = 6
    private var pendingDotOffset: UIOffset = .init(horizontal: 10, vertical: -6)

    override func viewDidLoad() {
        super.viewDidLoad()
        initConfig()
        initVc()
    }

    // ✅ 布局完成后再挂小红点（首次或旋转后都会走到这里）
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldShowDotAfterLayout, let my = myTabItem {
            _ = showDot(on: my, diameter: pendingDotDiameter, offset: pendingDotOffset)
            shouldShowDotAfterLayout = false
        }
    }

    func initConfig() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)

        let height: CGFloat = 44
        let corner: CGFloat = 22
        let baseImage = UIGraphicsImageRenderer(size: CGSize(width: 60, height: height)).image { _ in
            let rect = CGRect(x: 0, y: 0, width: 60, height: height)
            UIColor.secondarySystemFill.setFill()
            UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 3), cornerRadius: corner).fill()
        }
        let resizable = baseImage.resizableImage(withCapInsets: UIEdgeInsets(top: 21, left: 30, bottom: 21, right: 30), resizingMode: .stretch)
        appearance.selectionIndicatorImage = resizable

        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.normal.iconColor = .label
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.label]

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().itemPositioning = .automatic
        UITabBar.appearance().itemSpacing = 8
    }

    func initVc() {
        let mainVc = OverViewVC()
        let journalVc = JournalVC()
        let mineVc = MineVC()
        let forumVc = ForumVC()

        _ = mainVc.view; _ = journalVc.view; _ = forumVc.view

        let vc1 = mainVc
        vc1.tabBarItem = UITabBarItem(title: "概览",
                                      image: UIImage(named: "tabbar_main_normal")!,
                                      selectedImage: UIImage(named: "tabbar_main_selected")!)

        let vc2 = journalVc
        vc2.tabBarItem = UITabBarItem(title: "日志",
                                      image: UIImage(named: "tabbar_logs_normal")!,
                                      selectedImage: UIImage(named: "tabbar_logs_selected")!)

        let vc3 = forumVc
        vc3.tabBarItem = UITabBarItem(title: "干货",
                                      image: UIImage(named: "tabbar_forum_normal")!,
                                      selectedImage: UIImage(named: "tabbar_forum_selected")!)

        let vc4 = mineVc
        vc4.tabBarItem = UITabBarItem(title: "我的",
                                      image: UIImage(named: "tabbar_mine_normal")!,
                                      selectedImage: UIImage(named: "tabbar_mine_selected")!)

        self.myTabItem = vc4.tabBarItem
        self.viewControllers = [vc1, vc2, vc3, vc4].map { UINavigationController(rootViewController: $0) }
        self.selectedIndex = 1

        // ❗️不要在这里直接 showDot；先记住需求，等布局后再执行
        scheduleShowDot(for: vc4.tabBarItem, diameter: kFitWidth(3))
    }

    // MARK: - Badge（系统原生）
    func setMyBadge(visible: Bool) {
        if visible {
            myTabItem?.badgeValue = "."   // 用 "·" 或 "•" 可更小
            myTabItem?.badgeColor = .systemRed
        } else {
            myTabItem?.badgeValue = nil
        }
    }

    // MARK: - 自定义小红点（可控大小）

    /// 布局完成后显示小红点
    private func scheduleShowDot(for item: UITabBarItem, diameter: CGFloat, offset: UIOffset = .init(horizontal: 10, vertical: -6)) {
        self.pendingDotDiameter = diameter
        self.pendingDotOffset = offset
        self.shouldShowDotAfterLayout = true
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
    }

    /// 取得所有 UITabBarButton（先试 UIControl，失败再用类名兜底）
    private func tabBarButtons() -> [UIControl] {
        tabBar.layoutIfNeeded()

        // 1) 常规路径：UIControl 过滤
        var controls = tabBar.subviews.compactMap { $0 as? UIControl }
        if controls.isEmpty {
            // 2) 兜底：按类名匹配 UITabBarButton
            if let cls = NSClassFromString("UITabBarButton") {
                controls = tabBar.subviews.filter { $0.isKind(of: cls) }.compactMap { $0 as? UIControl }
            }
        }
        return controls.sorted { $0.frame.minX < $1.frame.minX }
    }

    @discardableResult
    func showDot(on item: UITabBarItem, diameter: CGFloat = 6, offset: UIOffset = .init(horizontal: 10, vertical: -6)) -> Bool {
        guard let items = tabBar.items,
              let idx = items.firstIndex(of: item) else { return false }

        let buttons = tabBarButtons()
        guard idx < buttons.count else { return false }
        let button = buttons[idx]

        // 先移除旧的
        button.layer.sublayers?.removeAll(where: { $0.name == "customDotLayer" })

        let dot = CAShapeLayer()
        dot.name = "customDotLayer"
        dot.fillColor = UIColor.systemRed.cgColor
        let r = diameter / 2.0
        let center = CGPoint(x: button.bounds.width - r + offset.horizontal,
                             y: r + offset.vertical)
        dot.path = UIBezierPath(arcCenter: center, radius: r, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        button.layer.addSublayer(dot)
        return true
    }

    func hideDot(on item: UITabBarItem) {
        guard let items = tabBar.items,
              let idx = items.firstIndex(of: item) else { return }
        let buttons = tabBarButtons()
        guard idx < buttons.count else { return }
        buttons[idx].layer.sublayers?.removeAll(where: { $0.name == "customDotLayer" })
    }
}
