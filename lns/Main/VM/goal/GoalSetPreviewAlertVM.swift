//
//  GoalSetPreviewAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/3.
//


class GoalSetPreviewAlertVM: UIView {
    
    var controller = WHBaseViewVC()
    var whiteViewHeight = kFitWidth(478)+WHUtils().getBottomSafeAreaHeight()
    var whiteViewOriginY = kFitWidth(0)
    
    
    let itemVmWidth = (SCREEN_WIDHT-kFitWidth(11))/7//kFitWidth(52)
    let itemVmHeight = kFitWidth(76)
    
    var timeDataSourceArray = NSMutableArray()
    var itemVmArray:[NaturalStatCalendarCollectionCellItemVM] = [NaturalStatCalendarCollectionCellItemVM]()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight
        
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(12))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        // 创建下拉手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        
        // 将手势识别器添加到view
        vi.addGestureRecognizer(panGestureRecognizer)
        
        return vi
    }()
    lazy var headView: NaturalStatCalendarHeadView = {
        let vm = NaturalStatCalendarHeadView.init(frame: .zero)
        vm.resetSubViewForGoalHead()
        return vm
    }()
    lazy var saveBtn : UIButton = {
        let btn = UIButton()
//        btn.frame = CGRect.init(x: kFitWidth(16), y: self.centerVm.frame.maxY + kFitWidth(40), width: kFitWidth(288), height: kFitWidth(48))
        btn.setTitle("保存目标", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME, for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .disabled)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.enablePressEffect()
//        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return btn
    }()
}

extension GoalSetPreviewAlertVM{
    @objc func nothingAction(){
        
    }
    @objc func showSelf() {
        self.isHidden = false
        bgView.isUserInteractionEnabled = false
        bgView.alpha = 0
        
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight
//        UIView.animate(withDuration: 0.25, delay: 0,options: .curveEaseInOut) {
        UIView.animate(withDuration: 0.35,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5-kFitWidth(2))
            self.bgView.alpha = 0.25
        }completion: { t in
            self.bgView.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.15, delay: 0,options: .curveEaseInOut) {
                self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
            }
        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
            self.bgView.alpha = 0
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
                 DLLog(message: "translation.y:\(translation.y)")
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

extension GoalSetPreviewAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        
        whiteView.addSubview(headView)
        whiteView.addSubview(saveBtn)
        
        dealDateArray()
        updateTimeItemVm()
        layoutWhiteViewFrame()
        saveBtn.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(8))
        }
        // 初始位置放在最终停靠位置，实际展示用 transform 下移
        whiteView.transform = .identity
    }
    
    private func layoutWhiteViewFrame() {
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func updateGoalCircleData(goalArray:NSArray,todayIndex:Int) {
        var caloriesMax = Double(0)
        var carboMax = Double(0)
        var proteinMax = Double(0)
        var fatMax = Double(0)
        let today = todayIndex //> 0 ?  todayIndex - 1 : 0
        
        for i in 0..<goalArray.count{
            let dict = goalArray[i]as? NSDictionary ?? [:]
            if caloriesMax < dict.doubleValueForKey(key: "calories"){
                caloriesMax = dict.doubleValueForKey(key: "calories")
            }
            if carboMax < dict.doubleValueForKey(key: "carbohydrates"){
                carboMax = dict.doubleValueForKey(key: "carbohydrates")
            }
            if proteinMax < dict.doubleValueForKey(key: "proteins"){
                proteinMax = dict.doubleValueForKey(key: "proteins")
            }
            if fatMax < dict.doubleValueForKey(key: "fats"){
                fatMax = dict.doubleValueForKey(key: "fats")
            }
        }
        
        var maxValue = carboMax
        if maxValue < proteinMax{
            maxValue = proteinMax
        }
        if maxValue < fatMax{
            maxValue = fatMax
        }
        for i in 0..<itemVmArray.count{
            let vm = itemVmArray[i]
            var dict = goalArray[(i+today)%goalArray.count] as? NSDictionary ?? [:]
            
            if (((i+today)/goalArray.count) % 2) == 0{
                vm.updateBgColor(color: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1))
            }else{
                vm.updateBgColor(color: .COLOR_TEXT_TITLE_0f1214_03)
            }
            vm.updateUI(dict: dict,
                        caloriesden: "\(caloriesMax)",
                        carbohydrateden: "\(maxValue)",
                        proteinden: "\(maxValue)",
                        fatden: "\(maxValue)")
        }
    }
    func updateGoalData(goalArray:NSArray,todayIndex:Int?=0) {
        var caloriesMax = Double(0)
        var carboMax = Double(0)
        var proteinMax = Double(0)
        var fatMax = Double(0)
        
        for i in 0..<goalArray.count{
            let dict = goalArray[i]as? NSDictionary ?? [:]
            if caloriesMax < dict.doubleValueForKey(key: "calories"){
                caloriesMax = dict.doubleValueForKey(key: "calories")
            }
            if carboMax < dict.doubleValueForKey(key: "carbohydrates"){
                carboMax = dict.doubleValueForKey(key: "carbohydrates")
            }
            if proteinMax < dict.doubleValueForKey(key: "proteins"){
                proteinMax = dict.doubleValueForKey(key: "proteins")
            }
            if fatMax < dict.doubleValueForKey(key: "fats"){
                fatMax = dict.doubleValueForKey(key: "fats")
            }
        }
        
        var maxValue = carboMax
        if maxValue < proteinMax{
            maxValue = proteinMax
        }
        if maxValue < fatMax{
            maxValue = fatMax
        }
        var firstWeekDay = 0
        for i in 0..<itemVmArray.count{
            let vm = itemVmArray[i]
            var dict = goalArray[i%goalArray.count] as? NSDictionary ?? [:]
            
            if goalArray.count == 7 {
                let sdate = self.timeDataSourceArray[i]as? String ?? "\(Date().todayDate)"
                var weekDay = Date().getWeekdayIndex(from: sdate)
                DLLog(message: "weekDay:\(sdate)  ---  \(weekDay)")
//                if weekDay == 7 {
//                    weekDay = 6
//                }
                dict = goalArray[weekDay-1] as? NSDictionary ?? [:]
                if i == 0 {
                    firstWeekDay = weekDay - 1
                }
                if (((i+firstWeekDay)/7) % 2) == 0 {
//                    vm.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.06)
                    vm.updateBgColor(color: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1))
                }else{
//                    vm.backgroundColor = .clear
                    vm.updateBgColor(color: .COLOR_TEXT_TITLE_0f1214_03)
                }
            }else{
                if ((i/goalArray.count) % 2) == 0{
//                    vm.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.06)
                    vm.updateBgColor(color: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1))
                }else{
//                    vm.backgroundColor = .clear
                    vm.updateBgColor(color: .COLOR_TEXT_TITLE_0f1214_03)
                }
            }
            vm.updateUI(dict: dict,
                        caloriesden: "\(caloriesMax)",
                        carbohydrateden: "\(maxValue)",
                        proteinden: "\(maxValue)",
                        fatden: "\(maxValue)")
