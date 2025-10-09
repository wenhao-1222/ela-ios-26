//
//  JournalRemarkTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/8/27.
//


class JournalRemarkTableViewCell: UITableViewCell {
    
    var remarkBlock:(()->())?
    var detalBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // 先让约束生效，拿到 label 的真实宽度
        contentView.layoutIfNeeded()

        let tagW = tagLabel.bounds.width
        if tagLabel.preferredMaxLayoutWidth != tagW {
            tagLabel.preferredMaxLayoutWidth = tagW
        }

        let remarkW = remarkLabel.bounds.width
        if remarkLabel.preferredMaxLayoutWidth != remarkW {
            remarkLabel.preferredMaxLayoutWidth = remarkW
        }
    }

    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var leftTitleLabel : LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.text = "注释"
        
        return lab
    }()
    lazy var placeLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "这里输入您的备注说明..."
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var tagLabel : LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var remarkLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byTruncatingTail
        
        return lab
    }()
    
    lazy var remarkTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(remarkTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}

extension JournalRemarkTableViewCell{
    func updateContent(remark:String,notesTag:String,queryDay:String) {
        DLLog(message: "notesTag:\(notesTag)")
        let arr = WHUtils.getArrayFromJSONString(jsonString: notesTag)
        var notesTagString = ""
        for i in 0..<arr.count{
            let dict = arr[i]as? NSDictionary ?? [:]
            let values = dict["value"]as? [String] ?? []
            
            var valueString = ""
            for j in 0..<values.count{
                valueString = valueString + values[j]
                if j < values.count - 1{
                    valueString = valueString + "，"
                }
            }
            notesTagString = notesTagString + dict.stringValueForKey(key: "key") + "：" + valueString
            if i < arr.count - 1{
                notesTagString = notesTagString + " | "
            }
        }
        DLLog(message: "notesTagString:\(notesTagString)")
        self.tagLabel.setTagText(notesTagString)
//        self.tagLabel.preferredMaxLayoutWidth = SCREEN_WIDHT - kFitWidth(50)
        if remark.count > 0 || notesTagString.count > 0{
            self.placeLabel.isHidden = true
            self.remarkLabel.text = remark
//            self.tagLabel.setNeedsLayout()
//            self.tagLabel.layoutIfNeeded()
            if remark.count > 0 {
                tagLabel.snp.remakeConstraints { make in
                    make.left.equalTo(kFitWidth(15))
                    make.top.equalTo(leftTitleLabel.snp.bottom).offset(kFitWidth(6))
                    make.right.equalTo(kFitWidth(-15))
                }
//                DispatchQueue.main.asyncAfter(deadline: .now()+0.03, execute: {
                    self.remarkLabel.snp.remakeConstraints { make in
                        make.left.equalTo(kFitWidth(15))
                        make.right.equalTo(kFitWidth(-15))
                        make.top.equalTo(self.tagLabel.snp.bottom).offset(kFitWidth(4))
                        make.bottom.equalTo(kFitWidth(-14))
                    }
//                })
            }else{
                tagLabel.snp.remakeConstraints { make in
                    make.left.equalTo(kFitWidth(15))
                    make.top.equalTo(leftTitleLabel.snp.bottom).offset(kFitWidth(6))
                    make.right.equalTo(kFitWidth(-15))
                    make.bottom.equalTo(kFitWidth(-14))
                }
                self.remarkLabel.text = ""
//                remarkLabel.snp.remakeConstraints { make in
//                    make.left.equalTo(kFitWidth(15))
//                    make.right.equalTo(kFitWidth(-15))
////                    make.bottom.equalToSuperview()
//                }
            }
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }else{
            self.placeLabel.isHidden = false
            self.remarkLabel.text = ""
            remarkLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(15))
                make.right.equalTo(kFitWidth(-15))
                make.top.equalTo(tagLabel.snp.bottom).offset(kFitWidth(4))
                make.bottom.equalTo(kFitWidth(-5))
            }
        }
    }
}


extension JournalRemarkTableViewCell{
    @objc func remarkTapAction() {
        self.remarkBlock?()
    }
}
extension JournalRemarkTableViewCell{
    func initUI() {
        contentView.addSubview(whiteView)
        whiteView.addSubview(leftTitleLabel)
        whiteView.addSubview(placeLabel)
        whiteView.addSubview(tagLabel)
        whiteView.addSubview(remarkLabel)
        
        whiteView.addSubview(remarkTapView)
        setConstrait()
        tagLabel.setContentHuggingPriority(.required, for: .vertical)
        tagLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        // remarkLabel 通常给低一点的垂直拥抱，让它优先让位：
        remarkLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        remarkLabel.setContentCompressionResistancePriority(.required, for: .vertical)

    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(12))
            make.left.equalTo(kFitWidth(10))
            make.right.equalTo(kFitWidth(-10))
            make.bottom.equalToSuperview()
        }
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(13.5))
        }
        placeLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-30))
            make.centerY.lessThanOrEqualTo(leftTitleLabel)
        }
        tagLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.top.equalTo(leftTitleLabel.snp.bottom).offset(kFitWidth(6))
            make.right.equalTo(kFitWidth(-15))
        }
        remarkLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.right.equalTo(kFitWidth(-15))
            make.top.equalTo(tagLabel.snp.bottom).offset(kFitWidth(4))
            make.bottom.equalTo(kFitWidth(-14))
        }
        
        remarkTapView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(remarkLabel)
        }
    }
}
