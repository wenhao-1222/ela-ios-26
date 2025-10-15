//
//  OverViewLogoLiquidVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/30.
//

import UIKit

/// 顶部“液态玻璃”导航：固定渐变（不随滚动变化）
/// 视觉要点：
/// 1) 毛玻璃常显；
/// 2) 叠一层主色着色渐变：顶部 alpha=0.80 → 底部 alpha≈0.02；
/// 3) 底部用竖向羽化遮罩渐隐，跟页面平滑衔接。
final class OverViewLogoLiquidVM: UIView {

    // 高度保持和原工程一致
    let selfHeight = kFitWidth(38) + statusBarHeight + kFitWidth(4)

    // ------- 可按需调整的外观参数 -------
    private let tintLightHex = "FFFFFF"     // 浅色模式主色（品牌蓝）
    private let tintDarkHex  = "1E5EFF"     // 深色模式主色（略调暗）
    private let topAlpha: CGFloat    = 0.5 // 顶部透明度
    private let bottomAlpha: CGFloat = 0 // 底部透明度
    private let featherHeight: CGFloat = 0//kFitWidth(38) + statusBarHeight + kFitWidth(4)//kFitWidth(24) // 底部羽化高度（px），越大越柔

    // Logo（按你原尺寸/位置）
    private let logoImg  = UIImage(named: "main_top_logo_cj")
    private let imgWidth = kFitWidth(139)
    private let imgHeight = kFitWidth(25)

    // 毛玻璃层：常显
    private lazy var blurView: UIVisualEffectView = {
        let effect: UIBlurEffect
//            if #available(iOS 13.0, *) {
//                effect = traitCollection.userInterfaceStyle == .dark
//                ? UIBlurEffect(style: .systemChromeMaterialDark)
//                : UIBlurEffect(style: .systemChromeMaterial)
//            } else {
                effect = UIBlurEffect(style: .extraLight)
//                }
        let v = UIVisualEffectView(effect: effect)
        v.clipsToBounds = true
        v.alpha = 0.5
//        v.backgroundColor = .THEME
        return v
    }()

    // 渐变着色层（在毛玻璃上叠一层颜色从上到下逐渐变淡）
    private let gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.startPoint = CGPoint(x: 0.5, y: 0.0)
        g.endPoint   = CGPoint(x: 0.5, y: 1.0)
        // 三段更自然：顶 -> 过渡 -> 底
        g.locations  = [0.0, 0.62, 1.0]
        g.opacity    = 1.0
        return g
    }()

    // 顶部轻微高光（提升玻璃质感，可按需调低/去掉）
    private let shineLayer: CAGradientLayer = {
        let s = CAGradientLayer()
        s.startPoint = CGPoint(x: 0.5, y: 0.0)
        s.endPoint   = CGPoint(x: 0.5, y: 1.0)
        s.locations  = [0, 0.15]
        s.opacity    = 0.22
        s.colors = [
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        return s
    }()

    // 底部羽化遮罩：让底缘在最后 featherHeight 内渐隐为 0，衔接更柔
    private let bottomFeatherMask = CAGradientLayer()

    // Logo 视图
    private(set) lazy var logoImgView: UIImageView = {
        let img = UIImageView(frame: CGRect(
            x: kFitWidth(32),
            y: self.selfHeight - kFitWidth(25) - kFitWidth(10),
            width: imgWidth,
            height: imgHeight
        ))
        img.image = logoImg?.withRenderingMode(.alwaysTemplate)
        img.tintColor = .white
        img.contentMode = .scaleAspectFit
        return img
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup
    private func setupUI() {
        addSubview(blurView)
        addSubview(logoImgView)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // 渐变与高光叠到毛玻璃之上
        blurView.contentView.layer.addSublayer(gradientLayer)
        blurView.contentView.layer.addSublayer(shineLayer)

        // 设置固定外观
        applyFixedTint()

        // 配置底部羽化遮罩
        configureBottomFeatherMask()
    }

    /// 根据深/浅色模式套用主色，并设置自上而下 0.8→0.02 的透明度
    private func applyFixedTint() {
        let baseTint: UIColor
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            baseTint = WHColor_16(colorStr: tintDarkHex)
        } else {
            baseTint = WHColor_16(colorStr: tintLightHex)
        }
        let aTop = max(0, min(1, topAlpha))
        let aBot = max(0, min(1, bottomAlpha))
        let aMid = (aTop + aBot) * 0.5

        gradientLayer.colors = [
            baseTint.withAlphaComponent(aTop).cgColor,
//            baseTint.withAlphaComponent(aMid).cgColor,
            baseTint.withAlphaComponent(aBot).cgColor
        ]
    }

    /// 底部竖向羽化遮罩：中上部完全可见，最后 featherHeight 区间渐隐为 0
    private func configureBottomFeatherMask() {
        bottomFeatherMask.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomFeatherMask.endPoint   = CGPoint(x: 0.5, y: 1.0)
        // mask 使用 alpha：白(1)=可见，黑(0)=不可见
        bottomFeatherMask.colors = [
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor,
        ]
//        bottomFeatherMask.colors = [
//            UIColor.white.cgColor,                       // 全可见
//            UIColor.white.cgColor,                       // 全可见
//            UIColor.black.withAlphaComponent(0).cgColor  // 渐隐到 0
//        ]
        blurView.layer.mask = bottomFeatherMask
    }
    func updateAlpha(offsetY:CGFloat) {
//        var percent = offsetY / selfHeight
//        percent = min(max(percent, 0), 1)
//        let value = pow(percent, 3)
//        backgroundColor = UIColor(white: 1, alpha: value)

//        let start = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
//        let end = WHColorWithAlpha(colorStr: "007AFF", alpha: 1)
        
        if offsetY >= kFitWidth(30){
            let imgWidth = imgWidth*0.85
            let imgHeight = imgHeight*0.85
            logoImgView.tintColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 1)//blendColor(from: start, to: end, progress: 1)
            logoImgView.frame = CGRect.init(x: SCREEN_WIDHT*0.5-imgWidth*0.5, y: self.selfHeight-imgHeight-kFitWidth(10), width: imgWidth, height: imgHeight)
        }else{
            logoImgView.tintColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)//blendColor(from: start, to: end, progress: 0)
            logoImgView.frame = CGRect.init(x: kFitWidth(32), y: self.selfHeight-imgHeight-kFitWidth(10), width: imgWidth, height: imgHeight)
        }
    }
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = blurView.bounds
        shineLayer.frame    = blurView.bounds

        // 根据当前高度计算羽化分界位置
        bottomFeatherMask.frame = blurView.bounds
        let h = bounds.height
        let fadeStart = max(0, min(1, (h - featherHeight) / max(h, 1))) // 渐隐起点的比例
        bottomFeatherMask.locations = [0.0, NSNumber(value: Double(fadeStart)), 1.0]
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyFixedTint()
        }
    }
}

private func blendColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
    let ratio = min(max(progress, 0), 1)
    var fr: CGFloat = 0, fg: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
    var tr: CGFloat = 0, tg: CGFloat = 0, tb: CGFloat = 0, ta: CGFloat = 0
    from.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
    to.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
    return UIColor(red: fr + (tr - fr) * ratio,
                   green: fg + (tg - fg) * ratio,
                   blue: fb + (tb - fb) * ratio,
                   alpha: fa + (ta - fa) * ratio)
}
