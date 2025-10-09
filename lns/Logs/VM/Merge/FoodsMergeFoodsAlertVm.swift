//
//  FoodsMergeFoodsAlertVm.swift
//  lns
//
//  Created by Elavatine on 2025/3/17.
//


import MCToast

class FoodsMergeFoodsAlertVm: UIView {
    
    var whiteViewHeight = kFitWidth(294)+kFitWidth(54)+WHUtils().getBottomSafeAreaHeight()
    var whiteViewOriginY = kFitWidth(67)
    
    var carNumber = Float(0)
    var proteinNumber = Float(0)
    var fatNumber = Float(0)
    
    var ctype = "1"
    var index = IndexPath()
    
    var foodsMsgDict = NSMutableDictionary()
    var updateBlock:((NSDictionary)->())?
    
    private let lineLayer = CAShapeLayer()
    var linePath = UIBezierPath()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
        initUI()
        
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
        
        //        let tap = UITapGestureRecognizer.init(target: self, action:#selector(hiddenView))
        //        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        linePath.move(to: CGPointMake(kFitWidth(12), kFitWidth(55)))
        linePath.addLine(to: CGPointMake(SCREEN_WIDHT-kFitWidth(24)-kFitWidth(32), kFitWidth(55)))
        lineLayer.path = linePath.cgPath
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(67) + SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        // 创建下拉手势识别器
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
//        // 将手势识别器添加到view
//        vi.addGestureRecognizer(panGestureRecognizer)
        
        let tap = UITapGestureRecognizer.init(target: self, action:#selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 17, weight: .semibold)
        
        return lab
    }()
    lazy var closeImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "date_fliter_cancel_img")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var closeTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var naturalBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_F7F8FA
        vi.layer.cornerRadius = kFitWidth(13)
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        return vi
    }()
    lazy var caloriesIconImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_merge_calories_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var caloriesNumLabel: UILabel = {
        let lab = UILabel()
        lab.text = "0"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 20, weight: .semibold)
        
        return lab
    }()
    lazy var caloriesUnitLab: UILabel = {
        let lab = UILabel()
        lab.text = "千卡"
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_45
        return lab
    }()
    lazy var carboItemVm: NaturalItemVM = {
        let vm = NaturalItemVM.init(frame: CGRect.init(x: kFitWidth(12), y: kFitWidth(67), width: 0, height: 0))
        vm.circleVi.backgroundColor = .COLOR_CARBOHYDRATE
        vm.contentLabel.text = "碳水 0g"
        return vm
    }()
    lazy var proteinItemVm: NaturalItemVM = {
        let vm = NaturalItemVM.init(frame: CGRect.init(x: (SCREEN_WIDHT-kFitWidth(32))*0.5-kFitWidth(50), y: kFitWidth(67), width: 0, height: 0))
        vm.circleVi.backgroundColor = .COLOR_PROTEIN
        vm.contentLabel.text = "蛋白质 0g"
        return vm
    }()
    lazy var fatItemVm: NaturalItemVM = {
        let vm = NaturalItemVM.init(frame: CGRect.init(x: (SCREEN_WIDHT-kFitWidth(32))-kFitWidth(112), y: kFitWidth(67), width: 0, height: 0))
        vm.circleVi.backgroundColor = .COLOR_FAT
        vm.contentLabel.text = "脂肪 0g"
        return vm
    }()
    lazy var numberSpecVm: FoodsMergeAlertSpecVM = {
        let vm = FoodsMergeAlertSpecVM.init(frame: CGRect.init(x: 0, y: kFitWidth(170), width: 0, height: 0))
        vm.changeBlock = {(dict)in
            DLLog(message: "FoodsMergeAlertSpecVM:\(dict)")
            self.carNumber = dict.stringValueForKey(key: "carbohydrate").floatValue
            self.proteinNumber = dict.stringValueForKey(key: "protein").floatValue
            self.fatNumber = dict.stringValueForKey(key: "fat").floatValue
            
            self.caloriesNumLabel.text = dict.stringValueForKey(key: "calories")
            self.carboItemVm.contentLabel.text = "碳水 \(WHUtils.convertStringToStringOneDigit("\(self.carNumber)") ?? "0")g"
            self.proteinItemVm.contentLabel.text = "蛋白质 \(WHUtils.convertStringToStringOneDigit("\(self.proteinNumber)") ?? "0")g"
            self.fatItemVm.contentLabel.text = "脂肪 \(WHUtils.convertStringToStringOneDigit("\(self.fatNumber)") ?? "0")g"
            self.numberSpecVm.specLabel.text = dict.stringValueForKey(key: "specName")
            self.numberSpecVm.specName = dict.stringValueForKey(key: "specName")
        }
        return vm
    }()
    lazy var buttonBottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: self.whiteViewHeight-kFitWidth(70)-WHUtils().getBottomSafeAreaHeight(), width: SCREEN_WIDHT, height: kFitWidth(70)+WHUtils().getBottomSafeAreaHeight()))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(20), y: kFitWidth(5), width: SCREEN_WIDHT-kFitWidth(40), height: kFitWidth(48))
