//
//  TagRowView.swift
//  lns
//
//  Created by Elavatine on 2025/8/27.
//
import UIKit

// MARK: - 外观配置
public struct TagRowAppearance {
    /// 标签文字字体（比如“刚好”、“聚餐”）
    public var chipFont: UIFont = .systemFont(ofSize: 12, weight: .regular)
    /// 左侧标题文字字体（比如“饱腹感”、“用餐场景”）
    public var titleFont: UIFont = .systemFont(ofSize: 12, weight: .medium)
    /// 左侧标题文字颜色（比如“饱腹感”、“用餐场景”）
    public var titleColor: UIColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
    /// 标签默认（未选中）背景色
    public var chipNormalBG: UIColor = .COLOR_BG_F5
    /// 标签默认（未选中）文字颜色
    public var chipNormalText: UIColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
    /// 标签选中时的背景色
    public var chipSelectedBG: UIColor = UIColor.THEME
    /// 标签选中时的文字颜色
    public var chipSelectedText: UIColor = UIColor.COLOR_BG_WHITE
    /// 标签默认（未选中）边框颜色
    public var chipBorderColor: UIColor = UIColor.clear
    /// 标签选中时的边框颜色
    public var chipSelectedBorderColor: UIColor = UIColor.clear
    /// 标签圆角半径（仅在没有固定高度时使用；固定高度时会被“高度的一半”覆盖）
    public var chipCornerRadius: CGFloat = kFitWidth(14)
    /// 标签内容的内边距（决定文字和边框的间距，上下左右）
    public var chipContentInsets: NSDirectionalEdgeInsets = .init(top: kFitWidth(5), leading:kFitWidth(12), bottom: kFitWidth(5), trailing: kFitWidth(12))
    /// 标签之间的间距
    public var chipSpacing: CGFloat = kFitWidth(12)
    /// 整行左/右内边距
    public var rowHorizontalPadding: CGFloat = kFitWidth(16)
    /// 整行上下内边距（固定高度时可设为 0 让标签更高）
    public var rowVerticalPadding: CGFloat = 0
    /// 滚动区域的额外内边距（影响横向滑动两端的留白）
    public var scrollContentInset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 16)

    public init() {}
}

// MARK: - 单个 Chip 按钮
final class TagChipButton: UIButton {
    var appearance = TagRowAppearance() { didSet { applyAppearance() } }
    /// 当所在行使用固定高度时，行会把计算好的 chipHeight 传递进来
    var enforcedHeight: CGFloat? { didSet { updateHeightAndCorner() } }

    private var heightConstraint: NSLayoutConstraint?

    override var isSelected: Bool { didSet { applyAppearance() } }

    init(title: String, appearance: TagRowAppearance) {
        self.appearance = appearance
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = appearance.chipFont
        clipsToBounds = true
        layer.cornerRadius = appearance.chipCornerRadius
        contentEdgeInsets = UIEdgeInsets(top: appearance.chipContentInsets.top,
                                         left: appearance.chipContentInsets.leading,
                                         bottom: appearance.chipContentInsets.bottom,
                                         right: appearance.chipContentInsets.trailing)
        applyAppearance()
        // 提高点击区域可用性
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .horizontal)
        accessibilityTraits.insert(.button)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func applyAppearance() {
        let bg = isSelected ? appearance.chipSelectedBG : appearance.chipNormalBG
        let fg = isSelected ? appearance.chipSelectedText : appearance.chipNormalText
        let border = isSelected ? appearance.chipSelectedBorderColor : appearance.chipBorderColor

        UIView.animate(withDuration: 0.15, delay: 0,options: .curveEaseInOut) {
            self.backgroundColor = bg
        }
        
        setTitleColor(fg, for: .normal)
        layer.borderColor = border.cgColor
        layer.borderWidth = border == .clear ? 0 : 1

        updateHeightAndCorner()
    }

    private func updateHeightAndCorner() {
        // 如果外部指定了固定高度 -> 按钮高度 = 指定值；圆角 = 高度一半
        if let h = enforcedHeight, h > 0 {
            if heightConstraint == nil {
                heightConstraint = heightAnchor.constraint(equalToConstant: h)
                heightConstraint?.isActive = true
            }
            heightConstraint?.constant = h
            layer.cornerRadius = kFitWidth(14)//h * 0.5
        } else {
            // 没有固定高度：使用 appearance 的圆角，并移除高度约束
            heightConstraint?.isActive = false
            heightConstraint = nil
            layer.cornerRadius = appearance.chipCornerRadius
        }
        layoutIfNeeded()
    }
}

// MARK: - 行视图：左侧标题 + 右侧可横滑标签
public final class TagRowView: UIView {

    public enum SelectionMode { case single, multiple }

    // 对外回调：返回选中的 index 集合
    public var onSelectionChanged: (([Int]) -> Void)?

    public var appearance = TagRowAppearance() {
        didSet { applyAppearanceAndLayout() }
    }

    public var selectionMode: SelectionMode = .single

    // 对外：可选固定行高（例如 28）
    public var fixedHeight: CGFloat? {
        didSet { applyFixedHeight() }
    }

    // 内部视图
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private var buttons: [TagChipButton] = []
    private var rowHeightConstraint: NSLayoutConstraint?

