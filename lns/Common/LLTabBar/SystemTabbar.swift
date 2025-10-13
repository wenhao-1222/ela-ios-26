//
//  SystemTabbar.swift
//  lns
//
//  Created by LNS2 on 2025/10/10.
//

import UIKit

class SystemTabbar: UITabBarController {

    private weak var myTabItem: UITabBarItem?
    let generator = UIImpactFeedbackGenerator(style: .soft)
    private var shouldShowDotAfterLayout = false
    private var pendingDotDiameter: CGFloat = 5
    private var pendingDotOffset: UIOffset = .init(horizontal: 10, vertical: -6)

    // 旧抑制开关保留（本方案不用）
    var suppressTabBarDuringInteractivePop: Bool = false
    private var didInitializeMineRedDotState = false
    private var guideVC: GuideTotalVC?

    /// 记录最后一次“正确”的 tabBar frame（用于复位）
    private var lastStableTabBarFrame: CGRect = .zero
    private var cachedHeight: CGFloat { max(1, tabBar.bounds.height) }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        generator.prepare()
        initConfig()
        initVc()
        observeMineTabNotifications()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gotoLogsNotification),
                                               name: NSNotification.Name(rawValue: "activePlan"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showGuideTotalIfNeeded),
                                               name: NOTIFI_NAME_GUIDE,
                                               object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 记录稳定 frame
        if tabBar.transform == .identity && !tabBar.isHidden && tabBar.alpha > 0.99 {
            lastStableTabBarFrame = tabBar.frame
        }

        // 初次布局后再挂小红点
        if shouldShowDotAfterLayout, let item = mineTabBarItem {
            if showDot(on: item, diameter: pendingDotDiameter, offset: pendingDotOffset) {
                shouldShowDotAfterLayout = false
            }
        }

        if didInitializeMineRedDotState == false {
            didInitializeMineRedDotState = true
            updateMineRedDotInitialState()
        }
    }

    /// 供外部（导航控制器）在显示前后强制复位
    func restoreStableFrameIfNeeded() {
        guard lastStableTabBarFrame != .zero else { return }
        tabBar.transform = .identity
        tabBar.frame = lastStableTabBarFrame
        if let custom = tabBar as? WHTabBar { custom.tabbar.transform = .identity }
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
        view.setNeedsLayout()
        view.layoutIfNeeded()
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

        let themeColor = UIColor.THEME
        appearance.stackedLayoutAppearance.selected.iconColor = themeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: themeColor]
        appearance.inlineLayoutAppearance.selected.iconColor = themeColor
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: themeColor]
        appearance.compactInlineLayoutAppearance.selected.iconColor = themeColor
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: themeColor]
        appearance.stackedLayoutAppearance.normal.iconColor = .label
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.label]

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().itemPositioning = .automatic
        UITabBar.appearance().itemSpacing = 8
        UITabBar.appearance().tintColor = themeColor
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
                                      selectedImage: UIImage(named: "tabbar_main_selected")?.withRenderingMode(.alwaysOriginal))

        let vc2 = journalVc
        vc2.tabBarItem = UITabBarItem(title: "日志",
                                      image: UIImage(named: "tabbar_logs_normal")!,
                                      selectedImage: UIImage(named: "tabbar_logs_selected")?.withRenderingMode(.alwaysOriginal))

        let vc3 = forumVc
        vc3.tabBarItem = UITabBarItem(title: "干货",
                                      image: UIImage(named: "tabbar_forum_normal")!,
                                      selectedImage: UIImage(named: "tabbar_forum_selected")?.withRenderingMode(.alwaysOriginal))

        let vc4 = mineVc
        vc4.tabBarItem = UITabBarItem(title: "我的",
                                      image: UIImage(named: "tabbar_mine_normal")!,
                                      selectedImage: UIImage(named: "tabbar_mine_selected")?.withRenderingMode(.alwaysOriginal))

        let navs = [vc1, vc2, vc3, vc4].map { SystemNavigationController(rootViewController: $0) }
        self.viewControllers = navs
        self.selectedIndex = 1
        self.myTabItem = navs[3].tabBarItem

        if UserInfoModel.shared.msgUnRead {
            scheduleShowDot(for: vc4.tabBarItem, diameter: kFitWidth(3))
        }
    }

    private var mineTabBarItem: UITabBarItem? {
        if let item = myTabItem { return item }
        guard let vcs = viewControllers, vcs.count > 3 else { return nil }
        return vcs[3].tabBarItem
    }

    // MARK: - Badge（系统原生）
    func setMyBadge(visible: Bool) {
        if visible {
            myTabItem?.badgeValue = "."
            myTabItem?.badgeColor = .systemRed
        } else {
            myTabItem?.badgeValue = nil
        }
    }

    // MARK: - 自定义小红点
    private func scheduleShowDot(for item: UITabBarItem, diameter: CGFloat, offset: UIOffset = .init(horizontal: 10, vertical: -6)) {
        self.pendingDotDiameter = diameter
        self.pendingDotOffset = offset
        self.shouldShowDotAfterLayout = true
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
    }

    private func tabBarButtons() -> [UIControl] {
        tabBar.layoutIfNeeded()
        func allSubviews(_ v: UIView) -> [UIView] { v.subviews + v.subviews.flatMap { allSubviews($0) } }
        let all = allSubviews(tabBar)
        let buttons = all.compactMap { $0 as? UIControl }.filter { control in
            let name = String(describing: type(of: control))
            let looksLike = control.subviews.contains { $0 is UIImageView } &&
                            control.subviews.contains { $0 is UILabel } &&
                            control.bounds.width > 10 && control.bounds.height > 10
            return name.contains("TabBarButton") || looksLike
        }
        return buttons.sorted { $0.frame.midX < $1.frame.midX }
    }

    private func tabBarButton(for item: UITabBarItem) -> UIControl? {
        tabBar.layoutIfNeeded()
        func associatedItem(for control: UIControl) -> UITabBarItem? {
            let selectors = [Selector(("tabBarItem")), Selector(("item"))]
            for selector in selectors where control.responds(to: selector) {
                if let unmanaged = control.perform(selector) {
                    let value = unmanaged.takeUnretainedValue()
                    if let item = value as? UITabBarItem { return item }
                }
            }
            return nil
        }
        func findButton(in view: UIView) -> UIControl? {
            for subview in view.subviews {
                if let control = subview as? UIControl,
                   let linkedItem = associatedItem(for: control),
                   linkedItem === item { return control }
                if let found = findButton(in: subview) { return found }
            }
            return nil
        }
        if let directMatch = findButton(in: tabBar) { return directMatch }
        if let items = tabBar.items,
           let idx = items.firstIndex(of: item) {
            let buttons = tabBarButtons()
            if idx < buttons.count { return buttons[idx] }
        }
        return nil
    }

    @discardableResult
    func showDot(on item: UITabBarItem,
                 diameter: CGFloat = 6,
                 offset: UIOffset = .init(horizontal: 12, vertical: -10)) -> Bool {
        guard let items = tabBar.items,
              let idx = items.firstIndex(of: item),
              items.count > 0 else { return false }

        let layerName = "customDotLayer_\(idx)"
        tabBar.layer.sublayers?.removeAll(where: { $0.name == layerName })
        tabBar.layoutIfNeeded()

        let count = CGFloat(items.count)
        let segmentWidth = tabBar.bounds.width / max(count, 1)
        let midX = segmentWidth * (CGFloat(idx) + 0.5)
        let baseY = tabBar.bounds.height * 0.28

        let x = midX
        let y = max(min(baseY + offset.vertical, tabBar.bounds.height - diameter/2), diameter/2)

        let dot = CAShapeLayer()
        dot.name = layerName
        dot.fillColor = UIColor.systemRed.cgColor
        let r = diameter / 2.0
        dot.path = UIBezierPath(arcCenter: CGPoint(x: x, y: y),
                                radius: r,
                                startAngle: 0,
                                endAngle: .pi * 2,
                                clockwise: true).cgPath
        tabBar.layer.addSublayer(dot)
        return true
    }

    func hideDot(on item: UITabBarItem) {
        guard let items = tabBar.items,
              let idx = items.firstIndex(of: item) else { return }
        let layerName = "customDotLayer_\(idx)"
        tabBar.layer.sublayers?.removeAll(where: { $0.name == layerName })
    }
}

