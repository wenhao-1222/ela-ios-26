//
//  FireworkParticlesBurst.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//

import UIKit

/// 播放 32 帧透明 PNG 粒子序列（frame_0000 ~ frame_0031）
/// - 一行调用：FireworkParticlesBurst.play(...)
public enum FireworkParticlesBurst {

    /// 播放一次（或循环）序列帧动画
    /// - Parameters:
    ///   - parent: 叠加到哪个 view 上
    ///   - center: 动画中心点（parent 坐标系）
    ///   - size: 动画显示尺寸（建议=徽章尺寸或略大）
    ///   - fps: 帧率（默认 15，接近你 gif 的节奏）
    ///   - loop: 是否循环（默认 false）
    ///   - autoRemove: 播放完自动从父视图移除（默认 true）
    ///   - bundle: 资源所在 bundle（默认 main）
    ///   - prefix: 文件名前缀（默认 "frame_"）
    ///   - frameCount: 帧数（默认 32）
    public static func play(in parent: UIView,
                            center: CGPoint,
                            size: CGSize,
                            fps: CGFloat = 15,
                            loop: Bool = false,
                            autoRemove: Bool = true,
                            bundle: Bundle = .main,
                            prefix: String = "frame_",
                            frameCount: Int = 32) {

        // 1) 加载帧（建议预加载，避免卡顿）
        let frames = loadFrames(bundle: bundle, prefix: prefix, frameCount: frameCount)
        guard !frames.isEmpty else {
            assertionFailure("FireworkParticlesBurst: 没找到帧资源。请确保已把 \(prefix)0000~\(prefix)\(String(format: "%04d", frameCount-1)).png 加入 Copy Bundle Resources 或 Asset Catalog。")
            return
        }

        // 2) 容器 view（方便定位 & 自动移除）
        let container = FireworkBurstView()
        container.isUserInteractionEnabled = false
        container.backgroundColor = .clear
        container.frame = CGRect(origin: .zero, size: size)
        container.center = center

        // 3) imageView 做序列帧动画
        let iv = container.imageView
        iv.frame = container.bounds
        iv.contentMode = .scaleToFill  // 如果你希望等比，改成 .scaleAspectFit
        iv.animationImages = frames
        iv.animationRepeatCount = loop ? 0 : 1
        iv.animationDuration = Double(frames.count) / Double(max(fps, 1))
        iv.startAnimating()

        parent.addSubview(container)

        // 4) 播完自动移除
        if autoRemove && !loop {
            let duration = iv.animationDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                container.removeFromSuperview()
            }
        }
    }

    // MARK: - Internal

    /// 优先用 UIImage(named:)（Asset Catalog / 主 bundle），找不到再用文件路径方式兜底
    private static func loadFrames(bundle: Bundle,
                                   prefix: String,
                                   frameCount: Int) -> [UIImage] {

        var images: [UIImage] = []
        images.reserveCapacity(frameCount)

        for i in 0..<frameCount {
            let name = "\(prefix)\(String(format: "%04d", i))"

            // 1) Asset Catalog / main bundle
            if let img = UIImage(named: name, in: bundle, compatibleWith: nil) {
                images.append(img)
                continue
            }

            // 2) Copy Bundle Resources（png 文件）
            if let url = bundle.url(forResource: name, withExtension: "png"),
               let data = try? Data(contentsOf: url),
               let img = UIImage(data: data, scale: UIScreen.main.scale) {
                images.append(img)
                continue
            }
        }

        return images
    }

    /// 简单容器
    private final class FireworkBurstView: UIView {
        let imageView = UIImageView()
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(imageView)
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            addSubview(imageView)
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            imageView.frame = bounds
        }
    }
}
