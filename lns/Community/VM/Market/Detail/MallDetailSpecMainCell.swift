//
//  MallDetailSpecMainCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/9.
//

class MallDetailSpecMainCell: UITableViewCell {
    
    var tapBlock:(()->())?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .COLOR_BG_WHITE
        contentView.backgroundColor = .COLOR_BG_WHITE          // 整个 cell 白底
        selectionStyle = .none
        initUI()
    }
    /// 灰色“胶囊”容器（文字+箭头都放这里）
    private lazy var chipView: UIView = {
        let v = UIView()
        // 你有统一的灰色可替换；这里给个接近图示的灰
        v.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        v.layer.cornerRadius = kFitWidth(4)
        v.layer.masksToBounds = true
        // 让容器更愿意按内容“包裹”宽度
        v.setContentHuggingPriority(.required, for: .horizontal)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        v.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        v.addGestureRecognizer(tap)
        
        return v
    }()
    /// 文本
    lazy var mallTextLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 1                    // 只显示一行
        lab.lineBreakMode = .byTruncatingTail    // 末尾截断，保证箭头可见
        // 降低水平方向的抗压缩，让位给箭头
        lab.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        lab.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lab.isUserInteractionEnabled = true
        return lab
    }()

    /// 箭头
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "mall_spec_arrow_down_icon")
        img.isUserInteractionEnabled = true
        // 箭头应保持固有宽度，不被拉伸或压缩
        img.setContentHuggingPriority(.required, for: .horizontal)
        img.setContentCompressionResistancePriority(.required, for: .horizontal)

        return img
    }()
}

extension MallDetailSpecMainCell {
    @objc func tapAction() {
        self.tapBlock?()
    }
}

// MARK: - Layout
extension MallDetailSpecMainCell {
    func initUI() {
        contentView.addSubview(chipView)
        chipView.addSubview(mallTextLabel)
        chipView.addSubview(arrowImgView)
        // 灰色胶囊放在白底里，左上留边；右侧不固定，随内容变化
        chipView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.top.equalToSuperview().offset(kFitWidth(12))
            // 不让它超出屏幕：最多到右边距 -15
            make.right.lessThanOrEqualToSuperview().offset(kFitWidth(-20))
            // 给个低优先级的底边，撑起 cell 高度
            make.bottom.equalToSuperview().offset(kFitWidth(-12)).priority(.low)
        }
        // label 约束
        mallTextLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(5))
            // 不能直接贴右边，因为右侧要给箭头留位置；用 <=，并由箭头的 leading 约束来锁定
//            make.right.lessThanOrEqualToSuperview().offset(kFitWidth(-34))
            make.bottom.equalToSuperview().offset(kFitWidth(-5)).priority(.low)
        }

        // 箭头紧跟在文字后面
        arrowImgView.snp.makeConstraints { make in
            make.left.equalTo(mallTextLabel.snp.right).offset(kFitWidth(2)) // 紧跟文字
            make.centerY.equalTo(mallTextLabel.snp.centerY)
            make.right.lessThanOrEqualToSuperview().offset(kFitWidth(-16)) // 允许在右侧留边
            make.width.height.equalTo(kFitWidth(16)) // 根据你的图标实际大小调整
        }
    }
}

// MARK: - 更新文案
extension MallDetailSpecMainCell {
    /// 根据需要保留你的 gap 参数；不再重做约束，避免抖动
    func updateText(text: String) {
        mallTextLabel.text = text
    }
}
