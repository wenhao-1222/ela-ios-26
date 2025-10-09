//
//  LogsRemarkAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/22.
//

import Foundation
import UIKit

class TAG_MODEL: NSObject {
    
    var hasValue = false
    var name = ""
    var value = ""
    var valueArr:[String] = [String]()
    
}

class LogsRemarkAlertVM: UIView {
    
    let topGap = WHUtils().getNavigationBarHeight()+kFitWidth(0)
    var whiteViewHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-kFitWidth(0)+kFitWidth(16)
    var textTopGap = kFitWidth(20)
    
    var remarkBlock:((String)->())?
    var hideBlock:(([TAG_MODEL],String)->())?
    var timer: Timer?
    
    var rowItems:[TagRowView] = [TagRowView]()
    var selectModels:[TAG_MODEL] = [TAG_MODEL]()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        self.isUserInteractionEnabled = true
        self.alpha = 0
        self.isHidden = true
        
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight()+SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        vi.alpha = 0
        
        // 创建下拉手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        // 将手势识别器添加到view
        vi.addGestureRecognizer(panGestureRecognizer)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var leftTitleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "注释"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .semibold)
        
        return lab
    }()
    
    lazy var arrowButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "logs_remark_arrow_down"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
//        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
    lazy var arrowTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        
        return vi
    }()
    lazy var penIcon : UIImageView = {
        let img = UIImageView()
//        img.setImgLocal(imgName: "logs_pen_icon")
        
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var placeHoldLabel : UILabel = {
        let lab = UILabel()
        lab.text = "这里输入您的注释说明"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var textView : UITextView = {
        let vi = UITextView.init(frame: CGRect.init(x: kFitWidth(18), y: kFitWidth(22), width: kFitWidth(200), height: kFitWidth(180)))
        vi.textColor = .COLOR_GRAY_BLACK_85
        vi.font = .systemFont(ofSize: 14, weight: .regular)
        vi.delegate = self
        vi.backgroundColor = .clear
        
        return vi
    }()
    lazy var textTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(textAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}

extension LogsRemarkAlertVM{
    func showView() {
        self.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        self.textView.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.alpha = 1
            self.whiteView.alpha = 1
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewHeight*0.5+self.topGap-kFitWidth(2))
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
//            self.whiteView.transform = .identity
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewHeight*0.5+self.topGap)
        }
        
//        UIView.animate(withDuration: 0.2, delay: 0,options: .curveLinear) {
//            self.alpha = 1
//            self.whiteView.alpha = 1
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewHeight*0.5+self.topGap)
//        }completion: { t in
////            self.textView.becomeFirstResponder()
//        }
    }
    @objc func hiddenView() {
        self.whiteView.becomeFirstResponder()
        self.textView.resignFirstResponder()
        
        DLLog(message: "selectModels:\(selectModels)")
//        selectModels.forEach {
//            DLLog(message: "\($0.name) -- \($0.value)")
//            DLLog(message: "\($0.name) -- \($0.valueArr)")
//        }
        
        self.hideBlock?(self.selectModels,self.textView.text)
        NotificationCenter.default.removeObserver(self)
        UIView.animate(withDuration: 0.2, delay: 0,options: .curveLinear) {
            self.alpha = 0
            self.whiteView.alpha = 0.3
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
        }completion: { t in
            self.isHidden = true
        }
    }
    @objc func nothingAction(){
        self.textView.resignFirstResponder()
    }
    @objc func textAction(){
        self.textView.becomeFirstResponder()
    }
    func updateContext(text:String,notesTag:String?="") {
        if text.count > 0 {
            penIcon.isHidden = true
            placeHoldLabel.isHidden = true
//            textView.isHidden = false
            textView.text = text
        }else{
            penIcon.isHidden = false
            placeHoldLabel.isHidden = false
//            textView.isHidden = true
            textView.text = ""
        }
        if notesTag?.count ?? 0 > 0 {
            let tagArray = WHUtils.getArrayFromJSONString(jsonString: notesTag!)
            for i in 0..<rowItems.count{
                let dict = ConstantModel.shared.diet_log_note_label_array[i]as? NSDictionary ?? [:]
                let values = dict["value"]as? [String] ?? []
                var selectIndex:[Int] = [Int]()
                for j in 0..<tagArray.count{
                    let tagDict = tagArray[j]as? NSDictionary ?? [:]
                    if tagDict.stringValueForKey(key: "key") == dict.stringValueForKey(key: "key"){
                        let arr = tagDict["value"]as? NSArray ?? []
                        for k in 0..<arr.count{
                            let string = arr[k]as? String ?? ""
                            if let index = values.firstIndex(of: string){
                                selectIndex.append(index)
                            }
                        }
                    }
                }
                rowItems[i].select(indices: selectIndex)
            }
        }else{
            for i in 0..<rowItems.count{
                rowItems[i].select(indices: [-1])
            }
        }
    }
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // 获取当前手势所在的view
        if let view = gesture.view {
            // 根据手势移动view的位置
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: view)
                DLLog(message: "translation.y:\(translation.y)")
                if translation.y < 0 && view.frame.minY <= WHUtils().getNavigationBarHeight(){
                    return
                }
                view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
                gesture.setTranslation(.zero, in: view)
                
            case .ended:
                if view.frame.minY - topGap >= kFitWidth(20){
                    self.hiddenView()
                }else{
                    UIView.animate(withDuration: 0.2, delay: 0,options: .curveLinear) {
                        self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.topGap+self.whiteViewHeight*0.5)
                    }
                }
            default:
                break
            }
        }
    }
    func startCountdown() {
        //一般倒计时是操作UI，使用主队列
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            // 定时器执行的操作
            DLLog(message: "timer:\(self.textView.text ?? "")")
            var string = self.textView.text ?? ""
            string = string.disable_emoji(text: string as NSString)
            if string.count > 400 {
                string = String(string.prefix(400))
            }
            self.textView.text = string
            
            if string.count == 0 {
                self.penIcon.isHidden = false
                self.placeHoldLabel.isHidden = false
            }else{
                self.penIcon.isHidden = true
                self.placeHoldLabel.isHidden = true
            }
        }
    }
    func disableTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

