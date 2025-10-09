//
//  MallDetailSpecChangeCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/8.
//


// MARK: - 你的 UITableViewCell：只负责“规格色块区域”
final class MallDetailSpecChangeCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    typealias SelectCallback = (_ selectedIndex: Int, _ option: SpecImageOption) -> Void
    
    private var options: [SpecImageOption] = []
    private var selectedIndex: Int = 0
    private var onSelect: SelectCallback?
    
    // 布局参数
    private let itemSize: CGFloat = kFitWidth(25)
    private let interItemSpacing: CGFloat = kFitWidth(12)
    private let lineSpacing: CGFloat = kFitWidth(12)
    private let contentInset: UIEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
    
    private lazy var flow: UICollectionViewFlowLayout = {
        let f = UICollectionViewFlowLayout()
        f.minimumInteritemSpacing = interItemSpacing
        f.minimumLineSpacing = lineSpacing
        f.scrollDirection = .vertical
        return f
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.allowsMultipleSelection = false
        cv.contentInset = contentInset
        cv.register(SpecImageCell.self, forCellWithReuseIdentifier: SpecImageCell.reuseID)
        return cv
    }()
    
    private var cvHeightConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        backgroundColor = .white
        selectionStyle = .none
        
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        cvHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cvHeightConstraint
        ])
    }
    
    /// 外部配置入口
    func configure(options: [SpecImageOption], selectedIndex: Int = 0, onSelect: SelectCallback?) {
        self.options = options
        self.selectedIndex = max(0, min(selectedIndex, options.count - 1))
        self.onSelect = onSelect
        collectionView.reloadData()
        
        // 默认选中
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.options.indices.contains(self.selectedIndex) else { return }
            let ip = IndexPath(item: self.selectedIndex, section: 0)
            self.collectionView.selectItem(at: ip, animated: false, scrollPosition: [])
            if let cell = self.collectionView.cellForItem(at: ip) as? SpecImageCell {
                cell.setSelectedUI(true, animated: false)
            }
        }
        
        // 更新高度以适配多行
        updateCollectionHeight()
    }
    
    private func itemsPerRow(for width: CGFloat) -> Int {
        let usable = width - contentInset.left - contentInset.right
        if usable <= itemSize { return 1 }
        var count = Int( (usable + interItemSpacing) / (itemSize + interItemSpacing) )
        count = max(1, count)
        return count
    }
    
    private func updateCollectionHeight() {
        let width = contentView.bounds.width > 0 ? contentView.bounds.width : UIScreen.main.bounds.width
        let perRow = itemsPerRow(for: width)
        guard perRow > 0 else { cvHeightConstraint.constant = 0; return }
        let rows = Int(ceil(CGFloat(options.count) / CGFloat(perRow)))
        let totalHeight = contentInset.top
            + CGFloat(rows) * itemSize
            + CGFloat(max(rows - 1, 0)) * lineSpacing
            + contentInset.bottom
        cvHeightConstraint.constant = totalHeight
        // 触发表格自适应高度
//        setNeedsLayout(); layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionHeight()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { options.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpecImageCell.reuseID, for: indexPath) as! SpecImageCell
        let opt = options[indexPath.item]
        
        // Demo：用背景色当“图片”
        cell.imageView.backgroundColor = opt.placeholderColor
        cell.imageView.setImgUrl(urlString: opt.imageURL ?? "")
        // 若换成图片链接（示例 Kingfisher）：
        // cell.imageView.kf.setImage(with: URL(string: opt.imageURL ?? ""))
        // 或 SDWebImage:
        // cell.imageView.sd_setImage(with: URL(string: opt.imageURL ?? ""), placeholderImage: nil)
        
        let isSelected = (indexPath.item == selectedIndex)
        cell.setSelectedUI(isSelected, animated: false)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != selectedIndex else {
            // 重复点击同一项，只做个轻反馈动画
            if let cell = collectionView.cellForItem(at: indexPath) as? SpecImageCell {
                cell.setSelectedUI(true, animated: true)
            }
            return
        }
        // 取消旧的
        let old = IndexPath(item: selectedIndex, section: 0)
        if let oldCell = collectionView.cellForItem(at: old) as? SpecImageCell {
            oldCell.setSelectedUI(false, animated: true)
        }
        // 选中新
        selectedIndex = indexPath.item
        if let newCell = collectionView.cellForItem(at: indexPath) as? SpecImageCell {
            newCell.setSelectedUI(true, animated: true)
        }
        // 回调给 VC
        onSelect?(selectedIndex, options[selectedIndex])
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemSize, height: itemSize)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
}
