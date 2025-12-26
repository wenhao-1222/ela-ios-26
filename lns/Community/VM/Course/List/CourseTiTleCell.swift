//
//  CourseTiTleCell.swift
//  lns
//
//  Created by Elavatine on 2025/4/14.
//

class CourseTitleCell: UITableViewCell {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bgView.addGradientBackground(startColor: UIColor(named: "color_bg_f5_course_list_start")!,
                                     endColor: UIColor(named: "color_bg_f5_course_list_end")!)
    }

    // MARK: - UI
    
    private let bgView = GradientView()
    
    private let titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 21, weight: .semibold)
        lab.numberOfLines = 0
        return lab
    }()
    
    private let dottedLineView = DottedLineView()

    private let detailLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12)
        lab.numberOfLines = 0
        return lab
    }()
    
    private let highLightLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .semibold)
        lab.numberOfLines = 0
        return lab
    }()
    
    private let highlightStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()
    
    private let promotionTagView = PromotionTagView()
    private let promotionDeadlineView = PromotionDeadlineTagView()
    
    lazy var priceLabel: UILabel = {
        let lab = UILabel()
        lab.isHidden = true
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return lab
    }()
    /// ⚠️ 把 detailLab + highLightLab + highlightStackView 全部放进 mainStack
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .COLOR_BG_F5
        selectionStyle = .none
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        
        contentView.addSubview(bgView)
        contentView.addSubview(titleLab)
        contentView.addSubview(promotionTagView)
        contentView.addSubview(promotionDeadlineView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(dottedLineView)
        contentView.addSubview(mainStack)
        
        // put into the stack
        mainStack.addArrangedSubview(detailLab)
        mainStack.addArrangedSubview(highLightLab)
        mainStack.addArrangedSubview(highlightStackView)

        // constraints
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        promotionTagView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLab)
        }
        promotionDeadlineView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLab)
        }
        priceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLab)
        }
        dottedLineView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(1)
        }
        
        mainStack.snp.makeConstraints { make in
            make.top.equalTo(dottedLineView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
        bgView.addGradientBackground(startColor: UIColor(named: "color_bg_f5_course_list_start")!,
                                     endColor: UIColor(named: "color_bg_f5_course_list_end")!)
    }
    
    // MARK: - Update
    
    func updateUI(dict: NSDictionary, isPaid: Bool = true) {
        
        titleLab.text = dict.stringValueForKey(key: "detailTitle")
        
        let highlight = dict["highlight"] as? NSDictionary ?? [:]
        let highlightContents = highlight["content"] as? [String] ?? []
        let highlightTitle = highlight.stringValueForKey(key: "title")
        
        
        if highlightContents.isEmpty {
            // 显示 detail
            detailLab.isHidden = false
            detailLab.text = dict.stringValueForKey(key: "detailSubtitle")
            
            highLightLab.isHidden = true
            highlightStackView.isHidden = true
            
        } else {
            // 显示亮点
            detailLab.isHidden = true
            highLightLab.isHidden = false
            highlightStackView.isHidden = false
            
            highLightLab.text = highlightTitle.count > 0 ? highlightTitle : "课程亮点"
            
            updateHighlightList(items: highlightContents)
        }
        
        priceLabel.isHidden = true
        let promotionInfo = highlight["promotionInfo"] as? NSDictionary ?? [:]
        if promotionInfo.stringValueForKey(key: "promotionText").count > 0 {
            promotionTagView.text = promotionInfo.stringValueForKey(key: "promotionText")
        }
        else if promotionInfo.stringValueForKey(key: "promotionEndTime").count > 0 {
            promotionDeadlineView.text = promotionInfo.stringValueForKey(key: "promotionEndTime")
        }
        else if promotionInfo.doubleValueForKey(key: "originalPrice") > 0 {
            priceLabel.isHidden = false
            let attr = NSMutableAttributedString(
                string: "¥\(promotionInfo.stringValueForKey(key: "originalPrice")) ",
                attributes: [
                    .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.COLOR_TEXT_TITLE_0f1214_50
                ]
            )
            let attr2 = NSAttributedString(
                string: " ¥",
                attributes: [
                    .foregroundColor: UIColor.THEME,
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium)
                ]
            )
            let attrPrice = NSAttributedString(
                string: dict.stringValueForKey(key: "price"),
                attributes: [
                    .foregroundColor: UIColor.THEME,
                    .font: UIFont.systemFont(ofSize: 26, weight: .semibold)
                ]
            )
            attr.append(attr2)
            attr.append(attrPrice)
            priceLabel.attributedText = attr
        }
        else if dict.doubleValueForKey(key: "price") > 0{
            priceLabel.isHidden = false
            let attr = NSMutableAttributedString(
                string: "¥ ",
                attributes: [
                    .foregroundColor: UIColor.THEME,
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium)
                ]
            )
            let attrPrice = NSAttributedString(
                string: dict.stringValueForKey(key: "price"),
                attributes: [
                    .foregroundColor: UIColor.THEME,
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium)
                ]
            )
            attr.append(attrPrice)
            priceLabel.attributedText = attr
        }
    }
    
    private func updateHighlightList(items: [String]) {
        
        highlightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for text in items {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 6
            row.alignment = .top   // 重要：顶部对齐，让行高一致
            

            // 行高样式
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 0
            paragraph.lineHeightMultiple = 1.5
            

            // ●
            let dot = UILabel()
            dot.textColor = .THEME
            dot.font = .systemFont(ofSize: 13)

            // dot 也套 paragraph
            dot.attributedText = NSAttributedString(
                string: "•",
                attributes: [
                    .font: dot.font as Any,
                    .foregroundColor: dot.textColor as Any,
                    .paragraphStyle: paragraph
                ]
            )

            
            // 文本 label
            let label = UILabel()
            label.textColor = .COLOR_TEXT_TITLE_0f1214_50
            label.font = .systemFont(ofSize: 13)
            label.numberOfLines = 0
            
            label.attributedText = NSAttributedString(
                string: text,
                attributes: [
                    .font: label.font as Any,
                    .foregroundColor: label.textColor as Any,
                    .paragraphStyle: paragraph
                ]
            )
            
            
            row.addArrangedSubview(dot)
            row.addArrangedSubview(label)
            
            highlightStackView.addArrangedSubview(row)
        }
    }

}
