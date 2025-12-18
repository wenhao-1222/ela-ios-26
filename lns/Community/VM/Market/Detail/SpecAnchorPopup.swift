//
//  SpecAnchorPopup.swift
//  lns
//
//  Created by Elavatine on 2025/9/10.
//

import UIKit

struct SpecOption {
    let id: String
    let title: String
    var inStock: Bool = true
}


final class SpecAnchorPopup: UIView {

    // MARK: - Public

    struct Config {
        var maxWidth: CGFloat = 260
        var maxHeight: CGFloat = 240
        var cornerRadius: CGFloat = 12
        var contentInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        var rowSpacing: CGFloat = 6
        var rowInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        var rowFont: UIFont = .systemFont(ofSize: 14)
        var textColor: UIColor = .COLOR_TEXT_TITLE_0f1214
        var disabledTextColor: UIColor = .COLOR_LINE_F0
        var bgColor: UIColor = .COLOR_CARD_BG_WHITE
        var arrowSize = CGSize(width: 16, height: kFitWidth(10)) // 底边=16，高=8
        var screenMargin: CGFloat = 12
        var shadowColor: UIColor = UIColor.black.withAlphaComponent(0.2)
        var shadowRadius: CGFloat = 12
        var shadowOpacity: Float = 1.0
        var shadowOffset: CGSize = .init(width: 0, height: 6)
        var separatorColor: UIColor = UIColor.black.withAlphaComponent(0.06)
        // 新增 👇
        var alignBubbleToLeft: Bool = true                // 是否固定左对齐
        var bubbleLeftMargin: CGFloat = kFitWidth(20)     // 弹窗距屏幕左侧
        var arrowLeftInset: CGFloat = kFitWidth(20)       // 箭头相对“弹窗左侧”的偏移
    }

    private let config: Config
    private let options: [SpecOption]
    private let onSelect: (Int, SpecOption) -> Void

    // 弹层包含一个“泡泡”容器和一个指向锚点的箭头
    private let bubble = UIView()
    private let stack = UIStackView()
    private let arrowLayer = CAShapeLayer()
    private let passthrough = UIButton(type: .custom) // 透明背景，用于点空白关闭

    private weak var anchorView: UIView?
    private weak var scrollViewToFollow: UIScrollView?
    private var kvo: NSKeyValueObservation?
    private var willShowBelow = true

