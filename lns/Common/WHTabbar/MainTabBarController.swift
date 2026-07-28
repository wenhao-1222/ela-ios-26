//
//  MainTabBarController.swift
//  lns
//
//  Created by Elavatine on 2025/3/27.
//

// MARK: - 主 TabBar 控制器
class MainTabBarController: UITabBarController {
    
    private var guideVC: GuideTotalVC?
    private var didAppearAfterRootSwitch = false
    
    var tabbar_3_name = "tabbar_forum"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .COLOR_BG_WHITE
        self.tabBar.backgroundColor = .COLOR_CARD_BG_WHITE
        setupViewControllers()
        setupForiPad()
        
        self.selectedIndex = 1
//        showGuideTotalIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(showGuideTotalIfNeeded), name: NOTIFI_NAME_GUIDE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mainTabBarDidStabilize), name: NOTIFI_NAME_MAIN_TABBAR_DID_STABILIZE, object: nil)
        DispatchQueue.main.async { [weak self] in
            self?.showGuideTotalIfNeeded()
        }
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppearAfterRootSwitch = true
        schedulePendingHealthKitAuthorizationIfNeeded()
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
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       super.traitCollectionDidChange(previousTraitCollection)

       guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
       updateTabBarImages()
   }
    private func updateTabBarImages() {
            guard let items = tabBar.items, items.count >= 4 else { return }

            let useDarkIcons = shouldUseDarkTabBarIcons()

            items[0].image = UIImage(named: useDarkIcons ? "tabbar_main_normal_dark" : "tabbar_main_normal")?.withRenderingMode(.alwaysOriginal)
            items[0].selectedImage = UIImage(named: useDarkIcons ? "tabbar_main_selected_dark" : "tabbar_main_selected")?.withRenderingMode(.alwaysOriginal)

            items[1].image = UIImage(named: useDarkIcons ? "tabbar_logs_normal_dark" : "tabbar_logs_normal")?.withRenderingMode(.alwaysOriginal)
            items[1].selectedImage = UIImage(named: useDarkIcons ? "tabbar_logs_selected_dark" : "tabbar_logs_selected")?.withRenderingMode(.alwaysOriginal)

            items[2].image = UIImage(named: useDarkIcons ? "\(tabbar_3_name)_normal_dark" : "\(tabbar_3_name)_normal")?.withRenderingMode(.alwaysOriginal)
            items[2].selectedImage = UIImage(named: useDarkIcons ? "\(tabbar_3_name)_selected_dark" : "\(tabbar_3_name)_selected")?.withRenderingMode(.alwaysOriginal)

            items[3].image = UIImage(named: useDarkIcons ? "tabbar_mine_normal_dark" : "tabbar_mine_normal")?.withRenderingMode(.alwaysOriginal)
            items[3].selectedImage = UIImage(named: useDarkIcons ? "tabbar_mine_selected_dark" : "tabbar_mine_selected")?.withRenderingMode(.alwaysOriginal)
        }
    private func shouldUseDarkTabBarIcons() -> Bool {
           traitCollection.userInterfaceStyle == .dark && UserConfigModel.shared.overrideUserInterfaceStyle != .light
       }
    // 添加 4 个示例页面
    private func setupViewControllers() {
        let vc1 = OverViewVC()//MainVC()
        vc1.tabBarItem = UITabBarItem(title: "概览", image: UIImage.init(named: "tabbar_main_normal")!, tag: 0)
//        vc1.tabBarItem.selectedImage =
        let vc2 = JournalVC()
        vc2.tabBarItem = UITabBarItem(title: "日志", image: UIImage.init(named: "tabbar_logs_normal")!, tag: 1)
        
//        let vc3 = ForumVC()
//        vc3.tabBarItem = UITabBarItem(title: "干货", image: UIImage.init(named: "tabbar_forum_normal")!, tag: 2)
        
        let vc3 = (UserInfoModel.shared.abTestModel.isTrial && UserInfoModel.shared.abTestModel.diet_important != .A) ? CourseTabVC() : DietPlanVC()
        let vc3Name = (UserInfoModel.shared.abTestModel.isTrial && UserInfoModel.shared.abTestModel.diet_important != .A) ? "课程" : "计划"
        tabbar_3_name = (UserInfoModel.shared.abTestModel.isTrial && UserInfoModel.shared.abTestModel.diet_important != .A) ? "tabbar_forum" : "tabbar_diet"
        vc3.tabBarItem = UITabBarItem(title: vc3Name, image: UIImage.init(named: "\(tabbar_3_name)_normal")!, tag: 2)
        
        let vc4 = MineVC()
        vc4.tabBarItem = UITabBarItem(title: "我的", image: UIImage.init(named: "tabbar_mine_normal")!, tag: 3)
        
        let useDarkIcons = shouldUseDarkTabBarIcons()
        
        self.setUpChildViewController(viewController: vc1,
                                      image: useDarkIcons ? UIImage(named: "tabbar_main_normal_dark")!.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_main_normal")!.withRenderingMode(.alwaysOriginal),
                                      selectImage: traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_main_selected_dark")!.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_main_selected")!.withRenderingMode(.alwaysOriginal),
                                      title: "概览")
        self.setUpChildViewController(viewController: vc2,
                                      image: useDarkIcons ? UIImage(named: "tabbar_logs_normal_dark")!.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_logs_normal")!.withRenderingMode(.alwaysOriginal),
                                      selectImage: traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_logs_selected_dark")!.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_logs_selected")!.withRenderingMode(.alwaysOriginal),
                                      title: "日志")
        self.setUpChildViewController(viewController: vc3,
                                      image: useDarkIcons ? UIImage(named: "\(tabbar_3_name)_normal_dark")!.withRenderingMode(.alwaysOriginal) : UIImage(named: "\(tabbar_3_name)_normal")!.withRenderingMode(.alwaysOriginal),
                                      selectImage: traitCollection.userInterfaceStyle == .dark ? UIImage(named: "\(tabbar_3_name)_selected_dark")!.withRenderingMode(.alwaysOriginal) : UIImage(named: "\(tabbar_3_name)_selected")!.withRenderingMode(.alwaysOriginal),
                                      title: "计划")
        self.setUpChildViewController(viewController: vc4,
                                      image: useDarkIcons ? UIImage(named: "tabbar_mine_normal_dark")!.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_mine_normal")!.withRenderingMode(.alwaysOriginal),
                                      selectImage: traitCollection.userInterfaceStyle == .dark ? UIImage(named: "tabbar_mine_selected_dark")!.withRenderingMode(.alwaysOriginal) : UIImage(named: "tabbar_mine_selected")!.withRenderingMode(.alwaysOriginal),
                                      title: "我的")
        
