//
//  JournalReportDailyDetailCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/12.
//


class JournalReportDailyDetailCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
//        isSkeletonable = true
//        contentView.isSkeletonable = true
        
        initUI()
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5_SEGMENT
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
//        vi.isSkeletonable = true
        
        return vi
    }()
    lazy var detailLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
}

extension JournalReportDailyDetailCell{
    func showSkeletonUI() {
        detailLab.text = nil
        detailLab.snp.remakeConstraints { make in
            make.top.equalTo(kFitWidth(16))
            make.left.equalTo(kFitWidth(46))
            make.right.equalTo(kFitWidth(-46))
            make.height.equalTo(kFitWidth(64))
            make.bottom.equalTo(kFitWidth(-32))
        }

        let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                 highlightColorLight: .COLOR_GRAY_E2,
                                 cornerRadius: kFitWidth(4),
                                 shimmerWidth: 0.22,
                                 shimmerDuration: 1.15)

        detailLab.showSkeleton(cfg)
    }

    func updateUI(dict:NSDictionary)  {
        if dict.stringValueForKey(key: "text").count > 0 {
//            self.hideSkeleton()
            detailLab.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(16))
                make.left.equalTo(kFitWidth(46))
                make.right.equalTo(kFitWidth(-46))
                make.height.equalTo(kFitWidth(64))
                make.bottom.equalTo(kFitWidth(-32))
            }
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            detailLab.showSkeleton(cfg)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
                let attr = NSMutableAttributedString(string: dict.stringValueForKey(key: "text"))
                self.detailLab.setLineHeight(attr: attr,lineHeight: kFitWidth(21))
                
                self.detailLab.snp.remakeConstraints { make in
                    make.top.equalTo(kFitWidth(16))
                    make.left.equalTo(kFitWidth(46))
                    make.right.equalTo(kFitWidth(-46))
                    make.bottom.equalTo(kFitWidth(-32))
                }
                // 3) 最后统一把骨架优雅淡出 + 内容淡入
                [self.detailLab].forEach { $0.hideSkeletonWithCrossfade() }
            })
        }
    }
}

extension JournalReportDailyDetailCell{
    func initUI() {
        contentView.addSubview(whiteView)
        contentView.addSubview(bgView)
        contentView.addSubview(detailLab)
        
        setConstrait()
    }
    func setConstrait(){
        whiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(-12))
            make.bottom.equalToSuperview()
        }
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(31))
            make.right.equalTo(kFitWidth(-31))
            make.bottom.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
        }
        detailLab.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(16))
            make.left.equalTo(kFitWidth(46))
            make.right.equalTo(kFitWidth(-46))
            make.bottom.equalTo(kFitWidth(-32))
        }
    }
}
