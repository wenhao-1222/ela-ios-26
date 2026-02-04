//
//  HabitItemVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//


class HabitItemVM: UIView {
    
    let selfHeight = kFitWidth(40)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var leftIconImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.isUserInteractionEnabled = true
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var pointLab: UILabel = {
        let lab = UILabel()
        lab.isUserInteractionEnabled = true
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.text = "积分"
        
        return lab
    }()
    lazy var pointLabel: UILabel = {
        let lab = UILabel()
        lab.isUserInteractionEnabled = true
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.text = "+1"
        return lab
    }()
    lazy var showButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(15)
        btn.clipsToBounds = true
        btn.setTitle("查看", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension HabitItemVM{
    func updateUI(isComplete:Bool,point:String,buttonText:String) {
        titleLabel.textColor = isComplete ? UIColor.COLOR_TEXT_TITLE_0f1214_50 : UIColor.COLOR_TEXT_TITLE_0f1214
        pointLabel.textColor = isComplete ? UIColor.COLOR_TEXT_TITLE_0f1214_50 : UIColor.COLOR_TEXT_TITLE_0f1214
        showButton.backgroundColor = isComplete ? UIColor.COLOR_BG_C4 : UIColor.THEME
        showButton.setTitle(isComplete ? "已达成" : buttonText, for: .normal)
//        showButton.setTitleColor(isComplete ? UIColor.COLOR_TEXT_WHITE : UIColor.white, for: .normal)
        leftIconImgView.alpha = isComplete ? 0.5 : 1
        pointLabel.text = "+\(point)"
    }
    ///初次与好友达成目标
    func updateUIForProteinFriendFirst(point:String,buttonText:String,status:String) {
        titleLabel.textColor = status == "3" ? UIColor.COLOR_TEXT_TITLE_0f1214_50 : UIColor.COLOR_TEXT_TITLE_0f1214
        pointLabel.textColor = status == "3"  ? UIColor.COLOR_TEXT_TITLE_0f1214_50 : UIColor.COLOR_TEXT_TITLE_0f1214
        showButton.backgroundColor = status == "2"  ? UIColor.THEME : UIColor.COLOR_BG_C4
        leftIconImgView.alpha = status == "3" ? 0.5 : 1
        pointLabel.text = "+\(point)"
        
        if status == "1"{
            showButton.setTitle("未达成", for: .normal)
            showButton.isUserInteractionEnabled = false
        }else if status == "2"{
            showButton.setTitle("领取", for: .normal)
            showButton.isUserInteractionEnabled = true
        }else if status == "3"{
            showButton.setTitle("已领取", for: .normal)
            showButton.isUserInteractionEnabled = false
        }
    }
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension HabitItemVM{
    func initUI() {
        addSubview(leftIconImgView)
        addSubview(titleLabel)
        addSubview(pointLab)
        addSubview(pointLabel)
        addSubview(showButton)
        
        setConstrait()
    }
    func setConstrait() {
        leftIconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(40))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(68))
            make.top.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(21))
            make.right.equalTo(kFitWidth(-90))
        }
        pointLab.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(kFitWidth(-1))
            make.height.equalTo(kFitWidth(16.5))
        }
        pointLabel.snp.makeConstraints { make in
            make.left.equalTo(pointLab.snp.right).offset(kFitWidth(6))
            make.centerY.lessThanOrEqualTo(pointLab)
        }
        showButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(67))
            make.height.equalTo(kFitWidth(30))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}
