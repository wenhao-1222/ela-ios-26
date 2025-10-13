//
//  SystemNavigationController.swift
//  lns
//
//  Created by LNS2 on 2025/10/13.
//
import UIKit
import ObjectiveC

final class SystemNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    // MARK: - State
    private var cachedTabBarHeight: CGFloat = 0

    // 记录被临时改动的 hidesBottomBarWhenPushed 原值
    private struct AssocKey { static var origHidesKey: UInt8 = 0 }
    private func setOriginalHides(_ value: Bool, for vc: UIViewController) {
        objc_setAssociatedObject(vc, &AssocKey.origHidesKey, NSNumber(value: value), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    private func originalHides(for vc: UIViewController) -> Bool? {
        (objc_getAssociatedObject(vc, &AssocKey.origHidesKey) as? NSNumber)?.boolValue
    }
    private func clearOriginalHides(for vc: UIViewController) {
        objc_setAssociatedObject(vc, &AssocKey.origHidesKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
        navigationBar.isHidden = true
        navigationBar.tintColor = .label
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        hookPopGestures()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !viewControllers.isEmpty { viewController.hidesBottomBarWhenPushed = true }
        super.pushViewController(viewController, animated: animated)
    }

    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        guard let tbc = tabBarController else { return }
        let tabBar = tbc.tabBar
        cachedTabBarHeight = max(1, tabBar.bounds.height)

        let toNeedsHide = shouldHideTabBar(for: viewController)
        let tbcEx = (tbc as? SystemTabbar)

        guard animated, let coordinator = transitionCoordinator else {
            if toNeedsHide {
                tbcEx?.suppressTabBarDuringInteractivePop = false
                hideTabBarHard(tabBar)
            } else {
                tbcEx?.suppressTabBarDuringInteractivePop = false
                restoreTabBarFrame(tabBar) // 强制复位
                showTabBarInstant(tabBar)
            }
            return
        }

        let toVC = viewController

        // 若目标页最终应显示 TabBar，过渡全程临时“欺骗系统”
        if !toNeedsHide {
            if originalHides(for: toVC) == nil { setOriginalHides(toVC.hidesBottomBarWhenPushed, for: toVC) }
            toVC.hidesBottomBarWhenPushed = true
        }

        // 起始：隐藏并移出屏外；打开“帧级抑制”
        tbcEx?.suppressTabBarDuringInteractivePop = !toNeedsHide
        hideTabBarHard(tabBar)

        // 交互状态变化
        coordinator.notifyWhenInteractionChanges { [weak self] context in
            guard let self = self,
                  let tabBar = self.tabBarController?.tabBar,
                  let tbcEx = self.tabBarController as? SystemTabbar else { return }
            if context.isCancelled {
                tbcEx.suppressTabBarDuringInteractivePop = false
                self.hideTabBarHard(tabBar)
                if let orig = self.originalHides(for: toVC) {
                    toVC.hidesBottomBarWhenPushed = orig
                    self.clearOriginalHides(for: toVC)
                }
                // 取消后立刻复位 frame，防止卡在半高
                self.restoreTabBarFrame(tabBar)
            }
        }

        // 收口
        coordinator.animate(alongsideTransition: nil) { [weak self] context in
            guard let self = self,
                  let tabBar = self.tabBarController?.tabBar,
                  let tbcEx = self.tabBarController as? SystemTabbar else { return }

            if context.isCancelled { return }

            if !toNeedsHide {
                // 到达需要显示 TabBar 的页面
                if let orig = self.originalHides(for: toVC) {
                    toVC.hidesBottomBarWhenPushed = orig
                    self.clearOriginalHides(for: toVC)
                } else {
                    toVC.hidesBottomBarWhenPushed = false
                }
                tbcEx.suppressTabBarDuringInteractivePop = false

                // 关键：显示前先精确复位 frame，再做淡入
                self.restoreTabBarFrame(tabBar)
                self.showTabBarWithAnimation(tabBar, duration: 0.15)
                // 显示后再做一次强制复位，抵消潜在的布局竞态
                DispatchQueue.main.async {
                    self.restoreTabBarFrame(tabBar)
                }
            } else {
                tbcEx.suppressTabBarDuringInteractivePop = false
                self.hideTabBarHard(tabBar)
                self.restoreTabBarFrame(tabBar)
                if let orig = self.originalHides(for: toVC) {
                    toVC.hidesBottomBarWhenPushed = orig
                    self.clearOriginalHides(for: toVC)
                }
            }
        }
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

// MARK: - Helpers
private extension SystemNavigationController {

    func shouldHideTabBar(for viewController: UIViewController?) -> Bool {
        guard let vc = viewController else { return false }
        if vc == viewControllers.first { return false }
        return vc.hidesBottomBarWhenPushed
    }

    /// 硬隐藏：isHidden = true + alpha = 0 + transform 下移出屏幕（不改安全区）
    func hideTabBarHard(_ tabBar: UITabBar) {
        tabBar.alpha = 0
        tabBar.isHidden = true
        tabBar.transform = CGAffineTransform(translationX: 0, y: cachedTabBarHeight)
        if let custom = tabBar as? WHTabBar {
            custom.tabbar.alpha = 0
            custom.tabbar.isHidden = true
            custom.tabbar.transform = CGAffineTransform(translationX: 0, y: cachedTabBarHeight)
        }
        // 不再强制 clipsToBounds，避免圆角阴影被裁剪看似“位置不对”
    }

    func showTabBarInstant(_ tabBar: UITabBar) {
        tabBar.isHidden = false
        tabBar.alpha = 1
        tabBar.transform = .identity
        if let custom = tabBar as? WHTabBar {
            custom.tabbar.isHidden = false
            custom.tabbar.alpha = 1
            custom.tabbar.transform = .identity
        }
        restoreTabBarFrame(tabBar)
    }

    func showTabBarWithAnimation(_ tabBar: UITabBar, duration: TimeInterval) {
        tabBar.isHidden = false
        tabBar.alpha = 0
        tabBar.transform = CGAffineTransform(translationX: 0, y: cachedTabBarHeight)
        if let custom = tabBar as? WHTabBar {
            custom.tabbar.isHidden = false
            custom.tabbar.alpha = 0
            custom.tabbar.transform = CGAffineTransform(translationX: 0, y: cachedTabBarHeight)
        }
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut]) {
            tabBar.alpha = 1
            tabBar.transform = .identity
            if let custom = tabBar as? WHTabBar {
                custom.tabbar.alpha = 1
                custom.tabbar.transform = .identity
            }
        } completion: { _ in
            self.restoreTabBarFrame(tabBar)
        }
    }

    /// 精确复位：把 transform 清零后，强制把 frame 拉到底边，并触发布局
    func restoreTabBarFrame(_ tabBar: UITabBar) {
        guard let container = tabBar.superview else { return }
        tabBar.transform = .identity
        if let custom = tabBar as? WHTabBar { custom.tabbar.transform = .identity }

        var f = tabBar.frame
        // 以容器高度为准，保证 y = 底部
        let containerH = container.bounds.height
        f.origin.y = containerH - f.height
        tabBar.frame = f

        // 强制一次布局，防止 WHTabBar 的内部布局晚于我们复位
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
        container.setNeedsLayout()
        container.layoutIfNeeded()
    }
}

// MARK: - Pop Gesture Hook（系统 + FDFullscreenPopGesture）
private extension SystemNavigationController {
    func hookPopGestures() {
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleAnyPopGesture(_:)))
        if let fdPan = value(forKey: "fd_fullscreenPopGestureRecognizer") as? UIPanGestureRecognizer {
            fdPan.addTarget(self, action: #selector(handleAnyPopGesture(_:)))
        }
    }

    @objc
    func handleAnyPopGesture(_ gr: UIPanGestureRecognizer) {
        guard gr.state == .began else { return }
        guard let tbc = tabBarController else { return }
        let tabBar = tbc.tabBar

        // 预测将显示的控制器（栈中倒数第二个）
        let count = viewControllers.count
        guard count >= 2 else { return }
        let toVC = viewControllers[count - 2]

        if !shouldHideTabBar(for: toVC) {
            if originalHides(for: toVC) == nil { setOriginalHides(toVC.hidesBottomBarWhenPushed, for: toVC) }
            toVC.hidesBottomBarWhenPushed = true
            cachedTabBarHeight = max(1, tabBar.bounds.height)
            (tabBarController as? SystemTabbar)?.suppressTabBarDuringInteractivePop = true
            hideTabBarHard(tabBar)
        } else {
            (tabBarController as? SystemTabbar)?.suppressTabBarDuringInteractivePop = false
            hideTabBarHard(tabBar)
        }
    }
}

