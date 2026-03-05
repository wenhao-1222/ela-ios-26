//
//  ElaProAgreementAlertVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/5.
//

import UIKit
import WebKit

class ElaProAgreementAlertVM: UIView {
    
    // MARK: - Layout constants
    var whiteViewHeight: CGFloat = kFitWidth(610) + WHUtils().getBottomSafeAreaHeight()
    let whiteViewTopRadius: CGFloat = kFitWidth(50)
    
    private var didLoadPage = false
    private let transparentStyleID = "ela_pro_agreement_transparent_style"
    /// 蒙层目标透明度：浅色 0.15，深色 0.85
    private var targetDimAlpha: CGFloat {
        return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
    }
    // 主题变更时（例如从浅色切到深色）同步调整蒙层透明度
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupWhiteViewBorder()
        applyTransparentBackgroundToLoadedPage()
        UIView.animate(withDuration: 0.2) {
            self.bgView.alpha = self.targetDimAlpha
            self.topGradientLayer.colors = [
                UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0.05).cgColor,
                UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0).cgColor
            ]
        }
    }
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isHidden = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateWhiteViewBorderFrame()
        topGradientLayer.frame = topGradientView.bounds
    }
    
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK//WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    private lazy var whiteView: UIView = {
        // 先用默认高度创建，后面 dealData() 会重算高度并设置 frame
        let vi = UIView(frame: CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight))
//        vi.backgroundColor = .COLOR_CARD_BG_WHITE_ALERT
        vi.backgroundColor = .clear
//        vi.layer.cornerRadius = whiteViewTopRadius
        vi.addClipCorner(corners: [.topLeft,.topRight], radius: whiteViewTopRadius)
        if #available(iOS 13.0, *) { vi.layer.cornerCurve = .continuous }
        vi.layer.masksToBounds = true
        
        // 吞掉点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)

        // 下拉关闭
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        vi.addGestureRecognizer(pan)
        
        return vi
    }()
    
    private lazy var whiteBlurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.contentView.backgroundColor = UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0.05)
        return view
    }()
    private let whiteBorderGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.locations = [0, 1]
        return layer
    }()
    private let whiteBorderMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 1
        return layer
    }()
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "ELA PRO条款和条件"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .semibold)
        
        return lab
    }()
    
    lazy var closeIconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "alert_close_icon")
        return img
    }()
    lazy var closeTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    private lazy var wkWebView: WKWebView = {
        let config = WKWebViewConfiguration()
        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = .clear
        if #available(iOS 15.0, *) {
            web.underPageBackgroundColor = .clear
        }
        web.navigationDelegate = self
        web.scrollView.backgroundColor = .clear
        web.scrollView.showsVerticalScrollIndicator = true
        return web
    }()
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0.05).cgColor,
            UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
}
// MARK: - Public API
extension ElaProAgreementAlertVM {
    func showSelf() {
        isHidden = false

        bgView.isUserInteractionEnabled = false
        
        // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0

        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.bgView.alpha = self.targetDimAlpha
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
    }

    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
    
