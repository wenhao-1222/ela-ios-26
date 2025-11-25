//
//  CourseTiTleCell.swift
//  lns
//
//  Created by Elavatine on 2025/4/14.
//

//class CourseTiTleCell: UITableViewCell {
//    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        bgView.addGradientBackground(startColor: UIColor(named: "color_bg_f5_course_list_start")!,
//                                     endColor: UIColor(named: "color_bg_f5_course_list_end")!)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.backgroundColor = .clear
//        self.selectionStyle = .none
//        
//        initUI()
//    }
//    lazy var bgView: GradientView = {
//        let vi = GradientView()
//        vi.isUserInteractionEnabled = true
//        
//        return vi
//    }()
//    lazy var titleLab: LineHeightLabel = {
//        let lab = LineHeightLabel()
//        lab.textColor = .COLOR_TEXT_TITLE_0f1214
//        lab.font = .systemFont(ofSize: 21, weight: .semibold)
//        lab.numberOfLines = 0
//        lab.lineBreakMode = .byWordWrapping
//        
//        return lab
//    }()
//    
//    lazy var dottedLineView: DottedLineView = {
//        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(12), y: kFitWidth(55), width: SCREEN_WIDHT-kFitWidth(56), height: kFitHeight(1)))
//        
//        return vi
//    }()
//    lazy var detailLab: LineHeightLabel = {
//        let lab = LineHeightLabel()
//        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
//        lab.font = .systemFont(ofSize: 12, weight: .regular)
//        lab.numberOfLines = 0
//        lab.lineBreakMode = .byWordWrapping
//        
//        return lab
//    }()
//    lazy var priceLab: UILabel = {
//        let lab = UILabel()
//        lab.text = "¥"
//        lab.isHidden = true
//        lab.textColor = .THEME
//        lab.font = .systemFont(ofSize: 12, weight: .semibold)
//        
//        return lab
//    }()
//    lazy var priceLabel: UILabel = {
//        let lab = UILabel()
//        lab.textColor = .THEME
//        lab.font = .systemFont(ofSize: 14, weight: .semibold)
//        lab.isHidden = true
//        
//        return lab
//    }()
//    lazy var lineView: UIView = {
//        let vi = UIView()
//        vi.backgroundColor = .COLOR_GRAY_E2
//        
//        return vi
//    }()
//    lazy var highLightLab: LineHeightLabel = {
//        let lab = LineHeightLabel()
//        lab.textColor = .COLOR_TEXT_TITLE_0f1214
//        lab.font = .systemFont(ofSize: 14, weight: .semibold)
//        lab.numberOfLines = 0
//        lab.lineBreakMode = .byWordWrapping
//        
//        return lab
//    }()
//    lazy var highlightStackView: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .vertical
//        stack.spacing = kFitWidth(8)
//        stack.alignment = .leading
//        return stack
//    }()
//
//}
//
//extension CourseTiTleCell{
//    func updateUI(dict:NSDictionary,isPaid:Bool=true) {
//        titleLab.text = dict.stringValueForKey(key: "detailTitle")
//        
//        let highlight = dict["highlight"]as? NSDictionary ?? [:]
//        let highlightContents = highlight["content"] as? [String] ?? []
//        let highlightTitle = highlight.stringValueForKey(key: "title")
//
//        if !highlightContents.isEmpty {
//            detailLab.text = ""
//            detailLab.isHidden = true
//            detailLab.snp.remakeConstraints { make in
//                make.height.equalTo(0)
//            }
//            
//            highLightLab.text = highlightTitle.count > 0 ? highlightTitle : "课程亮点"
//
//            updateHighlightList(items: highlightContents)
//        }else{
//            detailLab.text = dict.stringValueForKey(key: "detailSubtitle")
//            detailLab.isHidden = false
//            detailLab.snp.remakeConstraints { make in
//                make.left.equalTo(kFitWidth(16))
//                make.right.equalTo(kFitWidth(-16))
//                make.bottom.equalTo(kFitWidth(-4))
//                make.top.equalTo(dottedLineView.snp.bottom).offset(kFitWidth(12))
//            }
//            highLightLab.text = ""
//        }
//        
//        priceLab.isHidden = true
//        priceLabel.isHidden = true
//        
//        if dict.doubleValueForKey(key: "price") > 0 && isPaid == false && UserInfoModel.shared.abTestModel.tutorial_briefing_price_hidden == .B{
//            priceLab.isHidden = false
//            priceLabel.isHidden = false
//            priceLabel.text = dict["price"]as? String ?? "\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "price"))") ?? "")"
//        }
//    }
//    func updateHighlightList(items: [String]) {
//        // 清空旧内容
//        highlightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        for text in items {
//            let row = UIStackView()
//            row.axis = .horizontal
//            row.spacing = kFitWidth(6)
//            row.alignment = .leading
//            
//            let dotLab = LineHeightLabel()
//            dotLab.textColor = .THEME
//            dotLab.font = .systemFont(ofSize: 13)
//            dotLab.customLineHeight = kFitWidth(18)//UIFont.systemFont(ofSize: 13).lineHeight * 1.5
//            dotLab.text = "•"                   // 或 "●"
//            
//            let label = LineHeightLabel()
//            label.textColor = .COLOR_TEXT_TITLE_0f1214_50
//            label.font = .systemFont(ofSize: 13)
//            label.customLineHeight = kFitWidth(18)//label.font.lineHeight * 1.5
//            label.numberOfLines = 0
//            label.lineBreakMode = .byWordWrapping
//            label.text = text
//    
//            row.addArrangedSubview(dotLab)
//            row.addArrangedSubview(label)
//            
//            highlightStackView.addArrangedSubview(row)
//        }
//    }
//}
//
//extension CourseTiTleCell{
//    func initUI() {
//        contentView.addSubview(bgView)
//        contentView.addSubview(titleLab)
//        contentView.addSubview(detailLab)
//        contentView.addSubview(priceLab)
//        contentView.addSubview(priceLabel)
//        contentView.addSubview(dottedLineView)
//        contentView.addSubview(highLightLab)
//        contentView.addSubview(highlightStackView)
//        setConstrait()
//        
//        bgView.addGradientBackground(startColor: UIColor(named: "color_bg_f5_course_list_start")!,
//                                     endColor: UIColor(named: "color_bg_f5_course_list_end")!)
//    }
//    func setConstrait() {
//        bgView.snp.makeConstraints { make in
//            make.left.top.right.bottom.equalToSuperview()
//        }
//        titleLab.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.top.equalTo(kFitWidth(17))
//            make.right.equalTo(kFitWidth(-100))
//        }
//        priceLabel.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
//            make.centerY.lessThanOrEqualTo(titleLab)
//        }
//        priceLab.snp.makeConstraints { make in
//            make.right.equalTo(priceLabel.snp.left).offset(kFitWidth(-3))
//            make.centerY.lessThanOrEqualTo(priceLabel)
//        }
//        dottedLineView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
//            make.height.equalTo(kFitWidth(1))
//            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(12))
//        }
//        detailLab.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
//            make.bottom.equalTo(kFitWidth(-4))
//            make.top.equalTo(dottedLineView.snp.bottom).offset(kFitWidth(12))
//        }
//        highLightLab.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
//            make.top.equalTo(dottedLineView.snp.bottom).offset(kFitWidth(12))
//        }
//        
//        highlightStackView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
//            make.top.equalTo(highLightLab.snp.bottom).offset(kFitWidth(8))
//            make.bottom.lessThanOrEqualToSuperview().offset(kFitWidth(-12))
//        }
//    }
//}

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
    }
    
    
    // MARK: - Highlight Builder
    
//    private func updateHighlightList(items: [String]) {
//        
//        highlightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        for text in items {
//            let row = UIStackView()
//            row.axis = .horizontal
//            row.spacing = 6
//            row.alignment = .leading
//            
//            let dot = UILabel()
//            dot.text = "•"
//            dot.textColor = .THEME
//            dot.font = .systemFont(ofSize: 13)
//            
//            let label = UILabel()
//            label.textColor = .COLOR_TEXT_TITLE_0f1214_50
//            label.font = .systemFont(ofSize: 13)
//            label.numberOfLines = 0
//            label.text = text
//            
//            row.addArrangedSubview(dot)
//            row.addArrangedSubview(label)
//            
//            highlightStackView.addArrangedSubview(row)
//        }
//    }
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
