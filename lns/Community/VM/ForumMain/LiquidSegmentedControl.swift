//
//  LiquidSegmentedControl.swift
//  lns
//
//  Created by LNS2 on 2025/10/15.
//

import UIKit

// MARK: - LiquidSegmentedControl

public final class LiquidSegmentedControl: UIControl {

    // MARK: Public API

    public struct Style {
        public var font: UIFont                     = .systemFont(ofSize: 16, weight: .semibold)
        public var normalColor: UIColor             = UIColor.label.withAlphaComponent(0.5)
        public var selectedColor: UIColor           = UIColor.label
        public var contentInsets: UIEdgeInsets      = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        public var itemSpacing: CGFloat             = 12
        public var trackCornerRadius: CGFloat       = 18
        public var selectedInset: UIEdgeInsets      = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2) // 胶囊相对 cell 的缩进
        public var distribution: Distribution       = .equalWidth  // .equalWidth 或 .byContent
        public var selectionAnimation: SelectionAnimation = .spring(damping: 0.72, velocity: 0.5, duration: 0.36)
        public var blurStyle: UIBlurEffect.Style    = .systemChromeMaterialLight
        // 选中胶囊的白色渐变（更像玻璃；可调强度）
        public var selectedGradientTopAlpha: CGFloat = 0.18
        public var selectedGradientBottomAlpha: CGFloat = 0.08
        // 顶部高光
        public var highlightTopAlpha: CGFloat = 0.35
        public var highlightEndLocation: CGFloat = 0.25
        // 阴影
        public var shadowColor: UIColor  = UIColor.black.withAlphaComponent(1.0)
        public var shadowOpacity: Float  = 0.12
        public var shadowRadius: CGFloat = 10
        public var shadowOffset: CGSize  = CGSize(width: 0, height: 6)
        // 背景轨道（可选：轻微蒙层）
        public var trackBackgroundColor: UIColor? = UIColor.secondarySystemBackground.withAlphaComponent(0.2)

        public enum Distribution { case equalWidth, byContent }
        public enum SelectionAnimation {
            case none
            case spring(damping: CGFloat, velocity: CGFloat, duration: TimeInterval)
            case ease(duration: TimeInterval)
        }

