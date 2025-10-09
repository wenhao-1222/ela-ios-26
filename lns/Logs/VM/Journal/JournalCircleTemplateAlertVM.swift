//
//  JournalCircleTemplateAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/1.
//


import UIKit

class JournalCircleTemplateAlertVM: UIView {
    
    var whiteViewHeight = kFitWidth(313)+WHUtils().getBottomSafeAreaHeight()
    var confirmBlock:((NSDictionary)->())?
    
    var circleGoalArray = NSArray()
    var btnArray:[UIButton] = [UIButton]()
    var selectIndex = 0
    var selectDict = NSDictionary()
    var sdate = Date().todayDate
    var itmeVmGap = kFitWidth(20)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
//        self.addGestureRecognizer(tap)
//        
        itmeVmGap = (SCREEN_WIDHT-kFitWidth(70)*4-kFitWidth(17.5)*2)/3
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        v.addGestureRecognizer(tap)
        return v
    }()

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
        
        btn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
//        lab.text = "请选择训练部位"
        lab.text = "切换碳循环模板"
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
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()
    lazy var btnBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(6)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var caloriesVm: JournalCircleTemplateNaturalVM = {
        let vm = JournalCircleTemplateNaturalVM.init(frame: CGRect.init(x: kFitWidth(17.5), y: kFitWidth(129)+kFitWidth(60), width: 0, height: 0))
        vm.circleView.backgroundColor = .COLOR_CALORI
        vm.typeLabel.text = "热量（千卡）"
        return vm
    }()
    lazy var carboVm: JournalCircleTemplateNaturalVM = {
        let vm = JournalCircleTemplateNaturalVM.init(frame: CGRect.init(x: self.caloriesVm.frame.maxX+itmeVmGap, y: self.caloriesVm.frame.minY, width: 0, height: 0))
        vm.circleView.backgroundColor = .COLOR_CARBOHYDRATE
        vm.typeLabel.text = "碳水（g）"
        return vm
    }()
    lazy var proteinVm: JournalCircleTemplateNaturalVM = {
        let vm = JournalCircleTemplateNaturalVM.init(frame: CGRect.init(x: self.carboVm.frame.maxX+itmeVmGap, y: self.caloriesVm.frame.minY, width: 0, height: 0))
        vm.circleView.backgroundColor = .COLOR_PROTEIN
        vm.typeLabel.text = "蛋白质（g）"
        return vm
    }()
    lazy var fatVm: JournalCircleTemplateNaturalVM = {
        let vm = JournalCircleTemplateNaturalVM.init(frame: CGRect.init(x: self.proteinVm.frame.maxX+itmeVmGap, y: self.caloriesVm.frame.minY, width: 0, height: 0))
        vm.circleView.backgroundColor = .COLOR_FAT
        vm.typeLabel.text = "脂肪（g）"
        return vm
    }()
}

extension JournalCircleTemplateAlertVM{
    func showSelf() {
        updateBtnUI()
        self.isHidden = false
        
        bgView.isUserInteractionEnabled = false
        
        // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0

        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.bgView.alpha = 0.25
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
            
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
//        UIView.animate(withDuration: 0.15,delay: 0,options: .curveLinear) {
//            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-self.whiteViewHeight, width: SCREEN_WIDHT, height: self.whiteViewHeight)
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
//        } completion: { t in
////            self.alpha = 1
//        }

    }
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
//        UIView.animate(withDuration: 0.15,delay: 0,options: .curveLinear) {
//            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: self.whiteViewHeight)
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
//        } completion: { t in
////            self.alpha = 0
//            self.isHidden = true
//            self.backgroundColor = .clear
//        }
    }
    
    @objc func confirmAction() {
        self.hiddenSelf()
        let dict = self.circleGoalArray[self.selectIndex]as? NSDictionary ?? [:]
        confirmBlock?(dict)
    }
    @objc func nothingToDo() {
        
    }
}

extension JournalCircleTemplateAlertVM{
    @objc func btnTapAction(sender:UIButton) {
        self.selectIndex = sender.tag - 2400
        self.selectButton()
    }
}

