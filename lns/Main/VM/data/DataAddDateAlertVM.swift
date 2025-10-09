//
//  DataAddDateAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/17.
//

import Foundation
import UIKit

class DataAddDateAlertVM: UIView {
    
    var dateStringYear = ""
    var dateString = ""
    var weekDay = ""
    var isWeekDay = true
    
    var confirmBlock:((String)->())?
    
    var whiteViewHeight = kFitWidth(100)
    var whiteViewOriginY = kFitWidth(200)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.15)
        self.isUserInteractionEnabled = true
//        self.alpha = 0
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        initUI()
        
        changeDate(date: Date())
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-kFitWidth(300)-WHUtils().getBottomSafeAreaHeight()+SCREEN_HEIGHT, width: SCREEN_WIDHT, height: kFitWidth(300)+WHUtils().getBottomSafeAreaHeight()+kFitWidth(16)))
        self.whiteViewHeight = kFitWidth(300)+WHUtils().getBottomSafeAreaHeight()+kFitWidth(16)
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
//        vi.alpha = 0
        
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
        lab.text = "更改日期"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var todayButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("今天", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(todayAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var datePicker : UIDatePicker = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let picker = UIDatePicker()
        picker.calendar = calendar//.current
        picker.backgroundColor = .white
        picker.datePickerMode = .date
        picker.locale = Locale.current//Locale(identifier: "zh_CN")
        /**
         监控其值的变化
         */
        picker.addTarget(self, action: #selector(chooseDate( _:)), for:UIControl.Event.valueChanged)
        
        let minDay = Date().getLastYearsAgo(lastYears: -3)
        let maxDay = Date().getLastYearsAgo(lastYears: 3)
        picker.minimumDate = minDay
        picker.maximumDate = maxDay
        
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        return picker
    }()
}

extension DataAddDateAlertVM{
    @objc func showView() {
        self.isHidden = false
//        let whiteViewFrame = self.whiteView.frame
        whiteViewHeight = self.whiteView.frame.height
//        showWhiteViewAnimate()
        
        bgView.isUserInteractionEnabled = false
        // 刷新选择状态（如果外部修改了 selectFitnessType）
        
        // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0
        
        // 1) 蒙层先快后慢，140ms 淡到 0.45（与内容节奏不同步，减少“停顿感”）
//        UIView.animate(withDuration: 0.14, delay: 0, options: .curveEaseOut) {
//            self.bgView.alpha = 0.25
//        }

        // 2) 内容卡片：200ms，ease-out + 轻弹性小超冲（阻尼 0.88，初速 0.05）
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.bgView.alpha = 0.25
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
            
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
        
        
//        UIView.animate(withDuration: 0.25,delay: 0,options: .curveEaseOut) {
//            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-whiteViewFrame.height+kFitWidth(16)-kFitWidth(5), width: SCREEN_WIDHT, height: whiteViewFrame.height)
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.15)
//        } completion: { t in
//            UIView.animate(withDuration: 0.15,delay: 0,options: .curveEaseInOut) {
//                self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-whiteViewFrame.height+kFitWidth(16), width: SCREEN_WIDHT, height: whiteViewFrame.height)
//            }
//        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
//        
//        let whiteViewFrame = self.whiteView.frame
//        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
////            self.alpha = 0.7
//            
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
//            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewFrame.height)
////            self.whiteView.alpha = 0.7
//        }completion: { t in
//            self.isHidden = true
////            self.alpha = 0
////            self.whiteView.alpha = 0
//        }
    }
    func showWhiteViewAnimate() {
        let targetY = SCREEN_HEIGHT-whiteViewHeight
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight
        UIView.animate(withDuration: 0.25,delay: 0,options: .curveEaseOut) {
            self.whiteView.frame = CGRect.init(x: 0, y: targetY+kFitWidth(-5), width: SCREEN_WIDHT, height: self.whiteViewHeight+kFitWidth(20))
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.15)
        } completion: { t in
            UIView.animate(withDuration: 0.15,delay: 0,options: .curveEaseInOut) {
                self.whiteView.frame = CGRect.init(x: 0, y: targetY, width: SCREEN_WIDHT, height: self.whiteViewHeight)
            }
        }
    }
    @objc func nothingToDo() {
        
    }
    @objc func confirmAction(){
        let blockString = self.isWeekDay ? self.weekDay : self.dateString
        
        if self.confirmBlock != nil{
            self.confirmBlock!(blockString)
        }
        self.hiddenView()
    }
    @objc func todayAction(){
        datePicker.setDate(Date(), animated: true)
        changeDate(date: Date())
        confirmAction()
    }
}

extension DataAddDateAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(confirmButton)
        whiteView.addSubview(lineView)
        whiteView.addSubview(todayButton)
        whiteView.addSubview(datePicker)
        
        setConstrait()
        
        layoutWhiteViewFrame()
        // 初始位置放在最终停靠位置，实际展示用 transform 下移
        whiteView.transform = .identity
    }
    private func layoutWhiteViewFrame() {
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
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
        todayButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(lineView.snp.bottom)
            make.height.equalTo(kFitWidth(38))
            make.width.equalTo(kFitWidth(60))
        }
        datePicker.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(todayButton.snp.bottom)
            make.width.equalTo(kFitWidth(343))
        }
    }
}

extension DataAddDateAlertVM{
    /**
     获取选择的时间
     */
    @objc func chooseDate(_ datePicker:UIDatePicker) {
        let chooseDate = datePicker.date
        changeDate(date: chooseDate)
    }
    func changeDate(date:Date) {
        let  dateFormater = DateFormatter.init()
        dateFormater.dateFormat = "yyyy-MM-dd"
        dateFormater.locale = Locale.current//Locale(identifier: "zh_Hans_CN")
        dateFormater.calendar = Calendar(identifier: .gregorian)
        print(dateFormater.string(from: date))
        dateStringYear = dateFormater.string(from: date)
        
        dateFormater.dateFormat = "M月dd日"
        dateString = "\(dateFormater.string(from: date))"
        weekDay = "\(dateFormater.string(from: date)) \(Date().getWeekday(from: datePicker.date))"
        DLLog(message: "dateString:\(dateString)")
        DLLog(message: "weekDay:\(weekDay)")
    }
    func setDate(dateString:String) {
        let date = Date().changeDateStringToDate(dateString: dateString)
        datePicker.setDate(date, animated: true)
        changeDate(date: date)
    }
}
