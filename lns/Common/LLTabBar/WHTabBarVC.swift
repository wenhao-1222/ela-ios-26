//
//  WHTabBarVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/9.
//
import UIKit
import Foundation

class WHTabBarVC: UITabBarController {
    private enum Constants {
           static let mineTabIndex = 3
       }
    var tabbar = LLMyTabbar()
    var whTabBar = WHTabBar()
    private var guideVC: GuideTotalVC?
    private lazy var mineRedDotView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemRed
            view.layer.cornerRadius = kFitWidth(2.5)
            view.clipsToBounds = true
            view.isHidden = true
            return view
        }()

        private var didInitializeMineRedDotState = false
    lazy var coverWhiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear // 玻璃必须透明
        vi.isUserInteractionEnabled = false
        return vi
    }()

    // 方向
    override var shouldAutorotate: Bool {
        if #available(iOS 16.0, *) { return false } else { return true }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UserConfigModel.shared.allowedOrientations
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UserConfigModel.shared.userInterfaceOrientation
    }

    // TabBar 外观（清空系统选中“药丸”）
    private func applyCurrentAppearance() {
        let blur = UIBlurEffect(style: .systemChromeMaterial)
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = blur
        appearance.backgroundColor = .clear
        appearance.shadowColor = UIColor.label.withAlphaComponent(0.06)

        // ⛔️ 关键：去掉系统 selectionIndicator（灰色药丸）
        appearance.selectionIndicatorImage = UIImage() // 透明

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.isTranslucent = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyCurrentAppearance()
            updateTabBarImages()
            if selectedIndex == 1 {
                coverWhiteView.addShadow(opacity: 0.05, offset: CGSize(width: 0, height: -5))
            }
        }
    }

    func updateTabBarImages() {
        for (index, button) in tabbar.btnArr.enumerated() {
            switch index {
            case 0:
                button.setImage(traitCollection.userInterfaceStyle == .dark
                                ? UIImage(named: "tabbar_main_normal_dark")?.withRenderingMode(.alwaysOriginal)
                                : UIImage(named: "tabbar_main_normal")?.withRenderingMode(.alwaysOriginal),
                                for: .normal)
                button.setImage(traitCollection.userInterfaceStyle == .dark
                                ? UIImage(named: "tabbar_main_selected_dark")?.withRenderingMode(.alwaysOriginal)
                                : UIImage(named: "tabbar_main_selected")?.withRenderingMode(.alwaysOriginal),
                                for: .selected)
            case 1:
                button.setImage(traitCollection.userInterfaceStyle == .dark
                                ? UIImage(named: "tabbar_logs_normal_dark")?.withRenderingMode(.alwaysOriginal)
                                : UIImage(named: "tabbar_logs_normal")?.withRenderingMode(.alwaysOriginal),
                                for: .normal)
                button.setImage(traitCollection.userInterfaceStyle == .dark
                                ? UIImage(named: "tabbar_logs_selected_dark")?.withRenderingMode(.alwaysOriginal)
                                : UIImage(named: "tabbar_logs_selected")?.withRenderingMode(.alwaysOriginal),
                                for: .selected)
            case 2:
                button.setImage(traitCollection.userInterfaceStyle == .dark
                                ? UIImage(named: "tabbar_forum_normal_dark")?.withRenderingMode(.alwaysOriginal)
                                : UIImage(named: "tabbar_forum_normal")?.withRenderingMode(.alwaysOriginal),
                                for: .normal)
                button.setImage(traitCollection.userInterfaceStyle == .dark
                                ? UIImage(named: "tabbar_forum_selected_dark")?.withRenderingMode(.alwaysOriginal)
                                : UIImage(named: "tabbar_forum_selected")?.withRenderingMode(.alwaysOriginal),
                                for: .selected)
            case 3:
                button.setImage(traitCollection.userInterfaceStyle == .dark
                                ? UIImage(named: "tabbar_mine_normal_dark")?.withRenderingMode(.alwaysOriginal)
                                : UIImage(named: "tabbar_mine_normal")?.withRenderingMode(.alwaysOriginal),
                                for: .normal)
                button.setImage(traitCollection.userInterfaceStyle == .dark
                                ? UIImage(named: "tabbar_mine_selected_dark")?.withRenderingMode(.alwaysOriginal)
                                : UIImage(named: "tabbar_mine_selected")?.withRenderingMode(.alwaysOriginal),
                                for: .selected)
            default: break
            }
        }
    }
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
    override func viewDidLoad() {
        super.viewDidLoad()

        createMainTabBarView()
        childAllChildViewControllers()
        observeMineTabNotifications()
        tabbar.seletedButton = tabbar.btnArr[1]
        tabbar.seletedButton.isSelected = true

        NotificationCenter.default.addObserver(self, selector: #selector(gotoLogsNotification), name: NSNotification.Name(rawValue: "activePlan"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showGuideTotalIfNeeded), name: NOTIFI_NAME_GUIDE, object: nil)

        tabbar.centerClick()
        applyCurrentAppearance()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let customBar = tabBar as? WHTabBar else { return }
        let bounds = customBar.bounds

        if tabbar.frame != bounds { tabbar.frame = bounds }
        if coverWhiteView.frame != bounds { coverWhiteView.frame = bounds }

        coverWhiteView.layer.cornerRadius = customBar.layer.cornerRadius
        coverWhiteView.layer.masksToBounds = false

        customBar.tabbar = tabbar
        attachMineRedDotIfNeeded(in: customBar)
    }
    @objc private func showGuideTotalIfNeeded() {
        let vc = GuideTotalVC()
        vc.finishBlock = { [weak self] in self?.removeGuideTotalVC() }
        guideVC = vc
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.frame = view.bounds
    }

    func removeGuideTotalVC() {
        guard let vc = guideVC else { return }
        UIView.animate(withDuration: 0.3, animations: { vc.view.alpha = 0 }) { _ in
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            self.guideVC = nil
        }
        UserDefaults.standard.setValue("1", forKey: guide_total)
    }

    private func createMainTabBarView() {
//        let tabBarRect = tabBar.bounds
//        whTabBar.frame = tabBarRect
        whTabBar.frame = tabBar.bounds
        whTabBar.backgroundColor = .clear
//        setValue(whTabBar, forKeyPath: "tabBar")
        whTabBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        setValue(whTabBar, forKey: "tabBar")
        tabbar = LLMyTabbar()
//        tabbar.frame = CGRect(x: tabBar.bounds.minX,
//                              y: tabBar.bounds.minY,
//                              width: tabBar.bounds.width,
//                              height: tabBar.bounds.height)
        tabbar.frame = tabBar.bounds
                tabbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabbar.delegate = self
        tabbar.backgroundColor = .clear

//        whTabBar.addSubview(tabbar)
//        whTabBar.tabbar = tabbar

        whTabBar.insertSubview(coverWhiteView, belowSubview: tabbar)
//        coverWhiteView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: WHUtils().getTabbarHeight())
        coverWhiteView.frame = tabBar.bounds
        coverWhiteView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coverWhiteView.layer.masksToBounds = false
        coverWhiteView.addShadow(opacity: 0.05, offset: CGSize(width: 0, height: -5))
    }
    private func observeMineTabNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mineServiceMsgNotification),
                                               name: NSNotification.Name(rawValue: "serviceMsgUnRead"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mineServiceMsgReadNotification),
                                               name: NSNotification.Name(rawValue: "serviceMsgRead"),
                                               object: nil)
    }

    private func attachMineRedDotIfNeeded(in bar: WHTabBar) {
        guard let items = bar.items, items.count > Constants.mineTabIndex else { return }

        if mineRedDotView.superview !== bar {
            mineRedDotView.removeFromSuperview()
            bar.addSubview(mineRedDotView)
        }

        let itemCount = CGFloat(items.count)
        guard itemCount > 0 else { return }

        let itemWidth = bar.bounds.width / itemCount
        let redDotSize = kFitWidth(5)
        mineRedDotView.bounds = CGRect(x: 0, y: 0, width: redDotSize, height: redDotSize)
        mineRedDotView.layer.cornerRadius = redDotSize / 2

        let mineOriginX = CGFloat(Constants.mineTabIndex) * itemWidth
        let centerX = mineOriginX + itemWidth * 0.5 + kFitWidth(12)
        let centerY = kFitWidth(3) + redDotSize * 0.5
        mineRedDotView.center = CGPoint(x: centerX, y: centerY)

        if didInitializeMineRedDotState == false {
            didInitializeMineRedDotState = true
            updateMineRedDotInitialState()
        }
    }

    private func updateMineRedDotInitialState() {
        if UserInfoModel.shared.msgUnRead {
            setMineRedDotHidden(false)
        } else {
            mineServiceMsgReadNotification()
        }
        tabbar.mineServiceMsgReadNotification()
    }

    private func setMineRedDotHidden(_ hidden: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.mineRedDotView.isHidden = hidden
        }
    }

    @objc private func mineServiceMsgNotification() {
        setMineRedDotHidden(false)
    }

    @objc private func mineServiceMsgReadNotification() {
        let shouldHide = UserInfoModel.shared.settingNewFuncRead && UserInfoModel.shared.newsListHasUnRead == false
        setMineRedDotHidden(shouldHide)
    }
    func childAllChildViewControllers() {
        let mainVc = OverViewVC()
        let journalVc = JournalVC()
        let mineVc = MineVC()
        let forumVc = ForumVC()

        _ = mainVc.view; _ = journalVc.view; _ = forumVc.view

        if traitCollection.userInterfaceStyle == .dark && UserConfigModel.shared.overrideUserInterfaceStyle != .light {
            setUpChildViewController(viewController: mainVc, image: UIImage(named: "tabbar_main_normal_dark")!, selectImage: UIImage(named: "tabbar_main_selected_dark")!, title: "概览")
            setUpChildViewController(viewController: journalVc, image: UIImage(named: "tabbar_logs_normal_dark")!, selectImage: UIImage(named: "tabbar_logs_selected_dark")!, title: "日志")
            setUpChildViewController(viewController: forumVc, image: UIImage(named: "tabbar_forum_normal_dark")!, selectImage: UIImage(named: "tabbar_forum_selected_dark")!, title: "干货")
            setUpChildViewController(viewController: mineVc, image: UIImage(named: "tabbar_mine_normal_dark")!, selectImage: UIImage(named: "tabbar_mine_selected_dark")!, title: "我的")
        } else {
            setUpChildViewController(viewController: mainVc, image: UIImage(named: "tabbar_main_normal")!, selectImage: UIImage(named: "tabbar_main_selected")!, title: "概览")
            setUpChildViewController(viewController: journalVc, image: UIImage(named: "tabbar_logs_normal")!, selectImage: UIImage(named: "tabbar_logs_selected")!, title: "日志")
            setUpChildViewController(viewController: forumVc, image: UIImage(named: "tabbar_forum_normal")!, selectImage: UIImage(named: "tabbar_forum_selected")!, title: "干货")
            setUpChildViewController(viewController: mineVc, image: UIImage(named: "tabbar_mine_normal")!, selectImage: UIImage(named: "tabbar_mine_selected")!, title: "我的")
        }
    }

    func setUpChildViewController(viewController:UIViewController,image:UIImage,selectImage:UIImage,title:String) {
        // 仍需设置 item（用于状态管理），但系统按钮已被我们隐藏
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        viewController.tabBarItem.selectedImage = selectImage.withRenderingMode(.alwaysOriginal)

        let NAVC = LLNaviViewController(rootViewController: viewController)
        addChild(NAVC)
        tabbar.addTabBarButtonWithItem(item: viewController.tabBarItem)
        // 禁用系统 TabBarItem 的交互，避免出现“双层” TabBar
//       viewController.tabBarItem.isEnabled = false
    }
}

extension WHTabBarVC: LLMyTabbarDelegate {
    func tabbarDidSelectedButtomFromto(tabbar: LLMyTabbar, from: Int, to: Int) {
        selectedIndex = to
        if to != 2 { ZFPlayerModel.shared.playerManager.pause() }
        coverWhiteView.addShadow(opacity: 0.05, offset: CGSize(width: 0, height: -5))

        UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.9) {
            self.tabbar.layoutIfNeeded()
        }.startAnimation()
    }

    @objc func gotoLogsNotification() {
        DLLog(message: "跳转到日志")
        // 防守：若系统又生成 UITabBarButton，清一遍
        for vi in tabBar.subviews where vi is UIControl {
            vi.removeFromSuperview()
        }
    }

    @objc func widgetAddFoods() {
        let vc = FoodsListNewVC()
        vc.sourceType = .logs
        navigationController?.pushViewController(vc, animated: true)
    }
}
