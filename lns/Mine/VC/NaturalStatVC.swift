//
//  NaturalStatVC.swift
//  lns
//
//  Created by LNS2 on 2024/9/3.
//

import Foundation


class NaturalStatVC: WHBaseViewVC {
    
    var qtype = "1"//1-一个星期内；3-一个月内；6-半年内；7-一年内；99-自定义开始（必填项）和结束（默认今天）日期
    var startDate = ""
    var endData = ""
    
    var dateArray = NSMutableArray()
    var serveDataArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeQueryType(duration: 0)
        initUI()
        if let popGesture = self.navigationController?.fd_fullscreenPopGestureRecognizer {
            scrollViewBase.panGestureRecognizer.require(toFail: popGesture)
        }
//        addSwipeGesture()
        sendStatDataRequest()
        UserDefaults.standard.set("1", forKey: "statNewFuncRead")
//        UserInfoModel.shared.statNewFuncRead = true
    }
    lazy var naviView: NaturalStatNaviVM = {
        let vi = NaturalStatNaviVM.init(frame: .zero)
        vi.backArrowButton.tapBlock = {()in
            self.backTapAction()
        }
        vi.timetypeBlock = {()in
            self.timeTypeAlertVm.showView()
        }
        vi.statTypeBlock = {(type)in
            self.naviView.changeStatType(type: type)
            self.statCalendarVm.monthPickerView.hiddenSelf()
            if type == "right"{
//                UIView.animate(withDuration: 0.3) {
//                    let statBarVmCenter = self.statBarVm.center
//                    self.statBarVm.center = CGPoint.init(x: -SCREEN_WIDHT*0.5, y: statBarVmCenter.y)
//                    self.statCalendarVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: statBarVmCenter.y)
//                }
                self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
                self.navigationController?.fd_interactivePopDisabled = true
                self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
                self.naviView.layer.shadowOpacity = 0
            }else{
//                UIView.animate(withDuration: 0.3) {
//                    let statBarVmCenter = self.statBarVm.center
//                    self.statBarVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: statBarVmCenter.y)
//                    self.statCalendarVm.center = CGPoint.init(x: SCREEN_WIDHT*1.5, y: statBarVmCenter.y)
//                }
                self.scrollViewBase.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                self.navigationController?.fd_interactivePopDisabled = false
                self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
                self.naviView.layer.shadowOpacity = 0.05
            }
        }
        vi.monthBlock = {()in
            self.statCalendarVm.monthPickerView.showView()
        }
        return vi
    }()
    lazy var statBarVm: NaturalStatBarVM = {
        let vm = NaturalStatBarVM.init(frame: .zero)
        vm.controller = self
        return vm
    }()
    lazy var statCalendarVm: NaturalStatCalendarVM = {
        let vm = NaturalStatCalendarVM.init(frame: .zero)
        vm.controller = self
        vm.monthChangeBlock = {(monthString)in
            self.naviView.updateTimeTextForMonth(name: monthString)
        }
        return vm
    }()
    lazy var timeTypeAlertVm: NaturalStatTimeFilterAlertVM = {
        let vm = NaturalStatTimeFilterAlertVM.init(frame: .zero)
        vm.choiceBlock = {(type)in
            self.qtype = type
            self.naviView.updateTimeText(name: self.timeTypeAlertVm.selectDateTypeName)
            self.changeQueryType()
            
            self.sendStatDataRequest()
        }
        return vm
    }()
}

extension NaturalStatVC{
    func dealDataSource() {
        for i in 0..<self.dateArray.count{
            let sDate = self.dateArray[i]as? String ?? ""
            var hasData = false
            for j in 0..<self.serveDataArray.count{
                let dict = self.serveDataArray[j]as? NSDictionary ?? [:]
                if dict.stringValueForKey(key: "sdate") == sDate{
                    hasData = true
                    self.dateArray.replaceObject(at: i, with: dict)
                    break
                }
            }
            if hasData == false{
                NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
                
                let dict = ["caloriesden":NutritionDefaultModel.shared.calories,
                            "carbohydrateden":NutritionDefaultModel.shared.carbohydrate,
                            "proteinden":NutritionDefaultModel.shared.protein,
                            "fatden":NutritionDefaultModel.shared.fat,
                            "sdate":sDate]
                self.dateArray.replaceObject(at: i, with: dict)
            }
        }
        self.statBarVm.dgBarChartView.setDataSource(dataArray: self.dateArray, dateType: self.timeTypeAlertVm.selectDataType)
        self.statBarVm.naturalBarChartView.setDataSource(dataArray: self.dateArray, dateType: self.timeTypeAlertVm.selectDataType)
    }
    func dealDataSourceForYear() {
        for i in 0..<self.dateArray.count{
            let dateDict = self.dateArray[i]as? NSDictionary ?? [:]
            for j in 0..<self.serveDataArray.count{
                let dict = self.serveDataArray[j]as? NSDictionary ?? [:]
                if dict.stringValueForKey(key: "year") == dateDict.stringValueForKey(key: "year") &&
                    dict.stringValueForKey(key: "month") == dateDict.stringValueForKey(key: "month"){
                    let dataDict = NSMutableDictionary(dictionary: dict)
                    dataDict.setValue(dict.stringValueForKey(key: "caloriesAvg"), forKey: "calories")
                    dataDict.setValue(dict.stringValueForKey(key: "carbohydrateAvg"), forKey: "carbohydrate")
                    dataDict.setValue(dict.stringValueForKey(key: "fatAvg"), forKey: "fat")
                    dataDict.setValue(dict.stringValueForKey(key: "proteinAvg"), forKey: "protein")
                    self.dateArray.replaceObject(at: i, with: dataDict)
//                    self.dateArray.replaceObject(at: i, with: dict)
                    break
                }
            }
        }
        self.statBarVm.dgBarChartView.setDataSource(dataArray: self.dateArray, dateType: self.timeTypeAlertVm.selectDataType)
        self.statBarVm.naturalBarChartView.setDataSource(dataArray: self.dateArray, dateType: self.timeTypeAlertVm.selectDataType)
    }
}