extension LogsRemarkAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(leftTitleLabel)
        whiteView.addSubview(arrowButton)
        whiteView.addSubview(lineView)
        whiteView.addSubview(arrowTapView)
        whiteView.addSubview(penIcon)
        whiteView.addSubview(placeHoldLabel)
        whiteView.addSubview(textView)
        whiteView.addSubview(textTapView)
        updateUI()
    }
    func updateUI() {
        if ConstantModel.shared.diet_log_note_label_array.count > 0 {
            updateTagArray()
            setConstrait()
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.updateUI()
            })
        }
    }
    func updateTagArray() {
        rowItems.removeAll()
        selectModels.removeAll()
        
        textTopGap = kFitWidth(20)
        for i in 0..<ConstantModel.shared.diet_log_note_label_array.count{
            let dict = ConstantModel.shared.diet_log_note_label_array[i]as? NSDictionary ?? [:]
            let valus = dict["value"]as? [String] ?? []
            
            let model = TAG_MODEL()
            selectModels.append(model)
            
            let row = TagRowView(
                title: dict.stringValueForKey(key: "key"),
                items: valus,
                selectionMode: dict.stringValueForKey(key: "isMultiple") == "1" ? .multiple : .single,
                fixedHeight: kFitWidth(28)
            )
            
            whiteView.addSubview(row)
            if i == 0 {
                row.snp.makeConstraints { make in
                    make.top.equalTo(lineView.snp.bottom).offset(textTopGap)
                    make.left.right.equalToSuperview()
                }
            }else{
                row.snp.makeConstraints { make in
                    make.top.equalTo(lineView.snp.bottom).offset(textTopGap)
                    make.left.right.equalToSuperview()
                }
            }
            textTopGap = textTopGap + kFitWidth(28) + kFitWidth(12)
            rowItems.append(row)
            
            row.onSelectionChanged = { indices in
                print(" \(indices) selected indices:", indices)
                
                if indices.count > 0 {
                    var valuesArr:[String] = [String]()
                    for i in 0..<indices.count{
                        let index = indices[i]
                        let string = valus[index]
                        valuesArr.append(string)
                    }
                    model.name = dict.stringValueForKey(key: "key")
                    model.value = WHUtils.getJSONStringFromArray(array: valuesArr as NSArray)
                    model.valueArr = valuesArr
                    model.hasValue = true
                }else{
                    model.hasValue = false
                    model.name = ""
                    model.value = ""
                    model.valueArr = [String]()
                }
            }
        }
        
        if ConstantModel.shared.diet_log_note_label_array.count > 0 {
            textTopGap = textTopGap + kFitWidth(18)
        }
    }
    func setConstrait() {
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(54))
        }
        arrowButton.snp.makeConstraints { make in
//            make.top.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualTo(leftTitleLabel)
            make.right.equalTo(kFitWidth(-17))
            make.width.height.equalTo(kFitWidth(24))
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(leftTitleLabel.snp.bottom)
            make.height.equalTo(kFitWidth(4))
        }
        arrowTapView.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.bottom.equalTo(lineView)
            make.left.equalTo(arrowButton).offset(kFitWidth(-40))
        }
        penIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.top.equalTo(kFitWidth(50))
            make.top.equalTo(lineView.snp.bottom).offset(textTopGap)//.offset(kFitWidth(222))
            make.width.height.equalTo(kFitWidth(16))
        }
        placeHoldLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.centerY.lessThanOrEqualTo(penIcon)
        }
        textView.snp.makeConstraints { make in
            make.left.equalTo(penIcon)
            make.top.equalTo(placeHoldLabel).offset(kFitWidth(-6))
            make.right.equalTo(kFitWidth(-16))
//            make.right.equalTo(kFitWidth(-56))
            make.bottom.equalTo(kFitWidth(-100))
        }
        textTapView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(textView.snp.bottom)
        }
    }
}

