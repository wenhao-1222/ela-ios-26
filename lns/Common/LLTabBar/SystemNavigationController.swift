//
//  SystemNavigationController.swift
//  lns
//
//  Created by LNS2 on 2025/10/13.
//

// SystemNavigationController.swift —— TabBar 垂直动画（非交互：自下而上；交互：立即复原，取消则下沉隐藏）
import UIKit
import ObjectiveC

final class SystemNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    // 记录临时改动的 hidesBottomBarWhenPushed（用于“欺骗系统”，防止系统把 TabBar 拉入系统层动画）
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
    }

    // 只在本导航的根页显示 TabBar（你已限制四个根页，这里按“根页”判断是否显示）
    private func isRootOfThisNav(_ vc: UIViewController?) -> Bool {
        guard let vc = vc else { return false }
        return vc === viewControllers.first
    }

    // MARK: - Push（mainVc -> nextVc / 更深 push）
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 { viewController.hidesBottomBarWhenPushed = true }

        guard animated, let tabBar = tabBarController?.tabBar else {
            super.pushViewController(viewController, animated: animated)
            return
        }

        let pushingFromRootToFirst = (viewControllers.count == 1)
        if !pushingFromRootToFirst {
            // 更深层 push：保持到底部以下并隐藏，杜绝露头
            setTabBarHiddenBottom(tabBar)
            super.pushViewController(viewController, animated: animated)
            return
        }

        // 根 -> 第一个二级：从 0 动画到 +h（向下消失）
        unhideTabBarAtOffsetY(tabBar, offsetY: 0)
        super.pushViewController(viewController, animated: animated)
        if let coordinator = transitionCoordinator {
            let h = tabBar.bounds.height
            coordinator.animate(alongsideTransition: { _ in
                self.setTabBarOffsetY(tabBar, offsetY: h)
            }, completion: { [weak self] context in
                guard let self = self else { return }
                if context.isCancelled {
                    self.setTabBarOffsetY(tabBar, offsetY: 0)
                } else {
                    self.setTabBarHiddenBottom(tabBar)
                }
            })
        }
    }

    // MARK: - Pop（nextVc -> 根页）：非交互=自下而上；交互=立即复原，取消则下沉隐藏
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        guard let tabBar = tabBarController?.tabBar else { return }
        let willShowRoot = isRootOfThisNav(viewController)
        let toVC = viewController

        // 需要显示时，“欺骗系统”，避免系统把 TabBar 拉进过渡
        if willShowRoot {
            if originalHides(for: toVC) == nil { setOriginalHides(toVC.hidesBottomBarWhenPushed, for: toVC) }
            toVC.hidesBottomBarWhenPushed = true
        }

        guard animated, let coordinator = transitionCoordinator else {
            // 非动画：直接对齐目标态
            if willShowRoot {
                // 起始放到底部以下，随后立即不带动画复原到位，避免“先上挪再回”的错觉
                prepareTabBarStartAtBottom(tabBar)
                snapRevealToIdentity(tabBar) // 直接就位（无动画）
                (tabBarController as? SystemTabbar)?.restoreStableFrameIfNeeded()
            } else {
                setTabBarHiddenBottom(tabBar)
            }
            if let orig = self.originalHides(for: toVC) { toVC.hidesBottomBarWhenPushed = orig; self.clearOriginalHides(for: toVC) }
            return
        }

        if coordinator.isInteractive {
            // ✅ 交互返回：不跟随手势进度。判断到是回根页，就“立即”完整复原到位；若取消，则再整段下沉隐藏。
            if willShowRoot {
                prepareTabBarStartAtBottom(tabBar)
                animateReveal(tabBar, duration: 0.22)

                coordinator.notifyWhenInteractionChanges { [weak self] context in
                    guard let self = self, let tabBar = self.tabBarController?.tabBar else { return }
                    if context.isCancelled {
                        // 取消：执行整段隐藏动画回到底部
                        self.animateHideToBottom(tabBar, duration: 0.20)
                    }
                }

                coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                    guard let self = self else { return }
                    if let orig = self.originalHides(for: toVC) {
                        toVC.hidesBottomBarWhenPushed = orig
                        self.clearOriginalHides(for: toVC)
                    } else {
                        toVC.hidesBottomBarWhenPushed = false
                    }
                    (self.tabBarController as? SystemTabbar)?.restoreStableFrameIfNeeded()
                }
            } else {
                // 目标不是根页：保持隐藏到底部
                setTabBarHiddenBottom(tabBar)
                coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                    guard let self = self else { return }
                    if let orig = self.originalHides(for: toVC) { toVC.hidesBottomBarWhenPushed = orig; self.clearOriginalHides(for: toVC) }
                }
            }
        } else {
            // ✅ 非交互返回：自下而上滑入（一次性）
            if willShowRoot {
                prepareTabBarStartAtBottom(tabBar)
                animateReveal(tabBar, duration: coordinator.transitionDuration)
                coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                    guard let self = self else { return }
                    if let orig = self.originalHides(for: toVC) {
                        toVC.hidesBottomBarWhenPushed = orig
                        self.clearOriginalHides(for: toVC)
                    } else {
                        toVC.hidesBottomBarWhenPushed = false
                    }
                    (self.tabBarController as? SystemTabbar)?.restoreStableFrameIfNeeded()
                }
            } else {
                setTabBarHiddenBottom(tabBar)
                coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                    guard let self = self else { return }
                    if let orig = self.originalHides(for: toVC) { toVC.hidesBottomBarWhenPushed = orig; self.clearOriginalHides(for: toVC) }
                }
            }
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {
        // 兜底：根页可见，其它隐藏到底部
        if let tabBar = tabBarController?.tabBar {
            if isRootOfThisNav(viewController) {
                snapRevealToIdentity(tabBar)
            } else {
                setTabBarHiddenBottom(tabBar)
            }
        }
        (tabBarController as? SystemTabbar)?.restoreStableFrameIfNeeded()
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool { viewControllers.count > 1 }
}