extension NaturalStatVC{
    func initUI() {
        view.clipsToBounds = true
        view.addSubview(naviView)
        
        scrollViewBase.delegate = self
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.showsVerticalScrollIndicator = false
        
        view.insertSubview(scrollViewBase, belowSubview: naviView)
        scrollViewBase.frame = CGRect.init(x: 0, y: naviView.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-naviView.frame.maxY)
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT*2, height: 0)
        scrollViewBase.addSubview(statBarVm)
        scrollViewBase.addSubview(statCalendarVm)
        statBarVm.frame.origin = CGPoint(x: 0, y: 0)
        statCalendarVm.frame.origin = CGPoint(x: SCREEN_WIDHT, y: 0)
        
        view.addSubview(timeTypeAlertVm)
        self.naviView.addShadow(opacity: 0.05)
    }
    func changeQueryType(duration:CGFloat=0.3) {
        self.startDate = self.timeTypeAlertVm.startDate
        self.endData = self.timeTypeAlertVm.endDate
        if qtype == "1"{
            dateArray = NSMutableArray(array: NaturalUtil().getDateLastWeekDaysArray())
        }else if qtype == "3"{
            dateArray = NSMutableArray(array: NaturalUtil().getDateLastMonthDaysArray())
        }else if qtype == "6"{
            dateArray = NSMutableArray(array: NaturalUtil().getLasYearDaysArray(isHalfYear: true))
        }else if qtype == "7"{
            dateArray = NSMutableArray(array: NaturalUtil().getLasYearDaysArray(isHalfYear: false))
        }else{
            dateArray = NSMutableArray(array: NaturalUtil().getDaysSourceArray(startDate: self.startDate, endDate: self.endData))
        }
        if self.timeTypeAlertVm.selectIndex == 5 {
            statBarVm.naviTimeVm.timeLabel.text = "\(self.timeTypeAlertVm.customDateVm.startDateModel.yearInt)年\(self.timeTypeAlertVm.customDateVm.startDateModel.monthInt)月\(self.timeTypeAlertVm.customDateVm.startDateModel.dayInt)日 至 \(self.timeTypeAlertVm.customDateVm.endDateModel.yearInt)年\(self.timeTypeAlertVm.customDateVm.endDateModel.monthInt)月\(self.timeTypeAlertVm.customDateVm.endDateModel.dayInt)日"
//            statBarVm.naviTimeVm.timeLabel.text = "\(self.startDate) 至 \(self.endData)"
            UIView.animate(withDuration: duration, delay: 0,options: .curveLinear) {
                self.statBarVm.scrollViewBase.frame = CGRect.init(x: 0, y: self.statBarVm.naviTimeVm.frame.maxY, width: SCREEN_WIDHT, height: self.statBarVm.selfHeight-self.statBarVm.naviTimeVm.frame.maxY)
            }
        }else{
//            naviTimeVm.isHidden = true
            UIView.animate(withDuration: duration, delay: 0,options: .curveLinear) {
                self.statBarVm.scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.statBarVm.selfHeight)
            }completion: { t in
                
            }
        }
    }
}

extension NaturalStatVC{
    func sendStatDataRequest() {
        let param = ["qtype":self.qtype,
                     "start_date":self.startDate,
                     "end_date":self.endData]
        DLLog(message: "sendStatDataRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_stat, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "\(dataObj)")
            
            self.statBarVm.perDataVm.updateUI(dict: dataObj)
            self.statBarVm.fitnessStatVm.updateUI(dict: dataObj["workoutStatistics"]as? NSDictionary ?? [:])
            self.serveDataArray = dataObj["logs"]as? NSArray ?? []
            
            if self.qtype == "6" || self.qtype == "7"{
                self.dealDataSourceForYear()
            }else{
                self.dealDataSource()
            }
        }
    }
}

extension NaturalStatVC: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int((scrollView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
        updateNaviStatus(currentPage: currentPage)
        if currentPage == 0 {
            self.naviView.layer.shadowOpacity = 0.05
        }else{
            self.naviView.layer.shadowOpacity = 0
        }
    }
    func updateNaviStatus(currentPage:Int){
        if currentPage == 0 && self.naviView.selectType == "left" || currentPage == 1 && self.naviView.selectType == "right"{
            return
        }
        if currentPage == 0{
            self.naviView.selectType = "left"
            self.naviView.leftTitleButton.isSelected = true
            self.naviView.rightTitleButton.isSelected = false
            self.naviView.changeStatType(type: "left")
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.naviView.selectBottomLineView.center = CGPoint(x: self.naviView.leftTitleButton.center.x, y: self.naviView.selfHeight-kFitWidth(2))
            }
            self.navigationController?.fd_interactivePopDisabled = false
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        }else{
            self.naviView.selectType = "right"
            self.naviView.rightTitleButton.isSelected = true
            self.naviView.leftTitleButton.isSelected = false
            self.naviView.changeStatType(type: "right")
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.naviView.selectBottomLineView.center = CGPoint(x: self.naviView.rightTitleButton.center.x, y: self.naviView.selfHeight-kFitWidth(2))
            }
            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }
    }
}
