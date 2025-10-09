//
//  SpecSelectionView.swift
//  lns
//
//  Created by Elavatine on 2025/9/9.
//

import UIKit

// MARK: - 数据模型

public struct SpecItem: Hashable {
    public let id: String
    public let title: String
//    public init(id: String, title: String) {
//        self.id = id; self.title = title
//    }
    public let isEnabled: Bool
    
    public init(id: String, title: String, isEnabled: Bool = true) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
    }
}

public struct SpecGroup: Hashable {
    public let id: String
    public let title: String
    public let items: [SpecItem]
    public init(id: String = UUID().uuidString, title: String, items: [SpecItem]) {
        self.id = id; self.title = title; self.items = items
    }
}

// MARK: - 配置

public struct SpecConfig {
    public var interItemSpacing: CGFloat = 12
    public var lineSpacing: CGFloat = 12
    public var sectionInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    public var contentInsets: UIEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12) // tag 内边距
    public var tagMaxWidthRatio: CGFloat = 0.86 // 单个 tag 最大宽度=容器宽度*ratio，避免过宽
    public var tagCornerRadius: CGFloat = 10
    public var titleFont: UIFont = .systemFont(ofSize: 16, weight: .semibold)
    public var tagFont: UIFont = .systemFont(ofSize: 15)
    public var lineHeightMultiple: CGFloat = 1.5
    
    public init(
        interItemSpacing: CGFloat = 12,
        lineSpacing: CGFloat = 12,
        sectionInsets: UIEdgeInsets = .zero,
        contentInsets: UIEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12),
        tagMaxWidthRatio: CGFloat = 0.86,
        tagCornerRadius: CGFloat = 10,
        titleFont: UIFont = .systemFont(ofSize: 16, weight: .semibold),
        tagFont: UIFont = .systemFont(ofSize: 15),
        lineHeightMultiple: CGFloat = 1.5
    ) {
        self.interItemSpacing = interItemSpacing
        self.lineSpacing = lineSpacing
        self.sectionInsets = sectionInsets
        self.contentInsets = contentInsets
        self.tagMaxWidthRatio = tagMaxWidthRatio
        self.tagCornerRadius = tagCornerRadius
        self.titleFont = titleFont
        self.tagFont = tagFont
        self.lineHeightMultiple = lineHeightMultiple
    }
}

// MARK: - 标签计算工具（行高1.5、最大宽度限制、包裹布局）

private extension NSAttributedString {
    static func tagAttrString(_ text: String, font: UIFont, lineHeightMultiple: CGFloat) -> NSAttributedString {
            let ps = NSMutableParagraphStyle()
            // 中文更合适：逐字换行；英文也能正常回行
            ps.lineBreakMode = .byCharWrapping
            ps.lineHeightMultiple = lineHeightMultiple
            return NSAttributedString(string: text, attributes: [.font: font, .paragraphStyle: ps])
        }
}

