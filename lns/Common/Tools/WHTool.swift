//
//  WHTool.swift
//  ttjx
//
//  Created by 文 on 2020/1/2.
//  Copyright © 2020 ttjx. All rights reserved.
//

import Foundation

class WHTool{
    
    static let shared = WHTool()
    
    private init() {
        
    }
}

extension WHTool{
    
    // 获得当前ViewController
    func getCurrentViewController() -> UIViewController {
        
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        let currentVC = getFrom(rootVC: rootVC!)
        
        return currentVC
    }

    func getFrom(rootVC: UIViewController) -> UIViewController {
        var root = rootVC
        var controller = UIViewController()
        
        if (root.presentedViewController != nil) {
            root = root.presentedViewController!
        }
        
        if root.isKind(of: ViewController.self) {
            let tabVC = root as! ViewController
            controller = tabVC
        } else if root.isKind(of: UINavigationController.self) {
            let navVC = root as! UINavigationController
            controller = getFrom(rootVC: navVC.visibleViewController!)
        } else {
            controller = root
        }
        
        return controller
    }

    // 获取当前VC在Navigation中的索引
    func getCurrentVCIndex(navigationController: UINavigationController, viewController: UIViewController) -> Int {
        let controllers = navigationController.children
        for (index, vc) in controllers.enumerated() {
            if vc == viewController {
                return index
            }
        }
        
        return 0
    }

}