    public init(title: String,
                items: [String] = [],
                selectionMode: SelectionMode = .single,
                appearance: TagRowAppearance = .init(),
                fixedHeight: CGFloat? = nil) {
        self.selectionMode = selectionMode
        self.appearance = appearance
        self.fixedHeight = fixedHeight
        super.init(frame: .zero)
        setupViews()
        setTitle(title)
        setItems(items)
        applyFixedHeight()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateHorizontalScrolling()
    }
    // 标题固定在左侧
    public func setTitle(_ title: String) {
        titleLabel.text = title
    }

    // 设置标签数据
    public func setItems(_ items: [String]) {
        // 清空旧的
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        // 创建新的 chip
        for (idx, text) in items.enumerated() {
            let chip = TagChipButton(title: text, appearance: appearance)
            chip.tag = idx
            chip.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
            buttons.append(chip)
            stackView.addArrangedSubview(chip)
        }

        // 让新的按钮应用固定高度
        propagateChipHeightIfNeeded()
        notifySelectionChanged()
        updateHorizontalScrolling()
    }
    private func updateHorizontalScrolling() {
        // 先完成一次布局，保证 contentSize 准确
        layoutIfNeeded()
        let contentW = scrollView.contentSize.width
        let visibleW = scrollView.bounds.width

        let needScroll = contentW > visibleW + 0.5  // 容错 0.5pt
        scrollView.isScrollEnabled = needScroll
        scrollView.alwaysBounceHorizontal = needScroll
        scrollView.showsHorizontalScrollIndicator = needScroll
    }

    // 选中某些索引（用于回显）
    public func select(indices: [Int]) {
        switch selectionMode {
        case .single:
            for (i, b) in buttons.enumerated() { b.isSelected = (i == indices.first) }
        case .multiple:
            for (i, b) in buttons.enumerated() { b.isSelected = indices.contains(i) }
        }
        notifySelectionChanged()
    }

    // 获取当前选中索引
    public func selectedIndices() -> [Int] {
        buttons.enumerated().compactMap { $0.element.isSelected ? $0.offset : nil }
    }

    // MARK: - Setup
    private func setupViews() {
        // 标题
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // 滚动 & Stack
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = false   // 禁止纵向弹性
        scrollView.alwaysBounceHorizontal = true  // 保留横向弹性
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        scrollView.isDirectionalLockEnabled = true // 手指斜滑时锁定为横向
        // 🔐 关键：锁定内容高度 = 可视高度
        let equalHeight = scrollView.contentLayoutGuide.heightAnchor
            .constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        equalHeight.priority = .required
        equalHeight.isActive = true
        
        stackView.axis = .horizontal
        stackView.spacing = appearance.chipSpacing
        stackView.alignment = .center
        stackView.distribution = .fillProportionally

        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // 行高度由内部内容撑开（若设置 fixedHeight 会替换）
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: appearance.rowHorizontalPadding),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: appearance.rowVerticalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -appearance.rowVerticalPadding),

            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: kFitWidth(83)),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // stackView 贴合 scroll 内容区域（水平扩展）
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 0),
//            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: appearance.rowHorizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -appearance.rowHorizontalPadding),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: appearance.rowVerticalPadding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -appearance.rowVerticalPadding),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, constant: -(appearance.rowVerticalPadding * 2))
        ])

        applyAppearanceAndLayout()
        isAccessibilityElement = false
    }

    private func applyAppearanceAndLayout() {
        titleLabel.font = appearance.titleFont
        titleLabel.textColor = appearance.titleColor
        scrollView.contentInset = appearance.scrollContentInset
        
        stackView.spacing = appearance.chipSpacing
        // 同步 chips 的 appearance
        buttons.forEach { $0.appearance = appearance }
        propagateChipHeightIfNeeded()
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func applyFixedHeight() {
        // 行高约束
        if let h = fixedHeight {
            if rowHeightConstraint == nil {
                rowHeightConstraint = heightAnchor.constraint(equalToConstant: h)
                rowHeightConstraint?.isActive = true
            }
            rowHeightConstraint?.constant = h
        } else {
            rowHeightConstraint?.isActive = false
            rowHeightConstraint = nil
        }
        propagateChipHeightIfNeeded()
        layoutIfNeeded()
    }

    /// 把“由行高计算出的 chip 高度”传递给每个按钮，并设为半圆角
    private func propagateChipHeightIfNeeded() {
        guard let rowH = fixedHeight else {
            buttons.forEach { $0.enforcedHeight = nil } // 回到自动高度
            return
        }
        let chipH = max(0, rowH - 2 * appearance.rowVerticalPadding)
        buttons.forEach { $0.enforcedHeight = chipH }
    }

    // MARK: - Actions
    @objc private func handleTap(_ sender: TagChipButton) {
        switch selectionMode {
        case .single:
            if sender.isSelected {
                sender.isSelected = false
            } else {
                buttons.forEach { $0.isSelected = ($0 === sender) }
            }
        case .multiple:
            sender.isSelected.toggle()
        }
        notifySelectionChanged()
    }

    private func notifySelectionChanged() {
        onSelectionChanged?(selectedIndices())
    }
}
// 在文件底部加扩展：
extension TagRowView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            // 🔧 关键：任何时候都不允许出现纵向偏移
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
        }
    }
}