    private func loadIfNeeded() {
        guard !didLoadPage, let url = URL(string: URL_pro_agreement) else { return }
        didLoadPage = true
        configureWebViewAppearance()
        wkWebView.load(URLRequest(url: url))
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
                    background:transparent !important;background-color:transparent !important;
        }
        """

        let earlyJS = """
        var style = document.createElement('style');
        style.innerHTML = `\(earlyCSS)`;
        document.head.appendChild(style);
        document.documentElement.style.background = 'transparent';
        if (document.body) {
            document.body.style.background = 'transparent';
            document.body.style.backgroundColor = 'transparent';
        }
        """

        let earlyScript = WKUserScript(source: earlyJS,
                                       injectionTime: .atDocumentStart,
                                       forMainFrameOnly: true)

        wkWebView.configuration.userContentController.addUserScript(earlyScript)

        wkWebView.configuration.userContentController.addUserScript(cssScript)

        // --- 3. 保持 WKWebView 跟随系统外观 ---
        wkWebView.overrideUserInterfaceStyle = .unspecified
    }

    
    private func transparentBackgroundJavaScript() -> String {
        return """
        (function() {
            var style = document.getElementById('\(transparentStyleID)');
            if (!style) {
                style = document.createElement('style');
                style.id = '\(transparentStyleID)';
                document.documentElement.appendChild(style);
            }
            style.innerHTML = 'html,body{background:transparent !important;background-color:transparent !important;}';
            document.documentElement.style.background = 'transparent';
            if (document.body) {
                document.body.style.background = 'transparent';
                document.body.style.backgroundColor = 'transparent';
            }
        })();
        """
    }
    
    
    private func applyTransparentBackgroundToLoadedPage() {
        guard didLoadPage else { return }
        wkWebView.evaluateJavaScript(transparentBackgroundJavaScript(), completionHandler: nil)
    }
}

extension ElaProAgreementAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        
        whiteView.addSubview(whiteBlurView)
        whiteBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        whiteView.addSubview(titleLab)
        whiteView.addSubview(closeIconImgView)
        whiteView.addSubview(closeTapView)
        whiteView.addSubview(wkWebView)
        whiteView.addSubview(topGradientView)
        topGradientView.layer.addSublayer(topGradientLayer)
        
        setConstrait()
        setupWhiteViewBorder()
        loadIfNeeded()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(35))
            make.top.equalTo(kFitWidth(29))
        }
        closeIconImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-25))
            make.width.height.equalTo(kFitWidth(25))
            make.centerY.lessThanOrEqualTo(titleLab)
        }
        closeTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(closeIconImgView)
            make.width.height.equalTo(kFitWidth(75))
        }
        wkWebView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(40))
            make.bottom.equalTo(kFitWidth(-16)-WHUtils().getBottomSafeAreaHeight())
        }
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(wkWebView.snp.top)//.offset(kFitWidth(-10))
            make.height.equalTo(kFitWidth(50))
        }
    }
    private func setupWhiteViewBorder() {
        //color_text_white_d234_50
        if traitCollection.userInterfaceStyle == .dark{
            whiteBorderGradientLayer.colors = [WHColorWithAlpha(colorStr: "D2D3D4", alpha: 0.5).cgColor,
                                               WHColorWithAlpha(colorStr: "D2D3D4", alpha: 0).cgColor]
        }else{
            whiteBorderGradientLayer.colors = [WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5).cgColor,
                                               WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5).cgColor]
        }
        
        whiteBorderGradientLayer.mask = whiteBorderMaskLayer
        whiteView.layer.addSublayer(whiteBorderGradientLayer)
        updateWhiteViewBorderFrame()
    }

    private func updateWhiteViewBorderFrame() {
        whiteBorderGradientLayer.frame = whiteView.bounds

        let inset = whiteBorderMaskLayer.lineWidth / 2
        let pathRect = whiteView.bounds.insetBy(dx: inset, dy: inset)
        whiteBorderMaskLayer.path = UIBezierPath(roundedRect: pathRect,
                                                 cornerRadius: whiteViewTopRadius - inset).cgPath
    }
}

extension ElaProAgreementAlertVM: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        applyTransparentBackgroundToLoadedPage()
    }
}

extension ElaProAgreementAlertVM{
    @objc func nothingToDo() { /* 吞点击 */ }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        guard gesture.view === whiteView else { return }

        let translation = gesture.translation(in: whiteView)
        gesture.setTranslation(.zero, in: whiteView)

        switch gesture.state {
        case .changed:
            // 只允许向下拖动（ty >= 0）
            let currentTy = whiteView.transform.ty
            var newTy = currentTy + translation.y
            newTy = max(0, min(whiteViewHeight, newTy))
            whiteView.transform = CGAffineTransform(translationX: 0, y: newTy)

            // 同步调低蒙层
            let progress = min(1, max(0, newTy / whiteViewHeight))
            bgView.alpha = self.targetDimAlpha * (1 - progress)

        case .ended, .cancelled, .failed:
            let ty = whiteView.transform.ty
            let velocity = gesture.velocity(in: whiteView).y
            let threshold = kFitWidth(50)

            // 根据拖动距离或下滑速度决定收起
            if ty >= threshold || velocity > 800 {
                hiddenSelf()
            } else {
                // 回弹
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self.whiteView.transform = .identity
                    self.bgView.alpha = self.targetDimAlpha
                }
            }
        default:
            break
        }
    }
}
