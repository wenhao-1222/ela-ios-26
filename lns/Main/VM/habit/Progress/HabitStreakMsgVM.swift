//
//  HabitStreakMsgVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/16.
//


class HabitStreakMsgVM: UIView {
    
    var selfHeight = kFitWidth(118)
    let progressWidth = SCREEN_WIDHT-kFitWidth(114)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
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
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "连续记录"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        
        return lab
    }()
    lazy var maxDaysLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.text = "最高连胜 \(UserInfoModel.shared.streakDict.stringValueForKey(key: "max_streak")) 天"
        
        return lab
    }()
    lazy var daysLabel: UILabel = {
        let lab = UILabel()
        
        let attr = NSMutableAttributedString(string: "\(UserInfoModel.shared.streakDict.stringValueForKey(key: "streak"))/",
                                             attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
                                                                                                                                              .font:UIFont().DDInFontMedium(fontSize: 20)])
        let nextNum = UserInfoModel.shared.streakDict.stringValueForKey(key: "streak").intValue + UserInfoModel.shared.streakDict.stringValueForKey(key: "gap").intValue
        attr.append(NSAttributedString(string: "\(nextNum)",
                                       attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
                                                    .font:UIFont().DDInFontMedium(fontSize: 20)]))
        attr.append(NSAttributedString(string: "距离下一个里程碑",
                                       attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
                                                    .font:UIFont.systemFont(ofSize: 11, weight: .regular)]))
        
        lab.attributedText = attr
        
        return lab
    }()
    lazy var currentIconImg: UIImageView = {
        let img = UIImageView()
        
        if UserInfoModel.shared.streakDict.doubleValueForKey(key: "level") < 7{
            img.setImgLocal(imgName: "streak_icon_\(Int(UserInfoModel.shared.streakDict.doubleValueForKey(key: "level"))-1)")
        }else{
            img.setImgLocal(imgName: "streak_icon_6")
        }
        
        return img
    }()
    lazy var progressBgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(41), y: kFitWidth(89.5), width: progressWidth, height: kFitWidth(5)))
        vi.backgroundColor = .COLOR_BG_F2
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var progressView: UIView = {
        let vi = UIView()//.init(frame: CGRect.init(x: 0, y: 0, width: progressWidth*0.25, height: kFitWidth(5)))
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        
        var nextNum = UserInfoModel.shared.streakDict.stringValueForKey(key: "streak").intValue + UserInfoModel.shared.streakDict.stringValueForKey(key: "gap").intValue
        if nextNum == 0{
            nextNum = 1
        }
        let percent = (UserInfoModel.shared.streakDict.stringValueForKey(key: "streak").floatValue * 0.01) / (Float(nextNum) * 0.01)
        
        let width = Float(progressWidth) * Float(percent)
        vi.frame = CGRect.init(x: 0, y: 0, width: CGFloat(width), height: kFitWidth(5))
        
        return vi
    }()
    
    lazy var nextIconImg: UIImageView = {
        let img = UIImageView()
        if UserInfoModel.shared.streakDict.doubleValueForKey(key: "level") < 7{
            img.setImgLocal(imgName: "streak_icon_\(Int(UserInfoModel.shared.streakDict.doubleValueForKey(key: "level")))")
        }else{
            img.isHidden = true
            img.setImgLocal(imgName: "streak_icon_6")
        }
        return img
    }()
}

extension HabitStreakMsgVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(maxDaysLabel)
        whiteView.addSubview(daysLabel)
        whiteView.addSubview(currentIconImg)
        whiteView.addSubview(progressBgView)
        progressBgView.addSubview(progressView)
        whiteView.addSubview(nextIconImg)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.height.equalTo(kFitWidth(24))
        }
        maxDaysLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(titleLab)
        }
        daysLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(52))
            make.height.equalTo(kFitWidth(30))
            make.right.equalTo(kFitWidth(-16))
        }
        currentIconImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualTo(progressBgView)
            make.width.height.equalTo(kFitWidth(20))
        }
        nextIconImg.snp.makeConstraints { make in
            make.left.equalTo(progressBgView.snp.right).offset(kFitWidth(5))
            make.centerY.lessThanOrEqualTo(progressBgView)
            make.width.height.equalTo(kFitWidth(20))
        }
    }
}
