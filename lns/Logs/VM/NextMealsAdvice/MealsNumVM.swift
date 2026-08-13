//
//  MealsNumVM.swift
//  lns
//
//  Created by LNS2 on 2026/8/5.
//


import Foundation
import UIKit

class MealsNumVM: UIView {
    
    var selfHeight = kFitWidth(0)
    var selectedIndex = -1
    
    var selectedBlock:(()->())?
    var nextBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_BG_F2
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "今天预计还会吃几餐？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "包含这餐"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var pickerView : UIPickerView = {
        let vi = UIPickerView()
        vi.backgroundColor = . clear
        vi.dataSource = self
        vi.delegate = self
        
        return vi
    }()
    lazy var unitPreLabel : UILabel = {
        let lab = UILabel()
//        lab.text = "每日"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var unitAfterLabel : UILabel = {
        let lab = UILabel()
        lab.text = "餐"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(27)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        return btn
    }()
}

extension MealsNumVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsLabel)
        addSubview(pickerView)
        addSubview(nextButton)
        pickerView.addSubview(unitPreLabel)
        pickerView.addSubview(unitAfterLabel)
        
        configureDefaultSelection(sDate: Date().todayDate)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(58)+WHUtils().getNavigationBarHeight())
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(7))
        }
        pickerView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(kFitWidth(260))
//            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(90))
//            make.bottom.equalTo(-(kFitWidth(218)-kFitWidth(126))-kFitWidth(30))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(78))
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(252))
        }
        unitPreLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(3))
            make.left.equalTo(kFitWidth(132))
        }
        unitAfterLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(190))
            make.centerY.lessThanOrEqualTo(unitPreLabel)
        }
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
            make.height.equalTo(kFitWidth(54))
        }
    }
}
extension MealsNumVM{
    private var maxMealsNum: Int {
        let mealsNum = UserInfoModel.shared.mealsNumber
        return mealsNum > 0 ? mealsNum : 6
    }
    func configureDefaultSelection(sDate:String) {
        let totalMealsNum = maxMealsNum
        let eatMealsNum = eatMealsNumForLocalLogs(sDate: sDate)
        let defaultMealsNum = max(totalMealsNum - eatMealsNum, 1)
        pickerView.reloadAllComponents()
        selectMealsNum(defaultMealsNum)
    }
    private func selectMealsNum(_ mealsNum:Int) {
        let boundedMealsNum = min(max(mealsNum, 1), maxMealsNum)
        pickerView.selectRow(boundedMealsNum - 1, inComponent: 0, animated: false)
        QuestinonaireMsgModel.shared.mealsPerDay = "\(boundedMealsNum)"
    }
    private func eatMealsNumForLocalLogs(sDate:String) -> Int {
        guard let logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: sDate) else {
            return 0
        }
        let mealsArray = WHUtils.getArrayFromJSONString(jsonString: logsModel.foods)
        var eatMealsNum = 0
        for mealsItem in mealsArray {
            let foodsArray = mealsItem as? NSArray ?? []
            let hasEatFoods = foodsArray.contains { item in
                let foodsDict = item as? NSDictionary ?? [:]
                let state = foodsDict.stringValueForKey(key: "state")
                let status = foodsDict.stringValueForKey(key: "status")
                return state == "1" || state == "1.0" || status == "1" || status == "1.0"
            }
            if hasEatFoods {
                eatMealsNum += 1
            }
        }
        return eatMealsNum
    }
    func getDataData() {
        let index = pickerView.selectedRow(inComponent: 0)
        QuestinonaireMsgModel.shared.mealsPerDay = "\(index + 1)"
    }
    @objc func nextAction() {
        getDataData()
        nextBlock?()
    }
}

extension MealsNumVM:UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return maxMealsNum
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(60)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: kFitWidth(156), y: 0, width: kFitWidth(20), height: kFitWidth(60)))
        
        titleLabel.tag = 301
        titleLabel.font = .systemFont(ofSize: 28, weight: .medium)
//        titleLabel.textAlignment = .center
        titleLabel.text = "\(row + 1)"
        
        setUpPickerStyleRowStyle(row: row, component: component)
        return titleLabel
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        QuestinonaireMsgModel.shared.mealsPerDay = "\(row + 1)"
        DLLog(message: "每日餐数：\(QuestinonaireMsgModel.shared.mealsPerDay)")
   }
    
    func setUpPickerStyleRowStyle(row:Int,component:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
            if label != nil{
                label?.textColor = .THEME
            }
        })
    }
}
