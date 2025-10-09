//
//  QuestionnaireBirthdayVM.swift
//  lns
//  bottom_cover_img
//  Created by LNS2 on 2024/3/28.
//

import Foundation
import UIKit

class QuestionnaireBirthdayVM: UIView {
    
    var nextBlock:(()->())?
    var defaultIndex = 0
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "记录您的出生年份\n让预测更准确"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.textAlignment = .center
        
//        lab.setLineSpace(lineSpcae: 36, textString: "记录您的出生年份\n让预测更准确")
        
        return lab
    }()
    lazy var pickerView : UIPickerView = {
        let vi = UIPickerView()
        vi.backgroundColor = . clear
        vi.dataSource = self
        vi.delegate = self
        
        return vi
    }()
    lazy var yearUnitLabel : UILabel = {
        let lab = UILabel()
        lab.text = "年"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var yearDataArray : NSArray = {
        let currentYear = Date().currentYear
        
        let yearArr = NSMutableArray()
        for i in (currentYear-80)...(currentYear-12){
            yearArr.add(i)
            
            if i < 2000 {
                defaultIndex = defaultIndex + 1
            }
        }
        
        return yearArr
    }()
}

extension QuestionnaireBirthdayVM{
    @objc func nextAction(){
        if self.nextBlock != nil{
            self.nextBlock!()
        }
    }
    func getBirthDayData() {
        let index = pickerView.selectedRow(inComponent: 0)
        QuestinonaireMsgModel.shared.birthDay = "\(yearDataArray[index]as? Int ?? 0)"
        
        DLLog(message: "出生年份：\(QuestinonaireMsgModel.shared.birthDay)")
    }
}

extension QuestionnaireBirthdayVM{
    func initUI(){
        addSubview(tipsLabel)
        addSubview(pickerView)
        pickerView.addSubview(yearUnitLabel)
        
        setConstrait()
        pickerView.selectRow(defaultIndex, inComponent: 0, animated: true)
    }
    func setConstrait() {
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60))
        }
        pickerView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(231))
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(252))
        }
//        nextBtn.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.width.equalTo(kFitWidth(343))
//            make.height.equalTo(kFitWidth(48))
//            make.bottom.equalTo(kFitWidth(-12)-WHUtils().getBottomSafeAreaHeight())
//        }
        yearUnitLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(223))
        }
    }
}

extension QuestionnaireBirthdayVM:UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearDataArray.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(40)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleLabel = view as? UILabel
        
        if ((titleLabel == nil)){
            titleLabel = UILabel.init()
            titleLabel?.backgroundColor = .clear
        }
        
//        let index = self.pickerView.selectedRow(inComponent: component)
        titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
        titleLabel?.textAlignment = .center
        titleLabel?.text = "\(yearDataArray[row]as? Int ?? 0)"
        
        setUpPickerStyleRowStyle(row: row, component: component)
        
        return titleLabel!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        QuestinonaireMsgModel.shared.birthDay = "\(yearDataArray[row]as? Int ?? 0)"
        DLLog(message: "生日：\(QuestinonaireMsgModel.shared.birthDay)")
   }
    func setUpPickerStyleRowStyle(row:Int,component:Int) {
        var contentView = UIView()
        let subviews = pickerView.subviews
        if subviews.count > 0{
            let firstView = subviews.first
            if firstView != nil{
                contentView = firstView!
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
            if label != nil{
                label?.textColor = .THEME
            }
        })
    }
}
