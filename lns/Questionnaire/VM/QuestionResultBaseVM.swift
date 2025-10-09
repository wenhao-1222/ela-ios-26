//
//  QuestionResultBaseVM.swift
//  lns
//  卡路里 基础消耗 结果页
//  Created by Elavatine on 2024/10/29.
//


class QuestionResultBaseVM: UIView {
    
    var selfHeight = kFitWidth(0)
    
    var showTipsBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_GRAY_FA
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        lab.text = "结合您的代谢和活动量，\n您维持现体重所需的大致热量为："
        lab.numberOfLines = 2
        lab.adjustsFontSizeToFitWidth = true
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var caloriesBgView : UIView  = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.layer.cornerRadius = kFitWidth(32)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(bgViewTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var caloriesTextField: UITextField = {
        let text = UITextField()
//        text.placeholder = "0"
        text.font = UIFont().DDInFontMedium(fontSize: 32)
        text.keyboardType = .numberPad
        text.text = "0"
        text.textColor = .THEME
//        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.delegate = self
        
        let attr = NSMutableAttributedString(string: "|")
        let attrNum = NSMutableAttributedString(string: "0")
        attr.yy_color = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.85)
        attrNum.yy_color = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.25)
        
        attr.append(attrNum)
        text.attributedPlaceholder = attrNum
        
        return text
    }()
    lazy var caloriesUnitLabel: UILabel = {
        let lab = UILabel()
        lab.text = "千卡"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "我们运用 Katch-McArdle 公式计算出了您的瘦体重质量、基础代谢率和每日总消耗热量。这个预估值已包括了您日常活动和运动的热量消耗，因此无需额外记录运动量。"
        lab.text = "我们运用 Katch-McArdle 公式计算出了您的瘦体重质量、基础代谢率和每日总消耗热量。这个预估值已包括了您日常活动和运动的热量消耗，因此无需额外记录运动量。如果您觉得该数值过高或过低，可以点击并手动调整。"
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    lazy var tipsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("为什么选择Katch-McArdle公式?", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_DISABLE_BG_THEME, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(showTipsAction), for: .touchUpInside)
        
        return btn
    }()
}

extension QuestionResultBaseVM{
    @objc func bgViewTapAction() {
        caloriesTextField.becomeFirstResponder()
    }
    @objc func showTipsAction(){
        self.caloriesTextField.resignFirstResponder()
        if self.showTipsBlock != nil{
            self.showTipsBlock!()
        }
    }
}

extension QuestionResultBaseVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(caloriesBgView)
        caloriesBgView.addSubview(caloriesTextField)
        caloriesBgView.addSubview(caloriesUnitLabel)
        
        addSubview(tipsLabel)
        addSubview(tipsButton)
        
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(28))
//            make.right.equalTo(kFitWidth(-28))
            make.width.equalTo(kFitWidth(320))
            make.top.equalTo(kFitWidth(20))
        }
        caloriesBgView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(kFitWidth(-28))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(60))
            make.height.equalTo(kFitWidth(64))
        }
        caloriesTextField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualToSuperview()
        }
        caloriesUnitLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesTextField.snp.right).offset(kFitWidth(5))
            make.centerY.lessThanOrEqualToSuperview()
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(kFitWidth(-28))
            make.top.equalTo(caloriesBgView.snp.bottom).offset(kFitWidth(22))
        }
        tipsButton.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(20))
            make.height.equalTo(kFitWidth(30))
        }
    }
}

extension QuestionResultBaseVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        
        if textField.text?.count ?? 0 >= 5{
            return false
        }
        
        return true
    }
}
