//
//  UniversalTabBarController.swift
//  lns
//
//  Created by Elavatine on 2025/3/24.
//

import UIKit

// MARK: - 设备类型判断协议
protocol DeviceAdaptable {
    var isiPad: Bool { get }
    var isPortrait: Bool { get }
}

extension DeviceAdaptable {
    var isiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isPortrait: Bool {
        UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait ?? true
    }
}

// MARK: - 自定义 TabBar 控制器
class UniversalTabBarController: UITabBarController, DeviceAdaptable {
    
    // MARK: - 配置参数
    private enum Metrics {
        static let iPhoneTabHeight: CGFloat = 49
        static let iPadTabHeight: CGFloat = 60
        static let compactWidth: CGFloat = 375  // iPhone 标准宽度
    }
    
    // MARK: - UI 组件
    private lazy var customTabBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        return sv
    }()
    
    // MARK: - 布局计算属性
    private var tabBarHeight: CGFloat {
        isiPad ? Metrics.iPadTabHeight : Metrics.iPhoneTabHeight
    }
    
    private var effectiveWidth: CGFloat {
        if isiPad && view.bounds.width > Metrics.compactWidth {
            return Metrics.compactWidth  // iPad 上限制最大宽度
        }
        return view.bounds.width
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        setupViewControllers()
        observeOrientationChanges()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateTabBarFrame()
    }
    
    // MARK: - 配置方法
    private func configureHierarchy() {
        // 隐藏系统 TabBar
        tabBar.isHidden = true
        
        // 添加自定义 TabBar
        view.addSubview(customTabBar)
        customTabBar.addSubview(stackView)
        
        // 初始约束
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: customTabBar.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: customTabBar.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: customTabBar.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: customTabBar.bottomAnchor)
        ])
        
        [customTabBar, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - 视图控制器配置
    private func setupViewControllers() {
        let mainVc = OverViewVC()
        let journalVc = JournalVC()
        let mineVc = MineVC()
        let forumVc = ForumVC()
        
        //预加载
        _ = journalVc.view
        _ = forumVc.view
        
//        self.setUpChildViewController(viewController: mainVc, image: UIImage.init(named: "tabbar_main_normal")!, selectImage: UIImage.init(named: "tabbar_main_selected")!, title: "概览")
//        self.setUpChildViewController(viewController: journalVc, image: UIImage.init(named: "tabbar_logs_normal")!, selectImage: UIImage.init(named: "tabbar_logs_selected")!, title: "日志")
//        self.setUpChildViewController(viewController: forumVc, image: UIImage.init(named: "tabbar_forum_normal")!, selectImage: UIImage.init(named: "tabbar_forum_selected")!, title: "干货")
//        self.setUpChildViewController(viewController: mineVc, image: UIImage.init(named: "tabbar_mine_normal")!, selectImage: UIImage.init(named: "tabbar_mine_selected")!, title: "我的")
        let controllers = [
            makeViewController(title: "概览", icon: "house", type: MainVC.self),
            makeViewController(title: "日志", icon: "magnifyingglass", type: JournalVC.self),
            makeViewController(title: "干货", icon: "gear", type: ForumVC.self),
            makeViewController(title: "我的", icon: "gear", type: MineVC.self)
        ]
        
        viewControllers = controllers
        createTabItems(for: controllers)
    }
    
    private func makeViewController<T: UIViewController>(title: String, icon: String, type: T.Type) -> UIViewController {
        let vc = T()
        vc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), tag: 0)
        return UINavigationController(rootViewController: vc)
    }
    
    // MARK: - 动态布局
    private func updateTabBarFrame() {
        let safeAreaBottom = view.safeAreaInsets.bottom
        let totalHeight = tabBarHeight + safeAreaBottom
        
        customTabBar.frame = CGRect(
            x: (view.bounds.width - effectiveWidth) / 2,  // iPad 居中
            y: view.bounds.height - totalHeight,
            width: effectiveWidth,
            height: totalHeight
        )
        
        // 圆角处理（仅 iPad）
        if isiPad {
            customTabBar.layer.cornerRadius = 12
            customTabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    // MARK: - 方向监听
    private func observeOrientationChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleOrientationChange() {
        UIView.animate(withDuration: 0.3) {
            self.updateTabBarFrame()
        }
    }
    
    // MARK: - Tab 项创建
    private func createTabItems(for controllers: [UIViewController]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        controllers.enumerated().forEach { index, vc in
            let button = TabBarButton()
            button.configure(
                title: vc.tabBarItem.title ?? "",
                image: vc.tabBarItem.image,
                selectedImage: vc.tabBarItem.selectedImage
            )
            
            button.tag = index
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - 按钮点击处理
    @objc private func tabButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateButtonSelectionStates()
    }
    
    private func updateButtonSelectionStates() {
        stackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? TabBarButton else { return }
            button.isSelected = index == selectedIndex
        }
    }
}

// MARK: - 自定义 TabBar 按钮
private class TabBarButton: UIButton {
    
    private enum Metrics {
        static let imageSize: CGFloat = 24
        static let titleFont: UIFont = .systemFont(ofSize: 12, weight: .medium)
        static let iPadPadding: CGFloat = 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, image: UIImage?, selectedImage: UIImage?) {
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
        setImage(selectedImage, for: .selected)
        
        // 动态调整布局
        if UIDevice.current.userInterfaceIdiom == .pad {
            contentEdgeInsets = UIEdgeInsets(top: Metrics.iPadPadding, left: 0, bottom: Metrics.iPadPadding, right: 0)
        }
    }
    
    private func configureStyle() {
        titleLabel?.font = Metrics.titleFont
        tintColor = .systemGray
        setTitleColor(.systemGray, for: .normal)
        setTitleColor(.systemBlue, for: .selected)
        adjustsImageWhenHighlighted = false
        
        // 垂直布局
        transform = CGAffineTransform(scaleX: 1, y: 1)
//        semanticContentAttribute = .forceVertical
        
        // 图像约束
        imageView?.contentMode = .scaleAspectFit
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView!.heightAnchor.constraint(equalToConstant: Metrics.imageSize),
            imageView!.widthAnchor.constraint(equalToConstant: Metrics.imageSize)
        ])
    }
    
    override var isSelected: Bool {
        didSet {
            animateSelection()
        }
    }
    
    private func animateSelection() {
        UIView.animate(withDuration: 0.25) {
            self.transform = self.isSelected ?
                CGAffineTransform(scaleX: 1.1, y: 1.1) :
                .identity
        }
    }
}
