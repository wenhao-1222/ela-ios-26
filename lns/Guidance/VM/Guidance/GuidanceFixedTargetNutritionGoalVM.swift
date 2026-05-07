//
//  GuidanceFixedTargetNutritionGoalVM.swift
//  lns
//
//  Created by Codex on 2026/3/19.
//

import UIKit
import SnapKit
import MCToast

class GuidanceFixedTargetNutritionGoalVM: UIView {

    var saveBlock: (() -> ())?
    var tipsTapBlock:(()->())?
    var carNumber = 0
    var proteinNumber = 0
    var fatNumber = 0
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "你的卡路里和营养素目标"
        lab.text = "输入你的每日营养目标"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    private lazy var tipsButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("身体是动态的，目标也应如此", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.addTarget(self, action: #selector(tipsTapAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: (SCREEN_WIDHT-kFitWidth(320))*0.5, y: kFitWidth(192)+statusBarHeight, width: kFitWidth(320), height: kFitWidth(414)))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var labelOne : UILabel = {
        let lab = UILabel()
        lab.text = "-"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_25//WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = UIFont().DDInFontMedium(fontSize: 28)
        
        return lab
    }()
    lazy var labelTwo : UILabel = {
        let lab = UILabel()
        lab.text = "卡路里 (千卡)"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var goalImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_goal_selected")
        
        return img
    }()
    lazy var carVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(114), width: kFitWidth(320), height: 0))
        vm.titleLabel.text = "碳水化合物"
        vm.textField.textContentType = nil
//        vm.allowsLeadingZero = true
        
        vm.numberChangeBlock = {(number)in
            self.carNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var proteinVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(182), width: kFitWidth(320), height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.textField.textContentType = nil
        
        vm.numberChangeBlock = {(number)in
            self.proteinNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var fatVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(250), width: kFitWidth(320), height: 0))
        vm.titleLabel.text = "脂肪"
        vm.textField.textContentType = nil
        
        vm.numberChangeBlock = {(number)in
            self.fatNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(20), y: kFitWidth(346), width: kFitWidth(281), height: kFitWidth(44))
        btn.setTitle("保存目标", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
}

extension GuidanceFixedTargetNutritionGoalVM{
    @objc func tipsTapAction(){
        self.carVm.textField.resignFirstResponder()
        self.proteinVm.textField.resignFirstResponder()
        self.fatVm.textField.resignFirstResponder()
        self.tipsTapBlock?()
    }
    @objc func nextAction(){
        self.checkValue()
    }
    func checkValue() {
        if carVm.textField.text?.count == 0 {
            MCToast.mc_text("请输入碳水化合物数值",respond: .allow)
            return
        }
        
        if Int(carVm.textField.text ?? "0") ?? 0 >= 0 && Int(carVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("碳水化合物目标数值范围 0 ~ 4999 g",respond: .allow)
            return
        }
        if Int(proteinVm.textField.text ?? "0") ?? 0 >= 1 && Int(proteinVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("蛋白质目标数值范围 1 ~ 4999 g",respond: .allow)
            return
        }
        if Int(fatVm.textField.text ?? "0") ?? 0 >= 1 && Int(fatVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("脂肪目标数值范围 1 ~ 4999 g",respond: .allow)
            return
        }
        QuestinonaireMsgModel.shared.carbohydrates = carVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.protein = proteinVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.fats = fatVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.calories = labelOne.text ?? "0"
        
        QuestinonaireMsgModel.shared.carbohydratesNumber = carVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.proteinNumber = proteinVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.fatsNumber = fatVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.caloriesNumber = labelOne.text ?? "0"
        
//        WHBaseViewVC().changeRootVcToLogin()
        
        self.saveBlock?()
    }
    func calculateNumber() {
        if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
            labelOne.text = "-"
            labelOne.textColor = .COLOR_TEXT_TITLE_0f1214_25//WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
            return
        }
        //((protein + carbohydrate) * 4) + (fat * 9);
        let number = (proteinNumber + carNumber) * 4 + fatNumber * 9
        labelOne.text = "\(number)"
        labelOne.textColor = .COLOR_TEXT_TITLE_0f1214
    }
}

extension GuidanceFixedTargetNutritionGoalVM{
    func initUI() {
        backgroundColor = .COLOR_BG_F2//WHColor_16(colorStr: "FAFAFA")
        addSubview(titleLabel)
        addSubview(tipsButton)
        addSubview(whiteView)
        whiteView.addSubview(labelOne)
        whiteView.addSubview(labelTwo)
        whiteView.addSubview(goalImgView)
        whiteView.addSubview(carVm)
        whiteView.addSubview(proteinVm)
        whiteView.addSubview(fatVm)
        
        whiteView.addSubview(nextBtn)
        
        whiteView.addShadow()
        
        setConstrait()
    }
    func setConstrait(){
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(90)+statusBarHeight)
        }
        tipsButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
        }
        labelOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(24))
        }
        labelTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(62))
        }
        goalImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(24))
            make.width.height.equalTo(kFitWidth(48))
        }
    }
}
