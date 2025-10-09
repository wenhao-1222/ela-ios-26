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
//        NotificationCenter.default.addObserver(self, selector: #selector(backTapAction), name: NSNotification.Name(rawValue: "authenSuccess"), object: nil)
    }
}

extension WHCommonH5VC{
    func prepareWebView(){
        let url = URL(string: urlString as String)
        let request = URLRequest(url: url!)
        wkWebView.load(request)
//
        
//        if let fileURL = Bundle.main.url(forResource: "index", withExtension: "html") {
//            wkWebView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
//        } else {
//            print("HTML file not found")
//        }
        
//        var filePath = Bundle.main.path(forResource: "index", ofType: "html")
//        filePath = "file://\(filePath ?? "")"
//        let pathUrl = URL(string: filePath!)
//        wkWebView.load(URLRequest.init(url: pathUrl!))
        
        
//        let fullPath = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "")
//        let baseUrl = (fullPath?.deletingLastPathComponent())!
//        self.wkWebView.loadFileURL(fullPath!, allowingReadAccessTo: baseUrl)
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
        wkWebView.backgroundColor = WHColor_16(colorStr: "F6F6F6")
        wkWebView.scrollView.bounces = false
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
        naviView.backgroundColor = .white//WHColor_16(colorStr: "F6F6F6")
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
