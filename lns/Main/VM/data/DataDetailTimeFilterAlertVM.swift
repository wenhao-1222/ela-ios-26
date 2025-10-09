//
//  DataDetailTimeFilterAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/18.
//

import Foundation
import UIKit

class DataDetailTimeFilterAlertVM: UIView {
    
    var dateString = ""
    var weekDay = ""
    
    var confirmBlock:((NSDictionary)->())?
    
    let timeArray = [["qtype":"0","name":"全部"],
                     ["qtype":"1","name":"一周"],
                     ["qtype":"3","name":"1个月"],
                     ["qtype":"4","name":"2个月"],
                     ["qtype":"5","name":"3个月"],
                     ["qtype":"6","name":"6个月"],
                     ["qtype":"7","name":"1年"]]
    var selectedDict = ["qtype":"3","name":"1个月"]
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.alpha = 0
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-kFitWidth(260)-WHUtils().getBottomSafeAreaHeight(), width: SCREEN_WIDHT, height: kFitWidth(260)+WHUtils().getBottomSafeAreaHeight()+kFitWidth(16)))
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
        lab.text = "选择一个日期范围"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var datePicker : UIPickerView = {
        let vi = UIPickerView()
        vi.backgroundColor = . clear
        vi.dataSource = self
        vi.delegate = self
        
        return vi
    }()
}

extension DataDetailTimeFilterAlertVM{
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
        let index = datePicker.selectedRow(inComponent: 0)
        self.selectedDict = (timeArray[index]as? NSDictionary ?? [:]) as! [String : String]
        if self.confirmBlock != nil{
            self.confirmBlock!(self.selectedDict as NSDictionary)
        }
        self.hiddenView()
    }
}

extension DataDetailTimeFilterAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(confirmButton)
        whiteView.addSubview(lineView)
        whiteView.addSubview(datePicker)
        
        datePicker.selectRow(2, inComponent: 0, animated: false)
        
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
        datePicker.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(lineView.snp.bottom)
            make.width.equalTo(kFitWidth(343))
        }
    }
}

extension DataDetailTimeFilterAlertVM:UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeArray.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(40)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: kFitWidth(0), y: 0, width: kFitWidth(343), height: kFitWidth(40)))
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        let dict = timeArray[row]as? NSDictionary ?? [:]
        titleLabel.text = "\(dict["name"]as? String ?? "")"
        titleLabel.textColor = .COLOR_GRAY_BLACK_85
        titleLabel.textAlignment = .center
        
//        setUpPickerStyleRowStyle(row: row, component: component)
        return titleLabel
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        QuestinonaireMsgModel.shared.mealsPerDay = "\(row + 1)"
        DLLog(message: "每日餐数：\(QuestinonaireMsgModel.shared.mealsPerDay)")
   }
    
//    func setUpPickerStyleRowStyle(row:Int,component:Int) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
//            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
//            if label != nil{
//                label?.textColor = .COLOR_GRAY_BLACK_85
//            }
//        })
//    }
}
