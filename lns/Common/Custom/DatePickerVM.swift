//
//  DatePickerVM.swift
//  kxf
//
//  Created by 文 on 2023/6/6.
//

import Foundation
import UIKit

class DatePickerVM: UIView {
    
    var timeConfirmBlock : ((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "dfdfdf")
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("取 消", for: .normal)
        btn.setTitleColor(WHColor_16(colorStr: "666666"), for: .normal)
        
        btn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "开始时间"
//        lab.textColor = .COLOR_TEXT_BLACK333
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("确 定", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        
        btn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var datePicker : UIDatePicker = {
        let picker = UIDatePicker.init(frame: CGRect.init(x: 0, y: kFitWidth(40), width: SCREEN_WIDHT, height: kFitWidth(200)))
        picker.datePickerMode = .date
        picker.locale = NSLocale.init(localeIdentifier: "zh_CN") as Locale
        picker.backgroundColor = .clear
        picker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        return picker
    }()
}

extension DatePickerVM{
    @objc func cancelBtnAction(){
        self.isHidden = true
    }
    @objc func confirmBtnAction(){
        let select = datePicker.date
        let dateFormmater = DateFormatter.init()
        dateFormmater.dateFormat = "yyyy-MM-dd"
        dateFormmater.calendar = Calendar.init(identifier: .gregorian)
        dateFormmater.locale = Locale.init(identifier: "en_US_POSIX")
//        dateFormmater.dateFormat = "yyyyMMdd"
        
        
        if self.timeConfirmBlock != nil{
            self.timeConfirmBlock!(dateFormmater.string(from: select))
        }
        
        self.isHidden = true
    }
}

extension DatePickerVM{
    func initUI(){
        addSubview(whiteView)
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(confirmBtn)
        whiteView.addSubview(datePicker)
        whiteView.addSubview(titleLabel)
        setConstrait()
    }
    
    func setConstrait(){
        whiteView.snp.makeConstraints { (frame) in
            frame.left.bottom.right.width.equalToSuperview()
            frame.height.equalTo(300)
//            frame.bottom.equalTo(-getBottomSafeAreaHeight()-100)
        }
        cancelBtn.snp.makeConstraints { (frame) in
            frame.left.top.equalToSuperview()
            frame.height.equalTo(kFitWidth(40))
            frame.width.equalTo(kFitWidth(100))
        }
        confirmBtn.snp.makeConstraints { (frame) in
            frame.right.top.equalToSuperview()
            frame.height.equalTo(kFitWidth(40))
            frame.width.equalTo(kFitWidth(100))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualTo(cancelBtn)
        }
        datePicker.snp.makeConstraints { (frame) in
            frame.left.width.equalToSuperview()
            frame.bottom.equalToSuperview()
            frame.top.equalTo(kFitWidth(40))
        }
    }
}