extension JournalCircleTemplateAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
//        whiteView.addShadow()
        
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(confirmBtn)
        whiteView.addSubview(lineView)
        
        whiteView.addSubview(btnBgView)
        
        whiteView.addSubview(caloriesVm)
        whiteView.addSubview(carboVm)
        whiteView.addSubview(proteinVm)
        whiteView.addSubview(fatVm)
        
        layoutWhiteViewFrame()
        setConstrait()
        
        // 初始位置放在最终停靠位置，实际展示用 transform 下移
        whiteView.transform = .identity
    }
    
    private func layoutWhiteViewFrame() {
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func setConstrait()  {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(55))
        }
        cancelBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(55))
        }
        confirmBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(cancelBtn)
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(55))
            make.height.equalTo(kFitWidth(5))
        }
        btnBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(42))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(48))
        }
    }
    func updateBtnUI() {
        btnArray.removeAll()
        for vi in btnBgView.subviews{
            vi.removeFromSuperview()
        }
        
        if let circleGoalArrayTemp = UserDefaults.getArray(forKey: .circleGoalArray){
            circleGoalArray = circleGoalArrayTemp as NSArray
        }else{
            circleGoalArray = NSArray()
        }
        
        
        if circleGoalArray.count > 0 {
            let btnWidth = (SCREEN_WIDHT-kFitWidth(32)-kFitWidth(8))/CGFloat(circleGoalArray.count)
            let btnHeight = kFitWidth(40)
            
            let selfDate = Date().changeDateStringToDate(dateString: self.sdate)
            let daysGap = selfDate.daysDifference(from: UserInfoModel.shared.ccStartDate) ?? 0
            selectIndex = daysGap + UserInfoModel.shared.ccStartOffsetIndex//abs(daysGap + UserInfoModel.shared.ccStartOffsetIndex)
            
            if selectIndex < 0{
                selectIndex = abs(daysGap + UserInfoModel.shared.ccStartOffsetIndex)
            }
            if selectIndex >= circleGoalArray.count{
                selectIndex = selectIndex%(circleGoalArray.count)
            }
            
            for i in 0..<(circleGoalArray.count){
                let dict = circleGoalArray[i]as? NSDictionary ?? [:]
                let btn = initButton(title: dict.stringValueForKey(key: "carbLabel"), index: i)
                btn.frame = CGRect.init(x: kFitWidth(4) + btnWidth*CGFloat(i), y: kFitWidth(4), width: btnWidth, height: btnHeight)
                btn.tag = 2400 + i
                btnBgView.addSubview(btn)
                btnArray.append(btn)
                btn.addTarget(self, action: #selector(btnTapAction(sender: )), for: .touchUpInside)
                
                if i == selectIndex{
                    selectButton()
                }
            }
        }
    }
    func initButton(title:String,index:Int) -> UIButton {
        let btn = UIButton()
        if title.count > 0 {
            btn.setTitle(title, for: .normal)
        }else{
            let titleStr = getTitleString(index: index)
            btn.setTitle(titleStr, for: .normal)
        }
        
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BG_F5), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .selected)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(6)
        btn.clipsToBounds = true
//        btn.enablePressEffect()
        
        return btn
    }
    func getTitleString(index:Int) -> String {
        if index == 0 {
            return "一"
        }else if index == 1 {
            return "二"
        }else if index == 2 {
            return "三"
        }else if index == 3 {
            return "四"
        }else if index == 4 {
            return "五"
        }else if index == 5 {
            return "六"
        }else {
            return "七"
        }
    }
    func selectButton() {
        for i in 0..<btnArray.count{
            let btn = btnArray[i]
            if i == self.selectIndex{
                btn.isSelected = true
                btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            }else{
                btn.isSelected = false
                btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
            }
        }
        let dict = self.circleGoalArray[self.selectIndex]as? NSDictionary ?? [:]
        self.caloriesVm.numberLabel.text = WHUtils.convertStringToStringNoDigit(dict.stringValueForKey(key: "calories"))
        self.carboVm.numberLabel.text = WHUtils.convertStringToStringNoDigit(dict.stringValueForKey(key: "carbohydrates"))
        self.proteinVm.numberLabel.text = WHUtils.convertStringToStringNoDigit(dict.stringValueForKey(key: "proteins"))
        self.fatVm.numberLabel.text = WHUtils.convertStringToStringNoDigit(dict.stringValueForKey(key: "fats"))
    }
}
