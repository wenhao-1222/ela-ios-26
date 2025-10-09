//
//  LogsMealsAlertSetPopVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/15.
//

import Foundation
import UIKit
import MCToast

class LogsMealsAlertSetPopVM: FeedBackView {
    
//    var whiteViewHeight = kFitWidth(500) + WHUtils().getBottomSafeAreaHeight()
    
    var hourTimeArray = NSMutableArray()
    var minutTimeArray = NSMutableArray()
    
    var mealsIndex = ""
    var rotationArr = NSMutableArray()
    var placeholder = ""
    
    var confirmBlock:((NSDictionary)->())?
    var setAlertBlock:(()->())?
    
    /// 白色内容视图的默认高度
   var whiteViewHeight = kFitWidth(500) + WHUtils().getBottomSafeAreaHeight()
   /// 默认的白色内容视图高度，键盘收起时使用
   private let defaultWhiteViewHeight = kFitWidth(500) + WHUtils().getBottomSafeAreaHeight()
   /// timePickerView 默认高度
   private let pickerNormalHeight = kFitWidth(250)
   /// 键盘弹出时 timePickerView 缩小后的高度
   private let pickerKeyboardHeight = kFitWidth(100)
   /// 键盘显示状态标记
   private var keyboardShowing = false

    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
//        self.alpha = 0
        self.isHidden = true
        
        initTimeArray()
        initUI()
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
//        self.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
//        vi.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
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
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var confirmButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
    lazy var timePickerView: UIPickerView = {
        let picker = UIPickerView.init(frame: CGRect.init(x: 0, y: kFitWidth(55), width: SCREEN_WIDHT, height: kFitWidth(250)))
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    lazy var demicalLab : UILabel = {
        let lab = UILabel()
        lab.text = ":"
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 28, weight: .medium)
        
        return lab
    }()
    lazy var repeatLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.text = "重复"
        return lab
    }()
    lazy var repeatTimeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "周一 周二 周五 周日"
        return lab
    }()
    
    lazy var arrowImgView : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "mine_func_arrow")
        
        return img
    }()
    lazy var weekdaysVm: LogsMealsAlertSetWeekVM = {
        let vm = LogsMealsAlertSetWeekVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.btnTapBlock = {()in
            self.refreshWeekDays()
        }
        return vm
    }()
    lazy var remarkVm: LogsMealsAlertSetRemarkVM = {
        let vm = LogsMealsAlertSetRemarkVM.init(frame: CGRect.init(x: 0, y: kFitWidth(400), width: 0, height: 0))
        
        return vm
    }()
}


