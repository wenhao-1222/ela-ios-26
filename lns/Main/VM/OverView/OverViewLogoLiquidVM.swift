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
    
    private lazy var logoLeftFrame: CGRect = {
        CGRect(
            x: kFitWidth(32),
            y: selfHeight - imgHeight - kFitWidth(10),
            width: imgWidth,
            height: imgHeight
        )
    }()

    private lazy var logoCenteredFrame: CGRect = {
        let targetWidth = imgWidth * 0.7
        let targetHeight = imgHeight * 0.7
        return CGRect(
            x: SCREEN_WIDHT * 0.5 - targetWidth * 0.5,
            y: selfHeight - targetHeight - kFitWidth(10),
            width: targetWidth,
            height: targetHeight
        )
    }()

    private var isLogoCentered = false
    private var logoTransitionAnimator: UIViewPropertyAnimator?
    private var logoSnapshotView: UIView?
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
        let img = UIImageView(frame: logoLeftFrame)
        img.image = logoImg?.withRenderingMode(.alwaysTemplate)
        img.tintColor = .white
        img.contentMode = .scaleAspectFit
        return img
    }()
    private(set) lazy var logoCenterImgView: UIImageView = {
        let img = UIImageView(frame: logoCenteredFrame)
        img.image = logoImg?.withRenderingMode(.alwaysTemplate)
        img.tintColor = .THEME
        img.alpha = 0
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
        addSubview(logoCenterImgView)

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
    func updateAlpha(offsetY: CGFloat) {
        let threshold = kFitWidth(30)
        let shouldCenter = offsetY >= threshold

        if shouldCenter {
            let progressDenominator = max(selfHeight - threshold, 1)
            let progress = min(max((offsetY - threshold) / progressDenominator, 0), 1)
            blurView.alpha = min(0.85, progress * 0.85)
        } else {
            blurView.alpha = 0
        }
        
        if shouldCenter != isLogoCentered {
            applyLogoState(centered: shouldCenter, animated: true)
            isLogoCentered = shouldCenter
        } else if logoTransitionAnimator == nil {
            applyLogoState(centered: shouldCenter, animated: false)
        }
    }

    private func applyLogoState(centered: Bool, animated: Bool) {
        if centered {
            UIView.animate(withDuration: 0.2) {
                self.logoCenterImgView.alpha = 1
                self.logoImgView.alpha = 0
            }
        }else{
            UIView.animate(withDuration: 0.2) {
                self.logoCenterImgView.alpha = 0
                self.logoImgView.alpha = 1
            }
        }
//        let targetFrame = centered ? logoCenteredFrame : logoLeftFrame
//        let targetTint = centered
//            ? WHColorWithAlpha(colorStr: "007AFF", alpha: 1)
//            : WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
//
//        if animated {
//            runLogoTransition(to: targetFrame, tintColor: targetTint)
//        } else {
//            cancelLogoAnimation()
//            logoImgView.frame = targetFrame
//            logoImgView.tintColor = targetTint
//            logoImgView.alpha = 1
//        }
    }

    private func runLogoTransition(to frame: CGRect, tintColor: UIColor) {
        cancelLogoAnimation()

        let snapshot = logoImgView.snapshotView(afterScreenUpdates: false)
        if let snapshot = snapshot {
            snapshot.frame = logoImgView.frame
            addSubview(snapshot)
        }

        logoSnapshotView = snapshot

        UIView.performWithoutAnimation {
            self.logoImgView.tintColor = tintColor
            self.logoImgView.alpha = 0
        }

        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
            snapshot?.alpha = 0
            self.logoImgView.alpha = 1
            self.logoImgView.frame = frame
        }

        animator.addCompletion { position in
            if position != .end {
                self.logoImgView.frame = frame
                self.logoImgView.alpha = 1
            }

            if let snapshot = snapshot, self.logoSnapshotView === snapshot {
                snapshot.removeFromSuperview()
                self.logoSnapshotView = nil
            }

            if self.logoTransitionAnimator === animator {
                self.logoTransitionAnimator = nil
            }
        }

        animator.startAnimation()
        logoTransitionAnimator = animator
    }

    private func cancelLogoAnimation() {
        if let animator = logoTransitionAnimator {
            animator.stopAnimation(true)
            logoTransitionAnimator = nil
        }

        if let snapshot = logoSnapshotView {
            snapshot.removeFromSuperview()
            logoSnapshotView = nil
        }

        logoImgView.alpha = 1
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