//        btn.frame = CGRect.init(x: kFitWidth(20), y: self.whiteViewHeight-kFitWidth(70)-WHUtils().getBottomSafeAreaHeight(), width: kFitWidth(335), height: kFitWidth(48))
        btn.backgroundColor = .THEME
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return btn
    }()
}

extension FoodsMergeFoodsAlertVm{
    func initUI() {
        addSubview(whiteView)
        
        whiteView.addSubview(nameLabel)
        whiteView.addSubview(closeImgView)
        whiteView.addSubview(closeTapView)
        whiteView.addSubview(naturalBottomView)
        whiteView.addSubview(numberSpecVm)
        naturalBottomView.layer.addSublayer(lineLayer)
        naturalBottomView.addSubview(caloriesIconImg)
        naturalBottomView.addSubview(caloriesNumLabel)
        naturalBottomView.addSubview(caloriesUnitLab)
        naturalBottomView.addSubview(carboItemVm)
        naturalBottomView.addSubview(proteinItemVm)
        naturalBottomView.addSubview(fatItemVm)
        
        whiteView.addSubview(buttonBottomView)
        buttonBottomView.addSubview(saveButton)
        
        setConstrait()
        lineLayer.strokeColor = UIColor.COLOR_GRAY_D6D6D6.cgColor
        lineLayer.fillColor = nil
        lineLayer.lineWidth = kFitWidth(1) // 线宽
        lineLayer.lineDashPattern = [5,2]
        
        buttonBottomView.addShadow()
    }
    func setConstrait() {
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(54))
            make.right.equalTo(kFitWidth(-80))
        }
        closeImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.width.height.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualTo(nameLabel)
        }
        closeTapView.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(54))
            make.center.lessThanOrEqualTo(closeImgView)
        }
        naturalBottomView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(102))
            make.top.equalTo(kFitWidth(68))
        }
        caloriesIconImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(18))
            make.width.height.equalTo(kFitWidth(20))
        }
        caloriesNumLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
