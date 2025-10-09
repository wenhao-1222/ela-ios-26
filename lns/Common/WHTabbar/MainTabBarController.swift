//
//  MainTabBarController.swift
//  lns
//
//  Created by Elavatine on 2025/3/27.
//

// MARK: - 主 TabBar 控制器
class MainTabBarController: UITabBarController {
    
    private var guideVC: GuideTotalVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupForiPad()
        
        self.selectedIndex = 1
//        showGuideTotalIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(showGuideTotalIfNeeded), name: NOTIFI_NAME_GUIDE, object: nil)
        
    }
    
    override var traitCollection: UITraitCollection{
        let currentTraits = super.traitCollection
        // 合并当前 Trait 并覆盖 horizontalSizeClass
        return UITraitCollection(traitsFrom: [
            currentTraits,
            UITraitCollection(horizontalSizeClass: .compact)
        ])
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        // 强制刷新子控制器的 Trait
        children.forEach {
            setOverrideTraitCollection(
                UITraitCollection(horizontalSizeClass: .compact),
                forChild: $0
            )
        }
    }
    // 添加 4 个示例页面
    private func setupViewControllers() {
        let vc1 = OverViewVC()//MainVC()
        vc1.tabBarItem = UITabBarItem(title: "概览", image: UIImage.init(named: "tabbar_main_normal")!, tag: 0)
//        vc1.tabBarItem.selectedImage =
        let vc2 = JournalVC()
        vc2.tabBarItem = UITabBarItem(title: "日志", image: UIImage.init(named: "tabbar_logs_normal")!, tag: 1)
        
        let vc3 = ForumVC()
        vc3.tabBarItem = UITabBarItem(title: "干货", image: UIImage.init(named: "tabbar_forum_normal")!, tag: 2)
        
        let vc4 = MineVC()
        vc4.tabBarItem = UITabBarItem(title: "我的", image: UIImage.init(named: "tabbar_mine_normal")!, tag: 3)
        
        self.setUpChildViewController(viewController: vc1, image: UIImage.init(named: "tabbar_main_normal")!, selectImage: UIImage.init(named: "tabbar_main_selected")!, title: "概览")
        self.setUpChildViewController(viewController: vc2, image: UIImage.init(named: "tabbar_logs_normal")!, selectImage: UIImage.init(named: "tabbar_logs_selected")!, title: "日志")
        self.setUpChildViewController(viewController: vc3, image: UIImage.init(named: "tabbar_forum_normal")!, selectImage: UIImage.init(named: "tabbar_forum_selected")!, title: "干货")
        self.setUpChildViewController(viewController: vc4, image: UIImage.init(named: "tabbar_mine_normal")!, selectImage: UIImage.init(named: "tabbar_mine_selected")!, title: "我的")
        
//        UITabBar.appearance().barTintColor = .COLOR_GRAY_BLACK_85
        UITabBar.appearance().tintColor = .COLOR_GRAY_BLACK_85
//        UITabBar.appearance().unselectedItemTintColor = .COLOR_GRAY_BLACK_85
        viewControllers = [vc1, vc2, vc3, vc4].map { LLNaviViewController(rootViewController: $0) }
    }
    
    func setUpChildViewController(viewController:UIViewController,image:UIImage,selectImage:UIImage,title:String){
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        viewController.tabBarItem.selectedImage = selectImage.withRenderingMode(.alwaysOriginal)
//        viewController.tabBarItem
//        let NAVC = LLNaviViewController.init(rootViewController: viewController)
//        self.addChild(NAVC)
//        tabbar.addTabBarButtonWithItem(item: viewController.tabBarItem)
    }
    
    // iPad 适配
    private func setupForiPad() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // 关键点 1: 禁用侧边栏模式 (iOS 14+)
            if #available(iOS 14.0, *) {
//                setValue(false, forKey: "wantsCustomizableItems")
            }
            
            // 关键点 2: 强制紧凑布局
            overrideTraitCollection(forChild: self)
        }
    }
    
    // 关键点 3: 动态调整布局
    override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let compactTraits = UITraitCollection(horizontalSizeClass: .compact)
            return UITraitCollection(traitsFrom: [super.traitCollection, compactTraits])
        }
        return super.traitCollection
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
            UserDefaults.standard.setValue("1", forKey: guide_total)
        }
    }
    
    // 设备旋转时保持布局
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        setupForiPad()
//    }
}