extension LogsRemarkAlertVM:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
//        self.textView.snp.remakeConstraints { make in
//            make.left.equalTo(penIcon)
//            make.top.equalTo(placeHoldLabel).offset(kFitWidth(-6))
//            make.right.equalTo(kFitWidth(-56))
//            make.bottom.equalTo(kFitWidth(-400))
//        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == ""{
            if textView.text.count == 1 {
                penIcon.isHidden = false
                placeHoldLabel.isHidden = false
            }
            return true
        }
        if text == "\n"{
            textView.text = "\(textView.text ?? "")\n"
            return false
        }
        if textView.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
        penIcon.isHidden = true
        placeHoldLabel.isHidden = true
        
        if textView.text.count >= 400{
            return false
        }
        
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.remarkBlock != nil{
            self.remarkBlock!(self.textView.text)
        }
    }
}

extension LogsRemarkAlertVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.textView.snp.remakeConstraints { make in
                make.left.equalTo(self.penIcon)
                make.top.equalTo(self.placeHoldLabel).offset(kFitWidth(-6))
                make.right.equalTo(kFitWidth(-16))
                make.bottom.equalTo(-keyboardSize.size.height)
            }
        }
    }
    @objc func keyboardDidShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.textView.snp.remakeConstraints { make in
                make.left.equalTo(self.penIcon)
                make.top.equalTo(self.placeHoldLabel).offset(kFitWidth(-6))
                make.right.equalTo(kFitWidth(-16))
                make.bottom.equalTo(-keyboardSize.size.height-kFitWidth(40))
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        self.textView.snp.remakeConstraints { make in
            make.left.equalTo(self.penIcon)
            make.top.equalTo(self.placeHoldLabel).offset(kFitWidth(-6))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(-kFitWidth(100))
        }
    }
}
