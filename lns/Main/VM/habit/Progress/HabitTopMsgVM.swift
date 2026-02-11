//
//  HabitTopMsgVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//


class HabitTopMsgVM: UIView {
    
    let selfHeight = kFitWidth(267)
    var numberTapBlock:(()->())?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        changeButton.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214.cgColor
    }
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
//        img.setImgLocal(imgName: "habit_bg_ela_img")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var numberLabel: UICountingLabel = {
        let lab = UICountingLabel()
        lab.method = UILabelCountingMethod.linear
        lab.font = UIFont().DDInFontSemiBold(fontSize: 50)
        lab.text = "0"
        lab.format = "%d"
        return lab
    }()
    lazy var numberDetailLab: UILabel = {
        let lab = UILabel()
        lab.text = "明细"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        
        return lab
    }()
    lazy var numerDetailArrowImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_right_arrow_icon")
        return img
    }()
    lazy var numberTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(numberTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var changeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("兑换", for: .normal)
        btn.layer.cornerRadius = kFitWidth(15)
        btn.enablePressEffect()
        btn.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.backgroundColor = .clear
        
        return btn
    }()
}

extension HabitTopMsgVM{
    @objc func numberTapAction() {
        self.numberTapBlock?()
    }
}

extension HabitTopMsgVM{
    func initUI(){
        addSubview(bgImgView)
        addSubview(numberLabel)
        addSubview(numberDetailLab)
        addSubview(numerDetailArrowImg)
        addSubview(numberTapView)
        addSubview(changeButton)
        
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(54))
        }
        numberDetailLab.snp.makeConstraints { make in
            make.left.equalTo(numberLabel.snp.right).offset(kFitWidth(5))
            make.bottom.equalTo(numberLabel).offset(kFitWidth(-8))
        }
        numerDetailArrowImg.snp.makeConstraints { make in
            make.left.equalTo(numberDetailLab.snp.right)
            make.centerY.lessThanOrEqualTo(numberDetailLab)
            make.width.height.equalTo(kFitWidth(16))
        }
        numberTapView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(numberLabel).offset(kFitWidth(10))
            make.bottom.equalTo(numberLabel).offset(kFitWidth(10))
            make.right.equalTo(numerDetailArrowImg).offset(kFitWidth(240))
        }
        changeButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(120))
            make.width.equalTo(kFitWidth(68))
            make.height.equalTo(kFitWidth(30))
        }
    }
}
