//
//  InviteRewardsRuleVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/21.
//

import Foundation
import WebKit

class InviteRewardsRuleVM: UIView {
    
    let selfHeight = kFitWidth(156)
    var showMoreBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_CARD_BG_WHITE
        self.isUserInteractionEnabled = true
        initUI()
    }
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.text = "邀请奖励规则"
        return lab
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 3
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.adjustsFontSizeToFitWidth = true
        lab.isHidden = true
        
        let string = "1. 活动目的\n本活动旨在通过激励用户邀请他人注册和使用我们的服务，增加用户数量，提高用户活跃度和用户留存率..."
        lab.attributedText = string.mc_setLineSpace(lineSpace: kFitWidth(8))
        
        return lab
    }()
    lazy var wkWebView: WKWebView = {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .COLOR_CARD_BG_WHITE
        webView.scrollView.backgroundColor = .COLOR_CARD_BG_WHITE
        let url = URL(string: URL_reward_rule as String)
        let request = URLRequest(url: url!)
        
        webView.load(request)
        
        return webView
    }()
    lazy var showMoreButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("显示更多", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(showMoreAction), for: .touchUpInside)
        
        return btn
    }()
}

extension InviteRewardsRuleVM{
    @objc func showMoreAction() {
        if self.showMoreBlock != nil{
            self.showMoreBlock!()
        }
    }
    
    func configureWebViewAppearance() {
        let css = """
        body {
            background-color: #FFFFFF;
            color: #000000;
        }

        @media (prefers-color-scheme: dark) {
            body {
                background-color: #000000 !important;
                color: #FFFFFF !important;
            }
            * {
                color: #FFFFFF !important;
                background-color: transparent !important;
            }
            a {
                color: #4DA3FF !important;
            }
        }
        """

        let js = """
        var style = document.createElement('style');
        style.innerHTML = `\(css)`;
        document.head.appendChild(style);
        """

        let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        wkWebView.configuration.userContentController.addUserScript(userScript)

        if #available(iOS 13.0, *) {
            wkWebView.overrideUserInterfaceStyle = .unspecified  // 自动跟随系统
        }
    }
}
extension InviteRewardsRuleVM{
    func initUI() {
        addSubview(titleLab)
        addSubview(contentLabel)
        
        configureWebViewAppearance()
        addSubview(wkWebView)
        addSubview(showMoreButton)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        wkWebView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(40))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-45))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(46))
            make.right.equalTo(kFitWidth(-16))
//            make.height.equalTo(kFitWidth(66))
        }
        showMoreButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(42))
            make.width.equalTo(kFitWidth(200))
            make.bottom.equalToSuperview()
        }
    }
}
