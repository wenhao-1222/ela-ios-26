//
//  WHLoadingView.swift
//  lns
//
//  Created by LNS2 on 2024/8/7.
//

final class WHLoadingView: UIView {
    /// 懒加载,提示label
    private lazy var messageLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textAlignment = .center
       return l
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 反初始化器
    deinit { print("CCLoadingView deinit~") }
    
    // MARK: - 初始化器
    init(toast: String) {
        super.init(frame: .zero)
        
        let contentView = UIView()
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor =  WHColorWithAlpha(colorStr: "000000", alpha: 0.4)
        addSubview(contentView)
        
        let activity = UIActivityIndicatorView(style: .large)
        activity.color = .white
        contentView.addSubview(activity)
        
        if !toast.isEmpty {
            // 中间内容视图
            contentView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 120, height: 100))
            }
            
            // 加载转圈视图
            activity.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 37, height: 37))
            }
            
            // 文字提示视图
            messageLabel.text = toast
            addSubview(messageLabel)
            messageLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(contentView.snp.bottom)
                make.size.equalTo(CGSize(width: 120, height: 36))
            }
        }else {
            // 中间内容视图
            contentView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 100, height: 100))
            }
            
            // 加载转圈视图
            activity.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
        activity.startAnimating()
    }
}

extension UIView {
    /// 展示loading框(主线程中刷新UI)
    func showLoading(_ message: String = "") {
        // 若当前视图已加载CCLoadingView,则先移除后,再添加;
        if let lastView = subviews.last as? WHLoadingView { lastView.removeFromSuperview() }
        
        let loadingView = WHLoadingView(toast: message)
        addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    /// 隐藏loading框(主线程中刷新UI)
    func hideLoading() {
        for item in subviews {
            if item.isKind(of: WHLoadingView.self) {
                item.removeFromSuperview()
            }
        }
    }
}
