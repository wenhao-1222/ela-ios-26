//
//  WHTabBarVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/9.
//

import Foundation
import UIKit

class WHTabBarVC : UITabBarController{
    
    var tabbar = LLMyTabbar()
    var whTabBar = WHTabBar()
    private var guideVC: GuideTotalVC?
    
    lazy var coverWhiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    
    override var shouldAutorotate: Bool{
        if #available(iOS 16.0, *) {
            return false
        } else {
            return true//UserConfigModel.shared.allowedOrientations == .landscape
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UserConfigModel.shared.allowedOrientations
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return UserConfigModel.shared.userInterfaceOrientation
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
//        if UserConfigModel.shared.overrideUserInterfaceStyle == .light{
//            return
//        }
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // 外观模式切换时更新 TabBar 图标
            updateTabBarImages()
            if self.selectedIndex == 1{
                coverWhiteView.addShadow(opacity: 0.05,offset: CGSize(width: 0, height: -5))
            }
        }
    }

    func updateTabBarImages() {
        let tabBarItems = self.tabBar.items
        guard let items = tabBarItems else { return }

        // 遍历每个 TabBar item 并更新图标
        for (index, button) in self.tabbar.btnArr.enumerated() {
            switch index {
            case 0:
                // 概览
                button.setImage(traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_main_normal_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_main_normal")?.withRenderingMode(.alwaysOriginal), for: .normal)
                button.setImage(traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_main_selected_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_main_selected")?.withRenderingMode(.alwaysOriginal), for: .selected)
//                
//                item.image = traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_main_normal_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_main_normal")?.withRenderingMode(.alwaysOriginal)
//                item.selectedImage = traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_main_selected_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_main_selected")?.withRenderingMode(.alwaysOriginal)
            case 1:
                button.setImage(traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_logs_normal_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_logs_normal")?.withRenderingMode(.alwaysOriginal), for: .normal)
                button.setImage(traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_logs_selected_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_logs_selected")?.withRenderingMode(.alwaysOriginal), for: .selected)
                // 日志
//                item.image = traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_logs_normal_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_logs_normal")?.withRenderingMode(.alwaysOriginal)
//                item.selectedImage = traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_logs_selected_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_logs_selected")?.withRenderingMode(.alwaysOriginal)
            case 2:
                button.setImage(traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_forum_normal_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_forum_normal")?.withRenderingMode(.alwaysOriginal), for: .normal)
                button.setImage(traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_forum_selected_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_forum_selected")?.withRenderingMode(.alwaysOriginal), for: .selected)
                // 资讯
//                item.image = traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_forum_normal_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_forum_normal")?.withRenderingMode(.alwaysOriginal)
//                item.selectedImage = traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_forum_selected_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_forum_selected")?.withRenderingMode(.alwaysOriginal)
            case 3:
                button.setImage(traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_mine_normal_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_mine_normal")?.withRenderingMode(.alwaysOriginal), for: .normal)
                button.setImage(traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_mine_selected_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_mine_selected")?.withRenderingMode(.alwaysOriginal), for: .selected)
                // 我的
//                item.image = traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_mine_normal_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_mine_normal")?.withRenderingMode(.alwaysOriginal)
//                item.selectedImage = traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_mine_selected_dark")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_mine_selected")?.withRenderingMode(.alwaysOriginal)
            default:
                break
            }
        }
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        
        createMainTabBarView()
        childAllChildViewControllers()
        
        tabbar.seletedButton = tabbar.btnArr[1]
        tabbar.seletedButton.isSelected = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(gotoLogsNotification), name: NSNotification.Name(rawValue: "activePlan"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showGuideTotalIfNeeded), name: NOTIFI_NAME_GUIDE, object: nil)
        
        tabbar.centerClick()
//        showGuideTotalIfNeeded()
    }

    @objc private func showGuideTotalIfNeeded() {
//        if UserDefaults.standard.string(forKey: guide_total) == nil {
            let vc = GuideTotalVC()
            vc.finishBlock = { [weak self] in
                self?.removeGuideTotalVC()
            }
            guideVC = vc
            addChild(vc)
            view.addSubview(vc.view)
            vc.view.frame = view.bounds
//        }
    }

    func removeGuideTotalVC() {
        guard let vc = guideVC else { return }
        UIView.animate(withDuration: 0.3, animations: {
            vc.view.alpha = 0
        }) { _ in
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            self.guideVC = nil
//            UserDefaults.standard.setValue("1", forKey: guide_total)
        }

//        vc.willMove(toParent: nil)
//        vc.view.removeFromSuperview()
//        vc.removeFromParent()
//        guideVC = nil
        UserDefaults.standard.setValue("1", forKey: guide_total)
    }
    
    //创建自定义Tabbar
    private func createMainTabBarView(){
        //1.获取系统自带的标签栏视图的frame,并将其设置为隐藏
        let tabBarRect = self.tabBar.bounds
//        self.tabBar.isHidden = true
        whTabBar.frame = tabBarRect
        whTabBar.backgroundColor = .COLOR_BG_WHITE
        self.setValue(whTabBar, forKeyPath: "tabBar")
        
        tabbar =  LLMyTabbar.init()
        tabbar.frame = CGRect.init(x: self.tabBar.bounds.minX, y: self.tabBar.bounds.minY, width: self.tabBar.bounds.width, height: self.tabBar.bounds.height)
//        tabbar.frame = CGRect.init(x: self.tabBar.bounds.minX, y: self.tabBar.bounds.minY-kFitWidth(22), width: self.tabBar.bounds.width, height: self.tabBar.bounds.height+kFitWidth(22))
        tabbar.delegate = self
        tabbar.backgroundColor = .COLOR_BG_WHITE
//        tabbar.addShadow(opacity: 0.05)
        self.whTabBar.addSubview(tabbar)
        self.whTabBar.tabbar = tabbar
        self.whTabBar.tabbar.backgroundColor = .COLOR_BG_WHITE
        
        self.whTabBar.insertSubview(coverWhiteView, belowSubview: tabbar)
        coverWhiteView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: WHUtils().getTabbarHeight())
    }
    
    func childAllChildViewControllers(){
        let mainVc = OverViewVC()
        let journalVc = JournalVC()
        let mineVc = MineVC()
        let forumVc = ForumVC()
        
        //预加载
        _ = mainVc.view
        _ = journalVc.view
        _ = forumVc.view
        
        if traitCollection.userInterfaceStyle == .dark && UserConfigModel.shared.overrideUserInterfaceStyle != .light{
            self.setUpChildViewController(viewController: mainVc, image: UIImage.init(named: "tabbar_main_normal_dark")!, selectImage: UIImage.init(named: "tabbar_main_selected_dark")!, title: "概览")
            self.setUpChildViewController(viewController: journalVc, image: UIImage.init(named: "tabbar_logs_normal_dark")!, selectImage: UIImage.init(named: "tabbar_logs_selected_dark")!, title: "日志")
            self.setUpChildViewController(viewController: forumVc, image: UIImage.init(named: "tabbar_forum_normal_dark")!, selectImage: UIImage.init(named: "tabbar_forum_selected_dark")!, title: "干货")
            self.setUpChildViewController(viewController: mineVc, image: UIImage.init(named: "tabbar_mine_normal_dark")!, selectImage: UIImage.init(named: "tabbar_mine_selected_dark")!, title: "我的")
        }else{
            self.setUpChildViewController(viewController: mainVc, image: UIImage.init(named: "tabbar_main_normal")!, selectImage: UIImage.init(named: "tabbar_main_selected")!, title: "概览")
            self.setUpChildViewController(viewController: journalVc, image: UIImage.init(named: "tabbar_logs_normal")!, selectImage: UIImage.init(named: "tabbar_logs_selected")!, title: "日志")
            self.setUpChildViewController(viewController: forumVc, image: UIImage.init(named: "tabbar_forum_normal")!, selectImage: UIImage.init(named: "tabbar_forum_selected")!, title: "干货")
            self.setUpChildViewController(viewController: mineVc, image: UIImage.init(named: "tabbar_mine_normal")!, selectImage: UIImage.init(named: "tabbar_mine_selected")!, title: "我的")
        }
    }

    func setUpChildViewController(viewController:UIViewController,image:UIImage,selectImage:UIImage,title:String){
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        viewController.tabBarItem.selectedImage = selectImage.withRenderingMode(.alwaysOriginal)
        let NAVC = LLNaviViewController.init(rootViewController: viewController)
        self.addChild(NAVC)
        tabbar.addTabBarButtonWithItem(item: viewController.tabBarItem)
    }
}

extension WHTabBarVC:LLMyTabbarDelegate{
    //实现代理方法
    func tabbarDidSelectedButtomFromto(tabbar: LLMyTabbar, from: Int, to: Int) {
        self.selectedIndex = to
        if to != 2{
            ZFPlayerModel.shared.playerManager.pause()
        }
//        if to == 1 {
        coverWhiteView.addShadow(opacity: 0.05,offset: CGSize(width: 0, height: -5))
//        }else{
//            tabbar.addShadow(color: .clear,opacity: 0.02,offset: CGSize(width: 0, height: 5))
//        }
    }
    
    @objc func gotoLogsNotification(){
        DLLog(message: "跳转到日志")
//        self.selectedIndex = 1
        
        for vi in self.tabBar.subviews{
            if vi.isKind(of: UIControl.self){
                vi.removeFromSuperview()
            }
        }
    }
    
    @objc func widgetAddFoods(){
//        self.navigationController?.popToRootViewController(animated: true)
//        self.navigationController?.tabBarController?.selectedIndex = 1
        
        let vc = FoodsListNewVC()
        vc.sourceType = .logs
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
