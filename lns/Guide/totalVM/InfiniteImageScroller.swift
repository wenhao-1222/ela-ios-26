//
//  InfiniteImageScroller.swift
//  lns
//
//  Created by Elavatine on 2025/6/9.
//

import UIKit

/// 滚动方向
public enum ScrollDirection {
    case left
    case right
}

public class InfiniteImageScroller: UIView {
    // MARK: - Public 属性
    public var speed: CGFloat                   // 每秒滚动点数
    public var direction: ScrollDirection       // 滚动方向

    // MARK: - 私有属性
    private let imageView1 = UIImageView()
    private let imageView2 = UIImageView()
    private var displayLink: CADisplayLink?
    private var imageWidth: CGFloat = 0
    private let initialProgress: CGFloat
    private var scrollProgress: CGFloat

    // MARK: - 初始化
    /// - Parameters:
    ///   - frame: 视图的 frame
    ///   - imageName: 要滚动的图片名称
    ///   - direction: 滚动方向（.left 或 .right）
    ///   - speed: 滚动速度（pt/s）
    ///   - initialProgress: 初始滚动进度，按单张图片宽度比例计算，`0...1` 表示从图片哪个位置开始
    public init(frame: CGRect,
                imageName: String,
                direction: ScrollDirection = .left,
                speed: CGFloat = 50,
                initialProgress: CGFloat = 0)
    {
        self.direction = direction
        self.speed = speed
        let normalizedProgress = Self.normalizedProgress(initialProgress)
        self.initialProgress = normalizedProgress
        self.scrollProgress = normalizedProgress
        super.init(frame: frame)
        setupImageViews(imageName: imageName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) 尚未实现")
    }

    // MARK: - 布局
    public override func layoutSubviews() {
        super.layoutSubviews()
        // 确保 imageView 高度与容器相同，宽度按图片宽度
        let imgSize = imageView1.image?.size
        imageWidth = (imgSize?.width ?? 0) / (imgSize?.height ?? 1) * self.bounds.height
        if displayLink == nil {
            scrollProgress = initialProgress
        }
        applyImageFrames()
    }

    // MARK: - 私有方法
    private func setupImageViews(imageName: String) {
        guard let image = UIImage(named: imageName) else {
            assertionFailure("未能加载图片：\(imageName)")
            return
        }
        imageView1.image = image
        imageView2.image = image
        imageView1.contentMode = .scaleAspectFill
        imageView2.contentMode = .scaleAspectFill
        clipsToBounds = true
        addSubview(imageView1)
        addSubview(imageView2)
    }

    @objc private func step(_ link: CADisplayLink) {
        guard imageWidth > 0 else { return }
        let deltaProgress = CGFloat(link.duration) * speed / imageWidth
        let progressDelta = direction == .left ? deltaProgress : -deltaProgress
        scrollProgress = Self.normalizedProgress(scrollProgress + progressDelta)
        applyImageFrames()
    }

    // MARK: - 公有方法
    /// 开始滚动（如果已在滚动则无效）
    public func startScrolling() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// 暂停滚动
    public func pauseScrolling() {
        displayLink?.isPaused = true
    }

    /// 继续滚动
    public func resumeScrolling() {
        displayLink?.isPaused = false
    }

    /// 停止并销毁滚动
    public func stopScrolling() {
        displayLink?.invalidate()
        displayLink = nil
    }

    deinit {
        stopScrolling()
    }
}

private extension InfiniteImageScroller {
    static func normalizedProgress(_ progress: CGFloat) -> CGFloat {
        let normalized = progress.truncatingRemainder(dividingBy: 1)
        return normalized >= 0 ? normalized : normalized + 1
    }

    func applyImageFrames() {
        let height = bounds.height
        let offset = imageWidth * scrollProgress
        imageView1.frame = CGRect(x: -offset, y: 0, width: imageWidth, height: height)
        imageView2.frame = CGRect(x: imageView1.frame.maxX, y: 0, width: imageWidth, height: height)
    }
}
