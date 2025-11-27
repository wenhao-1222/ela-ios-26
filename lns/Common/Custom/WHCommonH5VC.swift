//
//  WHCommonH5VC.swift
//  ttjx
//
//  Created by 文 on 2019/10/10.
//  Copyright © 2019 ttjx. All rights reserved.
//

import UIKit
import WebKit

class WHCommonH5VC: WHBaseViewVC {
    
    var wkWebView = WKWebView()
    var progressView = UIProgressView()
    let h5TitleLabel = UILabel()
    var urlString = NSString()
    var isload = false
    var redirect_url = ""
    
    private let canGoBackKeyPath = "canGoBack"
      
    override func viewDidLoad() {
        super.viewDidLoad()
    
        initUI()
        prepareWebView()
        openInteractivePopGesture()
    }
}

extension WHCommonH5VC{
    func prepareWebView(){
        let url = URL(string: urlString as String)
        let request = URLRequest(url: url!)
        configureWebViewAppearance()
//        wkWebView.alpha =
        self.wkWebView.isHidden = true
        wkWebView.load(request)
    }
    func configureWebViewAppearance() {

        // --- 1. 移除 H5 中强制 light 的 meta 标签 ---
        let removeMeta = """
        var metas = document.querySelectorAll('meta[name="color-scheme"]');
        metas.forEach(m => m.remove());
        """
        let removeMetaScript = WKUserScript(source: removeMeta,
                                            injectionTime: .atDocumentStart,
                                            forMainFrameOnly: true)
        wkWebView.configuration.userContentController.addUserScript(removeMetaScript)

        // --- 2. 注入深色模式 CSS ---
        let css = """
        html, body {
            background-color: #FFFFFF !important;
            color: #000000 !important;
        }

        @media (prefers-color-scheme: dark) {

            html, body {
                background-color: #000000 !important;
                color: #FFFFFF !important;
            }

            * {
                background-color: transparent !important;
                color: #FFFFFF !important;
            }

            div, span, p, td, th, section, article, li, ul, ol {
                background: transparent !important;
                color: #FFFFFF !important;
            }

            input, textarea, select {
                background-color: #222222 !important;
                color: #FFFFFF !important;
                border-color: #444444 !important;
            }

            a {
                color: #4DA3FF !important;
            }

            img {
                filter: brightness(0.85) contrast(1.1);
            }
        }
        """

        let js = """
        var style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = `\(css)`;
        document.head.appendChild(style);
        """

        let cssScript = WKUserScript(source: js,
                                     injectionTime: .atDocumentEnd,
                                     forMainFrameOnly: true)
        let earlyCSS = """
        html, body {
            background-color: #000000 !important;
        }
        """

        let earlyJS = """
        var style = document.createElement('style');
        style.innerHTML = `\(earlyCSS)`;
        document.head.appendChild(style);
        """

        let earlyScript = WKUserScript(source: earlyJS,
                                       injectionTime: .atDocumentStart,
                                       forMainFrameOnly: true)

        wkWebView.configuration.userContentController.addUserScript(earlyScript)

        wkWebView.configuration.userContentController.addUserScript(cssScript)

        // --- 3. 保持 WKWebView 跟随系统外观 ---
        wkWebView.overrideUserInterfaceStyle = .unspecified
    }

    func initUI(){
        
        initNaviH5()
        h5TitleLabel.text = "加载中..."
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        wkWebView = WKWebView.init(frame: .zero, configuration: config)
        self.view.addSubview(wkWebView)
        wkWebView.snp.makeConstraints { (frame) in
            frame.width.equalTo(SCREEN_WIDHT)
            frame.height.equalTo(SCREEN_HEIGHT - getNavigationBarHeight())
            frame.top.equalToSuperview().offset(getNavigationBarHeight())
        }
        
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        wkWebView.backgroundColor = .COLOR_BG_WHITE//WHColor_16(colorStr: "F6F6F6")
        wkWebView.scrollView.bounces = false
        wkWebView.scrollView.backgroundColor = .COLOR_BG_WHITE
        wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        wkWebView.addObserver(self, forKeyPath: canGoBackKeyPath, options: .new, context: nil)
        
        self.view.addSubview(progressView)
        progressView.progressTintColor = UIColor.THEME
        progressView.trackTintColor = UIColor.clear
        progressView.snp.makeConstraints { (frame) in
            frame.width.equalTo(SCREEN_WIDHT)
            frame.height.equalTo(2)
            frame.top.equalTo(wkWebView.snp_top)
        }
    }
    
