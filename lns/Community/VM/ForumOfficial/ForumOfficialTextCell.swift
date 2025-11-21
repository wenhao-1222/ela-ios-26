//
//  ForumOfficialTextCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/19.
//



class ForumOfficialTextCell: UITableViewCell {
    
    var contentRefreshBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var detailLabel: YYLabel = {
        let lab = YYLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var detailLab: UITextView = {
        let lab = UITextView()
        lab.isEditable = false
        lab.isSelectable = true
        lab.isScrollEnabled = false
        lab.backgroundColor = .clear
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textContainer.lineFragmentPadding = 0
        
        return lab
    }()
}

extension ForumOfficialTextCell{
    func updateContent(text:String) {
        detailLab.text = text
        detailLab.textColor = .COLOR_TEXT_TITLE_0f1214
        detailLab.font = .systemFont(ofSize: 18, weight: .medium)
        detailLab.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        detailLab.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        // 计算文本高度
        let fixedWidth = kFitWidth(343)
        let newSize = detailLab.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        detailLab.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(10))
            make.height.equalTo(newSize.height+kFitWidth(8))
            make.bottom.equalTo(kFitWidth(-5))
        }
    }
    func updateContentText(text:String) {
        // 计算文本高度
        let fixedWidth = kFitWidth(343)
        var textString = text//.mc_cutToSuffix(from: 800)
        textString = textString.replacingOccurrences(of: "&amp;", with: "&")
        textString = textString.replacingOccurrences(of: "\r\n\r\n", with: "\r\n \r\n")
        
        let attr = textString.mc_setLineSpace(lineSpace: 8)
        
        detailLab.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        detailLab.attributedText = attr
        detailLab.textColor = .COLOR_TEXT_TITLE_0f1214
        detailLab.font = .systemFont(ofSize: 16, weight: .regular)
        let newSize = detailLab.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        DLLog(message: "updateContentText:\(newSize)")
        detailLab.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(0))
            make.height.equalTo(newSize.height)
            make.bottom.equalTo(kFitWidth(-2))
        }
    }
    func updateTimeAndLocation(time:String,location:String) {
        detailLab.text = "\(time)  发布于 \(location)"
        detailLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        detailLab.font = .systemFont(ofSize: 12, weight: .regular)
        detailLab.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if location == ""{
            detailLab.text = "\(time)"
        }
        detailLab.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(4))
            make.height.equalTo(kFitWidth(30))
            make.bottom.equalTo(kFitWidth(-8))
        }
    }
}
extension ForumOfficialTextCell{
    func initUI() {
        contentView.addSubview(detailLab)
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.right.equalTo(kFitWidth(-15))
            make.top.equalTo(kFitWidth(0))
        }
    }
}