//            make.top.equalTo(kFitWidth(13))
            make.centerY.lessThanOrEqualTo(caloriesIconImg)
        }
        caloriesUnitLab.snp.makeConstraints { make in
            make.left.equalTo(caloriesNumLabel.snp.right).offset(kFitWidth(2))
            make.bottom.equalTo(caloriesNumLabel)
        }
    }
    func updateUI(dict:NSDictionary) {
        foodsMsgDict = NSMutableDictionary(dictionary: dict)
        self.numberSpecVm.foodsMsgDict = dict["foods"]as? NSDictionary ?? [:]
        self.numberSpecVm.calculateSpecWeight()
        
        self.carNumber = dict.stringValueForKey(key: "carbohydrate").floatValue
        self.proteinNumber = dict.stringValueForKey(key: "protein").floatValue
        self.fatNumber = dict.stringValueForKey(key: "fat").floatValue
        
        self.nameLabel.text = dict.stringValueForKey(key: "fname")
        self.caloriesNumLabel.text = "\(Int(dict.doubleValueForKey(key: "calories").rounded()))"
        self.carboItemVm.contentLabel.text = "碳水 \(WHUtils.convertStringToString(String(format: "%.1f", dict.doubleValueForKey(key: "carbohydrate"))) ?? "0")g"
        self.proteinItemVm.contentLabel.text = "蛋白质 \(WHUtils.convertStringToString(String(format: "%.1f", dict.doubleValueForKey(key: "protein"))) ?? "0")g"
        self.fatItemVm.contentLabel.text = "脂肪 \(WHUtils.convertStringToString(String(format: "%.1f", dict.doubleValueForKey(key: "fat"))) ?? "0")g"
        self.numberSpecVm.numberTextField.text = "\(WHUtils.convertStringToStringThreeDigit(String(format: "%.3f", dict.doubleValueForKey(key: "qty"))) ?? "0")"
        self.numberSpecVm.specLabel.text = dict.stringValueForKey(key: "spec")
        self.showView()
    }
}

extension FoodsMergeFoodsAlertVm{
    @objc func nothingToDo() {
        self.numberSpecVm.numberTextField.resignFirstResponder()
    }
    @objc func saveAction(){
        if self.numberSpecVm.numberTextField.text?.floatValue ?? 0 <= 0{
            MCToast.mc_text("食物数量数据错误！")
            return
        }
        if caloriesNumLabel.text?.floatValue ?? 0 >= 100000 {
            MCToast.mc_text("食物热量数据错误！")
            return
        }
        if self.carNumber >= 100000 {
            MCToast.mc_text("食物碳水数据错误！")
            return
        }
        if self.proteinNumber >= 100000 {
            MCToast.mc_text("食物蛋白质数据错误！")
            return
        }
        if self.fatNumber >= 100000 {
            MCToast.mc_text("食物脂肪数据错误！")
            return
        }
        foodsMsgDict.setValue("\(caloriesNumLabel.text?.floatValue ?? 0)", forKey: "calories")
        foodsMsgDict.setValue("\(carNumber)", forKey: "carbohydrate")
        foodsMsgDict.setValue("\(proteinNumber)", forKey: "protein")
        foodsMsgDict.setValue("\(fatNumber)", forKey: "fat")
        foodsMsgDict.setValue("\(self.numberSpecVm.numberTextField.text?.floatValue ?? 0)", forKey: "qty")
        foodsMsgDict.setValue("\(self.numberSpecVm.specName)", forKey: "spec")
        
        DLLog(message: "\(foodsMsgDict)")
        self.updateBlock?(foodsMsgDict)
        self.hiddenView()
    }
    func showView() {
        self.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
            self.whiteView.alpha = 1
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)))
        }
    }
    @objc func hiddenView() {
        self.nothingToDo()
        NotificationCenter.default.removeObserver(self)
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.0)
            self.whiteView.alpha = 0.5
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
        }completion: { t in
            self.isHidden = true
        }
    }
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // 获取当前手势所在的view
        if let view = gesture.view {
            // 根据手势移动view的位置
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: view)
//                DLLog(message: "translation.y:\(translation.y)")
                if translation.y < 0 && view.frame.minY <= self.whiteViewOriginY{
                    return
                }
                view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
                gesture.setTranslation(.zero, in: view)
                
            case .ended:
                if view.frame.minY - self.whiteViewOriginY >= kFitWidth(20){
                    self.hiddenView()
                }else{
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
                    }
                }
            default:
                break
            }
        }
    }
    
}

extension FoodsMergeFoodsAlertVm{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: keyboardSize.origin.y-self.whiteViewHeight*0.5+kFitWidth(16))
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
        }
    }
}

