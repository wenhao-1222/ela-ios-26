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
    private var displayLink: CADisplayLink?
    private weak var drivingGesture: UIPanGestureRecognizer?

    // hidesBottomBarWhenPushed 临时修改记录
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

    // MARK: - Push（mainVc -> nextVc / nextVc -> nextVcB）
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let willHide = !viewControllers.isEmpty
        if willHide { viewController.hidesBottomBarWhenPushed = true }

        guard animated, let tbc = tabBarController else {
            super.pushViewController(viewController, animated: animated)
            return
        }

        let tabBar = tbc.tabBar
        let width = tabBar.bounds.width
        let pushingFromRootToFirst = (viewControllers.count == 1) // 只有从根 push 第一个二级，才做“从 0 到 -width”的动画

        // 如果不是从根 push 第一个二级（比如 nextVc -> nextVcB），避免露头：直接保持在 -width，无动画
        if !pushingFromRootToFirst {
            setTabBarOffset(tabBar, offsetX: -width)
            tabBar.isHidden = true      // 新增：彻底避免露头
            super.pushViewController(viewController, animated: animated)
            return
        }

        // 从根 -> 第一个二级：做一次向左滑出动画
        tabBar.isHidden = false
        tabBar.alpha = 1
        setTabBarOffset(tabBar, offsetX: 0)

        super.pushViewController(viewController, animated: animated)

        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.setTabBarOffset(tabBar, offsetX: -width)
            }, completion: { [weak self] context in
                guard let self = self else { return }
                if context.isCancelled {
                    self.setTabBarOffset(tabBar, offsetX: 0)
                } else {
                    (self.tabBarController as? SystemTabbar)?.restoreStableFrameIfNeeded()
                }
            })
        }
    }

    // MARK: - UINavigationControllerDelegate（pop：nextVc -> mainVc）
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        guard let tbc = tabBarController else { return }
        let tabBar = tbc.tabBar
        cachedTabBarHeight = max(1, tabBar.bounds.height)

        let toNeedsHide = shouldHideTabBar(for: viewController)
        if toNeedsHide{
            tabBar.isHidden = true
//            setTabBarOffset(tabBar, offsetX: -tabBar.bounds.width)
            return
        }
        guard animated, let coordinator = transitionCoordinator else {
            // 非动画：直接对齐目标态
            if toNeedsHide {
//                setTabBarOffset(tabBar, offsetX: -tabBar.bounds.width)
                // 目标不是根页：任何情况下都保持在左侧，不做 reveal
                tabBar.isHidden = true
                setTabBarOffset(tabBar, offsetX: -tabBar.bounds.width)
                
                return
            } else {
                setTabBarOffset(tabBar, offsetX: 0)
                (tbc as? SystemTabbar)?.restoreStableFrameIfNeeded()
            }
            return
        }

        let toVC = viewController

        // 为避免系统把 tabbar 拉入过渡：若最终需要显示，临时置 true
        if !toNeedsHide {
            // 下面才是“目标是根页”的逻辑（允许显示 TabBar）
            if originalHides(for: toVC) == nil { setOriginalHides(toVC.hidesBottomBarWhenPushed, for: toVC) }
            toVC.hidesBottomBarWhenPushed = true
        }else{
            tabBar.isHidden = false
        }

        if coordinator.isInteractive {
            // ===== 交互式返回：tabbar 与 mainVc 同步位移 =====
            tabBar.isHidden = false
            prepareTabBarForInteractiveReveal(tabBar)
            beginDrivingWithGesture()

            coordinator.notifyWhenInteractionChanges { [weak self] context in
                guard let self = self,
                      let tabBar = self.tabBarController?.tabBar else { return }
                if context.isCancelled {
                    // 取消：滑回左侧
                    self.endDrivingWithGesture()
                    self.setTabBarOffset(tabBar, offsetX: -tabBar.bounds.width)
                    if let orig = self.originalHides(for: toVC) {
                        toVC.hidesBottomBarWhenPushed = orig
                        self.clearOriginalHides(for: toVC)
                    }
                }
                // 注意：不在“将完成”这里停驱动，避免空档；交给下面 alongsideTransition 开始时再停。
            }

            coordinator.animate(alongsideTransition: { [weak self] _ in
                guard let self = self,
                      let tabBar = self.tabBarController?.tabBar else { return }
                // 过渡收尾动画启动的同一帧：停止 displayLink，并从当前位移无缝补到 0
                self.endDrivingWithGesture()
                self.finishReveal(tabBar, duration: coordinator.isAnimated ? coordinator.transitionDuration : 0.2)
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                if let orig = self.originalHides(for: toVC) {
                    toVC.hidesBottomBarWhenPushed = orig
                    self.clearOriginalHides(for: toVC)
                } else {
                    toVC.hidesBottomBarWhenPushed = false
                }
                (self.tabBarController as? SystemTabbar)?.restoreStableFrameIfNeeded()
            })
        } else {
            // ===== 非交互返回：从左侧入场 =====
            tabBar.isHidden = true
            prepareTabBarForInteractiveReveal(tabBar)
            animateReveal(tabBar, duration: coordinator.transitionDuration)
            if let orig = self.originalHides(for: toVC) {
                toVC.hidesBottomBarWhenPushed = orig
                self.clearOriginalHides(for: toVC)
            } else {
                toVC.hidesBottomBarWhenPushed = false
            }
            DispatchQueue.main.async { (self.tabBarController as? SystemTabbar)?.restoreStableFrameIfNeeded() }
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {
        endDrivingWithGesture()
        if let tabBar = tabBarController?.tabBar {
            if shouldHideTabBar(for: viewController) {
                setTabBarOffset(tabBar, offsetX: -tabBar.bounds.width)
                tabBar.isHidden = true
            } else {
                tabBar.isHidden = false
                setTabBarOffset(tabBar, offsetX: 0)
            }
        }
        (tabBarController as? SystemTabbar)?.restoreStableFrameIfNeeded()
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

// MARK: - Driving helpers（与 mainVc 相同偏移）
private extension SystemNavigationController {

    func prepareTabBarForInteractiveReveal(_ tabBar: UITabBar) {
        tabBar.isHidden = false
        tabBar.alpha = 1
        let w = tabBar.bounds.width
        setTabBarOffset(tabBar, offsetX: -w)
    }

    func beginDrivingWithGesture() {
        if let fdPan = value(forKey: "fd_fullscreenPopGestureRecognizer") as? UIPanGestureRecognizer {
            drivingGesture = fdPan
        } else {
            drivingGesture = interactivePopGestureRecognizer as? UIPanGestureRecognizer
        }
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(onTick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func endDrivingWithGesture() {
        displayLink?.invalidate()
        displayLink = nil
        drivingGesture = nil
    }

    @objc
    func onTick() {
        guard let gesture = drivingGesture,
              let container = view,
              let tabBar = tabBarController?.tabBar else { return }
        let tx = gesture.translation(in: container).x
        let w = tabBar.bounds.width
        let offset = max(-w, min(0, -w + tx))
        setTabBarOffset(tabBar, offsetX: offset)
    }

    func setTabBarOffset(_ tabBar: UITabBar, offsetX: CGFloat) {
        tabBar.transform = CGAffineTransform(translationX: offsetX, y: 0)
        if let custom = tabBar as? WHTabBar {
            custom.tabbar.transform = CGAffineTransform(translationX: offsetX, y: 0)
        }
    }

    func animateReveal(_ tabBar: UITabBar, duration: TimeInterval) {
        let w = tabBar.bounds.width
        setTabBarOffset(tabBar, offsetX: -w)
        UIView.animate(withDuration: max(0.18, duration), delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            self.setTabBarOffset(tabBar, offsetX: 0)
        }
    }

    func finishReveal(_ tabBar: UITabBar, duration: TimeInterval) {
        UIView.animate(withDuration: max(0.18, duration * 0.65), delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            self.setTabBarOffset(tabBar, offsetX: 0)
        }
    }
}

// MARK: - Utilities
private extension SystemNavigationController {
    func shouldHideTabBar(for viewController: UIViewController?) -> Bool {
//        guard let vc = viewController else { return false }
//        if vc == viewControllers.first { return false }
//        return vc.hidesBottomBarWhenPushed
        guard let vc = viewController else { return true } // 没有目标就隐藏
                // 只有当“目标 vc 是当前导航栈的第一个 vc”时才显示 TabBar
        return vc !== viewControllers.first
    }

    func hookPopGestures() {
        // 仅作为早期触发点；真正驾驶在 willShow 阶段
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(dummyPopGesture(_:)))
        if let fdPan = value(forKey: "fd_fullscreenPopGestureRecognizer") as? UIPanGestureRecognizer {
            fdPan.addTarget(self, action: #selector(dummyPopGesture(_:)))
        }
    }

    @objc func dummyPopGesture(_ gr: UIPanGestureRecognizer) { /* no-op */ }
}
