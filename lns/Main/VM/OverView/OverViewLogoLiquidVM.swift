//
//  OverViewLogoLiquidVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/30.
//

import UIKit

class OverViewLogoLiquidVM: UIView {

    // 高度与你现有一致
    let selfHeight = kFitWidth(38) + statusBarHeight + kFitWidth(4)

    var planTapBlock:(()->())?
    var editBlock:(()->())?

    private let logoImg = UIImage(named: "main_top_logo_cj")
    private let imgWidth  = kFitWidth(139)
    private let imgHeight = kFitWidth(25)

    // ① 毛玻璃（系统材质，深浅色自适应）
    private lazy var blurView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        v.clipsToBounds = true
        v.alpha = 0            // 初始透明，随滚动出现
        v.backgroundColor = .clear
        return v
    }()

    // ② 液态玻璃的纵向渐变叠加层（不是 mask，而是内容层）
    private let gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.startPoint = CGPoint(x: 0.5, y: 0.0)
        g.endPoint   = CGPoint(x: 0.5, y: 1.0)
        // 颜色会在 updateGradientColors() 中按明暗模式更新
        g.locations = [0.0, 0.55, 1.0]
        g.opacity   = 0       // 跟随滚动显现
        return g
    }()

    // ③ 边缘渐隐遮罩：让背景没有边界感（四向都柔和消失）
    private let edgeFadeMask = CAGradientLayer()

    // ④ 顶部微高光，增加“玻璃”质感
    private let shineLayer: CAGradientLayer = {
        let s = CAGradientLayer()
        s.startPoint = CGPoint(x: 0.5, y: 0.0)
        s.endPoint   = CGPoint(x: 0.5, y: 1.0)
        s.locations  = [0, 0.15]
        s.opacity    = 0      // 随滚动显现
        return s
    }()

    // 你的 Logo
    lazy var logoImgView: UIImageView = {
        let img = UIImageView(frame: CGRect(x: kFitWidth(32),
                                            y: self.selfHeight - kFitWidth(25) - kFitWidth(10),
                                            width: imgWidth, height: imgHeight))
        img.image = logoImg?.withRenderingMode(.alwaysTemplate)
        img.tintColor = .white
        img.contentMode = .scaleAspectFit
        return img
    }()

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        initUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func initUI() {
        addSubview(blurView)
        addSubview(logoImgView)

        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 把渐变与高光加到 blur 的内容层里（这样会跟随材质混合）
        blurView.contentView.layer.addSublayer(gradientLayer)
        blurView.contentView.layer.addSublayer(shineLayer)

        // 配置渐变与遮罩
        configureGradientBackground()
        configureEdgeFadeMask()
    }

    private func configureGradientBackground() {
        updateGradientColors()
        gradientLayer.frame = bounds
        shineLayer.frame    = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)

        // 顶部微高光（白 → 透明），提升“玻璃光晕”感
        let whiteTop = UIColor.white.withAlphaComponent(0.25).cgColor
        let white0   = UIColor.white.withAlphaComponent(0.0).cgColor
        shineLayer.colors = [whiteTop, white0]
    }

    private func configureEdgeFadeMask() {
        // 四向渐隐：中间不透明，四周渐变为 0，达到“无边界”视觉
        edgeFadeMask.frame = bounds
        edgeFadeMask.type = .radial
        // 中心黑色=可见，边缘透明=不可见（mask 使用 alpha）
        edgeFadeMask.colors = [
            UIColor.black.withAlphaComponent(1).cgColor,
            UIColor.black.withAlphaComponent(1).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor
        ]
        edgeFadeMask.locations = [0.0, 0.85, 1.0]
        edgeFadeMask.startPoint = CGPoint(x: 0.5, y: 0.1)
        edgeFadeMask.endPoint   = CGPoint(x: 0.5, y: 1.0)
        layer.mask = edgeFadeMask
    }

    // 深浅色自适应的液态渐变（顶部偏蓝、底部透明，像图三那种“消失感”）
    private func updateGradientColors() {
        let lightTop = UIColor(red: 120/255.0, green: 170/255.0, blue: 255/255.0, alpha: 0.28) // 淡蓝
        let lightMid = UIColor(red:  90/255.0, green: 140/255.0, blue: 255/255.0, alpha: 0.16)
        let lightEnd = UIColor.clear

        var top = lightTop, mid = lightMid, end = lightEnd

        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            top = UIColor(red: 60/255.0, green: 90/255.0, blue: 160/255.0, alpha: 0.30)
            mid = UIColor(red: 45/255.0, green: 70/255.0, blue: 150/255.0, alpha: 0.18)
            end = UIColor.clear
        }

        gradientLayer.colors = [top.cgColor, mid.cgColor, end.cgColor]
    }

    // 对外：滚动时调用，让导航从“透明”到“液态玻璃”
    func updateAlpha(offsetY: CGFloat) {
        let h = max(selfHeight, 1)
        let raw = min(max(offsetY / h, 0), 1)           // 0~1
        // 用缓动让出现更柔和
        let progress = pow(raw, 3)                      // ease-in

        blurView.alpha         = progress               // 毛玻璃出现
        gradientLayer.opacity  = Float(progress)        // 渐变出现
        shineLayer.opacity     = Float(progress * 0.7)  // 高光略弱

        // Logo 位置与颜色过渡
        let start = UIColor.white
        let end   = WHColorWithAlpha(colorStr: "007AFF", alpha: 1)
        logoImgView.tintColor = blendColor(from: start, to: end, progress: raw >= 0.3 ? 1 : 0)

        if offsetY >= kFitWidth(30) {
            logoImgView.frame = CGRect(x: SCREEN_WIDHT*0.5 - imgWidth*0.5,
                                       y: self.selfHeight - kFitWidth(25) - kFitWidth(10),
                                       width: imgWidth, height: imgHeight)
        } else {
            logoImgView.frame = CGRect(x: kFitWidth(32),
                                       y: self.selfHeight - kFitWidth(25) - kFitWidth(10),
                                       width: imgWidth, height: imgHeight)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = blurView.bounds
        shineLayer.frame    = blurView.bounds
        edgeFadeMask.frame  = bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            updateGradientColors()
        }
    }
}

// 颜色插值（保留你原逻辑）
private func blendColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
    let t = min(max(progress, 0), 1)
    var fr: CGFloat = 0, fg: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
    var tr: CGFloat = 0, tg: CGFloat = 0, tb: CGFloat = 0, ta: CGFloat = 0
    from.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
    to.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
    return UIColor(red: fr + (tr - fr) * t,
                   green: fg + (tg - fg) * t,
                   blue:  fb + (tb - fb) * t,
                   alpha: fa + (ta - fa) * t)
}