        public init() {}
    }

    public private(set) var items: [String] = []
    public var style: Style = Style() { didSet { applyStyle(); setNeedsLayout() } }

    /// 当前选中下标
    public private(set) var selectedIndex: Int = 0

    /// 闭包回调（除了 UIControl 的 .valueChanged 以外）
    public var onValueChanged: ((Int) -> Void)?

    /// 设置项目并可选默认选中项
    public func setItems(_ items: [String], selectedIndex: Int = 0) {
        self.items = items
        rebuildLabels()
        setSelectedIndex(selectedIndex, animated: false, sendEvent: false)
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    /// 代码切换选中项
    public func setSelectedIndex(_ index: Int, animated: Bool, sendEvent: Bool = true) {
        let idx = max(0, min(index, items.count - 1))
        guard idx != selectedIndex || animated else {
            selectedIndex = idx
            updateLabelColors()
            moveSelectedPill(to: idx, animated: animated)
            return
        }
        selectedIndex = idx
        updateLabelColors()
        moveSelectedPill(to: idx, animated: animated)
        if sendEvent {
            sendActions(for: .valueChanged)
            onValueChanged?(idx)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    // MARK: Init

    public init(items: [String], style: Style = Style()) {
        self.style = style
        super.init(frame: .zero)
        commonInit()
        setItems(items, selectedIndex: 0)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: Private views

    private let trackView = UIView() // 轨道背景（可带蒙层圆角）
    private var labels: [UILabel] = []
    private var tapGR: UITapGestureRecognizer!
    private var panGR: UIPanGestureRecognizer!

    // 选中胶囊（液态玻璃）
    private lazy var selectedPill: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: style.blurStyle))
        v.isUserInteractionEnabled = false
        v.clipsToBounds = true

        // 白色渐变
        let g = CAGradientLayer()
        g.startPoint = CGPoint(x: 0.5, y: 0.0)
        g.endPoint   = CGPoint(x: 0.5, y: 1.0)
        v.contentView.layer.addSublayer(g)

        // 顶部高光
        let hi = CAGradientLayer()
        hi.startPoint = CGPoint(x: 0.5, y: 0.0)
        hi.endPoint   = CGPoint(x: 0.5, y: 1.0)
        v.contentView.layer.addSublayer(hi)

        // 阴影
        v.layer.shadowColor = style.shadowColor.cgColor
        v.layer.shadowOpacity = style.shadowOpacity
        v.layer.shadowRadius = style.shadowRadius
        v.layer.shadowOffset = style.shadowOffset

        // 存引用
        v.contentView.layer.setValue(g,  forKey: "gradient")
        v.contentView.layer.setValue(hi, forKey: "highlight")
        return v
    }()

    // MARK: Setup

    private func commonInit() {
        backgroundColor = .clear

        addSubview(trackView)
        trackView.layer.masksToBounds = false

        // 手势
        tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGR)
        panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGR)

        // 初始样式
        applyStyle()

        // 层级：pill 在最底，文字在上
        addSubview(selectedPill)
    }

    private func applyStyle() {
        trackView.layer.cornerRadius = style.trackCornerRadius
        trackView.backgroundColor = style.trackBackgroundColor

        labels.forEach { lbl in
            lbl.font = style.font
        }

        updateLabelColors()
        updateSelectedPillAppearance()
    }

    private func updateSelectedPillAppearance() {
        if let g = selectedPill.contentView.layer.value(forKey: "gradient") as? CAGradientLayer {
            g.colors = [
                UIColor.white.withAlphaComponent(style.selectedGradientTopAlpha).cgColor,
                UIColor.white.withAlphaComponent(style.selectedGradientBottomAlpha).cgColor
            ]
            g.locations = [0.0, 1.0]
        }
        if let hi = selectedPill.contentView.layer.value(forKey: "highlight") as? CAGradientLayer {
            hi.colors = [
                UIColor.white.withAlphaComponent(style.highlightTopAlpha).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor
            ]
            hi.locations = [0.0, NSNumber(value: Double(style.highlightEndLocation))]
        }
        selectedPill.layer.shadowColor   = style.shadowColor.cgColor
        selectedPill.layer.shadowOpacity = style.shadowOpacity
        selectedPill.layer.shadowRadius  = style.shadowRadius
        selectedPill.layer.shadowOffset  = style.shadowOffset
    }

    private func rebuildLabels() {
        labels.forEach { $0.removeFromSuperview() }
        labels.removeAll()
        for (i, text) in items.enumerated() {
            let lbl = UILabel()
            lbl.text = text
            lbl.font = style.font
            lbl.textAlignment = .center
            lbl.adjustsFontSizeToFitWidth = true
            lbl.minimumScaleFactor = 0.8
            lbl.isUserInteractionEnabled = false
            lbl.accessibilityTraits = .button
            lbl.accessibilityLabel = text
            addSubview(lbl)
            labels.append(lbl)

            // 让 VoiceOver 能报出选中状态
            if i == selectedIndex { lbl.accessibilityTraits.insert(.selected) }
        }
        updateLabelColors()
        setNeedsLayout()
    }

    private func updateLabelColors() {
        for (i, lbl) in labels.enumerated() {
            if i == selectedIndex {
                lbl.textColor = style.selectedColor
                lbl.accessibilityTraits.insert(.selected)
            } else {
                lbl.textColor = style.normalColor
                lbl.accessibilityTraits.remove(.selected)
            }
        }
    }

    // MARK: Layout

    public override var intrinsicContentSize: CGSize {
        guard !items.isEmpty else { return CGSize(width: UIView.noIntrinsicMetric, height: 44) }
        // 估一个高度：字体 + 内边距
        let h = style.font.lineHeight + style.contentInsets.top + style.contentInsets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: ceil(h))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        // Track
        let trackFrame = bounds.inset(by: style.contentInsets)
        trackView.frame = trackFrame
        trackView.layer.cornerRadius = min(style.trackCornerRadius, trackFrame.height/2)

        // 计算每个 item 的 frame
        let itemFrames = computeItemFrames(in: trackFrame)

        // 布局 label
        for (i, frame) in itemFrames.enumerated() {
            labels[i].frame = frame
        }

        // 让胶囊对齐选中项
        moveSelectedPill(to: selectedIndex, animated: false)
    }

    private func computeItemFrames(in track: CGRect) -> [CGRect] {
        guard !items.isEmpty else { return [] }

        switch style.distribution {
        case .equalWidth:
            let count = CGFloat(items.count)
            let totalSpacing = style.itemSpacing * (count - 1)
            let cellW = max(0, (track.width - totalSpacing) / count)
            var x = track.minX
            return (0..<items.count).map { _ in
                let f = CGRect(x: x, y: track.minY, width: cellW, height: track.height).integral
                x += cellW + style.itemSpacing
                return f
            }

        case .byContent:
            // 按内容计算宽度
            var frames: [CGRect] = []
            var x = track.minX
            for lbl in labels {
                let w = lbl.intrinsicContentSize.width
                let paddedW = w + 16 // 给文字左右各加 8 的安全边距
                let f = CGRect(x: x, y: track.minY, width: paddedW, height: track.height).integral
                frames.append(f)
                x += paddedW + style.itemSpacing
            }
            // 若总宽超出，回退为等宽以避免溢出
            if x - style.itemSpacing > track.maxX {
                return computeItemFrames(in: track.insetBy(dx: 0, dy: 0)).map { $0 }
            }
            // 居中分布
            let used = (frames.last?.maxX ?? track.minX) - track.minX
            let offset = (track.width - used + style.itemSpacing) / 2
            return frames.map { $0.offsetBy(dx: offset, dy: 0) }
        }
    }

    // MARK: Interactions

    @objc private func handleTap(_ gr: UITapGestureRecognizer) {
        let p = gr.location(in: self)
        guard let idx = index(at: p) else { return }
        setSelectedIndex(idx, animated: true)
    }

    @objc private func handlePan(_ gr: UIPanGestureRecognizer) {
        let p = gr.location(in: self)
        switch gr.state {
        case .began, .changed:
            if let idx = index(at: p), idx != selectedIndex {
                // 拖动切换：轻微缩放增强“液态”感
                selectedPill.transform = CGAffineTransform(scaleX: 1.06, y: 0.98)
                setSelectedIndex(idx, animated: true)
            }
        default:
            UIView.animate(withDuration: 0.18) { self.selectedPill.transform = .identity }
        }
    }

    private func index(at point: CGPoint) -> Int? {
        for (i, lbl) in labels.enumerated() {
            if lbl.frame.inset(by: UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)).contains(point) {
                return i
            }
        }
        return nil
    }

    // MARK: Selected pill move

    private func pillFrame(for index: Int) -> CGRect {
        guard index >= 0, index < labels.count else { return .zero }
        let cell = labels[index].frame
        let inset = style.selectedInset
        let f = cell.inset(by: inset)
        return f.integral
    }

    private func moveSelectedPill(to index: Int, animated: Bool) {
        guard !labels.isEmpty else { return }
        let target = pillFrame(for: index)
        let r = min(target.height/2, style.trackCornerRadius)

        let apply = {
            self.selectedPill.frame = target
            self.selectedPill.layer.cornerRadius = r
            if let g = self.selectedPill.contentView.layer.value(forKey: "gradient") as? CAGradientLayer,
               let h = self.selectedPill.contentView.layer.value(forKey: "highlight") as? CAGradientLayer {
                g.frame = self.selectedPill.bounds
                h.frame = self.selectedPill.bounds
            }
        }

        if selectedPill.superview == nil { insertSubview(selectedPill, belowSubview: labels.first!) }

        guard animated else { apply(); return }

        switch style.selectionAnimation {
        case .none:
            apply()

        case .ease(let duration):
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState], animations: {
                self.selectedPill.transform = CGAffineTransform(scaleX: 1.06, y: 0.98)
                apply()
            }, completion: { _ in
                UIView.animate(withDuration: 0.18) { self.selectedPill.transform = .identity }
            })

        case .spring(let damping, let velocity, let duration):
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: damping,
                           initialSpringVelocity: velocity,
                           options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut],
                           animations: {
                               self.selectedPill.transform = CGAffineTransform(scaleX: 1.06, y: 0.98)
                               apply()
                           }, completion: { _ in
                               UIView.animate(withDuration: 0.18) { self.selectedPill.transform = .identity }
                           })
        }
    }
}
