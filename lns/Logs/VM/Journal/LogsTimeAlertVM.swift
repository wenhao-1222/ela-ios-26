//
//  LogsTimeAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/14.
//


import Foundation
import UIKit

class LogsTimeAlertVM: UIView {
    //kFitWidth(500) + WHUtils().getBottomSafeAreaHeight()
    var whiteViewHeight = kFitWidth(320) + WHUtils().getBottomSafeAreaHeight()
    
    var hourTimeArray = NSMutableArray()
    var minutTimeArray = NSMutableArray()
    
    var sDate = ""
    var mealsIndex = ""
    var confirmBlock:((String)->())?
    var setAlertBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.alpha = 0
        self.isHidden = true
        
        initTimeArray()
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        vi.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var closeButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
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
    lazy var setAlertButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("用餐提醒设置", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(setAlertAction), for: .touchUpInside)
        
        return btn
    }()
}

extension LogsTimeAlertVM{
    func updateTime(time:String,mealsIndex:Int,sDate:String) {
        self.sDate = sDate
        self.mealsIndex = "\(mealsIndex)"
        
        let timeStr = time.replacingOccurrences(of: "（", with: "")//.mc_clipFromPrefix(to: 5)
        let timeString = timeStr.replacingOccurrences(of: "）", with: "")
        DLLog(message: "updateTime\(timeString)")
        
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
    func showView() {
        self.isHidden = false
//        self.startCountdown()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.alpha = 1
            self.whiteView.alpha = 1
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)))
        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.alpha = 0
            self.whiteView.alpha = 0.7
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
        }completion: { t in
            self.isHidden = true
        }
    }
    
    
    @objc func nothingAction(){
        
    }
    @objc func cancelAction(){
        self.hiddenView()
    }
    @objc func confirmAction(){
        let hourRow = self.timePickerView.selectedRow(inComponent: 0)
        let minuteRow = self.timePickerView.selectedRow(inComponent: 1)
        
        let hour = self.hourTimeArray[hourRow]as? String ?? ""
        let minute = self.minutTimeArray[minuteRow]as? String ?? ""
        
        LogsSQLiteManager.getInstance().updateSingleMealTime(mealsIndex: mealsIndex, time: "\(hour):\(minute)", sDate: sDate)
        LogsSQLiteManager.getInstance().updateLogsEtime(sDate: sDate, endTime: Date().currentSeconds)
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: sDate, update: false)
        sendUpdateLogsMealsTimeRequest()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        
        self.hiddenView()
    }
    @objc func setAlertAction() {
        self.hiddenView()
        if self.setAlertBlock != nil{
            self.setAlertBlock!()
        }
    }
}

extension LogsTimeAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(confirmButton)
        whiteView.addSubview(lineView)
        whiteView.addSubview(titleLabel)
        
        whiteView.addSubview(timePickerView)
        timePickerView.addSubview(demicalLab)
        
//        whiteView.addSubview(setAlertButton)
        setConstrait()
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
//        setAlertButton.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
////            make.bottom.equalTo(kFitWidth(-10)-WHUtils().getBottomSafeAreaHeight())
//            make.top.equalTo(timePickerView.snp.bottom).offset(kFitWidth(5))
//            make.width.equalTo(kFitWidth(327))
//            make.height.equalTo(kFitWidth(56))
//        }
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

extension LogsTimeAlertVM:UIPickerViewDelegate,UIPickerViewDataSource{
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
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(20), y: 0, width: kFitWidth(60), height: kFitWidth(45)))
//        
//        if component == 0 {
//            lab.text = "\(hourTimeArray[row])"
//        }else{
//            lab.text =  "\(minutTimeArray[row])"
//        }
//        lab.textAlignment = .center
//        lab.adjustsFontSizeToFitWidth = true
//        lab.font = .systemFont(ofSize: 18, weight: .medium)
//        setUpPickerStyleRowStyle(row: row, component: component)
//        
//        return lab
//    }
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

extension LogsTimeAlertVM{
    //MARK: 上传日志每餐用餐时间
    func sendUpdateLogsMealsTimeRequest() {
        let logsDict = NSMutableDictionary(dictionary: LogsSQLiteManager.getInstance().getMealsTimeForUpload(sDate: sDate))
        logsDict.setValue("\(sDate)", forKey: "sdate")
        DLLog(message: "sendUpdateLogsMealsTimeRequest:\(logsDict)")
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_update_meal_time, parameters: logsDict as? [String : AnyObject]) { responseObject in
            DLLog(message: "sendUpdateLogsMealsTimeRequest:\(responseObject)")
        }
    }
}
