//
//  DataDetailTypeSettingAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/8/27.
//

import Foundation
import UIKit

class DataDetailTypeSettingAlertVM: UIView {
    
    var choiceBlock:((NSDictionary)->())?
    
    let dataArray = [
//        ["type":DATA_TYPE.weight,"name":"体重"],
//                     ["type":DATA_TYPE.waistline,"name":"腰围"],
//                     ["type":DATA_TYPE.hips,"name":"臀围"],
//                     ["type":DATA_TYPE.arm,"name":"臂围"],
                     ["type":DATA_TYPE.shoulder,"name":"肩宽"],
                     ["type":DATA_TYPE.bust,"name":"胸围"],
                     ["type":DATA_TYPE.thigh,"name":"大腿围"],
                     ["type":DATA_TYPE.calf,"name":"小腿围"],
                     ["type":DATA_TYPE.bfp,"name":"体脂率"]]
    
    var settingMsgDict = UserDefaults().getBodyDataSetting()
    var vmDataArray = [DataDetailTypeSettingAlertItemVM]()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
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


extension DataDetailTypeSettingAlertVM{
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
//        for vm in vmDataArray{
//            vm.selectImgView.isHidden = true
//            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
//        }
        
        let vm = vmDataArray[daysIndex]
//        vm.selectImgView.isHidden = false
//        vm.titleLabel.textColor = .THEME
        vm.isSelect = !vm.isSelect
        
        UserDefaults.set(value: "", forKey: .myFoodsList)
        
        var isSelect = "0"
        if vm.isSelect {
            isSelect = "1"
            vm.selectImgView.isHidden = false
            vm.titleLabel.textColor = .THEME
            
//            let dict = dataArray[daysIndex]
//            
//            if self.choiceBlock != nil{
//                self.choiceBlock!(dict as NSDictionary)
//            }
        }else{
            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        
        if daysIndex == 0{
            UserDefaults().updateBodyDataSetting(type: .shoulder, isSelect: isSelect)
        }else if daysIndex == 1{
            UserDefaults().updateBodyDataSetting(type: .bust, isSelect: isSelect)
        }else if daysIndex == 2{
            UserDefaults().updateBodyDataSetting(type: .thigh, isSelect: isSelect)
        }else if daysIndex == 3{
            UserDefaults().updateBodyDataSetting(type: .calf, isSelect: isSelect)
        }else if daysIndex == 4{
            UserDefaults().updateBodyDataSetting(type: .bfp, isSelect: isSelect)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBodyDataSetting"), object: nil)
    }
    func setSelectIndex(index:Int) {
        for vm in vmDataArray{
            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        
        let vm = vmDataArray[index]
        vm.selectImgView.isHidden = false
        vm.titleLabel.textColor = .THEME
    }
}


extension DataDetailTypeSettingAlertVM{
    func initUI()  {
        addSubview(whiteView)
        whiteView.addShadow()
        whiteView.frame = CGRect.init(x: SCREEN_WIDHT - kFitWidth(16) - kFitWidth(120), y: WHUtils().getNavigationBarHeight()+kFitWidth(4), width: kFitWidth(120), height: kFitWidth(48)*CGFloat(dataArray.count))
        
        initAlertView()
    }
    func initAlertView()  {
        for i in 0..<dataArray.count{
            let dict = dataArray[i]as? NSDictionary ?? [:]
            let vm = DataDetailTypeSettingAlertItemVM.init(frame: CGRect.init(x: 0, y: DataDetailTypeSettingAlertItemVM().selfHeight*CGFloat(i), width: 0, height: 0))
            vm.titleLabel.text = "\(dict["name"]as? String ?? "")"
            
//            if i < 4 {
//                vm.selectImgView.isHidden = false
//                vm.titleLabel.textColor = .THEME
//            }else{
                vm.selectImgView.isHidden = true
                vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
//            }
            whiteView.addSubview(vm)
//            vm.tag = 1150 + i
            vmDataArray.append(vm)
            
            vm.tapBlock = {()in
                self.setSelectStatus(daysIndex: i)
//                self.hiddenSelf()
            }
            
            if i == 0 && settingMsgDict.stringValueForKey(key: "shoulder") == "1"{
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
                vm.isSelect = true
            }else if i == 1 && settingMsgDict.stringValueForKey(key: "bust") == "1"{
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
                vm.isSelect = true
            }else if i == 2 && settingMsgDict.stringValueForKey(key: "thigh") == "1"{
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
                vm.isSelect = true
            }else if i == 3 && settingMsgDict.stringValueForKey(key: "calf") == "1"{
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
                vm.isSelect = true
            }else if i == 4 && settingMsgDict.stringValueForKey(key: "bfp") == "1"{
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
                vm.isSelect = true
            }
        }
    }
}

class DataDetailTypeSettingAlertItemVM: UIView {
    
    let selfHeight = kFitWidth(48)
    var tapBlock:(()->())?
    var isSelect = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(120), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var selectImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_type_selected_icon")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        
        return img
    }()
    
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    
    func initUI() {
        addSubview(titleLabel)
        addSubview(lineView)
        addSubview(selectImgView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        selectImgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.width.height.equalTo(kFitWidth(16))
        }
        lineView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}
