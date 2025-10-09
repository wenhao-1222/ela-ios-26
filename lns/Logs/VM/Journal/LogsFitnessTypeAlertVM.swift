//
//  LogsFitnessTypeAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/20.
//


import UIKit

class LogsFitnessTypeAlertVM: UIView {
    
    var whiteViewHeight = kFitWidth(256)+WHUtils().getBottomSafeAreaHeight()
    var confirmBlock:((String)->())?
    var fitnessArray = ConstantModel.shared.fitness_label_array
    var fitnessType = ""
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        if fitnessArray.count == 0{
            fitnessArray = UserDefaults.getArray(forKey: .fitness_label_array) as? NSArray ?? []
        }
                
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
//        lab.text = "请选择训练部位"
        lab.text = "力量训练标签"
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
}

extension LogsFitnessTypeAlertVM{
    func showSelf() {
        if fitnessArray.count == 0{
            if ConstantModel.shared.fitness_label_array.count == 0{
                return
            }
        }
        fitnessArray = ConstantModel.shared.fitness_label_array
//        var arrTemp = NSMutableArray(array: ["无"])
//        
//        arrTemp.addObjects(from: ConstantModel.shared.fitness_label_array as? [String] ?? [""])
        self.pickerView.reloadAllComponents()
        var rowIndex = 0
        for i in 0..<fitnessArray.count{
            let row = fitnessArray[i]as? String ?? ""
            if row == fitnessType{
                rowIndex = i
                break
            }
        }
        self.pickerView.selectRow(rowIndex, inComponent: 0, animated: false)
        
        self.isHidden = false
        
        UIView.animate(withDuration: 0.15,delay: 0,options: .curveLinear) {
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-self.whiteViewHeight, width: SCREEN_WIDHT, height: self.whiteViewHeight)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        } completion: { t in
//            self.alpha = 1
        }

    }
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.15,delay: 0,options: .curveLinear) {
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: self.whiteViewHeight)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        } completion: { t in
//            self.alpha = 0
            self.isHidden = true
            self.backgroundColor = .clear
        }
    }
    
    @objc func confirmAction() {
        self.hiddenSelf()
        
        let selectIndex = self.pickerView.selectedRow(inComponent: 0)
//        UserInfoModel.shared.mealsNumber = Int(mealsArray[selectIndex] as! String) ?? 6
//        UserDefaults.set(value: "\(UserInfoModel.shared.mealsNumber)", forKey: .mealsNumber)
        if self.confirmBlock != nil{
//            if selectIndex == 0 {
//                self.confirmBlock!("")
//            }else{
                self.confirmBlock!(fitnessArray[selectIndex]as? String ?? "")
//            }
        }
    }
    @objc func nothingToDo() {
        
    }
}

extension LogsFitnessTypeAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addShadow()
        
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(confirmBtn)
        whiteView.addSubview(lineView)
        whiteView.addSubview(pickerView)
        
        setConstrait()
//        setPickerViewInitStatus()
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
//    func setPickerViewInitStatus() {
//        for i in 0..<mealsArray.count{
//            let meals = mealsArray[i]as? String ?? ""
//            if meals == "\(UserInfoModel.shared.weightUnitName)"{
//                self.pickerView.selectRow(i, inComponent: 0, animated: false)
//                break
//            }
//        }
//    }
}

extension LogsFitnessTypeAlertVM:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fitnessArray.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(45)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(20), y: 0, width: kFitWidth(60), height: kFitWidth(45)))
        lab.text = "\(fitnessArray[row]as? String ?? "")"
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