private func measureTagSize(
    text: String,
    font: UIFont,
    lineHeightMultiple: CGFloat,
    maxWidth: CGFloat,
    contentInsets: UIEdgeInsets
) -> CGSize {
    let attr = NSAttributedString.tagAttrString(text, font: font, lineHeightMultiple: lineHeightMultiple)
    let limit = max(1, maxWidth - contentInsets.left - contentInsets.right)
    let rect = attr.boundingRect(
        with: CGSize(width: limit, height: .greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil
    )
    // 统一向上取整，避免 0.5 像素导致的截断
    let w = ceil(rect.width)  + contentInsets.left + contentInsets.right
    let h = ceil(rect.height) + contentInsets.top  + contentInsets.bottom
    return CGSize(width: min(maxWidth, w), height: h)
}

// 计算一组标签整体高度（换行排布）
private func flowHeight(
    sizes: [CGSize],
    containerWidth: CGFloat,
    interItem: CGFloat,
    lineSpacing: CGFloat,
    sectionInsets: UIEdgeInsets
) -> CGFloat {
    guard containerWidth > 0 else { return 0 }
    var x = sectionInsets.left
    var y: CGFloat = sectionInsets.top
    var lineHeight: CGFloat = 0
    let maxW = containerWidth - sectionInsets.left - sectionInsets.right
    
    for s in sizes {
        if x > sectionInsets.left, x + s.width > sectionInsets.left + maxW {
            // 换行
            y += lineHeight + lineSpacing
            x = sectionInsets.left
            lineHeight = 0
        }
        lineHeight = max(lineHeight, s.height)
        x += s.width + interItem
    }
    if !sizes.isEmpty { y += lineHeight }
    y += sectionInsets.bottom
    return ceil(y)
}

// MARK: - Tag Cell
private final class TagCell: UICollectionViewCell {
    static let reuseId = "TagCell"

    private let label = UILabel()
    private var cfg: SpecConfig!

    // 约束句柄，用于动态修改内边距
    private var topC: NSLayoutConstraint!
    private var leftC: NSLayoutConstraint!
    private var bottomC: NSLayoutConstraint!
    private var rightC: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        contentView.backgroundColor = UIColor(white: 0.96, alpha: 1)

        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        // 先给默认值，实际以 config.contentInsets 为准
        topC    = label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        leftC   = label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12)
        bottomC = label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        rightC  = label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12)
        NSLayoutConstraint.activate([topC, leftC, bottomC, rightC])
    }
    required init?(coder: NSCoder) { fatalError() }

    func apply(text: String, selected: Bool, enabled: Bool, config: SpecConfig) {
        self.cfg = config

        // 同步内边距 = config.contentInsets（关键）
        topC.constant    = config.contentInsets.top
        leftC.constant   = config.contentInsets.left
        bottomC.constant = -config.contentInsets.bottom
        rightC.constant  = -config.contentInsets.right

        label.attributedText = .tagAttrString(
            text,
            font: config.tagFont,
            lineHeightMultiple: config.lineHeightMultiple
        )

//        label.textColor = selected ? .THEME : .COLOR_TEXT_TITLE_0f1214
//        contentView.backgroundColor = selected ? .COLOR_BUTTON_HIGHLIGHT_BG_THEME_10 : UIColor.COLOR_BG_F2
//        contentView.layer.borderColor = selected ? UIColor.THEME.cgColor
//                                                 : UIColor.COLOR_BG_F2.cgColor
        if !enabled {
            label.textColor = .COLOR_TEXT_TITLE_0f1214_25
            contentView.backgroundColor = UIColor.COLOR_BG_F2
            contentView.layer.borderColor = UIColor.COLOR_BG_F2.cgColor
            contentView.alpha = 0.5
        } else {
            label.textColor = selected ? .THEME : .COLOR_TEXT_TITLE_0f1214
            contentView.backgroundColor = selected ? .COLOR_BUTTON_HIGHLIGHT_BG_THEME_10 : UIColor.COLOR_BG_F2
            contentView.layer.borderColor = selected ? UIColor.THEME.cgColor : UIColor.COLOR_BG_F2.cgColor
            contentView.alpha = 1
        }
    }
}

// MARK: - 单组视图（标题 + 流式标签）
private final class SpecGroupView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let group: SpecGroup
    let config: SpecConfig
    var onSelect: ((SpecGroup, SpecItem?) -> Void)?

    private let titleLabel = UILabel()
    private let collection: UICollectionView
    private var collectionHeight: NSLayoutConstraint!
    private var selectedId: String?

    init(group: SpecGroup, config: SpecConfig) {
        self.group = group
        self.config = config

//        let layout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = config.interItemSpacing
//        layout.minimumLineSpacing = config.lineSpacing
//        layout.sectionInset = config.sectionInsets
        
        let layout = LeftAlignedFlowLayout(
            interItemSpacing: config.interItemSpacing,
            lineSpacing: config.lineSpacing,
            sectionInsets: config.sectionInsets
        )

        self.collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)

        titleLabel.font = config.titleFont
        titleLabel.text = group.title
        titleLabel.textColor = .label

        addSubview(titleLabel)
        addSubview(collection)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collectionHeight = collection.heightAnchor.constraint(equalToConstant: 1)
        collectionHeight.isActive = true

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),

            collection.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            collection.leftAnchor.constraint(equalTo: leftAnchor),
            collection.rightAnchor.constraint(equalTo: rightAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        collection.backgroundColor = .clear
        collection.register(TagCell.self, forCellWithReuseIdentifier: TagCell.reuseId)
        collection.dataSource = self
        collection.delegate = self
        collection.alwaysBounceVertical = false
        collection.isScrollEnabled = false   // 关键：由高度约束撑开
    }

    required init?(coder: NSCoder) { fatalError() }

    // —— 对外：给 SpecSelectionView 的高度计算（整组高度 = 标题 + 10 + flow 高度）
    func requiredHeight(for width: CGFloat) -> CGFloat {
        let titleH = ceil(config.titleFont.lineHeight)
        return titleH + 10 + flowHeightOnly(for: width)
    }

    // —— 内部：仅计算标签流式区域高度
    private func flowHeightOnly(for width: CGFloat) -> CGFloat {
        let maxTagWidth = max(44, width * config.tagMaxWidthRatio)
        let sizes = group.items.map {
            measureTagSize(text: $0.title,
                           font: config.tagFont,
                           lineHeightMultiple: config.lineHeightMultiple,
                           maxWidth: maxTagWidth,
                           contentInsets: config.contentInsets)
        }
        return flowHeight(
            sizes: sizes,
            containerWidth: width,
            interItem: config.interItemSpacing,
            lineSpacing: config.lineSpacing,
            sectionInsets: config.sectionInsets
        )
    }

    // —— 当自身宽度确定后，把 collectionView 的高度约束设置为内容应有高度
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        guard w > 0 else { return }
        let flowH = flowHeightOnly(for: w)
        if abs(collectionHeight.constant - flowH) > 0.5 {
            collectionHeight.constant = flowH
        }
    }

    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        group.items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = group.items[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.reuseId, for: indexPath) as! TagCell
        cell.layer.cornerRadius = config.tagCornerRadius