extension SystemTabbar: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        generator.impactOccurred(intensity: 0.8)
        generator.prepare()
        return true
    }
}

extension SystemTabbar {
    private func observeMineTabNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mineServiceMsgNotification),
                                               name: NSNotification.Name(rawValue: "serviceMsgUnRead"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mineServiceMsgReadNotification),
                                               name: NSNotification.Name(rawValue: "serviceMsgRead"),
                                               object: nil)
    }

    private func updateMineRedDotInitialState() {
        if UserInfoModel.shared.msgUnRead {
            setMineRedDotHidden(false)
        } else {
            mineServiceMsgReadNotification()
        }
    }

    private func setMineRedDotHidden(_ hidden: Bool) {
        guard let item = mineTabBarItem else { return }
        if hidden {
            shouldShowDotAfterLayout = false
            hideDot(on: item)
        } else {
            let diameter = kFitWidth(3)
            let offset = UIOffset(horizontal: 10, vertical: -6)
            pendingDotDiameter = diameter
            pendingDotOffset = offset
            if showDot(on: item, diameter: diameter, offset: offset) == false {
                scheduleShowDot(for: item, diameter: diameter, offset: offset)
            }
        }
    }

    @objc private func mineServiceMsgNotification() {
        setMineRedDotHidden(false)
    }

    @objc private func mineServiceMsgReadNotification() {
        let shouldHide = UserInfoModel.shared.settingNewFuncRead && UserInfoModel.shared.newsListHasUnRead == false
        setMineRedDotHidden(shouldHide)
    }

    @objc private func showGuideTotalIfNeeded() {
        let vc = GuideTotalVC()
        vc.finishBlock = { [weak self] in self?.removeGuideTotalVC() }
        guideVC = vc
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.frame = view.bounds
    }

    private func removeGuideTotalVC() {
        guard let vc = guideVC else { return }
        UIView.animate(withDuration: 0.3, animations: { vc.view.alpha = 0 }) { _ in
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            self.guideVC = nil
        }
        UserDefaults.standard.setValue("1", forKey: guide_total)
    }

    @objc private func gotoLogsNotification() {
        selectedIndex = 1
    }
}



