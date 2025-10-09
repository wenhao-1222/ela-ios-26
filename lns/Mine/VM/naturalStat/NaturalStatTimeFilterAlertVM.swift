//
//  NaturalStatTimeFilterAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/9.
//

import Foundation


class NaturalStatTimeFilterAlertVM: UIView {
    
    var vmDataArray = [QuestionnairePlanFoodsTypeItemVM]()
    var selectIndex = 0
    var selectDataType = "1"
    var selectDateTypeName = "近一周"
    
    var startDate = ""
    var endDate = ""
    
    var choiceBlock:((String)->())?
    
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    lazy var typeArray: NSArray = {
        return [["type":"1","name":"近一周"],
                ["type":"3","name":"近一个月"],
                ["type":"6","name":"近半年"],
                ["type":"7","name":"近一年"],
                ["type":"99","name":"按月查看"],
                ["type":"99","name":"自定义日期"]]
    }()
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        return vi
    }()
    lazy var monthPickerView: NaturalStatTimeMonthFilterAlertVM = {
        let vm = NaturalStatTimeMonthFilterAlertVM.init(frame: .zero)
        vm.choiceBlock = {(dict)in
            self.selectIndex = 4
            self.selectDataType = "99"
        
            self.startDate = "\(dict.stringValueForKey(key: "year"))-\(dict["month"]as? String ?? "")-01"
            self.endDate = "\(dict.stringValueForKey(key: "year"))-\(dict["month"]as? String ?? "")-\(NaturalUtil().getDaysInMonth(year: Int(dict.doubleValueForKey(key: "year")),month:Int(dict.doubleValueForKey(key: "month"))))"
           
            self.selectDateTypeName = "\(dict.stringValueForKey(key: "year"))-\(dict.stringValueForKey(key: "month"))"
            self.selectType(daysIndex: 4)
        }
        vm.hiddenBlock = {()in
            self.hiddenSelf()
        }
        return vm
    }()
    lazy var customDateVm: NaturalStatDateCustomAlertVM = {
        let vm = NaturalStatDateCustomAlertVM.init(frame: .zero)
        vm.confirmBlock = {()in
            self.selectIndex = 5
            self.selectDataType = "99"
            self.startDate = self.customDateVm.startDate
            self.endDate = self.customDateVm.endDate
           
            self.selectDateTypeName = "自定义日期"
            self.selectType(daysIndex: 5)
        }
        vm.hiddenBlock = {()in
            self.hiddenSelf()
        }
        return vm
    }()
}

extension NaturalStatTimeFilterAlertVM{
    @objc func showView(){
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
        }
    }
    @objc func hiddenSelf(){
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
    func setSelectStatus(daysIndex:Int) {
        if daysIndex == 4{
            self.monthPickerView.showView()
            self.whiteView.alpha = 0
            return
        }else if daysIndex == 5{
            self.customDateVm.showView()
            self.whiteView.alpha = 0
            return
        }
        let dict = typeArray[daysIndex] as! NSDictionary
        
        self.startDate = ""
        self.endDate = ""
        selectDataType = dict["type"]as? String ?? "1"
        selectDateTypeName = dict["name"]as? String ?? "近一周"
        selectIndex = daysIndex
        selectType(daysIndex: daysIndex)
    }
    func selectType(daysIndex:Int) {
        for vm in vmDataArray{
            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        let vm = vmDataArray[daysIndex]
        vm.selectImgView.isHidden = false
        vm.titleLabel.textColor = .THEME
        
        self.hiddenSelf()
        if self.choiceBlock != nil{
            self.choiceBlock!(self.selectDataType)
        }
    }
}

extension NaturalStatTimeFilterAlertVM{
    func initUI()  {
        addSubview(whiteView)
        whiteView.addShadow()
        updateUI()
        
        addSubview(monthPickerView)
        addSubview(customDateVm)
    }
    @objc func updateUI() {
        whiteView.frame = CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-kFitWidth(120), y: WHUtils().getNavigationBarHeight()+kFitWidth(28), width: kFitWidth(120), height: kFitWidth(48)*CGFloat(typeArray.count))
        
        vmDataArray.removeAll()
        for vi in whiteView.subviews{
            vi.removeFromSuperview()
        }
        for i in 0..<typeArray.count{
            let dict = typeArray[i]as? NSDictionary ?? [:]
            let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(i), width: 0, height: 0))
            vm.frame = CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(i), width: kFitWidth(120), height: kFitWidth(48))
            vm.titleLabel.text = "\(dict["name"]as? String ?? "")"
            
            if i == 0 {
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
                vm.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(8))
            }else{
                vm.selectImgView.isHidden = true
                vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
                if i == typeArray.count-1{
                    vm.addClipCorner(corners: [.bottomLeft,.bottomRight], radius: kFitWidth(8))
                }
            }
            whiteView.addSubview(vm)
            vmDataArray.append(vm)
            
            vm.tapBlock = {()in
                self.setSelectStatus(daysIndex: i)
            }
        }
    }
}
