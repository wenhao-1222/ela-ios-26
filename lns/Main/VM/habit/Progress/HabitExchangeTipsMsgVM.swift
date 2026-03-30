//
//  HabitExchangeTipsMsgVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/6.
//

class HabitExchangeTipsMsgVM: UIView {
    
    var selfHeight = kFitWidth(157)
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var elaIconImg: UIImageView = {
        let img = UIImageView()
//        img.setImgLocal(imgName: "ela_icon_img")
        img.image = UIImage(named: "ela_icon_img")?.withTintColor(.THEME)
        // 284 52
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "捐赠计划"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 15, weight: .medium)
        return lab
    }()
    lazy var tipsLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
    lazy var showMoreLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
}

extension HabitExchangeTipsMsgVM{
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension HabitExchangeTipsMsgVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(elaIconImg)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(tipsLabel)
        whiteView.addSubview(showMoreLabel)
        
        setConstrait()
        tipsLabel.setLineHeight(textString: "2021年监测结果显示，仅在农村义务教育学生营养改善计划的重点监测抽样范围内，6至15岁学生消瘦率仍为9.8%，贫血率为12.0%，营养缺口依然真实存在，针对性的支持仍有必要。",lineHeight: tipsLabel.font.lineHeight)
        showMoreLabel.setLineHeight(textString: "查看更多",lineHeight: kFitWidth(20))
    }
    func setConstrait() {
        elaIconImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(22))
            make.width.equalTo(kFitWidth(71))
            make.height.equalTo(kFitWidth(13))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(elaIconImg.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(elaIconImg)
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(45))
        }
        showMoreLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
//            make.bottom.equalTo(kFitWidth(-20))
            make.bottom.equalTo(tipsLabel)
        }
    }
}