extension LogsMealsAlertSetPopVM{
    func updateTime(dict:NSDictionary,mealsIndex:Int) {
        self.mealsIndex = "\(mealsIndex)"
        self.placeholder = dict.stringValueForKey(key: "placeholder")
        
        let timeString = dict.stringValueForKey(key: "clock").mc_clipFromPrefix(to: 5)
        DLLog(message: "updateTime\(timeString)")
        
        updateWeekDays(dict: dict)
        remarkVm.placeHoldLabel.text = dict.stringValueForKey(key: "placeholder")
        remarkVm.updateContext(text: dict.stringValueForKey(key: "remark"))
        
        let timeArr = timeString.components(separatedBy: ":")
        if timeArr.count > 1{
            let hour = timeArr[0]
            let minute = timeArr[1]
            
            for i in 0..<self.hourTimeArray.count{
                if hourTimeArray[i]as? String ?? "" == hour{
                    self.timePickerView.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
            for i in 0..<self.minutTimeArray.count{
                if minutTimeArray[i]as? String ?? "" == minute{
                    self.timePickerView.selectRow(i, inComponent: 1, animated: false)
                    break
                }
            }
        }
        
        titleLabel.text = "第 \(mealsIndex) 餐"
        
        self.showView()
    }
    func updateWeekDays(dict:NSDictionary) {
//        let rotationString = dict.stringValueForKey(key: "rotation")
//        let rotationArray = WHUtils.getArrayFromJSONString(jsonString: rotationString)
        let rotationArray = dict["rotation"]as? NSArray ?? []
        DLLog(message: "rotationArray:\(rotationArray)")
        for i in 0..<self.weekdaysVm.btnArray.count{
            let btn = self.weekdaysVm.btnArray[i]
            if rotationArray.contains(i+1){
                btn.isSelected = true
            }else{
                btn.isSelected = false
            }
        }
        refreshWeekDays()
    }
    func refreshWeekDays() {
        var weekdaysString = ""
        var hasEmpty = false
        rotationArr.removeAllObjects()
        for i in 0..<self.weekdaysVm.btnArray.count{
            let btn = self.weekdaysVm.btnArray[i]
            if btn.isSelected == true{
                weekdaysString = weekdaysString + "周\(btn.titleLabel?.text ?? "") "
                rotationArr.add(i+1)
            }else{
                hasEmpty = true
            }
        }
        
        if hasEmpty == false{
            repeatTimeLabel.text = "每天"
        }else{
            repeatTimeLabel.text = weekdaysString
        }
    }
    func showView() {
        // 恢复默认高度，防止上一次键盘弹出后未还原
       whiteViewHeight = defaultWhiteViewHeight
//       whiteView.frame.size.height = whiteViewHeight
       timePickerView.frame.size.height = pickerNormalHeight

        self.isHidden = false
//        self.startCountdown()
        
        bgView.isUserInteractionEnabled = false
        
        // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
//        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0
//        whiteView.alpha = 1

        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
//            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)-kFitWidth(2)))
            self.bgView.alpha = 0.25
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
            
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
//            self.whiteView.transform = .identity
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)))
        }
        
//        UIView.animate(withDuration: 0.15, delay: 0,options: .curveLinear) {
//            self.alpha = 1
//            self.whiteView.alpha = 1
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)))
//        }
    }
    @objc func hiddenView() {
        self.resignFirstResponder()
        self.remarkVm.textView.endEditing(true)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
//            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
        
//        UIView.animate(withDuration: 0.15, delay: 0,options: .curveLinear) {
//            self.alpha = 0
//            self.whiteView.alpha = 0.7
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
//        }completion: { t in
//            self.isHidden = true
//        }
    }
    @objc func nothingAction(){
        self.remarkVm.textView.resignFirstResponder()
    }
    @objc func confirmAction(){
        if rotationArr.count == 0 {
            MCToast.mc_text("请选择提醒时间【周一 ~ 周日】")
            return
        }
        
        let hourRow = self.timePickerView.selectedRow(inComponent: 0)
        let minuteRow = self.timePickerView.selectedRow(inComponent: 1)
        
        let hour = self.hourTimeArray[hourRow]as? String ?? ""
        let minute = self.minutTimeArray[minuteRow]as? String ?? ""
        
        if self.confirmBlock != nil{
            let dict = ["clock":"\(hour):\(minute):00",
                        "remark":"\(self.remarkVm.textView.text ?? "")",
                        "placeholder":placeholder,
                        "rotation":rotationArr,
                        "sn":"\(mealsIndex)",
                        "status":"1"] as [String : Any]
            self.confirmBlock!(dict as NSDictionary)
        }
        
        self.hiddenView()
    }
    @objc func setAlertAction() {
        self.hiddenView()
        if self.setAlertBlock != nil{
            self.setAlertBlock!()
        }
    }
}

extension LogsMealsAlertSetPopVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(confirmButton)
        whiteView.addSubview(lineView)
        whiteView.addSubview(titleLabel)
        
        whiteView.addSubview(timePickerView)
        timePickerView.addSubview(demicalLab)
        
        whiteView.addSubview(repeatLab)
        whiteView.addSubview(repeatTimeLabel)
        whiteView.addSubview(arrowImgView)
        
        whiteView.addSubview(weekdaysVm)
        
        whiteView.addSubview(remarkVm)
        
        setConstrait()
