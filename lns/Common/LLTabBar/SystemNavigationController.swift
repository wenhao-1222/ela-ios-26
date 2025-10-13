//
//  SystemNavigationController.swift
//  lns
//
//  Created by LNS2 on 2025/10/13.
//

class SystemNavigationController: UINavigationController {
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !viewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if self.viewControllers.count == 1 {
            return super.popViewController(animated: animated)
        }

        if let tabBar = self.tabBarController?.tabBar,
           tabBar.isHidden,
           self.viewControllers.count == 2 {
            let originFrame = tabBar.frame
            tabBar.frame = originFrame.offsetBy(dx: 0, dy: originFrame.height)
            tabBar.isHidden = false
            UIView.animate(withDuration: 0.25) {
                tabBar.frame = originFrame
            }
        }
        // 系统会在返回时恢复 TabBar，无需额外处理
        return super.popViewController(animated: animated)
    }
}
