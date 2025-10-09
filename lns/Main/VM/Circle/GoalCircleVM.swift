//
//  GoalCircleVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/18.
//


import Foundation
import UIKit

class GoalCircleVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-WHUtils().getBottomSafeAreaHeight()-kFitWidth(70)//kFitWidth(410) + kFitWidth(56)
    var controller = WHBaseViewVC()
    
    var currentIndex = 0
    var todayIndex = 0
    var daysNumber = 4
    var goalsDataArray = NSMutableArray()
    /// 碳循环标签与天数对应的数据
    var circleTagsArray = NSMutableArray()
    
    var carNumber = 0
    var proteinNumber = 0
    var fatNumber = 0
    var caloriesNumber = 0
    
    var changeItemBlock:((NSDictionary)->())?
    var changeCircleTypeBlock:(()->())?
    var dataChangeBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        getCCTodayIndex()
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        scro.backgroundColor = .COLOR_BG_F5
        scro.bounces = false
        return scro
    }()
    lazy var bgWhiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(200)))
        vi.isUserInteractionEnabled = true
        
        vi.backgroundColor = .white
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "创建自己的目标"
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    
    lazy var tipsLab: UILabel = {
        let lab = UILabel()
        lab.text = "选择日期并调整数值"
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
//        lab.isHidden = true
        
        return lab
    }()
    lazy var changeTypeButton: GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT*0.5, height: selfHeight-WHUtils().getBottomSafeAreaHeight()))
        btn.setTitle("按周设定碳循环", for: .normal)
        btn.setImage(UIImage.init(named: "circle_change_icon"), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.backgroundColor = .clear
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(changeCircleTypeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var circleDaysVm: GoalCircleDaysVM = {
        let vm = GoalCircleDaysVM.init(frame: CGRect.init(x: 0, y: kFitWidth(62), width: 0, height: 0))
        vm.daysChangeBlock = {(daysNum)in
            let oldDays = self.daysNumber
            let oldIndex = self.currentIndex
            self.daysNumber = daysNum

            if daysNum < oldDays {
                if self.goalsDataArray.count >= daysNum {
                    let arr = self.goalsDataArray.subarray(with: NSRange(location: 0, length: daysNum))
                    self.goalsDataArray = NSMutableArray(array: arr)
                }
                if self.circleTagsArray.count >= daysNum {
                    let arr = self.circleTagsArray.subarray(with: NSRange(location: 0, length: daysNum))
                    self.circleTagsArray = NSMutableArray(array: arr)
                }
            } else if daysNum > oldDays {
                let dict = NSMutableDictionary(dictionary: self.goalsDataArray.lastObject as? NSDictionary ?? [:])
//                dict.setValue("", forKey: "cc_label")
                dict.setValue("", forKey: "carbLabel")
                for _ in oldDays..<daysNum {
                    self.circleTagsArray.add("")
                    self.goalsDataArray.add(dict)
                }
            }

//            self.weeksSegmentVm.updateCircleDays(daysNumber: self.daysNumber)
//            self.currentIndex = 0
            let tags = self.circleTagsArray.compactMap { $0 as? String }
            self.weeksSegmentVm.updateCircleDays(daysNumber: self.daysNumber, selectedIndex: (daysNum > oldIndex) ? oldIndex : 0,tags: tags)
            self.currentIndex = daysNum > oldIndex ? oldIndex : 0
//            self.todayIndex = daysNum > self.todayIndex ? self.todayIndex : 0
            
            if daysNum == 7 {
                self.templateVm.setTodayHidden(true)
                let week = Calendar.current.component(.weekday, from: Date())
                self.todayIndex = (week + 5) % 7
            } else {
                self.templateVm.setTodayHidden(false)
                self.todayIndex = daysNum > self.todayIndex ? self.todayIndex : 0
            }

            self.udpateTodayFrame()
            
            self.updateWeeksDayData()
            
            if self.daysNumber == 3{
                self.templateVm.tipsButton.isHidden = false
                self.templateAlertVm.updateContent(circleType: "1")
            }else if  self.daysNumber == 4{
                self.templateVm.tipsButton.isHidden = false
                self.templateAlertVm.updateContent(circleType: "2")
            }else {
                self.templateVm.tipsButton.isHidden = true
            }
            
            if self.currentIndex == self.todayIndex {
                self.templateVm.todaySelectImgView.setImgLocal(imgName: "circle_today_select_icon")
            } else {
                self.templateVm.todaySelectImgView.setImgLocal(imgName: "circle_today_normal_icon")
            }
        }
        return vm
    }()
    
    lazy var weeksSegmentVm : GoalCircleSegmentVM = {
        let vm = GoalCircleSegmentVM.init(frame: CGRect.init(x: 0, y: self.circleDaysVm.frame.maxY + kFitWidth(23), width: 0, height: 0))
        vm.delegate = self
        
        return vm
    }()
    lazy var todayLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = WHColor_16(colorStr: "FF8725")
        lab.text = "今日"
        lab.font = .systemFont(ofSize: 9, weight: .medium)
        lab.textAlignment = .center
        lab.textColor = .white
        
        return lab
    }()
    lazy var circleTagsVm: GoalCircleTagsVM = {
        let vm = GoalCircleTagsVM.init(frame: CGRect.init(x: 0, y: self.weeksSegmentVm.frame.maxY, width: 0, height: 0))
        vm.tagChangeBlock = {(tag)in
            DLLog(message: "碳循环标签：\(tag)")
            if self.circleTagsArray.count > self.currentIndex {
                self.circleTagsArray[self.currentIndex] = tag
            } else {
                while self.circleTagsArray.count <= self.currentIndex {
                    self.circleTagsArray.add("")
                }
                self.circleTagsArray[self.currentIndex] = tag
            }
            if self.goalsDataArray.count > self.currentIndex {
                let dict = NSMutableDictionary(dictionary: self.goalsDataArray[self.currentIndex] as? NSDictionary ?? [:])
//                dict.setValue(tag, forKey: "cc_label")
                dict.setValue(tag, forKey: "carbLabel")
                self.goalsDataArray.replaceObject(at: self.currentIndex, with: dict)
            }
            self.weeksSegmentVm.updateButton(tag: tag)
        }
        return vm
    }()
    lazy var tipsVm: GoalSetTipsVM = {
//        let vm = GoalSetTipsVM.init(frame: CGRect.init(x: 0, y: kFitWidth(186), width: 0, height: 0))
        let vm = GoalSetTipsVM.init(frame: CGRect.init(x: 0, y: self.circleTagsVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
    lazy var carboItemVm: GoalSetWeeksNaturalItemVM = {
        let vm = GoalSetWeeksNaturalItemVM.init(frame: CGRect.init(x: 0, y: self.tipsVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "碳水化合物"
        
        return vm
    }()
    lazy var proteinItemVm: GoalSetWeeksNaturalItemVM = {
        let vm = GoalSetWeeksNaturalItemVM.init(frame: CGRect.init(x: 0, y: self.carboItemVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "蛋白质"
        
        return vm
    }()
    lazy var fatItemVm: GoalSetWeeksNaturalItemVM = {
        let vm = GoalSetWeeksNaturalItemVM.init(frame: CGRect.init(x: 0, y: self.proteinItemVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "脂肪"
        
        return vm
    }()
    lazy var templateVm: GoalSetCircleTemplateVM = {
        let vm = GoalSetCircleTemplateVM.init(frame: CGRect.init(x: 0, y: self.fatItemVm.frame.maxY, width: 0, height: 0))
//        vm.isHidden = true
        vm.todayBlock = { () in
            self.todayIndex = self.currentIndex
            self.udpateTodayFrame()
        }
        vm.tapBlock = {()in
            self.templateAlertVm.showSelf()
        }
        return vm
    }()
    lazy var templateAlertVm: GoalSetCircleTemplateAlertVM = {
        let vm = GoalSetCircleTemplateAlertVM.init(frame: .zero)
        vm.confirmBlock = {(type)in
            self.updateDataForTemplate(type: type)
        }
        return vm
    }()
}

extension GoalCircleVM{
    func initUI() {
        addSubview(scrollView)
        addSubview(lineView)
        scrollView.addSubview(bgWhiteView)
        scrollView.addSubview(titleLab)
        scrollView.addSubview(circleDaysVm)
        scrollView.addSubview(tipsLab)
        scrollView.addSubview(changeTypeButton)
        scrollView.addSubview(weeksSegmentVm)
        scrollView.addSubview(circleTagsVm)
        scrollView.addSubview(tipsVm)
        scrollView.addSubview(carboItemVm)
        scrollView.addSubview(proteinItemVm)
        scrollView.addSubview(fatItemVm)
        scrollView.addSubview(templateVm)
        scrollView.addSubview(todayLabel)
        
        setConstrait()
        if templateVm.frame.maxY - scrollView.frame.size.height > kFitWidth(20){
            scrollView.contentSize = CGSize.init(width: 0, height: templateVm.frame.maxY)
        }
        
        bgWhiteView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: templateVm.frame.maxY)
        
        circleDaysVm.updateDaysNumber(daysNumber: self.daysNumber)
        changeTypeButton.imagePosition(style: .right, spacing: kFitWidth(3))
//        todayLabel.addClipCorner(corners: [.topLeft,.topRight,.bottomRight], radius: kFitWidth(8))
        
        udpateTodayFrame()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(templateAlertVm)
    }
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(24))
        }
        tipsLab.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
        }
        changeTypeButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(titleLab.snp.bottom)
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(24))
        }
        
    }
    func udpateTodayFrame() {
//        let btnWidth = (SCREEN_WIDHT-kFitWidth(27))/CGFloat(daysNumber)
//        
//        todayLabel.frame = CGRect.init(x: kFitWidth(13.5)+btnWidth*CGFloat(todayIndex+1)-kFitWidth(20), y:self.weeksSegmentVm.frame.minY-kFitWidth(8), width: kFitWidth(28), height: kFitWidth(15))
        guard todayIndex < weeksSegmentVm.btnArray.count,
              todayIndex >= 0
        else { return }

        let button = weeksSegmentVm.btnArray[todayIndex]
        let buttonFrame = weeksSegmentVm.convert(button.frame, to: scrollView)

        todayLabel.frame = CGRect(x: buttonFrame.maxX - kFitWidth(20),
                                  y: weeksSegmentVm.frame.minY - kFitWidth(8),
                                  width: kFitWidth(28),
                                  height: kFitWidth(15))
        todayLabel.addClipCorner(corners: [.topLeft, .topRight, .bottomRight], radius: kFitWidth(8))
    }
}

extension GoalCircleVM:GoalCircleSegmentVMDelegate{
    func segment(didSelectItemAt index: Int) {
        currentIndex = index
        updateWeeksDayData()
        
        if index == todayIndex {
            templateVm.todaySelectImgView.setImgLocal(imgName: "circle_today_select_icon")
        } else {
            templateVm.todaySelectImgView.setImgLocal(imgName: "circle_today_normal_icon")
        }
    }
    /// 更新碳循环数据，保证天数不超过 daysNumber 且最大为 7 天
    func updateGoalsDataArray(_ array: NSMutableArray) {
        let maxDays = min(daysNumber, 7)
        if array.count > maxDays {
            let arr = array.subarray(with: NSRange(location: 0, length: maxDays))
            goalsDataArray = NSMutableArray(array: arr)
        } else {
            goalsDataArray = NSMutableArray(array: array)
        }
    }
    func updateWeeksDayData(isInit:Bool = false) {
        if isInit {
            self.getCCTodayIndex()
        }
        
        if goalsDataArray.count > currentIndex && currentIndex >= 0{
            let dict = goalsDataArray[currentIndex]as? NSDictionary ?? [:]
            
            for i in 0..<self.goalsDataArray.count{
                let dict = self.goalsDataArray[i]as? NSDictionary ?? [:]
                if dict.stringValueForKey(key: "carbLabel").count > 0 {
                    self.circleTagsArray.removeAllObjects()
                    break
                }
            }
            for i in 0..<self.goalsDataArray.count{
                let dict = self.goalsDataArray[i]as? NSDictionary ?? [:]
                let carbLabel = dict.stringValueForKey(key: "carbLabel")
                if self.circleTagsArray.count <= i{
                    self.circleTagsArray.add(carbLabel)
                }
            }
            
            caloriesNumber = Int(dict.doubleValueForKey(key: "calories"))
            carNumber = Int(dict.doubleValueForKey(key: "carbohydrates"))
            proteinNumber = Int(dict.doubleValueForKey(key: "proteins"))
            fatNumber = Int(dict.doubleValueForKey(key: "fats"))
            
            tipsVm.totalPercentLabel.text = "\(caloriesNumber)"//dict.stringValueForKey(key: "calories")
            carboItemVm.numberLabel.text = "\(carNumber)"//"\(dict.stringValueForKey(key: "carbohydrates"))g"
            proteinItemVm.numberLabel.text = "\(proteinNumber)"//"\(dict.stringValueForKey(key: "proteins"))g"
            fatItemVm.numberLabel.text = "\(fatNumber)"//"\(dict.stringValueForKey(key: "fats"))g"
            
            calculatePercentNumber()
            
            if self.circleTagsArray.count > currentIndex {
                let tag = circleTagsArray[currentIndex] as? String ?? ""
                var indexTag = -1
                for i in 0..<ConstantModel.shared.cc_label_array.count {
                    if ConstantModel.shared.cc_label_array[i] as? String == tag {
                        indexTag = i
                        break
                    }
                }
                self.circleTagsVm.refreshSelectTag(index: indexTag)
                self.weeksSegmentVm.updateButton(tag: tag)
            } else {
                self.circleTagsVm.refreshSelectTag(index: -1)
                self.weeksSegmentVm.updateButton(tag: "")
            }

            if isInit{
                let tags = self.circleTagsArray.compactMap { $0 as? String }
                self.weeksSegmentVm.updateCircleDays(daysNumber: self.daysNumber, selectedIndex: self.currentIndex,tags: tags)
            }
            udpateTodayFrame()
            
            if self.changeItemBlock != nil{
                self.changeItemBlock!(dict)
            }
        }
    }
    func updateDaysNumber(dayNumber:Int)  {
        self.daysNumber = dayNumber
//        self.weeksSegmentVm.updateCircleDays(daysNumber: self.daysNumber)
        let tags = self.circleTagsArray.compactMap { $0 as? String }
        self.weeksSegmentVm.updateCircleDays(daysNumber: self.daysNumber,selectedIndex: self.currentIndex, tags: tags)
        self.circleDaysVm.updateDaysNumber(daysNumber: self.daysNumber)
        while self.circleTagsArray.count < dayNumber {
            self.circleTagsArray.add("")
        }
    }
    func updateDataForTemplate(type:String) {
        DLLog(message: "updateDataForTemplate:\(self.goalsDataArray)")
        if type == "1"{
            updateCircleTemplateData(carboPercent: [45,30,20])
            
            let tags = ["高碳","中碳","低碳"]
//            let tags = ["高碳日","中碳日","低碳日"]
            circleTagsArray.removeAllObjects()
            for i in 0..<min(tags.count, daysNumber) {
                circleTagsArray.add(tags[i])
                if goalsDataArray.count > i {
                    let dict = NSMutableDictionary(dictionary: goalsDataArray[i] as? NSDictionary ?? [:])
//                    dict.setValue(tags[i], forKey: "cc_label")
                    dict.setValue(tags[i], forKey: "carbLabel")
                    goalsDataArray.replaceObject(at: i, with: dict)
                }
            }
        }else{
            updateCircleTemplateData(carboPercent: [20,20,20,55])
            let tags = ["低碳","低碳","低碳","高碳"]
//            let tags = ["低碳日","低碳日","低碳日","高碳日"]
            circleTagsArray.removeAllObjects()
            for i in 0..<min(tags.count, daysNumber) {
                circleTagsArray.add(tags[i])
                if goalsDataArray.count > i {
                    let dict = NSMutableDictionary(dictionary: goalsDataArray[i] as? NSDictionary ?? [:])
//                    dict.setValue(tags[i], forKey: "cc_label")
                    dict.setValue(tags[i], forKey: "carbLabel")
                    goalsDataArray.replaceObject(at: i, with: dict)
                }
            }
        }

        while circleTagsArray.count < daysNumber {
            circleTagsArray.add("")
        }
        let displayTags = circleTagsArray.compactMap { $0 as? String }
        weeksSegmentVm.updateCircleDays(daysNumber: daysNumber, selectedIndex: currentIndex, tags: displayTags)
        updateWeeksDayData()
        
        if self.dataChangeBlock != nil{
            self.dataChangeBlock!()
        }
    }
    func updateCircleTemplateData(carboPercent:[Int]) {
        for i in 0..<self.goalsDataArray.count{
            if i < carboPercent.count{
                let dict = NSMutableDictionary(dictionary: self.goalsDataArray[i]as? NSDictionary ?? [:])
                
                let calories = Float(dict.doubleValueForKey(key: "calories"))
                let carboPer = carboPercent[i]
                var proteinPer = (100 - carboPer)/2
                var fatPer = (100 - carboPer)/2
                
                if i == 3 {//低低低高，第四天的比例为  55   25   20
                    proteinPer = 25
                    fatPer = 20
                }else if i == 0 && carboPer == 45{//高中低    第一天的比例为 45  30  25
                    proteinPer = 30
                    fatPer = 25
                }
                
                let carboNum = (calories * Float(carboPer) * 0.01)/4
                let proteinNUm = (calories * Float(proteinPer) * 0.01)/4
                let fatNum = (calories * Float(fatPer) * 0.01)/9
                
                dict.setValue("\(Int(carboNum.rounded()))", forKey: "carbohydrates")
                dict.setValue("\(Int(proteinNUm.rounded()))", forKey: "proteins")
                dict.setValue("\(Int(fatNum.rounded()))", forKey: "fats")
                
                self.goalsDataArray.replaceObject(at: i, with: dict)
            }
        }
        self.updateWeeksDayData()
    }
    func calculatePercentNumber() {
        let carboPercent = (Float(carNumber * 4) / Float(caloriesNumber)) * 100.0
        let proteinPercent = (Float(proteinNumber * 4) / Float(caloriesNumber)) * 100.0
//        let fatPercent = (Float(fatNumber * 9) / Float(caloriesNumber)) * 100.0
        let fatPercent = 100 - Int(carboPercent.rounded()) - Int(proteinPercent.rounded())
        carboItemVm.percentLab.text = "\(Int(carboPercent.rounded()))%"
        proteinItemVm.percentLab.text = "\(Int(proteinPercent.rounded()))%"
        fatItemVm.percentLab.text = "\(fatPercent)%"
    }
    @objc func changeCircleTypeAction() {
        if self.changeCircleTypeBlock != nil{
            self.changeCircleTypeBlock!()
        }
    }
    ///获取碳循环今日开始的下标
    func getCCTodayIndex(){
        if self.daysNumber == 7 {
            let week = Calendar.current.component(.weekday, from: Date())
            self.todayIndex = (week + 5) % 7
            if self.todayIndex < self.goalsDataArray.count {
                self.currentIndex = self.todayIndex
            } else {
                self.currentIndex = 0
            }
            DLLog(message: "getCCTodayIndex ==== weekDayIndex:\(todayIndex)")
            return
        }

        DLLog(message: "getCCTodayIndex ==== \(Date().changeDateStringToDate(dateString: UserInfoModel.shared.ccStartDate))")
        
//        let daysGap = Date().daysBetweenDate(toDate: Date().changeDateStringToDate(dateString: UserInfoModel.shared.ccStartDate))
        
        let daysGap = Date().daysDifference(from: UserInfoModel.shared.ccStartDate) ?? 0
        self.todayIndex = daysGap + UserInfoModel.shared.ccStartOffsetIndex//abs(daysGap + UserInfoModel.shared.ccStartOffsetIndex)
        
        if todayIndex < 0 {
            self.todayIndex = abs(daysGap + UserInfoModel.shared.ccStartOffsetIndex)
        }
        
        if self.todayIndex < self.goalsDataArray.count{
            self.currentIndex = self.todayIndex
        }else{
            todayIndex = 0
        }
        
        DLLog(message: "getCCTodayIndex ==== daysGap:\(daysGap)  ---  todayIndex:\(todayIndex)")
    }
}
