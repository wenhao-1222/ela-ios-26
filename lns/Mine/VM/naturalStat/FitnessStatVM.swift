//
//  FitnessStatVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/2.
//


class FitnessStatVM: UIView {
    
    let selfHeight = kFitWidth(215)  + kFitWidth(16)
    var whiteViewHeight = kFitWidth(215)
    var controller = WHBaseViewVC()
    
    var labelWidth = kFitWidth(94)
    var labelHeight = kFitWidth(25)
    
    var heightChangeBlock:((CGFloat)->())?
    var tipTapBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))

        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(16), height: whiteViewHeight))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
//        vi.clipsToBounds = true
        
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .bold)
        lab.text = "力量训练"
        
        return lab
    }()
    lazy var tipsButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "fitness_tips_icon"), for: .normal)
        
        return btn
    }()
    lazy var tipsTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tipsTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var fitnessTotalDaysLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_10
        lab.textAlignment = .center
        lab.text = "0"
        lab.font = UIFont().DDInFontSemiBold(fontSize: 28)
        return lab
    }()
    lazy var fitnessTotalDaysLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.textAlignment = .center
        lab.text = "训练（天）"
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }()
    lazy var xiuxiTotalDaysLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.textAlignment = .center
        lab.text = "0"
        lab.font = UIFont().DDInFontSemiBold(fontSize: 28)
        return lab
    }()
    lazy var xiuxiTotalDaysLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.textAlignment = .center
        lab.text = "休息（天）"
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }()
    lazy var fitnessTagLab: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .COLOR_BG_WHITE
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.text = "部位"
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(134), width: SCREEN_WIDHT-kFitWidth(48), height: kFitWidth(1)))
        
        return vi
    }()
    lazy var fitnessBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        
        return vi
    }()
    lazy var nodataLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "暂无数据"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.isHidden = true
        return lab
    }()
}

extension FitnessStatVM{
    @objc func tipsTapAction() {
        self.tipTapBlock?()
    }
}

extension FitnessStatVM{
    func updateUI(dict:NSDictionary) {
        if dict.doubleValueForKey(key: "workoutDays") > 0 {
            fitnessTotalDaysLabel.text = dict.stringValueForKey(key: "workoutDays")
            fitnessTotalDaysLabel.textColor = .THEME
        }else{
            fitnessTotalDaysLabel.text = "0"
            fitnessTotalDaysLabel.textColor = .COLOR_TEXT_TITLE_0f1214_10
        }
        xiuxiTotalDaysLabel.text = "\(Int(dict.doubleValueForKey(key: "restDays")))"
        
        self.updateFitnessData(fitnessArray: dict["bodyPartList"]as? NSArray ?? [])
    }
    func updateFitnessData(fitnessArray:NSArray) {
        for vi in fitnessBgView.subviews{
            vi.removeFromSuperview()
        }
        
        fitnessBgView.isHidden = true
        if fitnessArray.count == 0{
            nodataLabel.isHidden = false
            self.heightChangeBlock?(selfHeight)
        }else{
            nodataLabel.isHidden = true
            fitnessBgView.isHidden = false
            
            var originX = kFitWidth(16)
            var originY = kFitWidth(0)
            for i in 0..<fitnessArray.count{
                let lab = UILabel.init(frame: CGRect.init(x: originX, y: originY, width: labelWidth, height: labelHeight))
                let dict = fitnessArray[i]as? NSDictionary ?? [:]
                lab.text = "\(dict.stringValueForKey(key: "part")) \(dict.stringValueForKey(key: "num")) 次"
                lab.textAlignment = .center
                lab.font = .systemFont(ofSize: 14, weight: .regular)
                lab.layer.cornerRadius = kFitWidth(6)
                lab.clipsToBounds = true
                lab.adjustsFontSizeToFitWidth = true
                
//                if i == 0 {
//                    lab.textColor = .THEME
//                    lab.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
//                }else{
                    lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
                    lab.backgroundColor = .COLOR_TEXT_TITLE_0f1214_06
//                }
                
                fitnessBgView.addSubview(lab)
                
                if i < fitnessArray.count - 1{
                    originX = originX + labelWidth + kFitWidth(14)
                    if originX + labelWidth > SCREEN_WIDHT-kFitWidth(48){
                        originX = kFitWidth(16)
                        originY = originY + labelHeight + kFitWidth(14)
                    }
                }
            }
            let fitnessBgViewHeight = originY + labelHeight + kFitWidth(14)
            fitnessBgView.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(164), width: SCREEN_WIDHT-kFitWidth(48), height: CGFloat(fitnessBgViewHeight))
            whiteViewHeight = fitnessBgView.frame.maxY + kFitWidth(20)
            whiteView.frame = CGRect.init(x: kFitWidth(8), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(16), height: whiteViewHeight)
            
            self.heightChangeBlock?(whiteViewHeight)
        }
    }
}

extension FitnessStatVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(tipsButton)
        whiteView.addSubview(tipsTapView)
        whiteView.addSubview(fitnessTotalDaysLabel)
        whiteView.addSubview(fitnessTotalDaysLab)
        whiteView.addSubview(xiuxiTotalDaysLabel)
        whiteView.addSubview(xiuxiTotalDaysLab)
        whiteView.addSubview(dottedLineView)
        whiteView.addSubview(fitnessTagLab)
        whiteView.addSubview(fitnessBgView)
        whiteView.addSubview(nodataLabel)
        
        setConstrait()
        whiteView.addShadow(opacity: 0.05)
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
        }
        tipsButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(titleLabel)
            make.width.height.equalTo(kFitWidth(17))
            make.right.equalTo(kFitWidth(-16))
        }
        tipsTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(tipsButton)
            make.width.height.equalTo(kFitWidth(60))
        }
        fitnessTotalDaysLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(58))
            make.left.equalTo(kFitWidth(79))
            make.width.equalTo(kFitWidth(70))
        }
        fitnessTotalDaysLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(fitnessTotalDaysLabel)
            make.top.equalTo(fitnessTotalDaysLabel.snp.bottom).offset(kFitWidth(4))
        }
        xiuxiTotalDaysLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-79))
            make.width.equalTo(kFitWidth(70))
            make.centerY.lessThanOrEqualTo(fitnessTotalDaysLabel)
        }
        xiuxiTotalDaysLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(xiuxiTotalDaysLabel)
            make.centerY.lessThanOrEqualTo(fitnessTotalDaysLab)
        }
        fitnessTagLab.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(dottedLineView)
            make.width.equalTo(kFitWidth(48))
        }
        nodataLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(164))
        }
    }
}
