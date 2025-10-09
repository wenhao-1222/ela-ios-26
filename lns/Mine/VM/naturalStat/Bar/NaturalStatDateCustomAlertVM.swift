//
//  NaturalStatDateCustomAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/10.
//

import Foundation
import MCToast

class DateChoiceModel: NSObject {
    var yearInt = 0
    var monthInt = 0
    var dayInt = 0
}

class NaturalStatDateCustomAlertVM: UIView {
    
    let whiteViewOrigin = WHUtils().getNavigationBarHeight() + kFitWidth(28)
    let dateSourceYearArray = NaturalUtil().getNext3YearsArray()
    var startDate = ""
    var endDate = ""
    
    var dataSourceArray = NSMutableArray()
    var startDateModel = DateChoiceModel()
    var endDateModel = DateChoiceModel()
    
    var confirmBlock:(()->())?
    var hiddenBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        dataSourceArray = UserInfoModel.shared.dateArrayForStat
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        self.initUI()
    }
    lazy var dateSourceMonthArray: NSArray = {
        var monthArray = NSMutableArray()
        for i in 1..<13{
            let str = "\(i)"
            monthArray.add(str)
        }
        return monthArray
    }()
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: whiteViewOrigin , width: SCREEN_WIDHT, height: SCREEN_HEIGHT - whiteViewOrigin - WHUtils().getBottomSafeAreaHeight()-kFitWidth(56)))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothing))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var bottomWhiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: self.whiteView.frame.minY + kFitWidth(50), width: SCREEN_WIDHT, height: self.whiteView.frame.height-kFitWidth(50)))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        return vi
    }()
    lazy var topWeekDay: NaturalStatDateCustomHeadView = {
        let vm = NaturalStatDateCustomHeadView.init(frame: .zero)
        return vm
    }()
    lazy var bottomView : NaturalStatDateCustomBottomView = {
        let vm = NaturalStatDateCustomBottomView.init(frame: CGRect.init(x: 0, y: self.tableView.frame.maxY, width: 0, height: 0))
        vm.confirmBlock = {()in
            if self.startDate == "" || self.startDate.count == 0 {
                MCToast.mc_text("请选择开始日期")
                return
            }
            if self.endDate == "" || self.endDate.count == 0 {
                MCToast.mc_text("请选择结束日期")
                return
            }
            if self.confirmBlock != nil{
                self.confirmBlock!()
            }
            self.hiddenSelf()
            self.resetDate()
        }
        return vm
    }()
    lazy var tableView: UITableView = {
        let vi = UITableView(frame: CGRect.init(x: 0, y: kFitWidth(48), width: SCREEN_WIDHT, height: self.whiteView.frame.height-kFitWidth(110)-kFitWidth(48)), style: .grouped)
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        
        for i in 0..<self.dataSourceArray.count{
            vi.register(NaturalStatDateCustomTableViewCell.classForCoder(), forCellReuseIdentifier: "NaturalStatDateCustomTableViewCell\(i)")
        }
//        vi.register(NaturalStatDateCustomTableViewCell.classForCoder(), forCellReuseIdentifier: "NaturalStatDateCustomTableViewCell")
        
        return vi
    }()
}

