//
//  LLNaviViewController.swift
//  swiftStudy01
//
//  Created by 刘恋 on 2019/6/5.
//  Copyright © 2019 刘恋. All rights reserved.
//

import UIKit

let screenEdgePanGesture = UIScreenEdgePanGestureRecognizer.self

class LLNaviViewController: UINavigationController,UIGestureRecognizerDelegate,UINavigationControllerDelegate {

    override var shouldAutorotate: Bool{
        if #available(iOS 16.0, *) {
            return false
        } else {
            return true//UserConfigModel.shared.allowedOrientations == .landscape
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        if #available(iOS 16.0, *) {
//            return UserConfigModel.shared.allowedOrientations
//        }else{
//            return .portrait//UserConfigModel.shared.allowedOrientations == .landscape ? .landscape : .portrait
//        }
        return UserConfigModel.shared.allowedOrientations
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
//        if #available(iOS 16.0, *) {
//            return UserConfigModel.shared.userInterfaceOrientation
//        }else{
//            return .portrait//UserConfigModel.shared.userInterfaceOrientation == .landscapeLeft ? .landscapeLeft : .portrait
//        }
        return UserConfigModel.shared.userInterfaceOrientation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.creatUI()
        
    }
    
    func creatUI(){
        
        weak var weakSelf = self
        if self.responds(to:#selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer?.delegate = weakSelf
            self.delegate = weakSelf
        }
        self.navigationBar.barTintColor = .white
        self.navigationBar.tintColor = .black
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationBar.isHidden = true
    }

   
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 删除系统自带的tabBarButton
        if isIpad(){
            
        }else{
            if self.tabBarController?.tabBar.subviews.count ?? 0 > 0{
                for tabbar in (self.tabBarController?.tabBar.subviews)! {
                    if tabbar .isKind(of: NSClassFromString("UITabBarButton")!){
                        tabbar.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    //重写系统push方法
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count >= 1 {
            // 使用系统的 hidesBottomBarWhenPushed 行为，避免额外动画导致 TabBar 上跳
            viewController.hidesBottomBarWhenPushed = true
//            if let tabBar = self.tabBarController?.tabBar,
//               !tabBar.isHidden {
//                let originFrame = tabBar.frame
//                UIView.animate(withDuration: 0.25, animations: {
//                    tabBar.frame = originFrame.offsetBy(dx: 0, dy: originFrame.height)
//                }) { _ in
//                    tabBar.isHidden = true
//                    tabBar.frame = originFrame
//                }
//            }
        }
        super.pushViewController(viewController, animated: true)
        
        if self.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        
       //add by hgc 2018年03月06日 解决IPhoneX 模拟器下 push tabBar向上跳动
        // 2018 年遗留的修复代码，现已不再需要
//        var  frame2 = self.tabBarController?.tabBar.frame
//        let height = frame2?.size.height
//        frame2?.origin.y = UIScreen.main.bounds.size.height - ((height))!
//        self.tabBarController?.tabBar.frame = CGRect(x: ((frame2?.origin.x))!,y: ((frame2?.origin.y))!,width: ((frame2?.size.width))!,height: ((frame2?.size.height))!)
        
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if self.viewControllers.count == 1 {
            return super.popViewController(animated: animated)
        }

//        if let tabBar = self.tabBarController?.tabBar,
//           tabBar.isHidden,
//           self.viewControllers.count == 2 {
//            let originFrame = tabBar.frame
//            tabBar.frame = originFrame.offsetBy(dx: 0, dy: originFrame.height)
//            tabBar.isHidden = false
//            UIView.animate(withDuration: 0.25) {
//                tabBar.frame = originFrame
//            }
//        }
        // 系统会在返回时恢复 TabBar，无需额外处理
        return super.popViewController(animated: animated)
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            if self.viewControllers.count == 1{
                return false
            }
        }
        return true
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if self.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    deinit {
        if self.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer?.delegate = nil
        }
    }
}