//        layoutWhiteViewFrame()
//        // 初始位置放在最终停靠位置，实际展示用 transform 下移
//        whiteView.transform = .identity
    }
    
    private func layoutWhiteViewFrame() {
//        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
//        whiteView.layer.cornerRadius = whiteViewTopRadius
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(55))
            make.height.equalTo(kFitWidth(1))
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
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualTo(closeButton)
        }
        demicalLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()//.offset(kFitWidth(3))
            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(-3))
            make.height.equalTo(kFitWidth(30))
        }
        repeatLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(timePickerView.snp.bottom).offset(kFitWidth(10))
        }
        repeatTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(arrowImgView.snp.left).offset(kFitWidth(-10))
            make.centerY.lessThanOrEqualTo(repeatLab)
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(repeatLab)
            make.width.height.equalTo(kFitWidth(16))
        }
        weekdaysVm.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(repeatLab.snp.bottom).offset(kFitWidth(10))
            make.width.equalToSuperview()
            make.height.equalTo(self.weekdaysVm.selfHeight)
        }
    }
    func initTimeArray() {
        for i in 0..<24{
            if i < 10{
                hourTimeArray.add("0\(i)")
            }else{
                hourTimeArray.add("\(i)")
            }
        }
        for i in 0..<60{
            if i < 10{
                minutTimeArray.add("0\(i)")
            }else{
                minutTimeArray.add("\(i)")
            }
        }
    }
}

extension LogsMealsAlertSetPopVM:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hourTimeArray.count
        }else{
            return minutTimeArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(45)
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return kFitWidth(45)
        }else{
            return kFitWidth(45)
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if component == 0 {
            let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(80), height: kFitWidth(45)))
            lab.text = "\(self.hourTimeArray[row])"
            lab.font = UIFont().DDInFontMedium(fontSize: 30)
            lab.textAlignment = .center
            setUpPickerStyleRowStyle(row: row, component: component)
            return lab
        }else{
            let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(40), y: 0, width: kFitWidth(38), height: kFitWidth(45)))
            lab.text = "\(self.minutTimeArray[row])"
            lab.textAlignment = .center
            lab.adjustsFontSizeToFitWidth = true
            lab.font = UIFont().DDInFontMedium(fontSize: 30)
            setUpPickerStyleRowStyle(row: row, component: component)
            
            return lab
        }
    }
    func setUpPickerStyleRowStyle(row:Int,component:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let label = self.timePickerView.view(forRow: row, forComponent: component) as? UILabel
            if label != nil{
                label?.textColor = .THEME
            }
        })
    }
}

extension LogsMealsAlertSetPopVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        guard keyboardShowing == false else { return }
                keyboardShowing = true
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 调整内容高度及位置，确保全部显示
            whiteViewHeight = defaultWhiteViewHeight - (pickerNormalHeight - pickerKeyboardHeight)
            whiteView.frame.size.height = whiteViewHeight
            timePickerView.frame.size.height = pickerKeyboardHeight
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (keyboardSize.origin.y - ((self.whiteViewHeight-WHUtils().getBottomSafeAreaHeight()-kFitWidth(32))*0.5)))
                self.remarkVm.center = CGPointMake(SCREEN_WIDHT*0.5, self.whiteViewHeight-WHUtils().getBottomSafeAreaHeight()-kFitWidth(16)+self.remarkVm.selfHeight-kFitWidth(100))
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        guard keyboardShowing == true else { return }
        keyboardShowing = false

        whiteViewHeight = defaultWhiteViewHeight
        whiteView.frame.size.height = whiteViewHeight
        timePickerView.frame.size.height = pickerNormalHeight

        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.closeButton.alpha = 1
            self.confirmButton.alpha = 1
            self.lineView.alpha = 1
            self.titleLabel.alpha = 1
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)))
//            self.remarkVm.center = CGPointMake(SCREEN_WIDHT*0.5, self.weekdaysVm.frame.maxY+self.remarkVm.selfHeight*0.5)
            self.remarkVm.center = CGPointMake(SCREEN_WIDHT*0.5, self.whiteViewHeight-WHUtils().getBottomSafeAreaHeight()-kFitWidth(16)+self.remarkVm.selfHeight-kFitWidth(100))
        }completion: { t in
        }
    }
}