//            vm.updateUI(dict: dict,
//                        caloriesden: "\(caloriesMax)",
//                        carbohydrateden: "\(carboMax)",
//                        proteinden: "\(proteinMax)",
//                        fatden: "\(fatMax)")
        }
    }
    func updateTimeItemVm() {
        var firstWeekDay = 0
        initVmArray()
        for i in 0..<timeDataSourceArray.count{
            let sdate = self.timeDataSourceArray[i]as? String ?? "\(Date().todayDate)"
            let serialQueue = DispatchQueue(label: "com.stat.calculate\(i)")
            
            let dayDict = self.timeDataSourceArray[i]as? NSDictionary ?? [:]
            var originX = kFitWidth(0)
            var originY = kFitWidth(0)
            
            serialQueue.async {
                let weekDay = Date().getWeekdayIndex(from: sdate)
                
                if i == 0 {
                    firstWeekDay = weekDay - 1
                }
                
//                originX = kFitWidth(11)+self.getButtonOriginX(weekDay: weekDay)
                originX = kFitWidth(11)+self.itemVmWidth*CGFloat(weekDay-1)
                originY = (kFitWidth(76) + kFitWidth(16))*CGFloat((i+firstWeekDay)/7) + kFitWidth(48)
                
                if i == self.timeDataSourceArray.count - 1{
                    DispatchQueue.main.async(execute: {
                        self.whiteViewHeight = originY + self.itemVmHeight + WHUtils().getBottomSafeAreaHeight() + kFitWidth(12) + kFitWidth(60)
//                        self.whiteViewOriginY = SCREEN_HEIGHT - self.whiteViewHeight
                        self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: self.whiteViewHeight)
                        self.whiteView.backgroundColor = .white
                        self.whiteView.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(12))
                    })
                }
            }
            
            serialQueue.async {
                DispatchQueue.main.sync(execute: {
                    let vm = NaturalStatCalendarCollectionCellItemVM.init(frame: CGRect.init(x: originX, y: originY, width: self.itemVmWidth, height: self.itemVmHeight))
                    vm.fitnessLabel.isHidden = true
                    self.whiteView.addSubview(vm)
                    self.itemVmArray[i] = vm
                    vm.updateDaysLabel(sdate: sdate)
                    if i % 7 == 0 {
                        if i > 0 {
                            let vi = UIView.init(frame: CGRect.init(x: 0, y: CGFloat((i+firstWeekDay)/7)*kFitWidth(91)+kFitWidth(48), width: SCREEN_WIDHT, height: kFitWidth(1)))
                            vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
                            self.whiteView.addSubview(vi)
                        }
                        let leftVm = NaturalStatCalendarCollectionCellItemLeftVM.init(frame: CGRect.init(x: 0, y: originY, width: 0, height: 0))
                        self.whiteView.addSubview(leftVm)
                    }
                })
            }
        }
    }
    func initVmArray() {
        itemVmArray.removeAll()
        for i in 0..<timeDataSourceArray.count{
            itemVmArray.append(NaturalStatCalendarCollectionCellItemVM())
        }
    }
    func dealDateArray() {
        let todayDate = Date().todayDate
        let nextMonthDate = Date().getNextMonth(nextMonth: 1)
        let days = Date().daysBetweenDate(toDate: nextMonthDate)
        
        for i in 0...days{
            timeDataSourceArray.add("\(Date().nextDay(days: i))")
        }
    }
    func getButtonOriginX(weekDay:Int) -> CGFloat{
        if weekDay == 7 {
            return kFitWidth(0)
        }else{
            return itemVmWidth*CGFloat(weekDay)
        }
    }
}