    func initNaviH5(){
        let naviView = UIView()
        view.addSubview(naviView)
        naviView.backgroundColor = .COLOR_BG_WHITE//WHColor_16(colorStr: "F6F6F6")
        naviView.isUserInteractionEnabled = true
        naviView.snp.makeConstraints { (frame) in
            frame.width.equalToSuperview()
            frame.height.equalTo(getNavigationBarHeight())
        }
        
        let bottomGap = 22 - kFitWidth(10)
        
        let backArrowImg = UIImageView()
        naviView.addSubview(backArrowImg)
        backArrowImg.image = UIImage.init(named: "back_arrow")
        backArrowImg.snp.makeConstraints { (frame) in
            frame.width.equalTo(kFitWidth(19))
            frame.height.equalTo(kFitWidth(19))
            frame.left.equalTo(kFitWidth(11))
            frame.bottom.equalToSuperview().offset(-bottomGap)
        }
        backArrowImg.isUserInteractionEnabled = true
        
        let backArrowLabel = UILabel()
//        backArrowLabel.text = "返回"
//        backArrowLabel.textColor = .COLOR_TEXT_BLACK333
        backArrowLabel.font = .systemFont(ofSize: 15)
        naviView.addSubview(backArrowLabel)
        backArrowLabel.snp.makeConstraints { (frame) in
            frame.left.equalTo(backArrowImg.snp_right).offset(kFitWidth(5))
            frame.centerY.lessThanOrEqualTo(backArrowImg)
        }
        
        let backArrowView = UIView()
        naviView.addSubview(backArrowView)
        backArrowView.backgroundColor = .clear
        backArrowView.isUserInteractionEnabled = true
        backArrowView.snp.makeConstraints { (frame) in
            frame.left.equalTo(backArrowImg.snp_left)
            frame.right.equalTo(backArrowLabel.snp_right)
            frame.top.equalTo(backArrowImg.snp_top).offset(kFitWidth(-5))
            frame.bottom.equalTo(backArrowImg.snp_bottom).offset(kFitWidth(5))
        }
        let backArrowTap = UITapGestureRecognizer()
        backArrowTap.addTarget(self, action: #selector(h5BackTapAction))
        backArrowView.addGestureRecognizer(backArrowTap)
        
        
        let closeBtn = UIButton()
        naviView.addSubview(closeBtn)
        closeBtn.setTitle("关闭", for: .normal)
//        closeBtn.setTitleColor(.COLOR_TEXT_BLACK333, for: .normal)
        closeBtn.titleLabel?.font = .systemFont(ofSize: 15)
        closeBtn.snp.makeConstraints { (frame) in
            frame.left.equalTo(backArrowLabel.snp_right).offset(kFitWidth(6))
            frame.centerY.lessThanOrEqualTo(backArrowImg.snp_centerY)
        }
        closeBtn.addTarget(self, action: #selector(backTapAction), for: .touchUpInside)
        
        naviView.addSubview(h5TitleLabel)
//        h5TitleLabel.textColor = .COLOR_TEXT_BLACK333
        h5TitleLabel.textAlignment = .center
        h5TitleLabel.font = UIFont.systemFont(ofSize: 18)
        h5TitleLabel.snp.makeConstraints { (frame) in
            frame.centerY.equalTo(backArrowImg)
            frame.centerX.lessThanOrEqualToSuperview()
            frame.width.equalTo(kFitWidth(180))
        }
        
    }
     
    @objc func h5BackTapAction(){

        if wkWebView.canGoBack {
            wkWebView.goBack()
        }else{
            if (self.navigationController != nil) {
                self.navigationController?.popViewController(animated: true)
            }else{
                self.dismiss(animated: true) {
                    
                }
            }
        }
    }
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject){
        var showMessage = ""
        if error != nil{
            showMessage = "保存失败"
        }else{
            showMessage = "保存成功"
        }
    
       toast(showMessage)
    }
    
}

extension WHCommonH5VC:WKNavigationDelegate,WKUIDelegate{
    // 监听网页加载进度
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            DLLog(message: "监听网页加载进度")
            progressView.progress = Float(wkWebView.estimatedProgress)
            DLLog(message: Float(wkWebView.estimatedProgress))
        }else if keyPath == canGoBackKeyPath{
            if let newValue = change?[NSKeyValueChangeKey.newKey]{
                let newV = newValue as! Bool
                if newV == true{
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
                }else{
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
                }
            }
        }
    }
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DLLog(message: "开始加载...")
        DLLog(message: webView.url?.absoluteString)
        
        if webView.url?.absoluteString.range(of: "weixin://wap/pay?") != nil || webView.url?.absoluteString.range(of: "alipay://alipayclient/") != nil || (webView.url?.absoluteString.contains("taobao:"))!{
            self.openUrl(urlString: webView.url!.absoluteString)
        }
        
        DLLog(message: "开始加载...")
    }
    
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        DLLog(message: "当内容开始返回...")
    }
    
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        DLLog(message: "页面加载完成...")
//        UIView.animate(withDuration: 0.15, animations: {
////            self.wkWebView.alpha = 1
//        })
        self.wkWebView.isHidden = false
        
        /// 获取网页title
        h5TitleLabel.text = wkWebView.title
        
        if self.urlString as String == URL_privacy {
            h5TitleLabel.text = "隐私政策"
        }else if self.urlString as String == URL_agreement {
            h5TitleLabel.text = "用户注册协议"
        }
        
        UIView.animate(withDuration: 0.5) {
            self.progressView.isHidden = true
        }
        // ====== 覆盖 iframe 深色模式 ======
        let iframeCSS = """
        var iframes = document.getElementsByTagName('iframe');
        for (var i = 0; i < iframes.length; i++) {
            try {
                let doc = iframes[i].contentDocument;
                if (!doc) continue;
                var style = doc.createElement('style');
                style.innerHTML = `
                    html, body { background-color: #000000 !important; color: #FFFFFF !important; }
                    * { background-color: transparent !important; color: #FFFFFF !important; }
                `;
                doc.head.appendChild(style);
            } catch(e) {}
        }
        """
        webView.evaluateJavaScript(iframeCSS)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        DLLog(message: "页面加载失败...")
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 0.0
            self.progressView.isHidden = true
        }
    }
    // 实现以下代理方法
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
         let cred = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
         completionHandler(.useCredential, cred)
    }

    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if (!(navigationAction.targetFrame?.isMainFrame ?? false)) {
            wkWebView.load(navigationAction.request)
        }

        return nil;
    }
}
