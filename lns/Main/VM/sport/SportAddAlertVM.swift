//
//  SportAddAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//

import MCToast

class SportAddAlertVM: UIView {
    
    var whiteViewHeight = kFitWidth(234)
    var confirmBlock:(()->())?
    
    var model = SportCatogaryItemModel()
    var historyModel = SportHistoryModel()
    var weight = Float(0)
    var minute = Float(0)
    var calories = Float(0)
    
    var isCustom = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
                
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(10))
        vi.backgroundColor = .white
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    
    lazy var cancelBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "添加运动"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()
    lazy var confirmBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        return vi
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
    lazy var metsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        return lab
    }()
    lazy var caloriesLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        return lab
    }()
    lazy var weightItemVm: SportAddAlertItemVM = {
        let vm = SportAddAlertItemVM.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(146), width: 0, height: 0))
        vm.nameLabel.text = "我的体重"
        vm.unitLabel.text = "（\(UserInfoModel.shared.weightUnitName)）"
        vm.numberText.text = "\(WHUtils.convertStringToStringOneDigit("\(UserInfoModel.shared.lastWeight * UserInfoModel.shared.weightCoefficient)") ?? "")"
        self.weight = Float(UserInfoModel.shared.lastWeight)
        vm.dataChangeBlock = {(text)in
            DLLog(message: "体重：\(text)")
            var dataNum = text.floatValue
            self.weight = dataNum/Float(UserInfoModel.shared.weightCoefficient)
            UserInfoModel.shared.lastWeight = Double(self.weight)
            self.calculateCaloriesNumber()
        }
        return vm
    }()
    lazy var timeItemVm: SportAddAlertItemVM = {
        let vm = SportAddAlertItemVM.init(frame: CGRect.init(x: kFitWidth(192), y: kFitWidth(146), width: 0, height: 0))
        vm.nameLabel.text = "运动时长"
        vm.unitLabel.text = "（分钟）"
//        vm.numberText.text = "32"
        
        vm.dataChangeBlock = {(text)in
            DLLog(message: "时长：\(text)")
            self.minute = text.floatValue
            self.calculateCaloriesNumber()
        }
        return vm
    }()
}

extension SportAddAlertVM{
    func updateUI(sModel:SportCatogaryItemModel) {
        self.model = sModel
        self.historyModel = SportHistoryModel()
        nameLabel.text = sModel.name
        
        if model.met.doubleValue > 0 {
            metsLabel.text = "\(model.met) METs"
            self.isCustom = false
        }else{
            metsLabel.text = "\(Int(model.calories.doubleValue.rounded()))千卡 / \(Int(model.minute.doubleValue.rounded()))分钟"
            self.isCustom = true
        }
        judgeCustom()
        caloriesLabel.text = ""
        timeItemVm.numberText.text = ""
        self.minute = 0
    }
    func updateUIForHistort(sModel:SportHistoryModel) {
        self.model = SportCatogaryItemModel()
        self.historyModel = sModel
        nameLabel.text = sModel.name
        
        if sModel.met.doubleValue > 0 {
            metsLabel.text = "\(sModel.met) METs"
            self.isCustom = false
        }else{
            metsLabel.text = "\(sModel.caloriesUser)千卡 / \(sModel.durationUser)分钟"
            self.isCustom = true
        }
        judgeCustom()
        caloriesLabel.text = "消耗：\(Int(sModel.calories.doubleValue.rounded()))千卡"
        timeItemVm.numberText.text = "\(sModel.duration)"
        self.minute = Float(sModel.duration.doubleValue)
    }
    func judgeCustom() {
        if isCustom{
            weightItemVm.isHidden = true
            timeItemVm.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(146), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(64))
        }else{
            weightItemVm.isHidden = false
            timeItemVm.frame = CGRect.init(x: kFitWidth(192), y: kFitWidth(146), width: kFitWidth(167), height: kFitWidth(64))
        }
    }
    func showSelf() {
        self.isHidden = false
        self.timeItemVm.numberText.becomeFirstResponder()
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
//            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-self.whiteViewHeight, width: SCREEN_WIDHT, height: self.whiteViewHeight)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.2)
        } completion: { t in
//            self.alpha = 1
        }
    }
    @objc func cancelAction() {
        self.hiddenSelf()
    }
    @objc func hiddenSelf() {
        self.weightItemVm.numberText.resignFirstResponder()
        self.timeItemVm.numberText.resignFirstResponder()
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: self.whiteViewHeight)
        } completion: { t in
//            self.alpha = 0
            self.isHidden = true
            self.backgroundColor = .clear
        }
    }
    //MARK: 计算运动消耗  Calories Burned = Time(in minutes) × MET × Body Weight (kg) ÷ 200
    //运动净消耗(kcal) = (MET-1)x体重(kg)x 时间(小时)
    func calculateCaloriesNumber() {
        if isCustom{
            if self.model.id.count > 0 {
                calories = Float(self.model.calories.doubleValue / self.model.minute.doubleValue) * minute
            }else{
                calories = Float(self.historyModel.caloriesUser.doubleValue / self.historyModel.durationUser.doubleValue) * minute
            }
        }else{
            if self.model.id.count > 0 {
                calories = (Float(self.model.met.doubleValue) - 1) * weight * (minute / 60)
//                calories = minute * self.model.met.floatValue * weight / 200
            }else{
                calories = (Float(self.historyModel.met.doubleValue) - 1) * weight * (minute / 60)
//                calories = minute * self.historyModel.met.floatValue * weight / 200
//                calories = minute * self.historyModel.met.floatValue * weight / 200
            }
        }
        
        DLLog(message: "\(calories)")
        if calories > 0 {
            caloriesLabel.text = "消耗：\(Int(calories.rounded()))千卡"
        }else{
            caloriesLabel.text = ""
        }
    }
    
    @objc func confirmAction() {
        //体重数据 不能小于5kg
        if self.weight * Float(UserInfoModel.shared.weightCoefficient) < 5 && isCustom == false{
            MCToast.mc_text("请输入合理的体重数值",offset: SCREEN_HEIGHT - self.whiteView.frame.minY + kFitWidth(40))
            return
        }
        if self.minute < 0.1 {
            MCToast.mc_text("请输入合理的运动时长",offset: SCREEN_HEIGHT - self.whiteView.frame.minY + kFitWidth(40))
            return
        }
        self.hiddenSelf()
        
        if self.confirmBlock != nil{
            self.confirmBlock!()
        }
    }
    @objc func nothingToDo() {
        
    }
}

extension SportAddAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addShadow()
        
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(confirmBtn)
        whiteView.addSubview(lineView)
        
        whiteView.addSubview(nameLabel)
        whiteView.addSubview(metsLabel)
        whiteView.addSubview(caloriesLabel)
        
        whiteView.addSubview(weightItemVm)
        whiteView.addSubview(timeItemVm)
        
        setConstrait()
    }
    
    func setConstrait()  {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
        }
        cancelBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(56))
        }
        confirmBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(cancelBtn)
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(56))
            make.height.equalTo(kFitWidth(1))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(24))
        }
        metsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(54))
        }
        caloriesLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(metsLabel)
        }
    }
}

extension SportAddAlertVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            DLLog(message: "keyboardWillShow:\(keyboardSize)")
//            DLLog(message: "\(SCREEN_HEIGHT)")
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: keyboardSize.origin.y-self.whiteViewHeight*0.5)
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
//        DLLog(message: "keyboardWillHide:")
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-self.whiteViewHeight*0.5)
        }completion: { t in
//            self.hiddenSelf()
        }
    }
}
