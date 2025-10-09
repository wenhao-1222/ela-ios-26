//
//  DataDetailTypeFilterAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/18.
//

import Foundation
import UIKit

class DataDetailTypeFilterAlertVM: UIView {
    
    var choiceBlock:((NSDictionary)->())?
//    let dataArray = [["type":DATA_TYPE.weight,"name":"体重"],
//                     ["type":DATA_TYPE.waistline,"name":"腰围"],
//                     ["type":DATA_TYPE.hips,"name":"臀围"],
//                     ["type":DATA_TYPE.arm,"name":"臂围"],
//                     ["type":DATA_TYPE.shoulder,"name":"肩宽"],
//                     ["type":DATA_TYPE.bust,"name":"胸围"],
//                     ["type":DATA_TYPE.thigh,"name":"大腿围"],
//                     ["type":DATA_TYPE.calf,"name":"小腿围"]]
    var dataArrayForShow = NSMutableArray(array: [["type":DATA_TYPE.weight,"name":"体重"],
                                                  ["type":DATA_TYPE.waistline,"name":"腰围"],
                                                  ["type":DATA_TYPE.hips,"name":"臀围"],
                                                  ["type":DATA_TYPE.arm,"name":"手臂"]])
    var selectIndex = 0
    var selectDataType = DATA_TYPE.weight
    var vmDataArray = [QuestionnairePlanFoodsTypeItemVM]()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "updateBodyDataSetting"), object: nil)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        return vi
    }()
}


extension DataDetailTypeFilterAlertVM{
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
        for vm in vmDataArray{
            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        let vm = vmDataArray[daysIndex]
        vm.selectImgView.isHidden = false
        vm.titleLabel.textColor = .THEME
        
        let dict = dataArrayForShow[daysIndex] as! NSDictionary
        
        selectDataType = dict["type"]as? DATA_TYPE ?? .weight
        selectIndex = daysIndex
        
        if self.choiceBlock != nil{
            self.choiceBlock!(dict)
        }
    }
    func setSelectIndex(index:Int) {
        for vm in vmDataArray{
            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        self.selectDataType = .waistline
        let vm = vmDataArray[index]
        vm.selectImgView.isHidden = false
        vm.titleLabel.textColor = .THEME
    }
}


extension DataDetailTypeFilterAlertVM{
    func initUI()  {
        addSubview(whiteView)
        whiteView.addShadow()
        updateUI()
    }
    func initAlertView()  {
        vmDataArray.removeAll()
        for vi in whiteView.subviews{
            vi.removeFromSuperview()
        }
        for i in 0..<dataArrayForShow.count{
            let dict = dataArrayForShow[i]as? NSDictionary ?? [:]
            let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(i), width: 0, height: 0))
            vm.titleLabel.text = "\(dict["name"]as? String ?? "")"
            
            if i == selectIndex {
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
            }else{
                vm.selectImgView.isHidden = true
                vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
            }
            whiteView.addSubview(vm)
//            vm.tag = 1050 + i
            vmDataArray.append(vm)
            
            vm.tapBlock = {()in
                self.setSelectStatus(daysIndex: i)
                self.hiddenSelf()
            }
        }
        
    }
    @objc func updateUI() {
        let settingMsgDict = UserDefaults().getBodyDataSetting()
        dataArrayForShow = NSMutableArray(array: [["type":DATA_TYPE.weight,"name":"体重"],
                                                  ["type":DATA_TYPE.waistline,"name":"腰围"],
                                                  ["type":DATA_TYPE.hips,"name":"臀围"],
                                                  ["type":DATA_TYPE.arm,"name":"手臂"]])
        
        if settingMsgDict.stringValueForKey(key: "shoulder") == "1"{
            dataArrayForShow.add(["type":DATA_TYPE.shoulder,"name":"肩宽"])
        }else if selectDataType == .shoulder{
            setSelectStatus(daysIndex:0)
        }
        if settingMsgDict.stringValueForKey(key: "bust") == "1"{
            dataArrayForShow.add(["type":DATA_TYPE.bust,"name":"胸围"])
        }else if selectDataType == .bust{
            setSelectStatus(daysIndex:0)
        }
        if settingMsgDict.stringValueForKey(key: "thigh") == "1"{
            dataArrayForShow.add(["type":DATA_TYPE.thigh,"name":"大腿围"])
        }else if selectDataType == .thigh{
            setSelectStatus(daysIndex:0)
        }
        if settingMsgDict.stringValueForKey(key: "calf") == "1"{
            dataArrayForShow.add(["type":DATA_TYPE.calf,"name":"小腿围"])
        }else if selectDataType == .calf{
            setSelectStatus(daysIndex:0)
        }
        if settingMsgDict.stringValueForKey(key: "bfp") == "1"{
            dataArrayForShow.add(["type":DATA_TYPE.bfp,"name":"体脂率"])
        }else if selectDataType == .bfp{
            setSelectStatus(daysIndex:0)
        }
        whiteView.frame = CGRect.init(x: kFitWidth(16), y: WHUtils().getNavigationBarHeight()+kFitWidth(64), width: kFitWidth(200), height: kFitWidth(48)*CGFloat(dataArrayForShow.count))
        
        initAlertView()
    }
}

