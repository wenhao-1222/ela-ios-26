//
//  JournalReportDailyDesCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/12.
//


class JournalReportDailyDesCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
        self.isSkeletonable = true
        contentView.isSkeletonable = true
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
//        vi.layer.cornerRadius = kFitWidth(12)
//        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var detailLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.isSkeletonable = true
        lab.updateAnimatedSkeleton(usingColor: .blue)
        
        return lab
    }()
}

extension JournalReportDailyDesCell{
    func updateUI(dict:NSDictionary,gapsArray:NSArray,adviceDict:NSDictionary)  {
        let string = dict.stringValueForKey(key: "text")
        if string.count > 0 {
            hideSkeleton()
            detailLab.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(10))
                make.left.equalTo(kFitWidth(31))
                make.right.equalTo(kFitWidth(-31))
                make.height.equalTo(kFitWidth(40))
                make.bottom.equalTo(kFitWidth(-22))
            }
            detailLab.numberOfLines = 0
            let keyWords = dict["keywords"]as? NSArray ?? []
            detailLab.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(10))
                make.left.equalTo(kFitWidth(31))
                make.right.equalTo(kFitWidth(-31))
                make.bottom.equalTo(kFitWidth(-22))
            }
            let attr = string.attributedText(text: string, keywords: keyWords as! [String], font: .systemFont(ofSize: 14, weight: .semibold),color: .COLOR_TEXT_TITLE_0f1214)
            detailLab.attributedText = attr
            
            if gapsArray.count == 0 || adviceDict.stringValueForKey(key: "text").count == 0 {
                bgView.layer.cornerRadius = kFitWidth(12)
                bgView.clipsToBounds = true
            }
        }else{
            detailLab.text = ""
            detailLab.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(0))
                make.left.equalTo(kFitWidth(31))
                make.right.equalTo(kFitWidth(-31))
                make.height.equalTo(kFitWidth(0))
                make.bottom.equalTo(kFitWidth(-20))
            }
        }
    }
}

extension JournalReportDailyDesCell{
    func initUI() {
        contentView.addSubview(bgView)
        contentView.addSubview(whiteView)
        contentView.addSubview(detailLab)
        
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.bottom.equalToSuperview()
        }
        whiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(16))
            make.top.equalToSuperview()
        }
        detailLab.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(10))
            make.left.equalTo(kFitWidth(31))
            make.right.equalTo(kFitWidth(-31))
            make.height.equalTo(kFitWidth(40))
            make.bottom.equalTo(kFitWidth(-22))
        }
    }
}
