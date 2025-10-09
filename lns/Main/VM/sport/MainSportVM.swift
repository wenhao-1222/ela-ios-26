//
//  MainSportVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//


class MainSportVM: UIView {
    
    let selfHeight = kFitWidth(98)
    
    var tapBlock:(()->())?
    var tipsTapBlock:(()->())?
    var addTapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(0), width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(selfTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.text = "运动消耗"
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var alertButton : UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.setBackgroundImage(UIImage.init(named: "tips_gray_icon"), for: .normal)
        btn.addTarget(self, action: #selector(tipsTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var alertTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tipsTapAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var addButton : FeedBackTapButton = {
        let btn = FeedBackTapButton()
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
//        btn.setBackgroundImage(UIImage.init(named: "main_add_data_button"), for: .normal)
//        btn.setBackgroundImage(UIImage.init(named: "logs_add_icon_theme"), for: .normal)
        btn.setImage(UIImage(named: "logs_add_icon_theme"), for: .normal)
        btn.addPressEffect()
        
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var addTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
//        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(addAction))
//        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var caloriesIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "sport_calories_icon")
        return img
    }()
    lazy var caloriesLabel: UILabel = {
        let lab = UILabel()
        lab.text = "0千卡"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()
    lazy var timeIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "sport_time_icon")
        return img
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.text = "0分钟"
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()
}

extension MainSportVM{
    @objc func selfTapAction() {
//        TouchGenerator.shared.touchGenerator()
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    @objc func tipsTapAction() {
        if self.tipsTapBlock != nil{
            self.tipsTapBlock!()
        }
    }
    @objc func addAction() {
        if self.addTapBlock != nil{
            self.addTapBlock!()
        }
    }
    func updateUI(dict:NSDictionary){
        caloriesLabel.text = "\(WHUtils.convertStringToString("\(Int(dict.doubleValueForKey(key: "sportCalories").rounded()))") ?? "0")千卡"
        timeLabel.text = "\(WHUtils.convertStringToString("\(dict.stringValueForKey(key: "sportDuration"))") ?? "0")分钟"
    }
}

extension MainSportVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(alertButton)
        whiteView.addSubview(alertTapView)
        whiteView.addSubview(addButton)
//        whiteView.addSubview(addTapView)
        whiteView.addSubview(caloriesIcon)
        whiteView.addSubview(caloriesLabel)
        whiteView.addSubview(timeIcon)
        whiteView.addSubview(timeLabel)
        
        whiteView.addShadow(opacity: 0.05)
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        alertButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(titleLab)
            make.left.equalTo(titleLab.snp.right).offset(kFitWidth(4))
            make.width.height.equalTo(kFitWidth(16))
        }
        alertTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(alertButton)
            make.width.height.equalTo(kFitWidth(28))
        }
        addButton.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
//            make.top.equalTo(kFitWidth(16))
//            make.width.height.equalTo(kFitWidth(15))
            make.top.equalToSuperview()
//            make.right.equalTo(kFitWidth(-66))
            make.right.equalToSuperview()
            make.width.equalTo(kFitWidth(48))
            make.height.equalTo(kFitWidth(48))
        }
//        addTapView.snp.makeConstraints { make in
//            make.center.lessThanOrEqualTo(addButton)
//            make.width.height.equalTo(kFitWidth(50))
//        }
        caloriesIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(27))
            make.top.equalTo(kFitWidth(58))
            make.width.height.equalTo(kFitWidth(24))
        }
        caloriesLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesIcon.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(caloriesIcon)
        }
        timeIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(199))
            make.centerY.lessThanOrEqualTo(caloriesIcon)
            make.width.height.equalTo(caloriesIcon)
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(timeIcon.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(timeIcon)
        }
    }
}