extension NaturalStatDateCustomAlertVM{
    func dealDateModel(model:DateChoiceModel) {
        if startDateModel.yearInt > 0 && endDateModel.yearInt > 0 {
            //如果已经选择过开始和结束日期，再次点击日期的时候，重置，并将点击日期置为开始日期
            startDateModel = model
            endDateModel = DateChoiceModel() // 清空之前选择的结束日期
            resetQueryDate()
            self.tableView.reloadData()
            self.bottomView.updateUI(startTime: self.startDate, endTime: self.endDate)
            return
        }
        if self.startDateModel.yearInt == 0{
            //开始日期为空
            self.startDateModel = model
            resetQueryDate()
        }else {
//            已经选择了开始日期
            if self.startDateModel.yearInt > model.yearInt{
//                开始日期年份 ＞ 选择的日期年份
                self.startDateModel = model
                resetQueryDate()
            }else if self.startDateModel.yearInt == model.yearInt{
//                开始日期年份 ＝ 选择的日期年份
                if self.startDateModel.monthInt > model.monthInt{
                    self.startDateModel = model
                    resetQueryDate()
                }else if startDateModel.monthInt == model.monthInt{
                    if startDateModel.dayInt > model.dayInt{
                        startDateModel = model
                        resetQueryDate()
                    }else if startDateModel.dayInt == model.dayInt{
                        startDateModel = model
                        resetQueryDate()
                    }else{
                        if judgeEndDate(model: model){
                            endDateModel = model
                        }else{
                            MCToast.mc_text("日期选择不能超过三个月")
                        }
                    }
                }else{
                    if judgeEndDate(model: model){
                        endDateModel = model
                    }else{
                        MCToast.mc_text("日期选择不能超过三个月")
                    }
                }
            }else {
//                开始日期年份 ＜ 选择的日期年份
                if judgeEndDate(model: model){
                    endDateModel = model
                }else{
                    MCToast.mc_text("日期选择不能超过三个月")
                }
            }
            
            DLLog(message: "\(startDate)  --  \(endDate)")
        }
        
        self.bottomView.updateUI(startTime: self.startDate, endTime: self.endDate)
        self.tableView.reloadData()
    }
    func resetQueryDate() {
        self.startDate = ""
        self.endDate = ""
        self.endDateModel = DateChoiceModel()
        
        var startDateString = "\(startDateModel.yearInt)"
        if startDateModel.monthInt < 10{
            startDateString = "\(startDateString)-0\(startDateModel.monthInt)"
        }else{
            startDateString = "\(startDateString)-\(startDateModel.monthInt)"
        }
        if startDateModel.dayInt < 10{
            startDateString = "\(startDateString)-0\(startDateModel.dayInt)"
        }else{
            startDateString = "\(startDateString)-\(startDateModel.dayInt)"
        }
        startDate = startDateString
    }
    //MARK: 校验选择日期是否超过三个月
    func judgeEndDate(model:DateChoiceModel) -> Bool {
        var startDateString = "\(startDateModel.yearInt)"
        if startDateModel.monthInt < 10{
            startDateString = "\(startDateString)-0\(startDateModel.monthInt)"
        }else{
            startDateString = "\(startDateString)-\(startDateModel.monthInt)"
        }
        if startDateModel.dayInt < 10{
            startDateString = "\(startDateString)-0\(startDateModel.dayInt)"
        }else{
            startDateString = "\(startDateString)-\(startDateModel.dayInt)"
        }
        
        var endDateString = "\(model.yearInt)"
        if model.monthInt < 10{
            endDateString = "\(endDateString)-0\(model.monthInt)"
        }else{
            endDateString = "\(endDateString)-\(model.monthInt)"
        }
        if model.dayInt < 10{
            endDateString = "\(endDateString)-0\(model.dayInt)"
        }else{
            endDateString = "\(endDateString)-\(model.dayInt)"
        }
        
        let startDay = Date().changeDateStringToDate(dateString: startDateString)
        let endDay = Date().changeDateStringToDate(dateString: endDateString)
        
        if Date().isDateDistanceMoreThanMonths(endDay, from: startDay, month: 3){
            return false
        }else {
            startDate = startDateString
            endDate = endDateString
            return true
        }
    }
    
}

extension NaturalStatDateCustomAlertVM{
    func initUI() {
        addSubview(bottomWhiteView)
        addSubview(whiteView)
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: { [self] in
            whiteView.addSubview(topWeekDay)
            whiteView.addSubview(tableView)
            whiteView.addSubview(bottomView)
            
            bottomWhiteView.addShadow()
            tableView.delegate = self
            tableView.dataSource = self
            
            resetDate()
//        })
    }
    
    @objc func showView(){
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
            self.bottomWhiteView.alpha = 1
        }
    }
    @objc func hiddenSelf(){
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 0
            self.bottomWhiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
        if self.hiddenBlock != nil{
            self.hiddenBlock!()
        }
    }
    @objc func nothing() {
        
    }
    func resetDate() {
        self.startDate = ""
        self.endDate = ""
        self.startDateModel = DateChoiceModel()
        self.endDateModel = DateChoiceModel()
        self.tableView.reloadData()
        self.bottomView.updateUI(startTime: self.startDate, endTime: self.endDate)
        
        let monthArray = Date().currenYearMonth
        let currentYear = monthArray[0]as? String ?? ""
        let currentMonth = monthArray[1]as? String ?? ""
        
        let yearIndex = currentYear.intValue
        let monthIndex = currentMonth.intValue
        
        var currentIndex = (yearIndex-2021)*12 + monthIndex - 1
        if currentIndex < 0 {
            currentIndex = 0
        }else if currentIndex > self.dataSourceArray.count - 1{
            currentIndex = self.dataSourceArray.count - 1
        }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: currentIndex), at: .none, animated: false)
    }
}

extension NaturalStatDateCustomAlertVM:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NaturalStatDateCustomTableViewCell\(indexPath.section)", for: indexPath) as? NaturalStatDateCustomTableViewCell
        
        let dict = dataSourceArray[indexPath.section]as? NSDictionary ?? [:]
        
        cell?.updateUI(dict: dict)
        cell?.udpateChoiceStatus(startTime: startDate, endTime: endDate)
//        cell?.udpateChoiceStatus(startModel: startDateModel, endModel: endDateModel)
        
        cell?.btnTapBlock = {(model)in
            self.dealDateModel(model: model)
        }
        
        return cell ?? NaturalStatDateCustomTableViewCell()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(50)))
        
        let lab = UILabel()
        headView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(24))
        }
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        let dict = dataSourceArray[section]as? NSDictionary ?? [:]
        lab.text = dict.stringValueForKey(key: "month")
        
        return headView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(50)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dict = dataSourceArray[indexPath.section]as? NSDictionary ?? [:]
        let weeks = dict.doubleValueForKey(key: "weeks")
        
        return (kFitWidth(48) + kFitWidth(8)) * weeks - kFitWidth(8)
    }
}
