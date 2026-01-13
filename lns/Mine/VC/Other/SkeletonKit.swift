//
//  SkeletonKit.swift
//  lns
//
//  Created by Elavatine on 2025/8/15.
//

import UIKit

// MARK: - 配置对象（可按需扩展）
public struct SkeletonConfig {
    public var baseColorLight: UIColor
    public var highlightColorLight: UIColor
    public var baseColorDark: UIColor
    public var highlightColorDark: UIColor
    public var cornerRadius: CGFloat
    public var shimmerWidth: CGFloat      // 0~1，高亮带宽占比
    public var shimmerDuration: CFTimeInterval
    public var skeletonFadeInDuration: TimeInterval
    public var contentFadeInDuration: TimeInterval

    public init(
        baseColorLight: UIColor = UIColor(white: 0.8, alpha: 0.5),
        highlightColorLight: UIColor = UIColor(white: 0.05, alpha: 0.55),
        baseColorDark: UIColor = UIColor(white: 0.8, alpha: 0.5),
        highlightColorDark: UIColor = UIColor(white: 0.08, alpha: 0.55),
        cornerRadius: CGFloat = 10,
        shimmerWidth: CGFloat = 0.1,
        shimmerDuration: CFTimeInterval = 1.2,
        skeletonFadeInDuration: TimeInterval = 0.18,
        contentFadeInDuration: TimeInterval = 0.22
    ) {
        self.baseColorLight = baseColorLight
        self.highlightColorLight = highlightColorLight
        self.baseColorDark = baseColorDark
        self.highlightColorDark = highlightColorDark
        self.cornerRadius = cornerRadius
        self.shimmerWidth = max(0.05, min(shimmerWidth, 0.6))
        self.shimmerDuration = max(0.6, shimmerDuration)
        self.skeletonFadeInDuration = max(0.0, skeletonFadeInDuration)
        self.contentFadeInDuration = max(0.0, contentFadeInDuration)
    }

    func baseColor(for traits: UITraitCollection) -> UIColor {
        return traits.userInterfaceStyle == .dark ? baseColorDark : baseColorLight
    }
    func highlightColor(for traits: UITraitCollection) -> UIColor {
        return traits.userInterfaceStyle == .dark ? highlightColorDark : highlightColorLight
    }
}

// MARK: - 内部骨架视图
final class _SkeletonView: UIView {
    private let gradientLayer = CAGradientLayer()
    private var config: SkeletonConfig
    private var isAnimating = false

    init(frame: CGRect, config: SkeletonConfig, traits: UITraitCollection) {
        self.config = config
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        accessibilityElementsHidden = true

        layer.masksToBounds = true
        layer.cornerRadius = config.cornerRadius

//        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.45)
        gradientLayer.colors = [
            config.baseColor(for: traits).cgColor,
            config.highlightColor(for: traits).cgColor,
            config.baseColor(for: traits).cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let prev = previousTraitCollection,
              prev.userInterfaceStyle != traitCollection.userInterfaceStyle
        else { return }
        gradientLayer.colors = [
            config.baseColor(for: traitCollection).cgColor,
            config.highlightColor(for: traitCollection).cgColor,
            config.baseColor(for: traitCollection).cgColor
        ]
    }

    func start(with config: SkeletonConfig) {
        guard !isAnimating else { return }
        isAnimating = true

        // 从左到右：移动整个渐变层
//        let anim = CABasicAnimation(keyPath: "transform.translation.x")
//        anim.fromValue = -bounds.width
//        anim.toValue = bounds.width
        let anim = CABasicAnimation(keyPath: "locations")
        anim.fromValue = [-1.0, -0.5, 0.0]
        anim.toValue   = [ 1.0,  1.5, 2.0]
        anim.duration = config.shimmerDuration
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.repeatCount = .infinity
        gradientLayer.add(anim, forKey: "skeleton.shimmer")

        // 初次渐入
        alpha = 0
        UIView.animate(withDuration: config.skeletonFadeInDuration) {
            self.alpha = 1
        }
    }

    func stop() {
        isAnimating = false
        gradientLayer.removeAnimation(forKey: "skeleton.shimmer")
    }
}

// MARK: - UIView 扩展：一行集成
public extension UIView {

