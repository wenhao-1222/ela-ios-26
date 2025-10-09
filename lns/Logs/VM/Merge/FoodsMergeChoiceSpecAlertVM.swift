//
//  FoodsMergeChoiceSpecAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/18.
//


import Foundation
import UIKit

class FoodsMergeChoiceSpecAlertVM: UIView {
    
    let specDefaultDict = ["specNum":100,
                           "specName":"克"] as [String : Any]
    var specArray = NSArray()
    var selectSpecDict = ["specNum":100,
                          "specName":"克"] as [String : Any]
    var confirmBlock:((NSDictionary)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.alpha = 0
        self.isHidden = true
        specArray = [specDefaultDict]
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-kFitWidth(300)-WHUtils().getBottomSafeAreaHeight(), width: SCREEN_WIDHT, height: kFitWidth(300)+WHUtils().getBottomSafeAreaHeight()+kFitWidth(16)))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        vi.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var closeButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
    lazy var confirmButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "选择单位"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        
        return picker
    }()
}


extension FoodsMergeChoiceSpecAlertVM{
    @objc func showView() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.alpha = 1
            self.whiteView.alpha = 1
        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.alpha = 0
            self.whiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
    @objc func nothingToDo() {
        
    }
    @objc func confirmAction(){
        if self.confirmBlock != nil{
            self.confirmBlock!(self.selectSpecDict as NSDictionary)
        }
        self.hiddenView()
    }
    func setSpecArr(arr:NSArray) {
        DLLog(message: "setSpecArr:\(arr)")
        if specArray.count > 0 {
            self.specArray = arr
            self.selectSpecDict = specArray[0] as! [String : Any]
            self.pickerView.reloadAllComponents()
        }
    }
    func reloadPickerIndex(arr:[NSDictionary]) {
        if arr.count > 0 {
            let dict = arr[0]
            for i in 0..<self.specArray.count{
                let dictT = specArray[i] as! NSDictionary
                if dict.stringValueForKey(key: "specName") == dictT.stringValueForKey(key: "specName"){
                    self.pickerView.selectRow(i, inComponent: 0, animated: false)
                    return
                }
            }
        }
    }
}

extension FoodsMergeChoiceSpecAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(confirmButton)
        whiteView.addSubview(lineView)
        whiteView.addSubview(pickerView)
        
        setConstrait()
    }
    
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(55))
            make.height.equalTo(kFitWidth(1))
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(lineView)
        }
        closeButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.bottom.equalTo(lineView)
            make.width.equalTo(kFitWidth(56))
        }
        confirmButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.bottom.width.equalTo(closeButton)
        }
        pickerView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(lineView.snp.bottom)
            make.width.equalTo(kFitWidth(343))
        }
    }
}

extension FoodsMergeChoiceSpecAlertVM:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return specArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let dict = specArray[row] as! NSDictionary
        return dict.stringValueForKey(key: "specName")
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectSpecDict = specArray[row] as! [String : Any]
        DLLog(message: "UIPickerView, didSelectRow:\(selectSpecDict)")
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(40)
    }
}
