//
//  iPadTabBarVC.swift
//  lns
//
//  Created by Elavatine on 2025/3/27.
//


class iPadTabBarVC : UITabBarController{
    
    var tabbar = LLMyTabbar()
    var whTabBar = WHTabBar()
    
    lazy var coverWhiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
//        setupTabBarForiPad()
        createMainTabBarView()
        childAllChildViewControllers()
        
        tabbar.seletedButton = tabbar.btnArr[1]
        tabbar.seletedButton.isSelected = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(gotoLogsNotification), name: NSNotification.Name(rawValue: "activePlan"), object: nil)
        
        tabbar.centerClick()
    }
    
    private func setupTabBarForiPad() {
        // 关键点 1: 禁用 iPad 的侧边栏模式（iOS 14+）
        if #available(iOS 14.0, *) {
            // ✅ 这是正确的属性：设置 TabBar 样式为传统底部栏
            self.setValue(false, forKey: "wantsCustomizableItems")
        }
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
    //创建自定义Tabbar
    private func createMainTabBarView(){
        //1.获取系统自带的标签栏视图的frame,并将其设置为隐藏
        let tabBarRect = self.tabBar.bounds
//        self.tabBar.isHidden = true
//        whTabBar.frame = tabBarRect
//        whTabBar.backgroundColor = .white
//        self.setValue(whTabBar, forKeyPath: "tabBar")
        
        tabbar =  LLMyTabbar.init()
        tabbar.frame = CGRect.init(x: self.tabBar.bounds.minX, y: self.tabBar.bounds.minY, width: self.tabBar.bounds.width, height: self.tabBar.bounds.height)
//        tabbar.frame = CGRect.init(x: self.tabBar.bounds.minX, y: self.tabBar.bounds.minY-kFitWidth(22), width: self.tabBar.bounds.width, height: self.tabBar.bounds.height+kFitWidth(22))
        tabbar.delegate = self
        tabbar.backgroundColor = .white
        self.tabBar.insertSubview(coverWhiteView, belowSubview: tabbar)
//        self.whTabBar.addSubview(tabbar)
//        self.whTabBar.tabbar = tabbar
//        self.whTabBar.tabbar.backgroundColor = .white
//
//        self.whTabBar.insertSubview(coverWhiteView, belowSubview: tabbar)
        coverWhiteView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: WHUtils().getTabbarHeight())
    }
    
    func childAllChildViewControllers(){
        let mainVc = OverViewVC()
        let journalVc = JournalVC()
        let mineVc = MineVC()
        let forumVc = ForumVC()
        
        //预加载
        _ = journalVc.view
        _ = forumVc.view
        
        self.setUpChildViewController(viewController: mainVc, image: UIImage.init(named: "tabbar_main_normal")!, selectImage: UIImage.init(named: "tabbar_main_selected")!, title: "概览")
        self.setUpChildViewController(viewController: journalVc, image: UIImage.init(named: "tabbar_logs_normal")!, selectImage: UIImage.init(named: "tabbar_logs_selected")!, title: "日志")
        self.setUpChildViewController(viewController: forumVc, image: UIImage.init(named: "tabbar_forum_normal")!, selectImage: UIImage.init(named: "tabbar_forum_selected")!, title: "干货")
        self.setUpChildViewController(viewController: mineVc, image: UIImage.init(named: "tabbar_mine_normal")!, selectImage: UIImage.init(named: "tabbar_mine_selected")!, title: "我的")
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

extension iPadTabBarVC:LLMyTabbarDelegate{
    //实现代理方法
    func tabbarDidSelectedButtomFromto(tabbar: LLMyTabbar, from: Int, to: Int) {
        self.selectedIndex = to
        if to != 2{
            ZFPlayerModel.shared.playerManager.pause()
        }
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