    private struct _Assoc {
        static var skViewKey = "_skViewKey"
        static var skConfigKey = "_skConfigKey"
        static var skWasHiddenKey = "_skWasHiddenKey"
    }

    /// 是否正在显示骨架
    var isSkeletonActive: Bool {
        return (objc_getAssociatedObject(self, &_Assoc.skViewKey) as? _SkeletonView) != nil
    }

    /// 显示骨架（覆盖在当前 view 上）
    func showSkeleton(_ config: SkeletonConfig = SkeletonConfig()) {
        guard (objc_getAssociatedObject(self, &_Assoc.skViewKey) as? _SkeletonView) == nil else { return }

        let sk = _SkeletonView(frame: bounds, config: config, traits: traitCollection)
        sk.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(sk)
        bringSubviewToFront(sk)

        objc_setAssociatedObject(self, &_Assoc.skViewKey, sk, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &_Assoc.skConfigKey, config, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &_Assoc.skWasHiddenKey, self.isHidden, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 避免底层真实内容与骨架同时“强可见”，可按需降低透明度
        // 注意：不要把 self.alpha 降太低，以免影响交互区域。这里不动 alpha，只交给上层控制。
        sk.start(with: config)
    }

    /// 隐藏骨架 + 内容淡入（crossfade）
    func hideSkeletonWithCrossfade() {
        guard let sk = objc_getAssociatedObject(self, &_Assoc.skViewKey) as? _SkeletonView else { return }
        let config = (objc_getAssociatedObject(self, &_Assoc.skConfigKey) as? SkeletonConfig) ?? SkeletonConfig()

        sk.stop()
        // 先淡出骨架
        UIView.animate(withDuration: config.skeletonFadeInDuration, animations: {
            sk.alpha = 0
        }, completion: { _ in
            sk.removeFromSuperview()
        })

        objc_setAssociatedObject(self, &_Assoc.skViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 内容淡入
        UIView.transition(with: self,
                          duration: config.contentFadeInDuration,
                          options: .transitionCrossDissolve,
                          animations: { self.alpha = 1 },
                          completion: nil)
    }

    /// 立即移除骨架（无动画）
    func removeSkeletonImmediately() {
        if let sk = objc_getAssociatedObject(self, &_Assoc.skViewKey) as? _SkeletonView {
            sk.stop()
            sk.removeFromSuperview()
            objc_setAssociatedObject(self, &_Assoc.skViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 便捷：对一组子视图批量显示骨架
    func showSkeleton(on subviews: [UIView], config: SkeletonConfig = SkeletonConfig()) {
        subviews.forEach { $0.showSkeleton(config) }
    }

    /// 便捷：对一组子视图批量隐藏骨架 + 内容淡入
    func hideSkeletonWithCrossfade(on subviews: [UIView]) {
        subviews.forEach { $0.hideSkeletonWithCrossfade() }
    }
}

// MARK: - UITableView / UICollectionView 小帮手（可选）
public extension UITableView {
    /// 在加载中时常见做法：显示固定数量的“骨架行”（由真实 cell 布局决定）
    /// 做法：外部 DataSource 返回 loadingCount，cell 内部使用 showSkeleton/hideSkeleton。
    /// 这里给出一个便捷触发的 API（仅作为语义提示）。
    func reloadForSkeleton() {
        // 为了方便你在外部调用时表达“现在是 skeleton 刷新”
        // 实际实现保持空壳，直接 reloadData 即可。
        self.reloadData()
    }
}

public extension UICollectionView {
    func reloadForSkeleton() {
        self.reloadData()
    }
}
