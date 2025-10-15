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

    // Logo（按你原尺寸/位置）
    private let logoImg  = UIImage(named: "main_top_logo_cj")
    private let imgWidth = kFitWidth(139)
    private let imgHeight = kFitWidth(25)
    
    // 毛玻璃层（背景层，放在最底）
    private lazy var blurView: UIVisualEffectView = {
        let effect: UIBlurEffect
        effect = UIBlurEffect(style: .systemChromeMaterial)
        let v = UIVisualEffectView(effect: effect)
//        v.clipsToBounds = true
        v.alpha = 0          // 模糊层总体不透明度 7%
        v.backgroundColor = .clear
        return v
    }()
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
        
        blurView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(kFitWidth(54))
        }
        // 配置底部羽化遮罩
        configureBottomFeatherMask()
    }

    /// 底部竖向羽化遮罩：中上部完全可见，最后 featherHeight 区间渐隐为 0
    private func configureBottomFeatherMask() {
        bottomFeatherMask.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomFeatherMask.endPoint   = CGPoint(x: 0.5, y: 1.0)
        applySoftMask(to: bottomFeatherMask, topHold: 0.15, steps: 18, strength: 1)
        // 想更轻一点（整体弱化）：strength 设小些，比如 0.75
        // 想过渡更丝滑：steps 设 8 或 10（注意性能影响非常小）

        blurView.layer.mask = bottomFeatherMask
    }
    func updateAlpha(offsetY:CGFloat) {
        if offsetY >= kFitWidth(30){
            blurView.alpha = min(0.85,(offsetY*0.01)/(selfHeight*0.01))
            let imgWidth = imgWidth*0.85
            let imgHeight = imgHeight*0.85
            logoImgView.tintColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 1)//blendColor(from: start, to: end, progress: 1)
            logoImgView.frame = CGRect.init(x: SCREEN_WIDHT*0.5-imgWidth*0.5, y: self.selfHeight-imgHeight-kFitWidth(10), width: imgWidth, height: imgHeight)
        }else{
            blurView.alpha = 0
            logoImgView.tintColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)//blendColor(from: start, to: end, progress: 0)
            logoImgView.frame = CGRect.init(x: kFitWidth(32), y: self.selfHeight-imgHeight-kFitWidth(10), width: imgWidth, height: imgHeight)
        }
    }
    /// 生成一组柔和的梯度遮罩（上强下弱）
    /// - Parameters:
    ///   - topHold: 顶部保持强模糊的占比 [0,1]
    ///   - steps: 过渡分段数（越大越平滑，建议 4~8）
    ///   - strength: 整体“雾量”，1.0=原强度，0.6=更轻
    func applySoftMask(to layer: CAGradientLayer,
                       topHold: CGFloat = 0.25,
                       steps: Int = 6,
                       strength: CGFloat = 1.0)
    {
        func easeInOut(_ t: CGFloat) -> CGFloat {
            // 经典 cubic ease-in-out
            return t < 0.5 ? 4*t*t*t : 1 - pow(-2*t + 2, 3)/2
        }

        // 组装 locations：前面 0 和 topHold 做 plateau，其后做等距细分
        var locs: [CGFloat] = [0.0, max(0.0, min(1.0, topHold))]
        for i in 1...steps {
            let p = CGFloat(i) / CGFloat(steps)           // 0→1
            let y = topHold + (1 - topHold) * p           // topHold→1
            locs.append(y)
        }

        // 组装 colors：alpha 从 1.0（顶部）按 S 曲线缓慢降到 0
        var cols: [CGColor] = []
        for (idx, l) in locs.enumerated() {
            let t: CGFloat
            if l <= topHold {
                t = 0                                     // plateau 区全强
            } else {
                let local = (l - topHold) / (1 - topHold) // 归一化到 0~1
                t = easeInOut(local)
            }
            let a = max(0, min(1, (1 - t) * strength))    // 由强(1)到弱(0)
            cols.append(UIColor.black.withAlphaComponent(a).cgColor)
            
            // 小技巧：在 topHold 位置再插一个相同 alpha，做更稳的台阶
            if idx == 1 {
                cols.append(UIColor.black.withAlphaComponent(a).cgColor)
            }
        }

        // locations 也要对应重复一个（与上面对齐）
        locs.insert(locs[1], at: 2)

        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        layer.locations  = locs.map { NSNumber(value: Double($0)) }
        layer.colors     = cols
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomFeatherMask.frame = blurView.bounds
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