    init(options: [SpecOption], config: Config = .init(), onSelect: @escaping (Int, SpecOption) -> Void) {
        self.options = options
        self.config = config
        self.onSelect = onSelect
        super.init(frame: .zero)
        setup()
    }
    deinit { kvo?.invalidate() }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        // 全屏遮罩
        addSubview(passthrough)
        passthrough.addTarget(self, action: #selector(dismiss), for: .touchUpInside)

        // 气泡
        bubble.backgroundColor = config.bgColor
        bubble.layer.cornerRadius = config.cornerRadius
        bubble.layer.masksToBounds = false
        bubble.layer.shadowColor = config.shadowColor.cgColor
        bubble.layer.shadowRadius = config.shadowRadius
        bubble.layer.shadowOpacity = config.shadowOpacity
        bubble.layer.shadowOffset = config.shadowOffset
        addSubview(bubble)

        // 内容
        stack.axis = .vertical
        stack.spacing = config.rowSpacing
        bubble.addSubview(stack)

        // 分隔线 & 文本项
        for (idx, opt) in options.enumerated() {
            let btn = makeRow(title: opt.title, enabled: opt.inStock)
            btn.tag = idx
            if idx > 0 {
                let line = UIView()
                line.backgroundColor = config.separatorColor
                stack.addArrangedSubview(line)
                line.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    line.heightAnchor.constraint(equalToConstant: 0.5)
                ])
            }
            stack.addArrangedSubview(btn)
        }

        // 箭头
        arrowLayer.fillColor = config.bgColor.cgColor
        layer.addSublayer(arrowLayer)
    }

    private func makeRow(title: String, enabled: Bool) -> UIButton {
        let b = UIButton(type: .system)
        b.contentEdgeInsets = config.rowInsets
        b.titleLabel?.font = config.rowFont
        b.titleLabel?.numberOfLines = 0
        b.titleLabel?.lineBreakMode = .byWordWrapping
        b.setTitle(title, for: .normal)
        b.setTitleColor(enabled ? config.textColor : config.disabledTextColor, for: .normal)
//        b.isEnabled = enabled
        b.contentHorizontalAlignment = .left
        b.addTarget(self, action: #selector(onTapRow(_:)), for: .touchUpInside)
        return b
    }

    // MARK: - Show / Dismiss

    /// 显示在某个锚点视图附近，并自动判断在其「上/下」摆放。
    func show(from anchorView: UIView, in container: UIView, follow scrollView: UIScrollView? = nil) {
        self.anchorView = anchorView
        self.scrollViewToFollow = scrollView

        frame = container.bounds
        container.addSubview(self)

        passthrough.frame = bounds

        layoutNow()               // 先布局一次
        trackScrollIfNeeded()     // 监听滚动，保持跟随
        NotificationCenter.default.addObserver(self, selector: #selector(layoutNow),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)

        alpha = 0
        bubble.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
            self.alpha = 1
            self.bubble.transform = .identity
        }
    }

    @objc func dismiss() {
        NotificationCenter.default.removeObserver(self)
        kvo?.invalidate()
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
            self.bubble.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            self.removeFromSuperview()
        }
    }

    // MARK: - Actions

    @objc private func onTapRow(_ sender: UIButton) {
        let idx = sender.tag
        guard idx >= 0 && idx < options.count else { return }
        let option = options[idx]
//        guard option.inStock else { return }
        onSelect(idx, option)
        dismiss()
    }

    // MARK: - Layout / Follow

    @objc private func layoutNow() {
        guard let anchor = anchorView, let host = superview else { return }

        // 1) 计算内容最大宽度并让行文本可换行
        let maxContentWidth = config.maxWidth - (config.contentInsets.left + config.contentInsets.right)
        for view in stack.arrangedSubviews {
            if let b = view as? UIButton {
                b.titleLabel?.numberOfLines = 0
                b.titleLabel?.lineBreakMode = .byWordWrapping
                b.titleLabel?.preferredMaxLayoutWidth = maxContentWidth - (config.rowInsets.left + config.rowInsets.right)
            }
        }

        // 2) 计算气泡尺寸
        stack.translatesAutoresizingMaskIntoConstraints = true
        bubble.translatesAutoresizingMaskIntoConstraints = true

        let targetStackSize = stack.systemLayoutSizeFitting(
            CGSize(width: maxContentWidth, height: CGFloat.greatestFiniteMagnitude),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let bubbleW = min(config.maxWidth, targetStackSize.width + config.contentInsets.left + config.contentInsets.right)
        let bubbleH = min(config.maxHeight, targetStackSize.height + config.contentInsets.top + config.contentInsets.bottom)

        // 3) 锚点坐标
        let anchorRect = anchor.convert(anchor.bounds, to: host)

        // 4) 判断显示在上/下
        let spaceAbove = anchorRect.minY - config.screenMargin
        let spaceBelow = host.bounds.height - anchorRect.maxY - config.screenMargin
        willShowBelow = (spaceBelow >= bubbleH + config.arrowSize.height) || (spaceBelow >= spaceAbove)

        // 5) 计算气泡位置（左对齐）
        let arrowH = config.arrowSize.height
        var bubbleX: CGFloat
        if config.alignBubbleToLeft {
            // 弹窗靠屏幕左侧 kFitWidth(20)
            bubbleX = max(config.screenMargin,
                          min(config.bubbleLeftMargin, host.bounds.width - config.screenMargin - bubbleW))
        } else {
            bubbleX = anchorRect.midX - bubbleW / 2
            bubbleX = max(config.screenMargin, min(bubbleX, host.bounds.width - config.screenMargin - bubbleW))
        }

        var bubbleY: CGFloat
        if willShowBelow {
            bubbleY = anchorRect.maxY + arrowH
        } else {
            bubbleY = anchorRect.minY - arrowH - bubbleH
        }

        // 6) 布局泡泡与内容
        bubble.frame = CGRect(x: bubbleX, y: bubbleY, width: bubbleW, height: bubbleH)
        stack.frame = CGRect(
            x: config.contentInsets.left,
            y: config.contentInsets.top,
            width: bubbleW - config.contentInsets.left - config.contentInsets.right,
            height: bubbleH - config.contentInsets.top - config.contentInsets.bottom
        )
        // 准确的阴影路径，避免阴影渲染造成边缘色差
        bubble.layer.shadowPath = UIBezierPath(
            roundedRect: bubble.bounds,
            cornerRadius: config.cornerRadius
        ).cgPath
        // 7) 绘制箭头
        drawArrow(pointingTo: anchorRect, bubbleFrame: bubble.frame, below: willShowBelow)
    }
    private func drawArrow(pointingTo anchorRect: CGRect, bubbleFrame: CGRect, below: Bool) {
        let arrowW = config.arrowSize.width
        let arrowH = config.arrowSize.height

        // 让三角形与白色气泡重叠 1px（按屏幕 scale 计算），避免夹缝透底色
        let overlap: CGFloat = 1.0 / UIScreen.main.scale

        // 箭头水平中心：优先使用“距弹窗左侧 kFitWidth(16)”；并 clamp 到圆角内侧
        let minX = bubbleFrame.minX + config.cornerRadius + 6
        let maxX = bubbleFrame.maxX - config.cornerRadius - 6

        var centerX: CGFloat
        if config.alignBubbleToLeft {
            centerX = bubbleFrame.minX + config.arrowLeftInset
        } else {
            centerX = anchorRect.midX
        }
        centerX = max(minX, min(maxX, centerX))

        // 像素对齐，减少半像素导致的缝隙
        func pixelRound(_ v: CGFloat) -> CGFloat {
            let scale = UIScreen.main.scale
            return round(v * scale) / scale
        }
        centerX = pixelRound(centerX)

        let x0 = pixelRound(centerX - arrowW / 2)
        let x1 = pixelRound(centerX + arrowW / 2)

        let path = UIBezierPath()
        if below {
            // 箭头在上边，尖头向上：底边与泡泡上边重叠 overlap
            let topY = pixelRound(bubbleFrame.minY) - arrowH + overlap
            path.move(to: CGPoint(x: x0, y: topY + arrowH))
            path.addLine(to: CGPoint(x: centerX, y: topY))
            path.addLine(to: CGPoint(x: x1, y: topY + arrowH))
        } else {
            // 箭头在下边，尖头向下：底边与泡泡下边重叠 overlap
            let bottomY = pixelRound(bubbleFrame.maxY) + arrowH - overlap
            path.move(to: CGPoint(x: x0, y: bottomY - arrowH))
            path.addLine(to: CGPoint(x: centerX, y: bottomY))
            path.addLine(to: CGPoint(x: x1, y: bottomY - arrowH))
        }
        path.close()

        // 绘制属性
        arrowLayer.path = path.cgPath
        arrowLayer.fillColor = config.bgColor.cgColor
        arrowLayer.lineWidth = 0       // 不描边，避免边线显缝
        arrowLayer.lineJoin = .round
        arrowLayer.lineCap = .round

        // 与气泡一致的阴影（使用精确阴影路径，避免发散影响边缘）
        arrowLayer.shadowColor = config.shadowColor.cgColor
        arrowLayer.shadowOpacity = config.shadowOpacity
        arrowLayer.shadowOffset = config.shadowOffset
        arrowLayer.shadowRadius = config.shadowRadius
        arrowLayer.shadowPath = path.cgPath

        // 确保箭头在泡泡之上渲染（避免阴影被泡泡遮）
        arrowLayer.zPosition = bubble.layer.zPosition + 1
    }

    private func trackScrollIfNeeded() {
        guard let scroll = scrollViewToFollow else { return }
        kvo = scroll.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
            // 跟随锚点移动
            self?.layoutNow()
        }
    }
}
