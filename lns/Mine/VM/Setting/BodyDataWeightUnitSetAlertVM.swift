//
//  BodyDataWeightUnitSetAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/9/28.
//


import UIKit

class BodyDataWeightUnitSetAlertVM: UIView {
    
    var whiteViewHeight = kFitWidth(256)+WHUtils().getBottomSafeAreaHeight()
    var confirmBlock:((Int)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
//        self.addGestureRecognizer(tap)
                
        initUI()
        
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(10))
        vi.backgroundColor = .white
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    
    lazy var cancelBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        
        btn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "请选择体重单位"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()
    lazy var confirmBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        return vi
    }()
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView(frame: CGRect.init(x: 0, y: kFitWidth(50), width: SCREEN_WIDHT, height: kFitWidth(256)))
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    lazy var mealsArray: NSArray = {
        return ["kg",
                "斤",
                "磅"]
    }()
    
}

extension BodyDataWeightUnitSetAlertVM{
    func showSelf() {
        self.isHidden = false
        bgView.isUserInteractionEnabled = false
        
        // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0

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
//        UIView.animate(withDuration: 0.15,delay: 0,options: .curveLinear) {
//            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-self.whiteViewHeight, width: SCREEN_WIDHT, height: self.whiteViewHeight)
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.2)
//        } completion: { t in
////            self.alpha = 1
//        }

    }
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
//        UIView.animate(withDuration: 0.15,delay: 0,options: .curveLinear) {
//            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: self.whiteViewHeight)
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
//        } completion: { t in
////            self.alpha = 0
//            self.isHidden = true
//            self.backgroundColor = .clear
//        }
    }
    
    @objc func confirmAction() {
        self.hiddenSelf()
        
        let selectIndex = self.pickerView.selectedRow(inComponent: 0)
//        UserInfoModel.shared.mealsNumber = Int(mealsArray[selectIndex] as! String) ?? 6
//        UserDefaults.set(value: "\(UserInfoModel.shared.mealsNumber)", forKey: .mealsNumber)
        if self.confirmBlock != nil{
            self.confirmBlock!(selectIndex+1)
        }
    }
    @objc func nothingToDo() {
        
    }
}

extension BodyDataWeightUnitSetAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addShadow()
        
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(confirmBtn)
        whiteView.addSubview(lineView)
        whiteView.addSubview(pickerView)
        
        setConstrait()
        setPickerViewInitStatus()
        layoutWhiteViewFrame()
        // 初始位置放在最终停靠位置，实际展示用 transform 下移
        whiteView.transform = .identity
    }
    
    private func layoutWhiteViewFrame() {
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
//        whiteView.layer.cornerRadius = whiteViewTopRadius
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func setConstrait()  {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(48))
        }
        cancelBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(48))
        }
        confirmBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(cancelBtn)
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(48))
            make.height.equalTo(kFitWidth(1))
        }
    }
    func setPickerViewInitStatus() {
        for i in 0..<mealsArray.count{
            let meals = mealsArray[i]as? String ?? ""
            if meals == "\(UserInfoModel.shared.weightUnitName)"{
                self.pickerView.selectRow(i, inComponent: 0, animated: false)
                break
            }
        }
    }
}

extension BodyDataWeightUnitSetAlertVM:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mealsArray.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(45)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(20), y: 0, width: kFitWidth(60), height: kFitWidth(45)))
        lab.text = "\(mealsArray[row]as? String ?? "")"
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.font = .systemFont(ofSize: 20, weight: .regular)
        setUpPickerStyleRowStyle(row: row, component: component)
        
        return lab
    }
    func setUpPickerStyleRowStyle(row:Int,component:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
            if label != nil{
                label?.textColor = .THEME
            }
        })
    }
}
