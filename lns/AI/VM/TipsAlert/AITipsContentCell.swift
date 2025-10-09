//
//  AITipsContentCell.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//


class AITipsContentCell: UITableViewCell {
    
    var aiTipsBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var contentLab: YYLabel = {
        let lab = YYLabel()
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
//        vi.layer.cornerRadius = kFitWidth(20)
//        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
}

extension AITipsContentCell{
    func updateUI() {
        let attrStrign = "1. 请确保食物在框内，并保持正上方拍摄。\n2. 任何AI识别都无法代替人工计算，建议精准度要求高的用户用食物称手动记录（"
        let attr = NSMutableAttributedString(string: attrStrign)
        let tipsAttr = NSMutableAttributedString(string: "AI识别的限制")
        let tipsString = NSMutableAttributedString(string: "）\n")
        let tipsString2 = NSMutableAttributedString(string: "3. AI识别功能为测试版，高负载时可能会影响体验质量，敬请谅解。")
        
        tipsAttr.yy_color = .THEME
        tipsAttr.yy_setTextHighlight(NSRange(location: 0, length: tipsAttr.string.count), color: .THEME, backgroundColor: .clear) { vi, attr, range, rect in
            DLLog(message: "AI识别的限制")
            self.aiTipsBlock?()
        }
        
        attr.append(tipsAttr)
        attr.append(tipsString)
        attr.append(tipsString2)
         
        // 创建NSAttributedString并应用行高
        let range = NSMakeRange(0, attr.length)
//        attr.yy_setTextHighlight(NSRange(location: attrStrign.count, length: tipsAttr.length), color: .THEME, backgroundColor: .clear) { vi, attr, range, rect in
//            self.aiTipsBlock?()
//        }
        // 创建NSMutableParagraphStyle来设置行高
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = kFitWidth(5) // 设置额外的行高
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        // 应用NSAttributedString到UILabel
        contentLab.attributedText = attr
    }
}

extension AITipsContentCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(contentLab)
        bgView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(25))
//            make.right.equalTo(kFitWidth(-25))
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(10))
            make.bottom.equalTo(kFitWidth(-18))
        }
//        bgView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(25))
//            make.right.equalTo(kFitWidth(-25))
//            make.top.equalTo(kFitWidth(10))
//            make.bottom.equalTo(kFitWidth(-18))
//        }
        contentLab.snp.makeConstraints { make in
//            make.left.top.equalTo(kFitWidth(12))
//            make.right.bottom.equalTo(kFitWidth(-12))
            make.height.equalTo(kFitWidth(112))
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.bottom.equalToSuperview()
        }
    }
}