//        UITabBar.appearance().barTintColor = .COLOR_GRAY_BLACK_85
        UITabBar.appearance().tintColor = .COLOR_TEXT_TITLE_0f1214
//        UITabBar.appearance().unselectedItemTintColor = .COLOR_GRAY_BLACK_85
        viewControllers = [vc1, vc2, vc3, vc4].map { LLNaviViewController(rootViewController: $0) }
    }
    
    func setUpChildViewController(viewController:UIViewController,image:UIImage,selectImage:UIImage,title:String){
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        viewController.tabBarItem.selectedImage = selectImage.withRenderingMode(.alwaysOriginal)
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
        guard !UserInfoModel.shared.onboarding_flow_status, guideVC == nil else { return }
        let vc = GuideTotalVC()
        vc.finishBlock = { [weak self] in
            self?.removeGuideTotalVC()
        }
        guideVC = vc
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.frame = view.bounds
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
            UserInfoModel.shared.onboarding_flow_status = true
            UserDefaults.saveLoginUserGroupMsgCache()
            UserDefaults.standard.setValue("1", forKey: guide_total)
            self.schedulePendingHealthKitAuthorizationIfNeeded()
        }
    }

    @objc private func mainTabBarDidStabilize() {
        schedulePendingHealthKitAuthorizationIfNeeded()
    }

    private func schedulePendingHealthKitAuthorizationIfNeeded() {
        guard didAppearAfterRootSwitch, guideVC == nil, UserInfoModel.shared.onboarding_flow_status else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            HealthKitManager.markMainTabBarStableForInitialHealthAuthorization()
        }
    }
    
    // 设备旋转时保持布局
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        setupForiPad()
//    }
}