//        cell.apply(text: item.title, selected: (item.id == selectedId), config: config)
        cell.apply(text: item.title, selected: (item.id == selectedId), enabled: item.isEnabled, config: config)
        return cell
    }

    // MARK: FlowLayout Item Size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let W = collectionView.bounds.width
        let maxTagWidth = max(44, W * config.tagMaxWidthRatio)
        let item = group.items[indexPath.item]
        return measureTagSize(text: item.title,
                              font: config.tagFont,
                              lineHeightMultiple: config.lineHeightMultiple,
                              maxWidth: maxTagWidth,
                              contentInsets: config.contentInsets)
    }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return group.items[indexPath.item].isEnabled
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = group.items[indexPath.item]
        if selectedId == item.id{
            selectedId = nil
            collectionView.reloadData()
            onSelect?(group, nil)
            return
        }
        selectedId = item.id
        collectionView.reloadData()
        onSelect?(group, item)
    }
    // 预设选中项
    func setSelected(id: String?) {
        selectedId = id
        collection.reloadData()
    }
}

// MARK: - 多组组合视图（对外主入口）

public final class SpecSelectionView: UIView {
    public var onSelect: ((_ groupId: String, _ item: SpecItem?) -> Void)?
    
    private let stack = UIStackView()
    private let groups: [SpecGroup]
    private let config: SpecConfig
    private var groupViews: [SpecGroupView] = []
    
    public init(groups: [SpecGroup], config: SpecConfig = .init()) {
        self.groups = groups
        self.config = config
        super.init(frame: .zero)
        
        stack.axis = .vertical
        stack.spacing = 16
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leftAnchor.constraint(equalTo: leftAnchor),
            stack.rightAnchor.constraint(equalTo: rightAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        for g in groups {
            let gv = SpecGroupView(group: g, config: config)
            gv.onSelect = { [weak self] group, item in
                self?.onSelect?(group.id, item)
            }
            stack.addArrangedSubview(gv)
            groupViews.append(gv)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    /// 计算整个控件在给定宽度下的所需高度（用于弹窗内容高度、内嵌滚动区等）
    public func requiredHeight(for width: CGFloat) -> CGFloat {
        let sum = groupViews.reduce(CGFloat(0)) { partial, gv in
            partial + gv.requiredHeight(for: width)
        }
        // stack 的组间距
        let gaps = max(0, CGFloat(groupViews.count - 1)) * stack.spacing
        return ceil(sum + gaps)
    }
    
    // 根据组和 item 的 id 设置选中项
    public func setSelected(groupId: String, itemId: String) {
        guard let gv = groupViews.first(where: { $0.group.id == groupId }) else { return }
        gv.setSelected(id: itemId)
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        // 宽度变化时，让每个分组刷新一次内部 collectionView 的高度
        let w = bounds.width
        guard w > 0 else { return }
        for gv in groupViews {
            gv.setNeedsLayout()
            gv.layoutIfNeeded()
        }
    }
}