// MARK: - TabBar 垂直显隐工具
private extension SystemNavigationController {

    /// 保证 tabBar 的 frame.y 紧贴父视图底部（在做任何 transform 前调用）
    func anchorTabBarToBottom(_ tabBar: UITabBar) {
        guard let container = tabBar.superview else { return }
        // 关闭隐式动画，避免视觉跳动
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // 先清 transform 才能得到真实高度
        let oldTransform = tabBar.transform
        tabBar.transform = .identity
        container.layoutIfNeeded()

        // 以“父视图高度 - 当前tabBar高度”为准锚到底部
        var f = tabBar.frame
        let containerH = container.bounds.height
        f.origin.y = containerH - f.size.height
        tabBar.frame = f

        // 自定义 WHTabBar 时，内部 tabbar 也要清 transform，保持一致
        if let custom = tabBar as? WHTabBar {
            custom.tabbar.transform = .identity
            custom.setNeedsLayout()
            custom.layoutIfNeeded()
        }

        // 还原 transform（外面会再设置到目标偏移）
        tabBar.transform = oldTransform

        CATransaction.commit()
    }

    @inline(__always)
    func setTabBarOffsetY(_ tabBar: UITabBar, offsetY: CGFloat) {
        tabBar.transform = CGAffineTransform(translationX: 0, y: offsetY)
        if let custom = tabBar as? WHTabBar {
            custom.tabbar.transform = tabBar.transform
        }
    }

    /// 起始：把 TabBar 放到底部以下（+h），不触发隐式动画
    func prepareTabBarStartAtBottom(_ tabBar: UITabBar) {
        let h = tabBar.bounds.height
        anchorTabBarToBottom(tabBar) // ✅ 先锚到底部
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        tabBar.isHidden = false
        tabBar.alpha = 1
        setTabBarOffsetY(tabBar, offsetY: h) // 直接落在 +h 起点
        CATransaction.commit()
        if let custom = tabBar as? WHTabBar { custom.tabbar.isHidden = false; custom.tabbar.alpha = 1 }
    }

    /// 无动画地就位（identity）
    func snapRevealToIdentity(_ tabBar: UITabBar) {
        anchorTabBarToBottom(tabBar) // ✅ 先锚到底部
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        tabBar.isHidden = false
        tabBar.alpha = 1
        setTabBarOffsetY(tabBar, offsetY: 0)
        CATransaction.commit()
        if let custom = tabBar as? WHTabBar { custom.tabbar.isHidden = false; custom.tabbar.alpha = 1 }
    }

    /// 完整的上滑显示动画（+h → 0）
    func animateReveal(_ tabBar: UITabBar, duration: TimeInterval) {
        anchorTabBarToBottom(tabBar) // ✅ 动画前先锚定，起点就不会“抖”
        let d = max(0.18, duration)
        UIView.animate(withDuration: d,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]) {
            self.setTabBarOffsetY(tabBar, offsetY: 0)
        }
    }

    /// 完整的下沉隐藏动画（0 → +h），结束后标记隐藏
    func animateHideToBottom(_ tabBar: UITabBar, duration: TimeInterval) {
        anchorTabBarToBottom(tabBar) // ✅ 以正确基线下沉
        let h = tabBar.bounds.height
        UIView.animate(withDuration: max(0.18, duration),
                       delay: 0,
                       options: [.curveEaseIn, .beginFromCurrentState, .allowUserInteraction]) {
            self.setTabBarOffsetY(tabBar, offsetY: h)
        } completion: { _ in
            tabBar.isHidden = true
            tabBar.alpha = 0
            if let custom = tabBar as? WHTabBar { custom.tabbar.isHidden = true; custom.tabbar.alpha = 0 }
        }
    }

    /// 立即隐藏到底部（无动画）
    func setTabBarHiddenBottom(_ tabBar: UITabBar) {
        anchorTabBarToBottom(tabBar) // ✅ 先锚再隐藏
        let h = tabBar.bounds.height
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        tabBar.isHidden = true
        tabBar.alpha = 0
        setTabBarOffsetY(tabBar, offsetY: h)
        CATransaction.commit()
        if let custom = tabBar as? WHTabBar { custom.tabbar.isHidden = true; custom.tabbar.alpha = 0 }
    }

    /// 起始可见并设置到指定偏移（目前仅 push 动画用得到）
    func unhideTabBarAtOffsetY(_ tabBar: UITabBar, offsetY: CGFloat) {
        anchorTabBarToBottom(tabBar) // ✅ 在设偏移前锚一次
        tabBar.isHidden = false
        tabBar.alpha = 1
        setTabBarOffsetY(tabBar, offsetY: offsetY)
        if let custom = tabBar as? WHTabBar {
            custom.tabbar.isHidden = false
            custom.tabbar.alpha = 1
        }
    }
}
